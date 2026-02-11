import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/data/models/bet_session_models.dart';
import 'package:prophet_profiler/src/services/api_service_v2.dart';

/// État pour le BLoC de session active
class ActiveSessionState {
  final bool isLoading;
  final bool isPlacingBet;
  final bool isSettingWinner;
  final String? error;
  final String? successMessage;
  final SessionActiveDetails? sessionDetails;
  final SetWinnerResponse? winnerResult;
  
  // Pour le placement de pari
  final String? currentPlayerId;
  final String? currentPlayerName;

  const ActiveSessionState({
    this.isLoading = false,
    this.isPlacingBet = false,
    this.isSettingWinner = false,
    this.error,
    this.successMessage,
    this.sessionDetails,
    this.winnerResult,
    this.currentPlayerId,
    this.currentPlayerName,
  });

  ActiveSessionState copyWith({
    bool? isLoading,
    bool? isPlacingBet,
    bool? isSettingWinner,
    String? error,
    String? successMessage,
    SessionActiveDetails? sessionDetails,
    SetWinnerResponse? winnerResult,
    String? currentPlayerId,
    String? currentPlayerName,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ActiveSessionState(
      isLoading: isLoading ?? this.isLoading,
      isPlacingBet: isPlacingBet ?? this.isPlacingBet,
      isSettingWinner: isSettingWinner ?? this.isSettingWinner,
      error: clearError ? null : error ?? this.error,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      sessionDetails: sessionDetails ?? this.sessionDetails,
      winnerResult: winnerResult ?? this.winnerResult,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
    );
  }

  bool get canPlaceBet => 
      sessionDetails?.isBetting == true && 
      currentPlayerId != null &&
      !(sessionDetails?.participants.any((p) => 
          p.playerId == currentPlayerId && p.hasPlacedBet) ?? false);

  bool get canSetWinner => 
      (sessionDetails?.isBetting == true || sessionDetails?.isPlaying == true) &&
      sessionDetails?.allPlayersHaveBet == true;

  bool get isCompleted => sessionDetails?.isCompleted ?? false;

  ParticipantBetInfo? get currentPlayerInfo => 
      sessionDetails?.participants.firstWhere(
        (p) => p.playerId == currentPlayerId,
      );

  List<ParticipantBetInfo> get participantsWithoutBet => 
      sessionDetails?.participants.where((p) => !p.hasPlacedBet).toList() ?? [];
}

/// BLoC pour la Page Session Active
class ActiveSessionBloc extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  ActiveSessionState _state = const ActiveSessionState();
  ActiveSessionState get state => _state;

  Timer? _refreshTimer;

  /// Définit le joueur courant (pour les paris)
  void setCurrentPlayer(String playerId, String playerName) {
    _state = _state.copyWith(
      currentPlayerId: playerId,
      currentPlayerName: playerName,
    );
    notifyListeners();
  }

  /// Charge les détails de la session
  Future<void> loadSession(String sessionId) async {
    developer.log('🔄 Chargement session active: $sessionId', name: 'ActiveSessionBloc');
    
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final details = await _apiService.getSessionActiveDetails(sessionId);
      
      _state = _state.copyWith(
        isLoading: false,
        sessionDetails: details,
      );
      
      developer.log('✅ Session chargée: ${details.participants.length} participants, ${details.bets.length} paris', 
          name: 'ActiveSessionBloc');
    } catch (e) {
      developer.log('❌ Erreur chargement session: $e', name: 'ActiveSessionBloc');
      _state = _state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement: $e',
      );
    }
    notifyListeners();
  }

  /// Place un pari pour le joueur courant
  Future<bool> placeBet(String predictedWinnerId) async {
    if (_state.currentPlayerId == null || _state.sessionDetails == null) {
      developer.log('❌ Impossible de parier: pas de joueur ou session', name: 'ActiveSessionBloc');
      return false;
    }

    _state = _state.copyWith(isPlacingBet: true, clearError: true, clearSuccess: true);
    notifyListeners();

    try {
      final request = PlaceBetRequestV2(
        bettorId: _state.currentPlayerId!,
        predictedWinnerId: predictedWinnerId,
      );

      await _apiService.placeBetV2(_state.sessionDetails!.sessionId, request);
      
      // Recharger les détails pour mettre à jour l'UI
      await loadSession(_state.sessionDetails!.sessionId);
      
      _state = _state.copyWith(
        isPlacingBet: false,
        successMessage: 'Pari placé avec succès !',
      );
      
      developer.log('✅ Pari placé sur: $predictedWinnerId', name: 'ActiveSessionBloc');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('❌ Erreur placement pari: $e', name: 'ActiveSessionBloc');
      _state = _state.copyWith(
        isPlacingBet: false,
        error: 'Erreur lors du placement du pari: $e',
      );
      notifyListeners();
      return false;
    }
  }

  /// Définit le gagnant et résout les paris
  Future<bool> setWinner(String winnerId) async {
    if (_state.sessionDetails == null) {
      developer.log('❌ Impossible de définir gagnant: pas de session', name: 'ActiveSessionBloc');
      return false;
    }

    _state = _state.copyWith(isSettingWinner: true, clearError: true, clearSuccess: true);
    notifyListeners();

    try {
      final result = await _apiService.setSessionWinner(
        _state.sessionDetails!.sessionId, 
        winnerId,
      );
      
      // Recharger les détails
      await loadSession(_state.sessionDetails!.sessionId);
      
      _state = _state.copyWith(
        isSettingWinner: false,
        winnerResult: result,
        successMessage: '🏆 ${result.winnerName} est le champion !',
      );
      
      developer.log('✅ Gagnant défini: ${result.winnerName}', name: 'ActiveSessionBloc');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('❌ Erreur définition gagnant: $e', name: 'ActiveSessionBloc');
      _state = _state.copyWith(
        isSettingWinner: false,
        error: 'Erreur lors de la définition du gagnant: $e',
      );
      notifyListeners();
      return false;
    }
  }

  /// Démarre la partie (transition Betting -> Playing)
  Future<bool> startPlaying() async {
    if (_state.sessionDetails == null) {
      return false;
    }

    _state = _state.copyWith(clearError: true);
    notifyListeners();

    try {
      await _apiService.startPlaying(_state.sessionDetails!.sessionId);
      await loadSession(_state.sessionDetails!.sessionId);
      
      _state = _state.copyWith(
        successMessage: 'La partie commence !',
      );
      
      developer.log('✅ Partie démarrée', name: 'ActiveSessionBloc');
      notifyListeners();
      return true;
    } catch (e) {
      developer.log('❌ Erreur démarrage partie: $e', name: 'ActiveSessionBloc');
      _state = _state.copyWith(
        error: 'Erreur lors du démarrage: $e',
      );
      notifyListeners();
      return false;
    }
  }

  /// Démarre le rafraîchissement automatique
  void startAutoRefresh(String sessionId, {Duration interval = const Duration(seconds: 5)}) {
    stopAutoRefresh();
    developer.log('🔄 Démarrage auto-refresh (interval: ${interval.inSeconds}s)', name: 'ActiveSessionBloc');
    
    _refreshTimer = Timer.periodic(interval, (_) {
      loadSession(sessionId);
    });
  }

  /// Arrête le rafraîchissement automatique
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Efface le message d'erreur
  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  /// Efface le message de succès
  void clearSuccess() {
    _state = _state.copyWith(clearSuccess: true);
    notifyListeners();
  }

  /// Rafraîchit les données
  Future<void> refresh() async {
    if (_state.sessionDetails != null) {
      await loadSession(_state.sessionDetails!.sessionId);
    }
  }

  @override
  void dispose() {
    developer.log('🗑️ ActiveSessionBloc disposé', name: 'ActiveSessionBloc');
    stopAutoRefresh();
    super.dispose();
  }
}

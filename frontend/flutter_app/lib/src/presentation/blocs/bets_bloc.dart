import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../../data/models/bet_model.dart';
import '../../data/models/player_model.dart';
import '../../services/api_service.dart';

/// État du BLoC de paris
class BetsState {
  final bool isLoading;
  final bool isPlacingBet;
  final BetsSummary? betsSummary;
  final BetHistory? betHistory;
  final List<Player> participants;
  final Player? currentPlayer;
  final String? error;

  const BetsState({
    this.isLoading = false,
    this.isPlacingBet = false,
    this.betsSummary,
    this.betHistory,
    this.participants = const [],
    this.currentPlayer,
    this.error,
  });

  BetsState copyWith({
    bool? isLoading,
    bool? isPlacingBet,
    BetsSummary? betsSummary,
    BetHistory? betHistory,
    List<Player>? participants,
    Player? currentPlayer,
    String? error,
  }) {
    return BetsState(
      isLoading: isLoading ?? this.isLoading,
      isPlacingBet: isPlacingBet ?? this.isPlacingBet,
      betsSummary: betsSummary ?? this.betsSummary,
      betHistory: betHistory ?? this.betHistory,
      participants: participants ?? this.participants,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      error: error ?? this.error,
    );
  }

  /// Vérifie si l'utilisateur a déjà parié
  bool get hasUserBet {
    if (currentPlayer == null || betsSummary == null) return false;
    return betsSummary!.hasPlayerBet(currentPlayer!.id);
  }

  /// Vérifie si les paris sont ouverts
  bool get canPlaceBets {
    return betsSummary?.sessionStatus == SessionStatus.betting &&
           participants.length >= 2;
  }
}

/// BLoC pour la gestion des paris
class BetsBloc extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  BetsState _state = const BetsState();
  BetsState get state => _state;

  /// Charge le résumé des paris d'une session
  Future<void> loadBetsSummary(String sessionId) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final summary = await _apiService.getBetsSummary(sessionId);
      _state = _state.copyWith(
        isLoading: false,
        betsSummary: summary,
      );
      developer.log('✅ Résumé des paris chargé: ${summary.totalBets} paris', name: 'BetsBloc');
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des paris: $e',
      );
      developer.log('❌ Erreur chargement paris: $e', name: 'BetsBloc');
    }
    notifyListeners();
  }

  /// Place un pari
  Future<bool> placeBet({
    required String sessionId,
    required String bettorId,
    required String predictedWinnerId,
  }) async {
    _state = _state.copyWith(isPlacingBet: true, error: null);
    notifyListeners();

    try {
      await _apiService.placeBet(sessionId, bettorId, predictedWinnerId);
      
      // Recharger le résumé après avoir placé le pari
      await loadBetsSummary(sessionId);
      
      _state = _state.copyWith(isPlacingBet: false);
      notifyListeners();
      
      developer.log('✅ Pari placé avec succès', name: 'BetsBloc');
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isPlacingBet: false,
        error: 'Erreur lors du placement du pari: $e',
      );
      notifyListeners();
      developer.log('❌ Erreur placement pari: $e', name: 'BetsBloc');
      return false;
    }
  }

  /// Charge l'historique des paris d'un joueur
  Future<void> loadBetHistory(String playerId) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final history = await _apiService.getPlayerBetHistory(playerId);
      _state = _state.copyWith(
        isLoading: false,
        betHistory: history,
      );
      developer.log('✅ Historique chargé: ${history.totalBets} paris', name: 'BetsBloc');
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement de l\'historique: $e',
      );
      developer.log('❌ Erreur chargement historique: $e', name: 'BetsBloc');
    }
    notifyListeners();
  }

  /// Définit les participants de la session
  void setParticipants(List<Player> participants) {
    _state = _state.copyWith(participants: participants);
    notifyListeners();
  }

  /// Définit le joueur courant
  void setCurrentPlayer(Player player) {
    _state = _state.copyWith(currentPlayer: player);
    notifyListeners();
  }

  /// Efface l'erreur
  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  @override
  void dispose() {
    developer.log('🗑️ BetsBloc dispose', name: 'BetsBloc');
    super.dispose();
  }
}

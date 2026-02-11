import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/data/models/bet_session_models.dart';
import 'package:prophet_profiler/src/services/api_service_v2.dart';

/// État pour le BLoC de création de session
class BetCreationState {
  final bool isLoading;
  final bool isCreating;
  final String? error;
  final List<PlayerSummaryDto> availablePlayers;
  final List<dynamic> availableGames;
  final List<String> selectedPlayerIds;
  final String? selectedGameId;
  final DateTime? selectedDate;
  final String? location;
  final SessionActiveDetails? createdSession;

  const BetCreationState({
    this.isLoading = false,
    this.isCreating = false,
    this.error,
    this.availablePlayers = const [],
    this.availableGames = const [],
    this.selectedPlayerIds = const [],
    this.selectedGameId,
    this.selectedDate,
    this.location,
    this.createdSession,
  });

  BetCreationState copyWith({
    bool? isLoading,
    bool? isCreating,
    String? error,
    List<PlayerSummaryDto>? availablePlayers,
    List<dynamic>? availableGames,
    List<String>? selectedPlayerIds,
    String? selectedGameId,
    DateTime? selectedDate,
    String? location,
    SessionActiveDetails? createdSession,
    bool clearError = false,
  }) {
    return BetCreationState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      error: clearError ? null : error ?? this.error,
      availablePlayers: availablePlayers ?? this.availablePlayers,
      availableGames: availableGames ?? this.availableGames,
      selectedPlayerIds: selectedPlayerIds ?? this.selectedPlayerIds,
      selectedGameId: selectedGameId ?? this.selectedGameId,
      selectedDate: selectedDate ?? this.selectedDate,
      location: location ?? this.location,
      createdSession: createdSession ?? this.createdSession,
    );
  }

  bool get canCreate => 
      selectedGameId != null && 
      selectedPlayerIds.length >= 2 &&
      !isCreating;

  bool get hasMinimumPlayers => selectedPlayerIds.length >= 2;
  bool get hasMaximumPlayers => selectedPlayerIds.length >= 8; // Limite arbitraire
}

/// BLoC pour la Page Création Paris
class BetCreationBloc extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  BetCreationState _state = const BetCreationState();
  BetCreationState get state => _state;

  /// Charge les données initiales (joueurs et jeux)
  Future<void> loadInitialData() async {
    developer.log('🔄 Chargement données initiales création session', name: 'BetCreationBloc');
    
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final playersResponse = await _apiService.getAvailablePlayers();
      final games = await _apiService.getGames();

      _state = _state.copyWith(
        isLoading: false,
        availablePlayers: playersResponse.players,
        availableGames: games,
      );
      developer.log('✅ ${playersResponse.players.length} joueurs, ${games.length} jeux chargés', name: 'BetCreationBloc');
    } catch (e) {
      developer.log('❌ Erreur chargement données: $e', name: 'BetCreationBloc');
      _state = _state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement: $e',
      );
    }
    notifyListeners();
  }

  /// Sélectionne ou désélectionne un joueur
  void togglePlayerSelection(String playerId) {
    final currentSelection = List<String>.from(_state.selectedPlayerIds);
    
    if (currentSelection.contains(playerId)) {
      currentSelection.remove(playerId);
      developer.log('👤 Joueur désélectionné: $playerId', name: 'BetCreationBloc');
    } else {
      if (currentSelection.length >= 8) {
        developer.log('⚠️ Limite de 8 joueurs atteinte', name: 'BetCreationBloc');
        return;
      }
      currentSelection.add(playerId);
      developer.log('👤 Joueur sélectionné: $playerId', name: 'BetCreationBloc');
    }

    _state = _state.copyWith(selectedPlayerIds: currentSelection);
    notifyListeners();
  }

  /// Sélectionne un jeu
  void selectGame(String gameId) {
    developer.log('🎲 Jeu sélectionné: $gameId', name: 'BetCreationBloc');
    _state = _state.copyWith(selectedGameId: gameId);
    notifyListeners();
  }

  /// Définit la date
  void setDate(DateTime? date) {
    _state = _state.copyWith(selectedDate: date);
    notifyListeners();
  }

  /// Définit le lieu
  void setLocation(String? location) {
    _state = _state.copyWith(location: location);
    notifyListeners();
  }

  /// Crée la session
  Future<SessionActiveDetails?> createSession() async {
    if (!_state.canCreate) {
      developer.log('❌ Conditions non remplies pour création', name: 'BetCreationBloc');
      return null;
    }

    _state = _state.copyWith(isCreating: true, clearError: true);
    notifyListeners();

    try {
      final request = CreateBetSessionRequest(
        boardGameId: _state.selectedGameId!,
        playerIds: _state.selectedPlayerIds,
        date: _state.selectedDate,
        location: _state.location,
      );

      final session = await _apiService.createBetSession(request);
      
      _state = _state.copyWith(
        isCreating: false,
        createdSession: session,
      );
      
      developer.log('✅ Session créée: ${session.sessionId}', name: 'BetCreationBloc');
      notifyListeners();
      return session;
    } catch (e) {
      developer.log('❌ Erreur création session: $e', name: 'BetCreationBloc');
      _state = _state.copyWith(
        isCreating: false,
        error: 'Erreur lors de la création: $e',
      );
      notifyListeners();
      return null;
    }
  }

  /// Réinitialise le formulaire
  void reset() {
    _state = const BetCreationState(
      availablePlayers: [],
      availableGames: [],
    );
    notifyListeners();
  }

  @override
  void dispose() {
    developer.log('🗑️ BetCreationBloc disposé', name: 'BetCreationBloc');
    super.dispose();
  }
}

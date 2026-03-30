import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/data/models/bet_session_models.dart';
import 'package:prophet_profiler/src/services/api_service_v2.dart';

/// État pour le BLoC de la homepage
class HomepageState {
  final bool isLoading;
  final String? error;
  final ActiveSessionInfo? activeSession;
  final int totalPlayers;
  final int totalGames;
  final List<RecentSessionDto> recentSessions;
  final Map<String, dynamic>? quickStats;

  const HomepageState({
    this.isLoading = false,
    this.error,
    this.activeSession,
    this.totalPlayers = 0,
    this.totalGames = 0,
    this.recentSessions = const [],
    this.quickStats,
  });

  HomepageState copyWith({
    bool? isLoading,
    String? error,
    ActiveSessionInfo? activeSession,
    int? totalPlayers,
    int? totalGames,
    List<RecentSessionDto>? recentSessions,
    Map<String, dynamic>? quickStats,
    bool clearError = false,
  }) {
    return HomepageState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      activeSession: activeSession ?? this.activeSession,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      totalGames: totalGames ?? this.totalGames,
      recentSessions: recentSessions ?? this.recentSessions,
      quickStats: quickStats ?? this.quickStats,
    );
  }

  /// Indique s'il y a une session active
  bool get hasActiveSession => activeSession?.hasActiveSession ?? false;

  /// ID de la session active (ou null)
  String? get activeSessionId => activeSession?.sessionId;

  /// Nom du jeu de la session active
  String? get activeGameName => activeSession?.boardGameName;

  /// Statut de la session active
  String? get activeSessionStatus => activeSession?.status;

  /// Texte du statut pour l'UI
  String get activeSessionStatusText {
    switch (activeSessionStatus?.toLowerCase()) {
      case 'betting':
        return 'Paris ouverts';
      case 'playing':
        return 'Partie en cours';
      case 'completed':
        return 'Terminée';
      default:
        return 'Inconnue';
    }
  }

  /// Nombre de paris placés / total participants
  String get betsStatusText {
    if (activeSession == null) return '';
    return '${activeSession!.betsPlacedCount}/${activeSession!.participantCount} paris';
  }
}

/// BLoC pour la Homepage avec boutons conditionnels
class HomepageBloc extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  HomepageState _state = const HomepageState();
  HomepageState get state => _state;

  Timer? _refreshTimer;

  /// Charge les données de la homepage
  Future<void> loadData() async {
    developer.log('🏠 Chargement données homepage', name: 'HomepageBloc');
    
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final homepageData = await _apiService.getHomepageData();

      _state = _state.copyWith(
        isLoading: false,
        activeSession: homepageData.activeSession,
        totalPlayers: homepageData.totalPlayers,
        totalGames: homepageData.totalGames,
        recentSessions: homepageData.recentSessions,
      );
      
      developer.log(
        '✅ Homepage chargée - Active: ${homepageData.activeSession?.hasActiveSession ?? false}, '
        'Joueurs: ${homepageData.totalPlayers}, Jeux: ${homepageData.totalGames}',
        name: 'HomepageBloc'
      );
    } catch (e) {
      developer.log('❌ Erreur chargement homepage: $e', name: 'HomepageBloc');
      _state = _state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement: $e',
      );
    }
    notifyListeners();
  }

  /// Charge uniquement les stats rapides
  Future<void> loadQuickStats() async {
    try {
      final stats = await _apiService.getQuickStats();
      _state = _state.copyWith(quickStats: stats);
      notifyListeners();
    } catch (e) {
      developer.log('❌ Erreur chargement stats: $e', name: 'HomepageBloc');
    }
  }

  /// Vérifie l'existence d'une session active (lightweight check)
  Future<void> checkActiveSession() async {
    try {
      final activeSession = await _apiService.getActiveSession();
      _state = _state.copyWith(activeSession: activeSession);
      notifyListeners();
    } catch (e) {
      developer.log('❌ Erreur vérification session active: $e', name: 'HomepageBloc');
    }
  }

  /// Démarre le rafraîchissement périodique
  void startAutoRefresh({Duration interval = const Duration(seconds: 10)}) {
    stopAutoRefresh();
    developer.log('🔄 Démarrage auto-refresh homepage', name: 'HomepageBloc');
    
    _refreshTimer = Timer.periodic(interval, (_) {
      // checkActiveSession();
    });
  }

  /// Arrête le rafraîchissement
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Efface l'erreur
  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  /// Rafraîchit toutes les données
  Future<void> refresh() async {
    await loadData();
  }

  @override
  void dispose() {
    developer.log('🗑️ HomepageBloc disposé', name: 'HomepageBloc');
    stopAutoRefresh();
    super.dispose();
  }
}

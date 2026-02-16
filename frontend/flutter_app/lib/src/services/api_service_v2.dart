import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:prophet_profiler/src/core/config/app_config.dart';
import 'package:prophet_profiler/src/data/models/game_model.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';
import 'package:prophet_profiler/src/data/models/bet_model.dart';
import 'package:prophet_profiler/src/data/models/bet_session_models.dart';

/// Service API étendu pour Prophet-Profiler V2
/// 
/// Nouvelles fonctionnalités:
/// - Création de session de paris unifiée
/// - Gestion de session active
/// - Sélection du gagnant
/// - Données homepage
class ApiService {
  late final Dio _dio;

  ApiService() {
    developer.log('🔌 ApiService V2 initialisé avec URL: ${AppConfig.apiBaseUrl}', name: 'ApiService');
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // Allow self-signed certificates in development
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    
    // Intercepteur pour logger les requêtes/réponses
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log('📤 REQUEST: ${options.method} ${options.path}', name: 'ApiService');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}', name: 'ApiService');
        return handler.next(response);
      },
      onError: (error, handler) {
        developer.log('❌ ERROR: ${error.message} | ${error.requestOptions.path}', name: 'ApiService');
        return handler.next(error);
      },
    ));
  }

  // ============================================================================
  // NOUVEAU: BetCreation API (Page Création Paris)
  // ============================================================================

  /// Récupère la liste des joueurs disponibles pour une nouvelle session
  Future<AvailablePlayersResponse> getAvailablePlayers() async {
    try {
      developer.log('👥 Chargement des joueurs disponibles', name: 'ApiService');
      final response = await _dio.get('/betcreation/available-players');
      return AvailablePlayersResponse.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur chargement joueurs disponibles: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement des joueurs: $e');
    }
  }

  /// Crée une nouvelle session de paris avec participants
  Future<SessionActiveDetails> createBetSession(CreateBetSessionRequest request) async {
    try {
      developer.log('🎲 Création session de paris: ${request.boardGameId}', name: 'ApiService');
      final response = await _dio.post(
        '/betcreation/create-session',
        data: request.toJson(),
      );
      
      // Retourner les détails de la session créée
      return await getSessionActiveDetails(response.data['id'].toString());
    } catch (e) {
      developer.log('❌ Erreur création session: $e', name: 'ApiService');
      throw Exception('Erreur lors de la création de la session: $e');
    }
  }

  // ============================================================================
  // NOUVEAU: Session Active API (Page Session Active)
  // ============================================================================

  /// Récupère les détails complets d'une session pour la page Session Active
  Future<SessionActiveDetails> getSessionActiveDetails(String sessionId) async {
    try {
      developer.log('📋 Chargement détails session active: $sessionId', name: 'ApiService');
      final response = await _dio.get('/betcreation/session/$sessionId');
      return SessionActiveDetails.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur chargement session active: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement de la session: $e');
    }
  }

  /// Place un pari via le nouveau endpoint
  Future<void> placeBetV2(String sessionId, PlaceBetRequestV2 request) async {
    try {
      developer.log('🎯 Placement pari V2 - Session: $sessionId', name: 'ApiService');
      await _dio.post(
        '/betcreation/session/$sessionId/place-bet',
        data: request.toJson(),
      );
    } catch (e) {
      developer.log('❌ Erreur placement pari V2: $e', name: 'ApiService');
      throw Exception('Erreur lors du placement du pari: $e');
    }
  }

  /// Définit le gagnant et résout les paris
  Future<SetWinnerResponse> setSessionWinner(String sessionId, String winnerId) async {
    try {
      developer.log('🏆 Définition gagnant - Session: $sessionId, Winner: $winnerId', name: 'ApiService');
      final response = await _dio.post(
        '/betcreation/session/$sessionId/set-winner',
        data: {'winnerId': winnerId},
      );
      return SetWinnerResponse.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur définition gagnant: $e', name: 'ApiService');
      throw Exception('Erreur lors de la définition du gagnant: $e');
    }
  }

  /// Démarre la partie (transition Betting -> Playing)
  Future<void> startPlaying(String sessionId) async {
    try {
      developer.log('▶️ Démarrage partie - Session: $sessionId', name: 'ApiService');
      await _dio.post('/betcreation/session/$sessionId/start-playing');
    } catch (e) {
      developer.log('❌ Erreur démarrage partie: $e', name: 'ApiService');
      throw Exception('Erreur lors du démarrage de la partie: $e');
    }
  }

  // ============================================================================
  // NOUVEAU: Homepage API
  // ============================================================================

  /// Récupère toutes les données pour la homepage
  Future<HomepageDataResponse> getHomepageData() async {
    try {
      developer.log('🏠 Chargement données homepage', name: 'ApiService');
      final response = await _dio.get('/homepage/data');
      return HomepageDataResponse.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur chargement homepage: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement de la homepage: $e');
    }
  }

  /// Vérifie s'il existe une session active
  Future<bool> hasActiveSession() async {
    try {
      developer.log('🔍 Vérification session active', name: 'ApiService');
      final response = await _dio.get('/homepage/has-active-session');
      return response.data['hasActiveSession'] as bool;
    } catch (e) {
      developer.log('❌ Erreur vérification session active: $e', name: 'ApiService');
      return false;
    }
  }

  /// Récupère la session active (ou null)
  Future<ActiveSessionInfo?> getActiveSession() async {
    try {
      developer.log('📍 Récupération session active', name: 'ApiService');
      final response = await _dio.get('/sessions/active');
      final info = ActiveSessionInfo.fromJson(response.data);
      return info.hasActiveSession ? info : null;
    } catch (e) {
      developer.log('❌ Erreur récupération session active: $e', name: 'ApiService');
      return null;
    }
  }

  /// Récupère les sessions récentes
  Future<List<RecentSessionDto>> getRecentSessions({int count = 5}) async {
    try {
      developer.log('📜 Chargement sessions récentes (count: $count)', name: 'ApiService');
      final response = await _dio.get('/sessions/recent?count=$count');
      return (response.data as List)
          .map((json) => RecentSessionDto.fromJson(json))
          .toList();
    } catch (e) {
      developer.log('❌ Erreur chargement sessions récentes: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement des sessions récentes: $e');
    }
  }

  /// Récupère les statistiques rapides
  Future<Map<String, dynamic>> getQuickStats() async {
    try {
      developer.log('📊 Chargement statistiques rapides', name: 'ApiService');
      final response = await _dio.get('/homepage/quick-stats');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      developer.log('❌ Erreur chargement statistiques: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement des statistiques: $e');
    }
  }

  // ============================================================================
  // EXISTANT: Players API
  // ============================================================================

  Future<List<Player>> getPlayers() async {
    final response = await _dio.get('/players');
    return (response.data as List)
        .map((json) => Player.fromJson(json))
        .toList();
  }

  Future<Player> getPlayer(String id) async {
    final response = await _dio.get('/players/$id');
    return Player.fromJson(response.data);
  }

  Future<Player> createPlayer(Player player) async {
    final response = await _dio.post('/players', data: player.toJson());
    return Player.fromJson(response.data);
  }

  // ============================================================================
  // EXISTANT: Games API
  // ============================================================================

  Future<List<Game>> getGames() async {
    final response = await _dio.get('/games');
    return (response.data as List)
    .map((json) => Game.fromJson(json))
    .toList();
  }

  Future<dynamic> getGame(String gameId) async {
    final response = await _dio.get('/games/$gameId');
    return response.data;
  }

  Future<Game> createGame(Game game) async {
    final response = await _dio.post('/games', data: game.toJson());
    return Game.fromJson(response.data);
  }

  // ============================================================================
  // EXISTANT: Sessions API (Legacy - gardé pour compatibilité)
  // ============================================================================

  Future<dynamic> createSession(Map<String, dynamic> data) async {
    final response = await _dio.post('/sessions', data: data);
    return response.data;
  }

  Future<dynamic> getSession(String sessionId) async {
    try {
      developer.log('📋 Chargement session: $sessionId', name: 'ApiService');
      final response = await _dio.get('/sessions/$sessionId');
      return response.data;
    } catch (e) {
      developer.log('❌ Erreur chargement session: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement de la session: $e');
    }
  }

  Future<dynamic> transitionSession(String sessionId, String newStatus) async {
    try {
      developer.log('🔄 Transition session $sessionId vers $newStatus', name: 'ApiService');
      final response = await _dio.post(
        '/sessions/$sessionId/transition',
        data: {'newStatus': newStatus},
      );
      return response.data;
    } catch (e) {
      developer.log('❌ Erreur transition session: $e', name: 'ApiService');
      throw Exception('Erreur lors de la transition: $e');
    }
  }

  Future<dynamic> completeSession(String sessionId, String winnerId) async {
    try {
      developer.log('🏆 Completion session $sessionId, gagnant: $winnerId', name: 'ApiService');
      final response = await _dio.post(
        '/sessions/$sessionId/complete',
        data: {'winnerId': winnerId},
      );
      return response.data;
    } catch (e) {
      developer.log('❌ Erreur completion session: $e', name: 'ApiService');
      throw Exception('Erreur lors de la completion: $e');
    }
  }

  // ============================================================================
  // EXISTANT: Bets API (Legacy)
  // ============================================================================

  Future<BetsSummary> getBetsSummary(String sessionId) async {
    try {
      developer.log('📊 Chargement résumé paris session: $sessionId', name: 'ApiService');
      final response = await _dio.get('/sessions/$sessionId/bets/summary');
      return BetsSummary.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur chargement résumé paris: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement des paris: $e');
    }
  }

  Future<Bet> placeBet(String sessionId, String bettorId, String predictedWinnerId) async {
    try {
      developer.log('🎲 Placement pari - Session: $sessionId, Parieur: $bettorId, Choix: $predictedWinnerId', name: 'ApiService');
      final request = PlaceBetRequest(
        bettorId: bettorId,
        predictedWinnerId: predictedWinnerId,
      );
      final response = await _dio.post(
        '/sessions/$sessionId/bets',
        data: request.toJson(),
      );
      return Bet.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur placement pari: $e', name: 'ApiService');
      throw Exception('Erreur lors du placement du pari: $e');
    }
  }

  Future<BetHistory> getPlayerBetHistory(String playerId) async {
    try {
      developer.log('📜 Chargement historique paris joueur: $playerId', name: 'ApiService');
      final response = await _dio.get('/players/$playerId/bets/history');
      return BetHistory.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur chargement historique paris: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement de l\'historique: $e');
    }
  }

  // ============================================================================
  // EXISTANT: Rankings API
  // ============================================================================

  Future<dynamic> getChampions() async {
    final response = await _dio.get('/rankings/champions');
    return response.data;
  }

  Future<dynamic> getOracles() async {
    final response = await _dio.get('/rankings/oracles');
    return response.data;
  }

  Future<dynamic> calculateMatchScore(List<String> playerIds, String gameId) async {
    final response = await _dio.post('/match-score', data: {
      'playerIds': playerIds,
      'gameId': gameId,
    });
    return response.data;
  }

  // ============================================================================
  // EXISTANT: Upload API
  // ============================================================================

  Future<String> uploadPlayerPhoto(String playerId, File imageFile) async {
    try {
      developer.log('📤 Upload photo joueur: $playerId', name: 'ApiService');
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'player_$playerId.jpg',
        ),
      });

      final response = await _dio.post(
        '/players/$playerId/photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      developer.log('✅ Photo uploadée: ${response.data}', name: 'ApiService');
      return response.data['photoUrl'] as String;
    } catch (e) {
      developer.log('❌ Erreur upload photo: $e', name: 'ApiService');
      throw Exception('Erreur lors de l\'upload de la photo: $e');
    }
  }
}

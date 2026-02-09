import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:prophet_profiler/src/core/config/app_config.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';
import 'package:prophet_profiler/src/data/models/bet_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    developer.log('🔌 ApiService initialisé avec URL: ${AppConfig.apiBaseUrl}', name: 'ApiService');
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

  // Players
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

  // Games
  Future<List<dynamic>> getGames() async {
    final response = await _dio.get('/games');
    return response.data;
  }

  // Match Score
  Future<dynamic> calculateMatchScore(List<String> playerIds, String gameId) async {
    final response = await _dio.post('/match-score', data: {
      'playerIds': playerIds,
      'gameId': gameId,
    });
    return response.data;
  }

  // Sessions
  Future<dynamic> createSession(Map<String, dynamic> data) async {
    final response = await _dio.post('/sessions', data: data);
    return response.data;
  }

  Future<dynamic> getSession(String sessionId) async {
    try {
      developer.log('📋 Chargement de la session: $sessionId', name: 'ApiService');
      final response = await _dio.get('/api/sessions/$sessionId');
      return response.data;
    } catch (e) {
      developer.log('❌ Erreur chargement session: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement de la session: $e');
    }
  }

  Future<dynamic> transitionSession(String sessionId, String newStatus) async {
    try {
      developer.log('🔄 Transition de la session $sessionId vers $newStatus', name: 'ApiService');
      final response = await _dio.post(
        '/api/sessions/$sessionId/transition',
        data: {'status': newStatus},
      );
      return response.data;
    } catch (e) {
      developer.log('❌ Erreur transition session: $e', name: 'ApiService');
      throw Exception('Erreur lors de la transition: $e');
    }
  }

  Future<dynamic> completeSession(String sessionId, String winnerId) async {
    try {
      developer.log('🏆 Completion de la session $sessionId, gagnant: $winnerId', name: 'ApiService');
      final response = await _dio.post(
        '/api/sessions/$sessionId/complete',
        data: {'winnerId': winnerId},
      );
      return response.data;
    } catch (e) {
      developer.log('❌ Erreur completion session: $e', name: 'ApiService');
      throw Exception('Erreur lors de la completion: $e');
    }
  }

  // Bets
  Future<BetsSummary> getBetsSummary(String sessionId) async {
    try {
      developer.log('📊 Chargement du résumé des paris pour session: $sessionId', name: 'ApiService');
      final response = await _dio.get('/api/sessions/$sessionId/bets/summary');
      return BetsSummary.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur chargement résumé paris: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement des paris: $e');
    }
  }

  Future<Bet> placeBet(String sessionId, String bettorId, String predictedWinnerId) async {
    try {
      developer.log('🎲 Placement du pari - Session: $sessionId, Parieur: $bettorId, Choix: $predictedWinnerId', name: 'ApiService');
      final request = PlaceBetRequest(
        bettorId: bettorId,
        predictedWinnerId: predictedWinnerId,
      );
      final response = await _dio.post(
        '/api/sessions/$sessionId/bets',
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
      developer.log('📜 Chargement de l\'historique des paris pour joueur: $playerId', name: 'ApiService');
      final response = await _dio.get('/api/players/$playerId/bets/history');
      return BetHistory.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur chargement historique paris: $e', name: 'ApiService');
      throw Exception('Erreur lors du chargement de l\'historique: $e');
    }
  }

  // Rankings
  Future<dynamic> getChampions() async {
    final response = await _dio.get('/rankings/champions');
    return response.data;
  }

  Future<dynamic> getOracles() async {
    final response = await _dio.get('/rankings/oracles');
    return response.data;
  }

  // Upload Photo
  Future<String> uploadPlayerPhoto(String playerId, File imageFile) async {
    try {
      developer.log('📤 Upload photo pour joueur: $playerId', name: 'ApiService');
      
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
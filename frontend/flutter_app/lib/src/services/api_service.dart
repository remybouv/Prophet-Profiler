import 'package:dio/dio.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'https://localhost:49704/api';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'Content-Type': 'application/json',
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

  Future<dynamic> placeBet(String sessionId, String bettorId, String predictedWinnerId) async {
    final response = await _dio.post('/sessions/$sessionId/bets', data: {
      'bettorId': bettorId,
      'predictedWinnerId': predictedWinnerId,
    });
    return response.data;
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
}
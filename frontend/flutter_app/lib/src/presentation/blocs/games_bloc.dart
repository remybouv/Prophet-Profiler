import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prophet_profiler/src/data/models/game_model.dart';
import 'package:prophet_profiler/src/services/api_service_v2.dart';

abstract class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object?> get props => [];
}

class LoadGames extends GamesEvent {
  const LoadGames();
}

class CreateGame extends GamesEvent {
  final String name;

  const CreateGame({required this.name});

  @override
  List<Object?> get props => [name];
}

// ==================== STATES ====================

abstract class GamesState extends Equatable {
  const GamesState();

  @override
  List<Object?> get props => [];
}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {}

class GamesLoaded extends GamesState {
  final List<Game> games;

  const GamesLoaded(this.games);

  @override
  List<Object?> get props => [games];
}

class GamesError extends GamesState {
  final String message;

  const GamesError(this.message);

  @override
  List<Object?> get props => [message];
}

class GameCreating extends GamesState {}

class GameCreated extends GamesState {
  final Game game;

  const GameCreated(this.game);

  @override
  List<Object?> get props => [game];
}

class GameCreateError extends GamesState {
  final String message;

  const GameCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

// ======================== BLOC ======================
class GamesBloc extends Bloc<GamesEvent, GamesState> {
  final ApiService _apiService;

  GamesBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(GamesInitial()) {
    on<LoadGames>(_onLoadGames);
    on<CreateGame>(_onCreateGame);
  }

  Future<void> _onLoadGames(LoadGames event, Emitter<GamesState> emit) async {
    developer.log('🔄 [BLOC] Chargement des jeux...', name: 'GamesBloc');
    emit(GamesLoading());
    try {
      final games = await _apiService.getGames();
      developer.log('✅ [BLOC] ${games.length} jeux chargés', name: 'GamesBloc');
      emit(GamesLoaded(games));
    } catch (e) {
      developer.log('❌ [BLOC] Erreur chargement: $e', name: 'GamesBloc');
      emit(GamesError('Impossible de charger les jeux: $e'));
    }
  }

  Future<void> _onCreateGame(CreateGame event, Emitter<GamesState> emit) async {
    developer.log('📝 [BLOC] Création joueur: ${event.name}',
        name: 'PlayersBloc');
    emit(GameCreating());
    try {
      final game = Game(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        gameName: event.name,
      );
      final createdGame = await _apiService.createGame(game);
      developer.log('✅ [BLOC] Jeu créé: ${createdGame.id}', name: 'GamesBloc');
      emit(GameCreated(createdGame));
    } catch (e) {
      developer.log('❌ [BLOC] Erreur création: $e', name: 'GamesBloc');
      emit(GameCreateError('Erreur lors de la création: $e'));
    }
  }
}

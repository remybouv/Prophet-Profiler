import 'dart:developer' as developer;
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';
import 'package:prophet_profiler/src/services/api_service.dart';

// ==================== EVENTS ====================

abstract class PlayersEvent extends Equatable {
  const PlayersEvent();

  @override
  List<Object?> get props => [];
}

class LoadPlayers extends PlayersEvent {
  const LoadPlayers();
}

class CreatePlayer extends PlayersEvent {
  final String name;
  final String? photoUrl;
  final int aggressivity;
  final int patience;
  final int analysis;
  final int bluff;

  const CreatePlayer({
    required this.name,
    this.photoUrl,
    required this.aggressivity,
    required this.patience,
    required this.analysis,
    required this.bluff,
  });

  @override
  List<Object?> get props => [name, photoUrl, aggressivity, patience, analysis, bluff];
}

// ==================== STATES ====================

abstract class PlayersState extends Equatable {
  const PlayersState();

  @override
  List<Object?> get props => [];
}

class PlayersInitial extends PlayersState {}

class PlayersLoading extends PlayersState {}

class PlayersLoaded extends PlayersState {
  final List<Player> players;

  const PlayersLoaded(this.players);

  @override
  List<Object?> get props => [players];
}

class PlayersError extends PlayersState {
  final String message;

  const PlayersError(this.message);

  @override
  List<Object?> get props => [message];
}

class PlayerCreating extends PlayersState {}

class PlayerCreated extends PlayersState {
  final Player player;

  const PlayerCreated(this.player);

  @override
  List<Object?> get props => [player];
}

class PlayerCreateError extends PlayersState {
  final String message;

  const PlayerCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class PlayersBloc extends Bloc<PlayersEvent, PlayersState> {
  final ApiService _apiService;

  PlayersBloc({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService(),
        super(PlayersInitial()) {
    on<LoadPlayers>(_onLoadPlayers);
    on<CreatePlayer>(_onCreatePlayer);
  }

  Future<void> _onLoadPlayers(LoadPlayers event, Emitter<PlayersState> emit) async {
    developer.log('🔄 [BLOC] Chargement des joueurs...', name: 'PlayersBloc');
    emit(PlayersLoading());
    try {
      final players = await _apiService.getPlayers();
      developer.log('✅ [BLOC] ${players.length} joueurs chargés', name: 'PlayersBloc');
      emit(PlayersLoaded(players));
    } catch (e) {
      developer.log('❌ [BLOC] Erreur chargement: $e', name: 'PlayersBloc');
      emit(PlayersError('Impossible de charger les joueurs: $e'));
    }
  }

  Future<void> _onCreatePlayer(CreatePlayer event, Emitter<PlayersState> emit) async {
    developer.log('📝 [BLOC] Création joueur: ${event.name}', name: 'PlayersBloc');
    emit(PlayerCreating());
    try {
      // Générer un ID temporaire (le backend en génère un vrai)
      final player = Player(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        name: event.name,
        photoUrl: event.photoUrl,
        profile: PlayerProfile(
          aggressivity: event.aggressivity,
          patience: event.patience,
          analysis: event.analysis,
          bluff: event.bluff,
        ),
      );

      final createdPlayer = await _apiService.createPlayer(player);
      developer.log('✅ [BLOC] Joueur créé: ${createdPlayer.id}', name: 'PlayersBloc');
      emit(PlayerCreated(createdPlayer));
      
      // Recharger la liste
      add(const LoadPlayers());
    } catch (e) {
      developer.log('❌ [BLOC] Erreur création: $e', name: 'PlayersBloc');
      emit(PlayerCreateError('Erreur lors de la création: $e'));
    }
  }

  // Méthode publique pour uploader la photo
  Future<String> uploadPlayerPhoto(String playerId, File imageFile) async {
    developer.log('📤 [BLOC] Upload photo pour: $playerId', name: 'PlayersBloc');
    try {
      final photoUrl = await _apiService.uploadPlayerPhoto(playerId, imageFile);
      developer.log('✅ [BLOC] Photo uploadée: $photoUrl', name: 'PlayersBloc');
      return photoUrl;
    } catch (e) {
      developer.log('❌ [BLOC] Erreur upload photo: $e', name: 'PlayersBloc');
      throw Exception('Erreur upload photo: $e');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prophet_profiler/src/presentation/blocs/players_bloc.dart';
import 'package:prophet_profiler/src/presentation/pages/player_form_page.dart';
import 'dart:developer' as developer;

class PlayersPage extends StatelessWidget {
  const PlayersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayersBloc()..add(const LoadPlayers()),
      child: const _PlayersView(),
    );
  }
}

class _PlayersView extends StatelessWidget {
  const _PlayersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joueurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              developer.log('🔄 Refresh demandé', name: 'PlayersPage');
              context.read<PlayersBloc>().add(const LoadPlayers());
            },
          ),
        ],
      ),
      body: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) {
          if (state is PlayersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is PlayersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PlayersBloc>().add(const LoadPlayers());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          
          if (state is PlayersLoaded) {
            if (state.players.isEmpty) {
              return const Center(child: Text('Aucun joueur encore'));
            }
            
            return ListView.builder(
              itemCount: state.players.length,
              itemBuilder: (context, index) {
                final player = state.players[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber,
                    backgroundImage: player.photoUrl != null 
                        ? NetworkImage(player.photoUrl!) 
                        : null,
                    child: player.photoUrl == null 
                        ? Text(
                            player.name.isNotEmpty 
                                ? player.name[0].toUpperCase() 
                                : '?',
                          )
                        : null,
                  ),
                  title: Text(player.name),
                  subtitle: Text(
                    'A:${player.profile.aggressivity} P:${player.profile.patience} '
                    'A:${player.profile.analysis} B:${player.profile.bluff}',
                  ),
                );
              },
            );
          }
          
          return const Center(child: Text('Chargement...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          developer.log('➕ Ajouter joueur cliqué', name: 'PlayersPage');
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlayerFormPage()),
          );
          
          // Si création réussie, recharger la liste
          if (result == true && context.mounted) {
            developer.log('✅ Retour avec succès, reload liste', name: 'PlayersPage');
            context.read<PlayersBloc>().add(const LoadPlayers());
          }
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

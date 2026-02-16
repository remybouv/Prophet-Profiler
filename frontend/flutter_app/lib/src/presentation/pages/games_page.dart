import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import 'package:prophet_profiler/src/presentation/blocs/games_bloc.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamePageState();
}

class _GamePageState extends State<GamesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => GamesBloc()..add(const LoadGames()),
        child: Scaffold(
          appBar: AppBar(title: const Text('Jeux')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.casino, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Liste des jeux',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(key: _formKey, spacing: 10, children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du jeu',
                        hintText: 'Entrez le nom (2-50 caractères)',
                        prefixIcon: const Icon(Icons.games),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est obligatoire';
                        }
                        if (value.trim().length < 2) {
                          return 'Le nom doit faire au moins 2 caractères';
                        }
                        if (value.trim().length > 50) {
                          return 'Le nom ne doit pas dépasser 50 caractères';
                        }
                        return null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      developer.log('🎮 Bouton jeu cliqué', name: 'GamesPage');
                      _addGame(context);
                    },
                    child: const Icon(Icons.add,
                        color: AppColors.royalIndigo, size: 30),
                  ),
                ]),
                const Text('Fonctionnalité en cours de développement'),
                const SizedBox(height: 24),
                BlocBuilder<GamesBloc, GamesState>(builder: (context, state) {
                  if (state is GamesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GamesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message,
                              style: const TextStyle(color: Colors.red)),
                          ElevatedButton(
                              onPressed: () {
                                context
                                    .read()<GamesBloc>()
                                    .add(const LoadGames());
                              },
                              child: const Text('Réessayer'))
                        ],
                      ),
                    );
                  }

                  if (state is GamesLoaded) {
                    if (state.games.isEmpty) {
                      return const Center(
                          child: Text(
                              'Aucun jeu, veuillez entrer votre premier jeu'));
                    }

                    return ListView.builder(
                      itemCount: state.games.length,
                      itemBuilder: (context, index) {
                        final game = state.games[index];
                        return ListTile(
                          title: Text(game.gameName),
                        );
                      },
                    );
                  }

                  return const Center(child: Text('Chargement...'));
                })
              ],
            ),
          ),
        ));
  }

  void _addGame(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context
          .read<GamesBloc>()
          .add(CreateGame(name: _nameController.text.trim()));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/services/api_service.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';
import 'dart:developer' as developer;

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final ApiService _apiService = ApiService();
  List<Player> _players = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    developer.log('🔄 Chargement des joueurs...', name: 'PlayersPage');
    setState(() => _isLoading = true);
    try {
      final players = await _apiService.getPlayers();
      developer.log('✅ ${players.length} joueurs chargés', name: 'PlayersPage');
      setState(() {
        _players = players;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      developer.log('❌ Erreur chargement joueurs: $e', name: 'PlayersPage');
      setState(() {
        _error = 'Impossible de charger les joueurs. Vérifiez la connexion API.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joueurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPlayers,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _players.isEmpty
                  ? const Center(child: Text('Aucun joueur encore'))
                  : ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child: Text(player.nickname[0].toUpperCase()),
                          ),
                          title: Text(player.nickname),
                          subtitle: Text('ELO: ${player.eloScore.toStringAsFixed(0)}'),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          developer.log('➕ Ajouter joueur cliqué', name: 'PlayersPage');
          _showAddPlayerDialog();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau joueur'),
        content: const Text('Fonctionnalité à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

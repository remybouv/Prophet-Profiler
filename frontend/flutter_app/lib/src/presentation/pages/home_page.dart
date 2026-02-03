import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'players_page.dart';
import 'games_page.dart';
import 'rankings_page.dart';
import 'new_session_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prophet & Profiler'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          developer.log('📱 Navigation vers index: $index', name: 'HomePage');
          switch (index) {
            case 0: // Accueil - déjà là
              break;
            case 1: // Joueurs
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayersPage()),
              );
              break;
            case 2: // Jeux
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamesPage()),
              );
              break;
            case 3: // Classements
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RankingsPage()),
              );
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Joueurs'),
          NavigationDestination(icon: Icon(Icons.casino), label: 'Jeux'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Classements'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.casino, size: 48, color: Colors.amber[300]),
            const SizedBox(height: 8),
            const Text(
              'Qui sera le champion de ce soir ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              developer.log('🎮 Bouton Nouvelle Session cliqué', name: 'HomePage');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewSessionPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle Session'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              developer.log('👤 Bouton Ajouter Joueur cliqué', name: 'HomePage');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayersPage()),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Ajouter Joueur'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activité récente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune session récente',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
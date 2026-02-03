import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class RankingsPage extends StatelessWidget {
  const RankingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Classements'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.emoji_events), text: 'Champions'),
              Tab(icon: Icon(Icons.visibility), text: 'Oracles'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChampionsTab(),
            _buildOraclesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildChampionsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          const Text(
            'Classement des Champions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              developer.log('🏆 Champions chargés', name: 'RankingsPage');
            },
            child: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }

  Widget _buildOraclesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility, size: 64, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Classement des Oracles',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              developer.log('🔮 Oracles chargés', name: 'RankingsPage');
            },
            child: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }
}

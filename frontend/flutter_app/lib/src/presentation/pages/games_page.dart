import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jeux')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.casino, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Liste des jeux',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Fonctionnalité en cours de développement'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                developer.log('🎮 Bouton jeu cliqué', name: 'GamesPage');
              },
              child: const Text('Ajouter un jeu'),
            ),
          ],
        ),
      ),
    );
  }
}

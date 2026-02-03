import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class NewSessionPage extends StatelessWidget {
  const NewSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Créer une session',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Sélectionnez un jeu et les joueurs participants'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                developer.log('▶️ Démarrer session cliqué', name: 'NewSessionPage');
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Démarrer la session'),
            ),
          ],
        ),
      ),
    );
  }
}

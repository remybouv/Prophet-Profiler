import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/player_model.dart';

class BetSelectionDialog {
  static Future<Player?> show(BuildContext context, List<Player> participants, String currentPlayerId) {
    return showDialog<Player>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parier sur le champion'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final player = participants[index];
              final isCurrentPlayer = player.id == currentPlayerId;
              return ListTile(
                title: Text(player.name),
                subtitle: isCurrentPlayer ? const Text('Vous ne pouvez pas parier sur vous-même') : null,
                enabled: !isCurrentPlayer,
                onTap: isCurrentPlayer ? null : () => Navigator.pop(context, player),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ],
      ),
    );
  }
}

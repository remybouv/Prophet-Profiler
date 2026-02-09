import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';
import 'package:prophet_profiler/src/data/models/bet_model.dart';

class BetResultsDialog {
  static void show(BuildContext context, BetsSummary summary, String winnerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🏆 $winnerName est le champion !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paris :'),
            ...summary.bets.map((bet) => ListTile(
              title: Text('${bet.bettorName} → ${bet.predictedWinnerName}'),
              trailing: bet.isCorrect
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }
}

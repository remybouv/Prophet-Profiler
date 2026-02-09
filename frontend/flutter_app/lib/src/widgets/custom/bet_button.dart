import 'package:flutter/material.dart';
import 'package:prophet_profiler/src/core/theme/widgets_theme.dart';

class BetButton extends StatelessWidget {
  final int placedBets;
  final int totalParticipants;
  final bool hasUserBet;
  final VoidCallback onPressed;

  const BetButton({
    super.key,
    required this.placedBets,
    required this.totalParticipants,
    required this.hasUserBet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(hasUserBet ? Icons.visibility : Icons.sports_kabaddi),
      label: Text('$placedBets/$totalParticipants paris'),
      style: ElevatedButton.styleFrom(
        backgroundColor: hasUserBet ? AppColors.slate : AppColors.gold,
        foregroundColor: hasUserBet ? AppColors.cream : AppColors.royalIndigo,
      ),
    );
  }
}

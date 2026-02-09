import 'package:flutter/material.dart';
import '../../../core/theme/widgets_theme.dart';

/// Bouton "Qui sera le champion ?" avec badge affichant le nombre de paris
/// 
/// Visible uniquement quand la session est en statut "Betting"
/// Devient "Voir les paris" après avoir parié
class BetButton extends StatelessWidget {
  final int betsCount;
  final int totalParticipants;
  final bool hasUserBet;
  final bool isEnabled;
  final VoidCallback onPressed;

  const BetButton({
    super.key,
    required this.betsCount,
    required this.totalParticipants,
    required this.hasUserBet,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si l'utilisateur a déjà parié, afficher "Voir les paris"
    if (hasUserBet) {
      return _buildViewBetsButton(theme);
    }

    // Si les paris sont désactivés (moins de 2 joueurs)
    if (!isEnabled) {
      return _buildDisabledButton(theme);
    }

    // Bouton principal pour parier
    return _buildPlaceBetButton(theme);
  }

  Widget _buildPlaceBetButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.royalIndigo,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: AppColors.gold.withOpacity(0.4),
        ),
        icon: const Icon(Icons.casino, size: 22),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Qui sera le champion ?',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildViewBetsButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.gold, width: 2),
          foregroundColor: AppColors.gold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.visibility, size: 22),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Voir les paris',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisabledButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceVariant,
          foregroundColor: AppColors.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.onSurfaceVariant.withOpacity(0.5),
        ),
        icon: Icon(Icons.casino, size: 22, color: AppColors.onSurfaceVariant.withOpacity(0.5)),
        label: const Flexible(
          child: Text(
            'Minimum 2 joueurs requis',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasUserBet 
            ? AppColors.gold.withOpacity(0.2) 
            : AppColors.royalIndigo.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasUserBet 
              ? AppColors.gold.withOpacity(0.3) 
              : AppColors.royalIndigo.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$betsCount/$totalParticipants',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: hasUserBet ? AppColors.gold : AppColors.royalIndigo,
        ),
      ),
    );
  }
}

/// Version compacte du bouton de pari pour la navigation bar
class BetNavButton extends StatelessWidget {
  final int betsCount;
  final int totalParticipants;
  final bool hasUserBet;
  final VoidCallback onPressed;

  const BetNavButton({
    super.key,
    required this.betsCount,
    required this.totalParticipants,
    required this.hasUserBet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filled(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: hasUserBet ? AppColors.surface : AppColors.gold,
            foregroundColor: hasUserBet ? AppColors.gold : AppColors.royalIndigo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(48, 48),
          ),
          icon: Icon(
            hasUserBet ? Icons.visibility : Icons.casino,
            size: 24,
          ),
        ),
        // Badge
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.royalIndigo, width: 2),
            ),
            child: Text(
              '$betsCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

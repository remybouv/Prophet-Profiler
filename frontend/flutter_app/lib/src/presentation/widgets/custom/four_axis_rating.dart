import 'package:flutter/material.dart';
import '../../core/theme/widgets_theme.dart';
import 'star_rating.dart';

/// Widget affichant les 4 axes de profil avec notation par étoiles
/// 
/// Axes:
/// - Agressivité (Rouge)
/// - Patience (Bleu)
/// - Analyse (Vert)
/// - Bluff (Violet)
class FourAxisRating extends StatelessWidget {
  final int aggressivity;
  final int patience;
  final int analysis;
  final int bluff;
  final ValueChanged<String, int>? onAxisChanged;
  final bool readOnly;
  final bool showLabels;
  final double spacing;

  const FourAxisRating({
    super.key,
    required this.aggressivity,
    required this.patience,
    required this.analysis,
    required this.bluff,
    this.onAxisChanged,
    this.readOnly = false,
    this.showLabels = true,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAxisRow(
          context: context,
          label: 'Agressivité',
          icon: Icons.local_fire_department,
          color: AppColors.aggressivity,
          value: aggressivity,
          axisKey: 'aggressivity',
        ),
        SizedBox(height: spacing),
        _buildAxisRow(
          context: context,
          label: 'Patience',
          icon: Icons.hourglass_empty,
          color: AppColors.patience,
          value: patience,
          axisKey: 'patience',
        ),
        SizedBox(height: spacing),
        _buildAxisRow(
          context: context,
          label: 'Analyse',
          icon: Icons.psychology,
          color: AppColors.analysis,
          value: analysis,
          axisKey: 'analysis',
        ),
        SizedBox(height: spacing),
        _buildAxisRow(
          context: context,
          label: 'Bluff',
          icon: Icons.face,
          color: AppColors.bluff,
          value: bluff,
          axisKey: 'bluff',
        ),
      ],
    );
  }

  Widget _buildAxisRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required int value,
    required String axisKey,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icône avec couleur de l'axe
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Label
          if (showLabels) ...[
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
          // Étoiles de notation
          Expanded(
            flex: 3,
            child: StarRating(
              rating: value,
              readOnly: readOnly,
              starSize: 20,
              starSpacing: 2,
              onRatingChanged: readOnly
                  ? null
                  : (rating) => onAxisChanged?.call(axisKey, rating),
            ),
          ),
        ],
      ),
    );
  }
}

/// Version compacte pour les cartes joueur
class FourAxisRatingCompact extends StatelessWidget {
  final int aggressivity;
  final int patience;
  final int analysis;
  final int bluff;

  const FourAxisRatingCompact({
    super.key,
    required this.aggressivity,
    required this.patience,
    required this.analysis,
    required this.bluff,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMiniAxis(AppColors.aggressivity, aggressivity, 'Agr'),
        _buildMiniAxis(AppColors.patience, patience, 'Pat'),
        _buildMiniAxis(AppColors.analysis, analysis, 'Ana'),
        _buildMiniAxis(AppColors.bluff, bluff, 'Blf'),
      ],
    );
  }

  Widget _buildMiniAxis(Color color, int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value / 5,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value/5',
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

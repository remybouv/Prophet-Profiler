import 'package:flutter/material.dart';
import '../../core/theme/widgets_theme.dart';

/// Widget de notation par étoiles interactif
/// 
/// Affiche 5 étoiles dorées qui peuvent être cliquées pour noter.
/// Supporte le mode lecture seule et le mode édition.
class StarRating extends StatefulWidget {
  final int rating;
  final int maxRating;
  final ValueChanged<int>? onRatingChanged;
  final bool readOnly;
  final double? starSize;
  final double? starSpacing;
  final String? label;

  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.onRatingChanged,
    this.readOnly = false,
    this.starSize,
    this.starSpacing,
    this.label,
  }) : assert(rating >= 0 && rating <= maxRating, 'Rating must be between 0 and maxRating');

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _hoverRating = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final starTheme = theme.starRatingThemeExt;
    final starSize = widget.starSize ?? starTheme.starSize;
    final starSpacing = widget.starSpacing ?? starTheme.starSpacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxRating, (index) {
            final starNumber = index + 1;
            final displayRating = _hoverRating > 0 ? _hoverRating : widget.rating;
            final isFilled = starNumber <= displayRating;

            return Padding(
              padding: EdgeInsets.only(
                right: index < widget.maxRating - 1 ? starSpacing : 0,
              ),
              child: _buildStar(
                starNumber: starNumber,
                isFilled: isFilled,
                isHovered: starNumber <= _hoverRating && _hoverRating > 0,
                size: starSize,
                theme: starTheme,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStar({
    required int starNumber,
    required bool isFilled,
    required bool isHovered,
    required double size,
    required StarRatingThemeExtension theme,
  }) {
    final color = isFilled
        ? (isHovered ? theme.hoverColor : theme.filledColor)
        : theme.emptyColor;

    return GestureDetector(
      onTap: widget.readOnly
          ? null
          : () {
              setState(() {
                widget.onRatingChanged?.call(starNumber);
              });
            },
      onTapDown: widget.readOnly
          ? null
          : (_) {
              setState(() {
                _hoverRating = starNumber;
              });
            },
      onTapUp: widget.readOnly
          ? null
          : (_) {
              setState(() {
                _hoverRating = 0;
              });
            },
      onTapCancel: widget.readOnly
          ? null
          : () {
              setState(() {
                _hoverRating = 0;
              });
            },
      child: MouseRegion(
        onEnter: widget.readOnly
            ? null
            : (_) {
                setState(() {
                  _hoverRating = starNumber;
                });
              },
        onExit: widget.readOnly
            ? null
            : (_) {
                setState(() {
                  _hoverRating = 0;
                });
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          transform: isHovered
              ? Matrix4.identity()..scale(1.15)
              : Matrix4.identity(),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
            color: color,
            size: size,
            shadows: isFilled
                ? [
                    Shadow(
                      color: theme.filledColor.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

/// Version compacte pour les listes
class StarRatingCompact extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;

  const StarRatingCompact({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return StarRating(
      rating: rating,
      maxRating: maxRating,
      readOnly: true,
      starSize: size,
      starSpacing: 2,
    );
  }
}

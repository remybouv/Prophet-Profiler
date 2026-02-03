import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';
import '../../core/theme/widgets_theme.dart';

/// Jauge semi-circulaire affichant un score de match 0-100%
/// 
/// Couleurs selon le score:
/// - 0-39%: Rouge (danger)
/// - 40-69%: Orange (warning)
/// - 70-100%: Vert (success)
class MatchScoreGauge extends StatelessWidget {
  final double score;
  final String? label;
  final double? size;
  final double? strokeWidth;
  final bool showValue;
  final bool animated;

  const MatchScoreGauge({
    super.key,
    required this.score,
    this.label,
    this.size,
    this.strokeWidth,
    this.showValue = true,
    this.animated = true,
  }) : assert(score >= 0 && score <= 100, 'Score must be between 0 and 100');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gaugeTheme = theme.gaugeThemeExt;
    final gaugeSize = size ?? gaugeTheme.size;
    final gaugeStrokeWidth = strokeWidth ?? gaugeTheme.strokeWidth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: gaugeSize,
          height: gaugeSize * 0.6,
          child: animated
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedScore, child) {
                    return CustomPaint(
                      size: Size(gaugeSize, gaugeSize * 0.6),
                      painter: _SemiCircularGaugePainter(
                        score: animatedScore,
                        strokeWidth: gaugeStrokeWidth,
                        backgroundColor: gaugeTheme.backgroundColor,
                        lowColor: gaugeTheme.lowColor,
                        mediumColor: gaugeTheme.mediumColor,
                        highColor: gaugeTheme.highColor,
                      ),
                    );
                  },
                )
              : CustomPaint(
                  size: Size(gaugeSize, gaugeSize * 0.6),
                  painter: _SemiCircularGaugePainter(
                    score: score,
                    strokeWidth: gaugeStrokeWidth,
                    backgroundColor: gaugeTheme.backgroundColor,
                    lowColor: gaugeTheme.lowColor,
                    mediumColor: gaugeTheme.mediumColor,
                    highColor: gaugeTheme.highColor,
                  ),
                ),
        ),
        if (showValue) ...[
          const SizedBox(height: 8),
          AnimatedScoreValue(
            score: score,
            style: gaugeTheme.valueStyle,
            animated: animated,
          ),
        ],
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label!,
            style: gaugeTheme.labelStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Affiche la valeur du score avec animation
class AnimatedScoreValue extends StatelessWidget {
  final double score;
  final TextStyle style;
  final bool animated;

  const AnimatedScoreValue({
    super.key,
    required this.score,
    required this.style,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!animated) {
      return Text(
        '${score.toInt()}%',
        style: style,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final gaugeTheme = Theme.of(context).gaugeThemeExt;
        final color = gaugeTheme.getColorForValue(value);

        return Text(
          '${value.toInt()}%',
          style: style.copyWith(color: color),
        );
      },
    );
  }
}

/// Painter personnalisé pour la jauge semi-circulaire
class _SemiCircularGaugePainter extends CustomPainter {
  final double score;
  final double strokeWidth;
  final Color backgroundColor;
  final Color lowColor;
  final Color mediumColor;
  final Color highColor;

  _SemiCircularGaugePainter({
    required this.score,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.lowColor,
    required this.mediumColor,
    required this.highColor,
  });

  Color get _scoreColor {
    if (score < 40) return lowColor;
    if (score < 70) return mediumColor;
    return highColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    // Arc de fond
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );

    // Arc de progression avec dégradé
    final scoreAngle = (score / 100) * pi;
    
    // Création du dégradé selon le score
    final gradient = SweepGradient(
      center: Alignment.bottomCenter,
      startAngle: pi,
      endAngle: 0,
      colors: [
        lowColor,
        mediumColor,
        highColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      scoreAngle,
      false,
      progressPaint,
    );

    // Pointe indicateur
    final indicatorAngle = pi + scoreAngle;
    final indicatorX = center.dx + radius * cos(indicatorAngle);
    final indicatorY = center.dy + radius * sin(indicatorAngle);

    final indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      strokeWidth / 2 + 2,
      indicatorPaint,
    );

    final innerIndicatorPaint = Paint()
      ..color = _scoreColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      strokeWidth / 2,
      innerIndicatorPaint,
    );

    // Lignes de repère (0, 50, 100)
    _drawMarkers(canvas, center, radius);
  }

  void _drawMarkers(Canvas canvas, Offset center, double radius) {
    final markerPaint = Paint()
      ..color = backgroundColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Marqueur 0%
    final marker0X = center.dx + (radius - 10) * cos(pi);
    final marker0Y = center.dy + (radius - 10) * sin(pi);
    canvas.drawLine(
      Offset(center.dx + radius * cos(pi), center.dy + radius * sin(pi)),
      Offset(marker0X, marker0Y),
      markerPaint,
    );

    // Marqueur 50%
    final marker50X = center.dx + (radius - 10) * cos(pi * 1.5);
    final marker50Y = center.dy + (radius - 10) * sin(pi * 1.5);
    canvas.drawLine(
      Offset(center.dx + radius * cos(pi * 1.5), center.dy + radius * sin(pi * 1.5)),
      Offset(marker50X, marker50Y),
      markerPaint,
    );

    // Marqueur 100%
    final marker100X = center.dx + (radius - 10) * cos(0);
    final marker100Y = center.dy + (radius - 10) * sin(0);
    canvas.drawLine(
      Offset(center.dx + radius * cos(0), center.dy + radius * sin(0)),
      Offset(marker100X, marker100Y),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SemiCircularGaugePainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

/// Badge compact pour afficher un score dans une liste
class MatchScoreBadge extends StatelessWidget {
  final double score;
  final double size;

  const MatchScoreBadge({
    super.key,
    required this.score,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final gaugeTheme = Theme.of(context).gaugeThemeExt;
    final color = gaugeTheme.getColorForValue(score);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '${score.toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

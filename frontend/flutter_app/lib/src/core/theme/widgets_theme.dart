import 'package:flutter/material.dart';

/// Design System - Royal Indigo & Gold Theme
/// 
/// Couleurs principales:
/// - Royal Indigo: #1A1B3A (primary background)
/// - Gold: #D4A574 (accent, highlights)
/// - Deep Purple: #2D2E5A (card backgrounds)
/// - Success Green: #4CAF50 (high match scores)
/// - Warning Orange: #FF9800 (medium match scores)
/// - Danger Red: #F44336 (low match scores)

class AppColors {
  // Primary Palette
  static const Color royalIndigo = Color(0xFF1A1B3A);
  static const Color royalIndigoLight = Color(0xFF2D2E5A);
  static const Color royalIndigoDark = Color(0xFF0F0F25);
  
  // Accent
  static const Color gold = Color(0xFFD4A574);
  static const Color goldLight = Color(0xFFE8C9A0);
  static const Color goldDark = Color(0xFFB8935F);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Profile Axis Colors
  static const Color aggressivity = Color(0xFFE53935); // Red
  static const Color patience = Color(0xFF1E88E5);     // Blue
  static const Color analysis = Color(0xFF43A047);     // Green
  static const Color bluff = Color(0xFF8E24AA);        // Purple
  
  // Neutral
  static const Color surface = Color(0xFF25264A);
  static const Color surfaceVariant = Color(0xFF323366);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFB0B0C0);
}

/// Theme Extensions for custom widget theming
@immutable
class CardThemeExtension extends ThemeExtension<CardThemeExtension> {
  final BorderRadius borderRadius;
  final double elevation;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const CardThemeExtension({
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.elevation = 4,
    this.backgroundColor = AppColors.royalIndigoLight,
    this.borderColor = AppColors.gold,
    this.borderWidth = 1,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  });

  @override
  CardThemeExtension copyWith({
    BorderRadius? borderRadius,
    double? elevation,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return CardThemeExtension(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }

  @override
  CardThemeExtension lerp(CardThemeExtension? other, double t) {
    if (other is! CardThemeExtension) return this;
    return CardThemeExtension(
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      margin: EdgeInsets.lerp(margin, other.margin, t)!,
    );
  }
}

@immutable
class ButtonThemeExtension extends ThemeExtension<ButtonThemeExtension> {
  final BorderRadius borderRadius;
  final double elevation;
  final EdgeInsets padding;
  final double height;
  final TextStyle textStyle;

  const ButtonThemeExtension({
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.elevation = 2,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.height = 48,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  });

  @override
  ButtonThemeExtension copyWith({
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsets? padding,
    double? height,
    TextStyle? textStyle,
  }) {
    return ButtonThemeExtension(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
      height: height ?? this.height,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  ButtonThemeExtension lerp(ButtonThemeExtension? other, double t) {
    if (other is! ButtonThemeExtension) return this;
    return ButtonThemeExtension(
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      elevation: lerpDouble(elevation, other.elevation, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      height: lerpDouble(height, other.height, t)!,
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
    );
  }
}

@immutable
class GaugeThemeExtension extends ThemeExtension<GaugeThemeExtension> {
  final double strokeWidth;
  final double size;
  final Color lowColor;
  final Color mediumColor;
  final Color highColor;
  final Color backgroundColor;
  final TextStyle valueStyle;
  final TextStyle labelStyle;

  const GaugeThemeExtension({
    this.strokeWidth = 12,
    this.size = 120,
    this.lowColor = AppColors.danger,
    this.mediumColor = AppColors.warning,
    this.highColor = AppColors.success,
    this.backgroundColor = AppColors.surfaceVariant,
    this.valueStyle = const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.gold,
    ),
    this.labelStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
    ),
  });

  @override
  GaugeThemeExtension copyWith({
    double? strokeWidth,
    double? size,
    Color? lowColor,
    Color? mediumColor,
    Color? highColor,
    Color? backgroundColor,
    TextStyle? valueStyle,
    TextStyle? labelStyle,
  }) {
    return GaugeThemeExtension(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      size: size ?? this.size,
      lowColor: lowColor ?? this.lowColor,
      mediumColor: mediumColor ?? this.mediumColor,
      highColor: highColor ?? this.highColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      valueStyle: valueStyle ?? this.valueStyle,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  GaugeThemeExtension lerp(GaugeThemeExtension? other, double t) {
    if (other is! GaugeThemeExtension) return this;
    return GaugeThemeExtension(
      strokeWidth: lerpDouble(strokeWidth, other.strokeWidth, t)!,
      size: lerpDouble(size, other.size, t)!,
      lowColor: Color.lerp(lowColor, other.lowColor, t)!,
      mediumColor: Color.lerp(mediumColor, other.mediumColor, t)!,
      highColor: Color.lerp(highColor, other.highColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      valueStyle: TextStyle.lerp(valueStyle, other.valueStyle, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
    );
  }

  Color getColorForValue(double value) {
    if (value < 40) return lowColor;
    if (value < 70) return mediumColor;
    return highColor;
  }
}

@immutable
class StarRatingThemeExtension extends ThemeExtension<StarRatingThemeExtension> {
  final double starSize;
  final double starSpacing;
  final Color filledColor;
  final Color emptyColor;
  final Color hoverColor;

  const StarRatingThemeExtension({
    this.starSize = 24,
    this.starSpacing = 4,
    this.filledColor = AppColors.gold,
    this.emptyColor = AppColors.surfaceVariant,
    this.hoverColor = AppColors.goldLight,
  });

  @override
  StarRatingThemeExtension copyWith({
    double? starSize,
    double? starSpacing,
    Color? filledColor,
    Color? emptyColor,
    Color? hoverColor,
  }) {
    return StarRatingThemeExtension(
      starSize: starSize ?? this.starSize,
      starSpacing: starSpacing ?? this.starSpacing,
      filledColor: filledColor ?? this.filledColor,
      emptyColor: emptyColor ?? this.emptyColor,
      hoverColor: hoverColor ?? this.hoverColor,
    );
  }

  @override
  StarRatingThemeExtension lerp(StarRatingThemeExtension? other, double t) {
    if (other is! StarRatingThemeExtension) return this;
    return StarRatingThemeExtension(
      starSize: lerpDouble(starSize, other.starSize, t)!,
      starSpacing: lerpDouble(starSpacing, other.starSpacing, t)!,
      filledColor: Color.lerp(filledColor, other.filledColor, t)!,
      emptyColor: Color.lerp(emptyColor, other.emptyColor, t)!,
      hoverColor: Color.lerp(hoverColor, other.hoverColor, t)!,
    );
  }
}

/// Extension method to easily access custom themes
extension CustomThemeExtensions on ThemeData {
  CardThemeExtension get cardThemeExt =>
      extension<CardThemeExtension>() ?? const CardThemeExtension();

  ButtonThemeExtension get buttonThemeExt =>
      extension<ButtonThemeExtension>() ?? const ButtonThemeExtension();

  GaugeThemeExtension get gaugeThemeExt =>
      extension<GaugeThemeExtension>() ?? const GaugeThemeExtension();

  StarRatingThemeExtension get starRatingThemeExt =>
      extension<StarRatingThemeExtension>() ?? const StarRatingThemeExtension();
}

/// Helper to create complete theme with all extensions
ThemeData createProphetTheme() {
  final baseTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.royalIndigo,
      brightness: Brightness.dark,
      primary: AppColors.gold,
      secondary: AppColors.goldLight,
      surface: AppColors.royalIndigoLight,
      background: AppColors.royalIndigo,
    ),
    scaffoldBackgroundColor: AppColors.royalIndigo,
    cardTheme: CardTheme(
      color: AppColors.royalIndigoLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.gold, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.royalIndigoDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.gold, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.gold,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.onSurfaceVariant,
      ),
    ),
  );

  return baseTheme.copyWith(
    extensions: [
      const CardThemeExtension(),
      const ButtonThemeExtension(),
      const GaugeThemeExtension(),
      const StarRatingThemeExtension(),
    ],
  );
}

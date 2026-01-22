import 'dart:ui';
import 'package:flutter/material.dart';

/// Premium Admin Theme Constants
/// Design "Top das Galáxias" - Glassmorphic, Gradients, Premium Effects
class AdminTheme {
  AdminTheme._();

  // ==================== COLORS ====================

  /// Dark background colors
  static const Color bgDark = Color(0xFF0F0F1A);
  static const Color bgCard = Color(0xFF1A1A2E);
  static const Color bgCardLight = Color(0xFF252542);
  static const Color bgSurface = Color(0xFF16162A);
  static const Color bgCanvas = bgDark;

  /// Primary gradient (Indigo -> Violet)
  static const List<Color> gradientPrimary = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  /// Success gradient (Emerald)
  static const List<Color> gradientSuccess = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  /// Warning gradient (Amber)
  static const List<Color> gradientWarning = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];

  /// Danger gradient (Red)
  static const List<Color> gradientDanger = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];

  /// Info gradient (Cyan -> Blue)
  static const List<Color> gradientInfo = [
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
  ];

  /// Pink gradient
  static const List<Color> gradientPink = [
    Color(0xFFEC4899),
    Color(0xFFDB2777),
  ];

  /// Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);

  /// Border colors
  static const Color borderLight = Color(0x1AFFFFFF); // 10% white
  static const Color borderMedium = Color(0x33FFFFFF); // 20% white

  // ==================== GRADIENTS ====================

  /// Linear gradient for cards based on type
  static LinearGradient cardGradient(CardType type) {
    final colors = _getGradientColors(type);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colors[0].withOpacity(0.15), colors[1].withOpacity(0.05)],
    );
  }

  /// Icon gradient based on type
  static LinearGradient iconGradient(CardType type) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: _getGradientColors(type),
    );
  }

  static List<Color> _getGradientColors(CardType type) {
    switch (type) {
      case CardType.revenue:
        return gradientSuccess;
      case CardType.bookings:
        return gradientInfo;
      case CardType.average:
        return gradientPrimary;
      case CardType.rating:
        return gradientWarning;
      case CardType.danger:
        return gradientDanger;
      case CardType.neutral:
        return gradientPrimary;
    }
  }

  /// Background gradient for the entire dashboard
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
    stops: [0.0, 0.5, 1.0],
  );

  // ==================== SHADOWS ====================

  /// Glow shadow for cards
  static List<BoxShadow> glowShadow(Color color, {double intensity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// Subtle shadow for cards
  static List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ==================== DECORATIONS ====================

  /// Glassmorphic decoration for cards
  static BoxDecoration glassmorphicDecoration({
    double opacity = 0.8,
    double borderRadius = 20,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: bgCard.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderLight),
      boxShadow: glowColor != null
          ? glowShadow(glowColor, intensity: 0.2)
          : subtleShadow,
    );
  }

  /// Premium card decoration with gradient border
  static BoxDecoration premiumCardDecoration({
    required CardType type,
    double borderRadius = 20,
  }) {
    final colors = _getGradientColors(type);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bgCard, bgCard.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: colors[0].withOpacity(0.3), width: 1),
      boxShadow: glowShadow(colors[0], intensity: 0.15),
    );
  }

  // ==================== BLUR ====================

  /// Standard blur for glassmorphic effect
  static ImageFilter get standardBlur =>
      ImageFilter.blur(sigmaX: 10, sigmaY: 10);

  /// Heavy blur for modals
  static ImageFilter get heavyBlur => ImageFilter.blur(sigmaX: 20, sigmaY: 20);

  // ==================== TEXT STYLES ====================

  static const TextStyle headingLarge = TextStyle(
    color: textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    color: textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingSmall = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  static const TextStyle bodySmall = TextStyle(
    color: textSecondary,
    fontSize: 12,
  );

  static const TextStyle labelSmall = TextStyle(
    color: textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle statValue = TextStyle(
    color: textPrimary,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // ==================== SPACING ====================

  static const double paddingXS = 4;
  static const double paddingSM = 8;
  static const double paddingMD = 16;
  static const double paddingLG = 24;
  static const double paddingXL = 32;

  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;

  // ==================== INPUT DECORATION ====================

  static InputDecoration inputDecoration({required String label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: bgCard,
      labelStyle: const TextStyle(color: textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(color: borderMedium),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSM),
        borderSide: const BorderSide(
          color: Colors.white,
        ), // Using white directly as primary-ish
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSM)),
    );
  }
}

/// Card type enum for styling
enum CardType { revenue, bookings, average, rating, danger, neutral }

/// Extension to get greeting based on time
extension TimeGreeting on DateTime {
  String get greeting {
    final hour = this.hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  IconData get greetingIcon {
    final hour = this.hour;
    if (hour < 6) return Icons.bedtime_rounded;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 18) return Icons.wb_cloudy_rounded;
    return Icons.nightlight_round;
  }
}

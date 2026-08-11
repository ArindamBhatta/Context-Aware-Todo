// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'color_palette/brand_blues.dart';

class AppTheme {
  // Private constants
  static const double _defaultBorderRadius = 8.0;
  // static const double _largeBorderRadius = 16.0;
  static const double _buttonHeight = 58.0;

  /// Responsive breakpoints
  static const double breakpointNarrow = 300.0;
  static const double breakpointMedium = 600.0;
  static const double breakpointWide = 900.0;

  /// Info card dimensions
  static const double cardMinWidth =
      160.0; // Minimum target width for each card
  static const double cardHeight = 80.0;
  static const double vehicleImageSize = 100.0;
  static const double progressBarHeight = 6.0;

  /// Default spacing values for consistent padding/margin
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 40.0;

  /// Border radius values for consistent styling
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 16.0;

  /// Shadow presets for elevation
  static final List<BoxShadow> lightShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  /// Card shape for consistent styling
  static RoundedRectangleBorder get cardShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(borderRadiusM),
  );

  /// Standard padding presets
  static EdgeInsets get paddingAll => EdgeInsets.all(spacingM);
  static EdgeInsets get paddingHorizontal =>
      EdgeInsets.symmetric(horizontal: spacingM);
  static EdgeInsets get paddingVertical =>
      EdgeInsets.symmetric(vertical: spacingM);
  static EdgeInsets get paddingLarge => EdgeInsets.all(spacingL);
  static EdgeInsets get paddingForm =>
      EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingS);

  /// Content padding for sections
  static EdgeInsets get contentPadding =>
      EdgeInsets.symmetric(horizontal: spacingM, vertical: spacingM);

  /// Vehicle details theming
  static BoxDecoration infoCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(borderRadiusM),
      boxShadow: lightShadow,
    );
  }

  static TextStyle sectionHeaderStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onBackground,
    );
  }

  static Color sectionIconColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF00E5FF)
          : const Color(0xFF00E5FF);

  static Color progressBarColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF00E5FF)
          : const Color(0xFF00E5FF);

  /// Progress section
  static TextStyle progressItemStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle progressLabelStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }

  /// Card styling for info sections
  static TextStyle infoCardLabelStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    );
  }

  static TextStyle infoCardValueStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// Helper method to calculate optimal columns based on width
  static int getOptimalColumns(double availableWidth) {
    return max(1, (availableWidth / cardMinWidth).floor());
  }

  /// Grid delegate for consistent info card grids
  static SliverGridDelegateWithFixedCrossAxisCount infoGridDelegate(
    int columns,
  ) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: 3.0,
      crossAxisSpacing: spacingM,
      mainAxisSpacing: spacingM,
      mainAxisExtent: cardHeight,
    );
  }

  /// Get light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _getLightColorScheme(),
      textTheme: _getTextTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      // cardTheme: _cardTheme(),
      appBarTheme: _appBarTheme(),
      dividerTheme: _dividerTheme(),
      iconTheme: _iconTheme(),
      chipTheme: _chipTheme(),
      extensions: [
        CustomComponentsTheme(
          statusBadgeStyle: StatusBadgeStyle(
            borderRadius: _defaultBorderRadius / 2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// Get dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _getDarkColorScheme(),
      textTheme: _getTextTheme(isDark: true),
      elevatedButtonTheme: _elevatedButtonTheme(isDark: true),
      outlinedButtonTheme: _outlinedButtonTheme(isDark: true),
      textButtonTheme: _textButtonTheme(isDark: true),
      inputDecorationTheme: _inputDecorationTheme(isDark: true),
      // cardTheme: _cardTheme(isDark: true),
      appBarTheme: _appBarTheme(isDark: true),
      dividerTheme: _dividerTheme(isDark: true),
      iconTheme: _iconTheme(isDark: true),
      chipTheme: _chipTheme(isDark: true),
      extensions: [
        CustomComponentsTheme(
          statusBadgeStyle: StatusBadgeStyle(
            borderRadius: _defaultBorderRadius / 2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            textStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Private helper methods for theme components

  static ColorScheme _getLightColorScheme() {
    return BrandBlues.lightColorScheme;
  }

  static ColorScheme _getDarkColorScheme() {
    return BrandBlues.darkColorScheme;
  }

  static TextTheme _getTextTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    final Color mainTextColor = isDark ? Colors.white : colorScheme.onSurface;
    final Color secondaryTextColor =
        isDark ? Colors.white70 : colorScheme.onSurface.withOpacity(0.7);

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: mainTextColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: mainTextColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: mainTextColor,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: mainTextColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: mainTextColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: mainTextColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: mainTextColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: mainTextColor,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: mainTextColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: mainTextColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: mainTextColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: mainTextColor,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mainTextColor,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: Size(double.infinity, _buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
        ),
        elevation: 4,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    final Color borderColor = isDark ? Colors.white70 : colorScheme.primary;

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : colorScheme.primary,
        minimumSize: Size(double.infinity, _buttonHeight),
        side: BorderSide(color: borderColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultBorderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: isDark ? Colors.white : colorScheme.primary,
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    final Color borderColor = isDark ? Colors.white54 : colorScheme.outline;
    final Color fillColor = isDark ? Colors.black12 : colorScheme.surface;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingL,
        vertical: spacingL,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      hintStyle: GoogleFonts.poppins(
        color: isDark ? Colors.white54 : colorScheme.onSurface.withOpacity(0.5),
        fontSize: 16,
      ),
      labelStyle: GoogleFonts.poppins(
        color: isDark ? Colors.white70 : colorScheme.onSurface.withOpacity(0.7),
        fontSize: 16,
      ),
    );
  }

  static AppBarTheme _appBarTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    return AppBarTheme(
      backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: colorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
    );
  }

  static DividerThemeData _dividerTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    return DividerThemeData(
      color: isDark ? Colors.white24 : colorScheme.outlineVariant,
      thickness: 1,
      space: spacingM,
    );
  }

  static IconThemeData _iconTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    return IconThemeData(
      color: isDark ? Colors.white : colorScheme.onSurface,
      size: 24,
    );
  }

  static ChipThemeData _chipTheme({bool isDark = false}) {
    final ColorScheme colorScheme =
        isDark ? BrandBlues.darkColorScheme : BrandBlues.lightColorScheme;
    return ChipThemeData(
      backgroundColor: isDark ? Colors.white12 : colorScheme.surfaceContainerLow,
      disabledColor: isDark ? Colors.white10 : colorScheme.surfaceContainerHighest,
      selectedColor: colorScheme.primary.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
      ),
      labelStyle: GoogleFonts.poppins(
        color: isDark ? Colors.white : colorScheme.onSurface,
        fontSize: 14,
      ),
    );
  }

  // Shadow helpers
  static List<BoxShadow> get defaultShadow => [
    BoxShadow(
      color: BrandBlues.lightColorScheme.shadow.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: BrandBlues.lightColorScheme.shadow.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 2,
    ),
  ];
}

/// Custom theme extension for components not covered by Material
class CustomComponentsTheme extends ThemeExtension<CustomComponentsTheme> {
  final StatusBadgeStyle statusBadgeStyle;

  CustomComponentsTheme({required this.statusBadgeStyle});

  @override
  ThemeExtension<CustomComponentsTheme> copyWith({
    StatusBadgeStyle? statusBadgeStyle,
  }) {
    return CustomComponentsTheme(
      statusBadgeStyle: statusBadgeStyle ?? this.statusBadgeStyle,
    );
  }

  @override
  ThemeExtension<CustomComponentsTheme> lerp(
    ThemeExtension<CustomComponentsTheme>? other,
    double t,
  ) {
    if (other is! CustomComponentsTheme) {
      return this;
    }

    return CustomComponentsTheme(
      statusBadgeStyle: StatusBadgeStyle.lerp(
        statusBadgeStyle,
        other.statusBadgeStyle,
        t,
      ),
    );
  }
}

/// Style for status badges
class StatusBadgeStyle {
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle textStyle;

  const StatusBadgeStyle({
    required this.borderRadius,
    required this.padding,
    required this.textStyle,
  });

  static StatusBadgeStyle lerp(
    StatusBadgeStyle a,
    StatusBadgeStyle b,
    double t,
  ) {
    return StatusBadgeStyle(
      borderRadius: lerpDouble(a.borderRadius, b.borderRadius, t),
      padding: EdgeInsets.lerp(a.padding, b.padding, t)!,
      textStyle: TextStyle.lerp(a.textStyle, b.textStyle, t)!,
    );
  }
}

/// Helper method for lerping doubles
double lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}

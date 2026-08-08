import 'package:flutter/material.dart';

class AppColorSchemes {
  static const ColorScheme light = ColorScheme.light(
    primary: Color(0xFF4F46E5), // Indigo 600
    onPrimary: Colors.white,
    secondary: Color(0xFF8B5CF6), // Purple 500
    onSecondary: Colors.white,
    tertiary: Color(0xFF3B82F6), // Blue 500
    onTertiary: Colors.white,
    surfaceBright: Color(0xFFF8FAFC), // Slate 50
    surface: Colors.white,
    onSurface: Color(0xFF0F172A), // Slate 900
    surfaceContainerHighest: Color(0xFFEEF2F6), // Slate 100
    onSurfaceVariant: Color(0xFF64748B), // Slate 500
    error: Color(0xFFEF4444), // Red 500
  );

  static const ColorScheme dark = ColorScheme.dark(
    primary: Color(0xFF6366F1), // Indigo 500
    onPrimary: Colors.white,
    secondary: Color(0xFFA78BFA), // Purple 400
    onSecondary: Colors.black,
    tertiary: Color(0xFF60A5FA), // Blue 400
    onTertiary: Colors.black,
    surfaceBright: Color(0xFF1E293B), // Slate 800
    surface: Color(0xFF0F172A), // Slate 900
    onSurface: Colors.white,
    surfaceContainerHighest: Color(0xFF334155), // Slate 700
    onSurfaceVariant: Color(0xFF94A3B8), // Slate 400
    error: Color(0xFFF87171), // Red 400
  );
}

import 'package:flutter/material.dart';

/// Central color palette (pale theme) used across the app.
class Palette {
  // Pale background / surface
  static const Color background = Color(0xFFF7F6FF);
  static const Color surface = Color(0xFFEFEAFF);

  // Primary (soft blue)
  static const Color primary = Color(0xFF2B7BE9);
  static const Color primaryDark = Color(0xFF1663B8);

  // Blue tones (for time/clock UI)
  static const Color blue = Color(0xFF2B7BE9);
  static const Color clockBackground = Color(0xFFEAF6FF);
  // Dark pink for time highlight (optional)
  static const Color darkPink = Color(0xFFB0005A);
  // Pale pink background for clock column
  static const Color clockPinkBackground = Color(0xFFFBEAF1);
  // Payment / dark card color used in payment offer
  static const Color paymentCard = Color(0xFF012D5A);

  // Premium screen background (used for premium UI and map sheet)
  static const Color premiumBackground = Color(0xFF001F3F);

  // Accent (use same orange as navbar)
  static const Color accent = Colors.orangeAccent;

  // Text / icon on primary
  static const Color onPrimary = Color(0xFF1F1B2E);

  // Muted text on dark surfaces
  static const Color mutedOnDark = Color(0xFFBDB8D9);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Big display text: game title, "COLLISION"/game-over headline, tier names
  static TextStyle displayTitle({Color color = Colors.white, double fontSize = 40}) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 4.0,
      color: color,
    );
  }

  // Large numbers: score during gameplay, final score, high score value
  static TextStyle scoreNumber({Color color = Colors.white, double fontSize = 56}) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.0,
      color: color,
    );
  }

  // Small all-caps tracked labels: "SCORE", "BEST", "TIER 1", "GAME OVER" subtitle
  static TextStyle label({Color color = Colors.white70, double fontSize = 13}) {
    return GoogleFonts.rajdhani(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.5,
      color: color,
    );
  }

  // Buttons: "TRY AGAIN", "TAP TO START", "SHARE SCORE"
  static TextStyle button({Color color = Colors.black, double fontSize = 16}) {
    return GoogleFonts.rajdhani(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: color,
    );
  }

  // Body/readable text: achievement descriptions, settings labels, leaderboard entries
  static TextStyle body({Color color = Colors.white70, double fontSize = 14}) {
    return GoogleFonts.rajdhani(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      color: color,
    );
  }
}

class GamePalette {
  final int tier;
  final String name;
  final List<Color> background;
  final List<Color> gateGradient;
  final Color orbColor;
  final Color orbGlow;
  final Color accent;
  final List<Color> particleColors;

  const GamePalette({
    required this.tier,
    required this.name,
    required this.background,
    required this.gateGradient,
    required this.orbColor,
    required this.orbGlow,
    required this.accent,
    required this.particleColors,
  });

  static const List<GamePalette> palettes = [
    // Tier 1: Vortex (Deep Violet -> Cyan)
    GamePalette(
      tier: 1,
      name: 'Vortex',
      background: [Color(0xFF0F0C1B), Color(0xFF201335)],
      gateGradient: [Color(0xFF8A2387), Color(0xFFE94057)],
      orbColor: Color(0xFF00FFFF),
      orbGlow: Color(0x8000FFFF),
      accent: Color(0xFF00FFFF),
      particleColors: [Color(0xFF00FFFF), Color(0xFF00BCFF), Color(0xFFE94057)],
    ),
    // Tier 2: Nebula (Midnight Blue -> Indigo)
    GamePalette(
      tier: 2,
      name: 'Nebula',
      background: [Color(0xFF020024), Color(0xFF090979)],
      gateGradient: [Color(0xFF00d4ff), Color(0xFF097991)],
      orbColor: Color(0xFFFF007F),
      orbGlow: Color(0x80FF007F),
      accent: Color(0xFFFF007F),
      particleColors: [Color(0xFFFF007F), Color(0xFFFF52AF), Color(0xFF00d4ff)],
    ),
    // Tier 3: Sunset (Sunset Orange -> Pink)
    GamePalette(
      tier: 3,
      name: 'Sunset',
      background: [Color(0xFF2D0B22), Color(0xFF530B1C)],
      gateGradient: [Color(0xFFF27121), Color(0xFFE94057)],
      orbColor: Color(0xFFFFE066),
      orbGlow: Color(0x80FFE066),
      accent: Color(0xFFFFE066),
      particleColors: [Color(0xFFFFE066), Color(0xFFF27121), Color(0xFFE94057)],
    ),
    // Tier 4: Emerald (Emerald -> Teal)
    GamePalette(
      tier: 4,
      name: 'Emerald',
      background: [Color(0xFF051B11), Color(0xFF0A3321)],
      gateGradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
      orbColor: Color(0xFFE0FFFF),
      orbGlow: Color(0x80E0FFFF),
      accent: Color(0xFF38EF7D),
      particleColors: [Color(0xFF38EF7D), Color(0xFF11998E), Color(0xFFE0FFFF)],
    ),
    // Tier 5: Antigravity (Noir -> Electric Crimson)
    GamePalette(
      tier: 5,
      name: 'Antigravity',
      background: [Color(0xFF000000), Color(0xFF1A0008)],
      gateGradient: [Color(0xFF7F0000), Color(0xFFFF1A1A)],
      orbColor: Color(0xFFFFFFFF),
      orbGlow: Color(0x99FFFFFF),
      accent: Color(0xFFFF1A1A),
      particleColors: [Color(0xFFFFFFFF), Color(0xFFFF1A1A), Color(0xFF7F0000)],
    ),
  ];

  static GamePalette getPaletteForScore(int score) {
    if (score < 10) return palettes[0];
    if (score < 20) return palettes[1];
    if (score < 35) return palettes[2];
    if (score < 50) return palettes[3];
    return palettes[4];
  }

  static ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0C1B),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FFFF),
        secondary: Color(0xFFE94057),
        surface: Color(0xFF201335),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.white70,
        ),
      ),
    );
  }
}

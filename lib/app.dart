import 'package:flutter/material.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/screens/game_screen.dart';

class DriftApp extends StatelessWidget {
  const DriftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drift',
      debugShowCheckedModeBanner: false,
      theme: GamePalette.getThemeData(),
      home: const GameScreen(),
    );
  }
}

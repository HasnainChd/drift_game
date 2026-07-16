import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final highScoreProvider = StateNotifierProvider<HighScoreNotifier, int>((ref) {
  return HighScoreNotifier();
});

class HighScoreNotifier extends StateNotifier<int> {
  HighScoreNotifier() : super(0) {
    _loadHighScore();
  }

  static const String _key = 'drift_high_score';

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getInt(_key) ?? 0;
    } catch (_) {
      // Fallback if preferences fail
    }
  }

  Future<void> updateHighScore(int newScore) async {
    if (newScore > state) {
      state = newScore;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_key, newScore);
      } catch (_) {
        // Ignored
      }
    }
  }
}

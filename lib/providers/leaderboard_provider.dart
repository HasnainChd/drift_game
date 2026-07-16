import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift_game/models/score_entry.dart';

class LeaderboardNotifier extends StateNotifier<List<ScoreEntry>> {
  static const String _key = 'leaderboard_v1';

  LeaderboardNotifier() : super([]) {
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_key);
      if (str != null) {
        final list = jsonDecode(str) as List<dynamic>;
        state = list.map((e) => ScoreEntry.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
  }

  Future<void> addScore(int score) async {
    final entry = ScoreEntry(
      score: score,
      timestamp: DateTime.now().toIso8601String(),
    );
    final updatedList = List<ScoreEntry>.from(state)..add(entry);
    // Sort descending by score
    updatedList.sort((a, b) => b.score.compareTo(a.score));
    // Keep top 5
    if (updatedList.length > 5) {
      updatedList.removeRange(5, updatedList.length);
    }
    state = updatedList;
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_key, str);
    } catch (_) {}
  }
}

final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, List<ScoreEntry>>((ref) {
  return LeaderboardNotifier();
});

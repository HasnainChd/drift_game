import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift_game/models/achievement.dart';

class AchievementsNotifier extends StateNotifier<List<Achievement>> {
  static const String _key = 'achievements_v1';

  static final List<Achievement> _defaultAchievements = [
    Achievement(id: 'first_flight', title: 'First Flight', description: 'Pass your first gate', isUnlocked: false),
    Achievement(id: 'hang_of_it', title: 'Getting the Hang of It', description: 'Score 10 points', isUnlocked: false),
    Achievement(id: 'master', title: 'Vortex Master', description: 'Score 25 points', isUnlocked: false),
    Achievement(id: 'legend', title: 'Halfway to Legend', description: 'Score 50 points', isUnlocked: false),
    Achievement(id: 'survivor', title: 'Survivor', description: 'Survive 30 seconds in a single run', isUnlocked: false),
    Achievement(id: 'century', title: 'Century', description: 'Score 100 points', isUnlocked: false),
  ];

  AchievementsNotifier() : super(_defaultAchievements) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_key);
      if (str != null) {
        final list = jsonDecode(str) as List<dynamic>;
        state = list.map((e) => Achievement.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
  }

  Future<List<String>> checkUnlocks({required int score, required double survivalTime}) async {
    final List<String> newlyUnlocked = [];
    final updated = state.map((achievement) {
      if (achievement.isUnlocked) return achievement;

      bool shouldUnlock = false;
      if (achievement.id == 'first_flight' && score >= 1) {
        shouldUnlock = true;
      } else if (achievement.id == 'hang_of_it' && score >= 10) {
        shouldUnlock = true;
      } else if (achievement.id == 'master' && score >= 25) {
        shouldUnlock = true;
      } else if (achievement.id == 'legend' && score >= 50) {
        shouldUnlock = true;
      } else if (achievement.id == 'survivor' && survivalTime >= 30.0) {
        shouldUnlock = true;
      } else if (achievement.id == 'century' && score >= 100) {
        shouldUnlock = true;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(achievement.title);
        return achievement.copyWith(isUnlocked: true);
      }
      return achievement;
    }).toList();

    if (newlyUnlocked.isNotEmpty) {
      state = updated;
      await _save();
    }
    return newlyUnlocked;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_key, str);
    } catch (_) {}
  }
}

final achievementsProvider = StateNotifierProvider<AchievementsNotifier, List<Achievement>>((ref) {
  return AchievementsNotifier();
});

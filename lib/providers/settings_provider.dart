import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool hasPlayedBefore;

  SettingsState({
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.hasPlayedBefore,
  });

  SettingsState copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? hasPlayedBefore,
  }) {
    return SettingsState(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      hasPlayedBefore: hasPlayedBefore ?? this.hasPlayedBefore,
    );
  }

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'hasPlayedBefore': hasPlayedBefore,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) => SettingsState(
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        hasPlayedBefore: json['hasPlayedBefore'] as bool? ?? false,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const String _key = 'settings_v1';

  SettingsNotifier() : super(SettingsState(soundEnabled: true, hapticsEnabled: true, hasPlayedBefore: false)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_key);
      if (str != null) {
        state = SettingsState.fromJson(jsonDecode(str) as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  Future<void> setSoundEnabled(bool val) async {
    state = state.copyWith(soundEnabled: val);
    await _save();
  }

  Future<void> setHapticsEnabled(bool val) async {
    state = state.copyWith(hapticsEnabled: val);
    await _save();
  }

  Future<void> setHasPlayedBefore(bool val) async {
    state = state.copyWith(hasPlayedBefore: val);
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(state.toJson()));
    } catch (_) {}
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

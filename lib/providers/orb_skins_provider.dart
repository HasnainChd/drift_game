import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift_game/models/orb_skin.dart';

class OrbSkinsState {
  final List<OrbSkin> skins;
  final String selectedSkinId;

  OrbSkinsState({
    required this.skins,
    required this.selectedSkinId,
  });

  OrbSkin get selectedSkin {
    return skins.firstWhere((s) => s.id == selectedSkinId, orElse: () => skins.first);
  }

  OrbSkinsState copyWith({
    List<OrbSkin>? skins,
    String? selectedSkinId,
  }) {
    return OrbSkinsState(
      skins: skins ?? this.skins,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
    );
  }

  Map<String, dynamic> toJson() => {
        'skins': skins.map((s) => s.toJson()).toList(),
        'selectedSkinId': selectedSkinId,
      };

  factory OrbSkinsState.fromJson(Map<String, dynamic> json) {
    final list = json['skins'] as List<dynamic>;
    return OrbSkinsState(
      skins: list.map((e) => OrbSkin.fromJson(e as Map<String, dynamic>)).toList(),
      selectedSkinId: json['selectedSkinId'] as String,
    );
  }
}

class OrbSkinsNotifier extends StateNotifier<OrbSkinsState> {
  static const String _key = 'orb_skins_v1';

  static final List<OrbSkin> _defaultSkins = [
    OrbSkin(id: 'default', name: 'Vortex', unlockScoreThreshold: 0, primaryColorValue: 0xFF00FFFF, glowColorValue: 0x8000FFFF, isUnlocked: true),
    OrbSkin(id: 'ember', name: 'Ember', unlockScoreThreshold: 10, primaryColorValue: 0xFFF27121, glowColorValue: 0x80E94057, isUnlocked: false),
    OrbSkin(id: 'emerald', name: 'Emerald', unlockScoreThreshold: 25, primaryColorValue: 0xFF38EF7D, glowColorValue: 0x8011998E, isUnlocked: false),
    OrbSkin(id: 'midnight', name: 'Midnight', unlockScoreThreshold: 50, primaryColorValue: 0xFF00D4FF, glowColorValue: 0x80090979, isUnlocked: false),
    OrbSkin(id: 'solar', name: 'Solar', unlockScoreThreshold: 100, primaryColorValue: 0xFFFFD700, glowColorValue: 0x80FFFFFF, isUnlocked: false),
  ];

  OrbSkinsNotifier() : super(OrbSkinsState(skins: _defaultSkins, selectedSkinId: 'default')) {
    _loadSkins();
  }

  Future<void> _loadSkins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_key);
      if (str != null) {
        state = OrbSkinsState.fromJson(jsonDecode(str) as Map<String, dynamic>);
      }
    } catch (_) {}
  }

  Future<void> selectSkin(String id) async {
    final skin = state.skins.firstWhere((s) => s.id == id, orElse: () => state.skins.first);
    if (skin.isUnlocked) {
      state = state.copyWith(selectedSkinId: id);
      await _save();
    }
  }

  Future<List<String>> checkUnlocks(int score) async {
    final List<String> newlyUnlocked = [];
    final updatedSkins = state.skins.map((skin) {
      if (!skin.isUnlocked && score >= skin.unlockScoreThreshold) {
        newlyUnlocked.add(skin.name);
        return skin.copyWith(isUnlocked: true);
      }
      return skin;
    }).toList();

    if (newlyUnlocked.isNotEmpty) {
      state = state.copyWith(skins: updatedSkins);
      await _save();
    }
    return newlyUnlocked;
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(state.toJson()));
    } catch (_) {}
  }
}

final orbSkinsProvider = StateNotifierProvider<OrbSkinsNotifier, OrbSkinsState>((ref) {
  return OrbSkinsNotifier();
});

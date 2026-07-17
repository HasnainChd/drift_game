import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/providers/settings_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final palette = GamePalette.getPaletteForScore(0);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF140F26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SYSTEM CONTROLS',
                  style: AppTextStyles.displayTitle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  // Sound Toggle
                  SwitchListTile(
                    title: Text(
                      'SOUND EFFECTS',
                      style: AppTextStyles.button(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Atmospheric game audio feedback',
                      style: AppTextStyles.body(
                        fontSize: 11.0,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    value: settings.soundEnabled,
                    activeColor: palette.orbColor,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setSoundEnabled(val);
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  // Haptics Toggle
                  SwitchListTile(
                    title: Text(
                      'HAPTIC ENGINE',
                      style: AppTextStyles.button(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Tactile impact bumps on jump & shatter',
                      style: AppTextStyles.body(
                        fontSize: 11.0,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    value: settings.hapticsEnabled,
                    activeColor: palette.orbColor,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).setHapticsEnabled(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/models/achievement.dart';
import 'package:drift_game/providers/achievements_provider.dart';

class AchievementsSheet extends ConsumerWidget {
  const AchievementsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementsProvider);
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
                  'ACHIEVEMENTS',
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: achievements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12.0),
              itemBuilder: (context, index) {
                final Achievement ach = achievements[index];

                return Container(
                  decoration: BoxDecoration(
                    color: ach.isUnlocked
                        ? palette.orbColor.withOpacity(0.04)
                        : Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: ach.isUnlocked
                          ? palette.orbColor.withOpacity(0.2)
                          : Colors.white.withOpacity(0.06),
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Row(
                    children: [
                      Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ach.isUnlocked
                              ? palette.orbColor.withOpacity(0.15)
                              : Colors.white10,
                        ),
                        child: Icon(
                          ach.isUnlocked ? Icons.emoji_events : Icons.lock,
                          color: ach.isUnlocked ? palette.orbColor : Colors.white30,
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ach.title,
                              style: AppTextStyles.body(
                                fontSize: 14.0,
                                color: ach.isUnlocked ? Colors.white : Colors.white54,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              ach.description,
                              style: AppTextStyles.body(
                                fontSize: 11.0,
                                color: ach.isUnlocked ? Colors.white70 : Colors.white38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (ach.isUnlocked)
                        Icon(
                          Icons.check_circle,
                          color: palette.orbColor,
                          size: 20.0,
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_game/core/constants.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/providers/game_controller.dart';

class ScoreHud extends ConsumerWidget {
  const ScoreHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final tier = GameConstants.getTier(gameState.score);
    final palette = GamePalette.getPaletteForScore(gameState.score);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Score Display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SCORE',
                  style: AppTextStyles.label(
                    fontSize: 10.0,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                Text(
                  '${gameState.score}',
                  style: AppTextStyles.scoreNumber(
                    fontSize: 48.0,
                    color: Colors.white,
                  ).copyWith(height: 1.1),
                ),
              ],
            ),

            // Tier Status (e.g., "T3 / Nebula")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TIER ${tier.tier}',
                    style: AppTextStyles.label(
                      fontSize: 9.0,
                      color: palette.orbColor,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    tier.name.toUpperCase(),
                    style: AppTextStyles.label(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

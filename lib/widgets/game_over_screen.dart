import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/providers/game_controller.dart';
import 'package:drift_game/providers/high_score_provider.dart';

class GameOverScreen extends ConsumerWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);
    final highScore = ref.watch(highScoreProvider);
    final isNewRecord = gameState.score >= highScore && gameState.score > 0;
    final palette = GamePalette.getPaletteForScore(gameState.score);

    return Container(
      color: Colors.black.withOpacity(0.6), // Dark overlay over the blurred canvas
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Game Over Text
            Text(
              'COLLISION',
              style: AppTextStyles.displayTitle(
                fontSize: 42.0,
                color: const Color(0xFFFF3366),
              ),
            )
                .animate()
                .fade(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),

            const SizedBox(height: 8.0),

            Text(
              'GAME OVER',
              style: AppTextStyles.label(
                fontSize: 14.0,
                color: Colors.white.withOpacity(0.5),
              ),
            )
                .animate()
                .fade(delay: 200.ms, duration: 400.ms),

            const Spacer(flex: 2),

            // Scoreboard Container
            Container(
              width: 280,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  // New Record Badge
                  if (isNewRecord) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: palette.orbColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'NEW RECORD',
                        style: AppTextStyles.label(
                          fontSize: 9.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        ..scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.1, 1.1),
                          duration: 500.ms,
                        )
                        .then()
                        .shake(duration: 300.ms),
                    const SizedBox(height: 12.0),
                  ],

                  // Final Score
                  Text(
                    'SCORE',
                    style: AppTextStyles.label(
                      fontSize: 12.0,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    '${gameState.score}',
                    style: AppTextStyles.scoreNumber(
                      fontSize: 64.0,
                      color: isNewRecord ? palette.orbColor : Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12.0),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8.0),

                  // High Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BEST',
                        style: AppTextStyles.label(
                          fontSize: 12.0,
                          color: Colors.white38,
                        ),
                      ),
                      Text(
                        '$highScore',
                        style: AppTextStyles.scoreNumber(
                          fontSize: 18.0,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),
                  
                  // Share Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.06),
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      Share.share('I scored ${gameState.score} on Drift! Can you beat it?');
                    },
                    icon: const Icon(Icons.share, size: 16.0),
                    label: Text(
                      'SHARE SCORE',
                      style: AppTextStyles.button(
                        fontSize: 11.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fade(delay: 350.ms, duration: 600.ms)
                .slideY(begin: 0.1, end: 0.0),

            const Spacer(flex: 3),

            // Tap to Retry Button
            GestureDetector(
              onTap: () {
                ref.read(gameControllerProvider.notifier).startGame();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 18.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 15.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'TRY AGAIN',
                  style: AppTextStyles.button(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.04, 1.04),
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 20.0),

            // Back to Menu button
            TextButton(
              onPressed: () {
                ref.read(gameControllerProvider.notifier).resetToMenu();
              },
              child: Text(
                'BACK TO MENU',
                style: AppTextStyles.button(
                  fontSize: 12.0,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            )
                .animate()
                .fade(delay: 600.ms, duration: 400.ms),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

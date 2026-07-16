import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/providers/game_controller.dart';
import 'package:drift_game/providers/high_score_provider.dart';
import 'package:drift_game/providers/settings_provider.dart';
import 'package:drift_game/widgets/skins_sheet.dart';
import 'package:drift_game/widgets/achievements_sheet.dart';
import 'package:drift_game/widgets/leaderboard_sheet.dart';
import 'package:drift_game/widgets/settings_sheet.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  Widget _buildMenuIconButton(
      BuildContext context, IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20.0),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  void _showSkinsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SkinsSheet(),
    );
  }

  void _showAchievementsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AchievementsSheet(),
    );
  }

  void _showLeaderboardSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LeaderboardSheet(),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highScore = ref.watch(highScoreProvider);
    final settings = ref.watch(settingsProvider);
    final palette = GamePalette.getPaletteForScore(0); // Vortex tier colors for menu

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),

          // Game Title with glow and gradient text
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [palette.orbColor, palette.gateGradient[1]],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'DRIFT',
              style: TextStyle(
                fontSize: 82.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
                color: Colors.white,
              ),
            ),
          )
              .animate()
              .fade(duration: 800.ms)
              .slideY(begin: -0.3, end: 0.0, curve: Curves.easeOutBack),

          // Subtitle
          Text(
            'TAP-TO-FLAP ARCADE',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.0,
              color: Colors.white.withOpacity(0.5),
            ),
          )
              .animate()
              .fade(delay: 300.ms, duration: 600.ms),

          const Spacer(flex: 2),

          // High Score Board
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'HIGH SCORE',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: palette.orbColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  '$highScore',
                  style: const TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fade(delay: 500.ms, duration: 800.ms)
              .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut),

          const Spacer(flex: 3),

          // Pulsing Tap to Start Prompt
          GestureDetector(
            onTap: () {
              ref.read(gameControllerProvider.notifier).startGame();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 18.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: LinearGradient(
                  colors: [
                    palette.gateGradient[0],
                    palette.gateGradient[1],
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.gateGradient[0].withOpacity(0.4),
                    blurRadius: 20.0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text(
                'TAP TO START',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: Colors.white,
                ),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: 16.0),

          // "TAP TO RISE" instruction tip (first session only)
          if (!settings.hasPlayedBefore)
            Text(
              'TAP TO RISE',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: palette.orbColor,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 800.ms)
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                ),

          const Spacer(flex: 2),

          // Sub-menus Row: Skins, Achievements, Leaderboard, Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuIconButton(
                  context, Icons.palette_outlined, 'Skins', () => _showSkinsSheet(context)),
              const SizedBox(width: 16.0),
              _buildMenuIconButton(
                  context, Icons.emoji_events_outlined, 'Achievements', () => _showAchievementsSheet(context)),
              const SizedBox(width: 16.0),
              _buildMenuIconButton(
                  context, Icons.leaderboard_outlined, 'Leaderboard', () => _showLeaderboardSheet(context)),
              const SizedBox(width: 16.0),
              _buildMenuIconButton(
                  context, Icons.settings_outlined, 'Settings', () => _showSettingsSheet(context)),
            ],
          )
              .animate()
              .fade(delay: 700.ms, duration: 600.ms),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

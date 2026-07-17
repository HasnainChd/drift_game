import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:drift_game/core/constants.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/models/game_state.dart';
import 'package:drift_game/painters/background_painter.dart';
import 'package:drift_game/painters/gate_painter.dart';
import 'package:drift_game/painters/orb_painter.dart';
import 'package:drift_game/painters/particle_painter.dart';
import 'package:drift_game/providers/game_controller.dart';
import 'package:drift_game/providers/orb_skins_provider.dart';

class GameCanvas extends ConsumerStatefulWidget {
  const GameCanvas({super.key});

  @override
  ConsumerState<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends ConsumerState<GameCanvas> {
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final selectedSkin = ref.watch(orbSkinsProvider).selectedSkin;
    final palette = GamePalette.getPaletteForScore(gameState.score);

    // Calculate screen shake offset
    Offset shakeOffset = Offset.zero;
    if (gameState.screenShake > 0) {
      const double maxShakeOffset = 14.0; // px
      final double shakeIntensity = gameState.screenShake;
      shakeOffset = Offset(
        (_random.nextDouble() * 2 - 1) * maxShakeOffset * shakeIntensity,
        (_random.nextDouble() * 2 - 1) * maxShakeOffset * shakeIntensity,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Send layout dimensions to controller as soon as constraints are known
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(gameControllerProvider.notifier)
              .setupScreenDimensions(constraints.maxWidth, constraints.maxHeight);
        });

        return GestureDetector(
          onTapDown: (_) {
            ref.read(gameControllerProvider.notifier).flap();
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. STATIC BACKGROUND LAYER
              TweenAnimationBuilder<Color?>(
                duration: const Duration(milliseconds: 1000),
                tween: ColorTween(begin: palette.background[0], end: palette.background[0]),
                builder: (context, startColor, child) {
                  return TweenAnimationBuilder<Color?>(
                    duration: const Duration(milliseconds: 1000),
                    tween: ColorTween(begin: palette.background[1], end: palette.background[1]),
                    builder: (context, endColor, child) {
                      return RepaintBoundary(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: BackgroundPainter(
                            colorStart: startColor ?? palette.background[0],
                            colorEnd: endColor ?? palette.background[1],
                            elapsedTime: gameState.elapsedTime,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              // 2. ACTIVE GAMEPLAY LAYER (with screen shake transform applied)
              RepaintBoundary(
                child: Transform.translate(
                  offset: shakeOffset,
                  child: Stack(
                    children: [
                      // Gates
                      CustomPaint(
                        size: Size.infinite,
                        painter: GatePainter(
                          gates: gameState.gates,
                          palette: palette,
                        ),
                      ),

                      // Particles (gate-pass bursts and collision shatter)
                      CustomPaint(
                        size: Size.infinite,
                        painter: ParticlePainter(
                          particles: gameState.particles,
                        ),
                      ),

                      // Player Orb
                      CustomPaint(
                        size: Size.infinite,
                        painter: OrbPainter(
                          orbY: gameState.orbY,
                          orbVelocity: gameState.orbVelocity,
                          trail: gameState.trail,
                          radius: GameConstants.orbRadius,
                          palette: palette,
                          orbColor: Color(selectedSkin.primaryColorValue),
                          orbGlow: Color(selectedSkin.glowColorValue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Achievement Banner
              if (gameState.achievementBannerText != null)
                Positioned(
                  top: 90,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD700),
                          Color(0xFFFFA500),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.3),
                          blurRadius: 12.0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.black, size: 24.0),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ACHIEVEMENT UNLOCKED',
                                style: AppTextStyles.label(
                                  fontSize: 10.0,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                gameState.achievementBannerText!,
                                style: AppTextStyles.body(
                                  fontSize: 13.0,
                                  color: Colors.black,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .slideY(begin: -0.4, end: 0.0, duration: 400.ms, curve: Curves.easeOutBack)
                      .fade(duration: 400.ms)
                      .then(delay: 1700.ms)
                      .fade(duration: 400.ms)
                      .slideY(begin: 0.0, end: -0.4, duration: 400.ms),
                ),


            ],
          ),
        );
      },
    );
  }
}

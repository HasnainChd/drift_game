import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_game/models/game_state.dart';
import 'package:drift_game/providers/game_controller.dart';
import 'package:drift_game/widgets/game_canvas.dart';
import 'package:drift_game/widgets/game_over_screen.dart';
import 'package:drift_game/widgets/menu_screen.dart';
import 'package:drift_game/widgets/score_hud.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // The Game Canvas is active during playing and game-over states,
          // and we show it as a static background during menu state as well.
          const GameCanvas(),

          // overlay switcher for states
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            child: _buildStateOverlay(gameState.status),
          ),
        ],
      ),
    );
  }

  Widget _buildStateOverlay(GameStatus status) {
    switch (status) {
      case GameStatus.menu:
        return const MenuScreen(key: ValueKey('menu'));
      case GameStatus.playing:
        return const Stack(
          key: ValueKey('playing'),
          children: [
            ScoreHud(),
          ],
        );
      case GameStatus.gameOver:
        return const GameOverScreen(key: ValueKey('game_over'));
    }
  }
}

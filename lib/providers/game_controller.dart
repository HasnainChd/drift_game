import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_game/core/constants.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/models/game_state.dart';
import 'package:drift_game/models/gate.dart';
import 'package:drift_game/providers/high_score_provider.dart';
import 'package:drift_game/providers/settings_provider.dart';
import 'package:drift_game/providers/orb_skins_provider.dart';
import 'package:drift_game/providers/achievements_provider.dart';
import 'package:drift_game/providers/leaderboard_provider.dart';

class GameParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double maxLifetime;
  final double remainingLifetime;

  GameParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.maxLifetime,
    required this.remainingLifetime,
  });

  double get progress => ((maxLifetime - remainingLifetime) / maxLifetime).clamp(0.0, 1.0);

  GameParticle copyWith({
    double? x,
    double? y,
    double? vx,
    double? vy,
    Color? color,
    double? size,
    double? maxLifetime,
    double? remainingLifetime,
  }) {
    return GameParticle(
      x: x ?? this.x,
      y: y ?? this.y,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      color: color ?? this.color,
      size: size ?? this.size,
      maxLifetime: maxLifetime ?? this.maxLifetime,
      remainingLifetime: remainingLifetime ?? this.remainingLifetime,
    );
  }
}

class GameControllerState {
  final double orbY;
  final double orbVelocity;
  final List<Gate> gates;
  final int score;
  final GameStatus status;
  final double elapsedTime;
  final double lastGateSpawnX;
  final List<Offset> trail;
  final double screenWidth;
  final double screenHeight;
  final double screenShake;
  final List<GameParticle> particles;
  final double dt;
  final String? achievementBannerText;

  GameControllerState({
    required this.orbY,
    required this.orbVelocity,
    required this.gates,
    required this.score,
    required this.status,
    required this.elapsedTime,
    required this.lastGateSpawnX,
    required this.trail,
    required this.screenWidth,
    required this.screenHeight,
    required this.screenShake,
    required this.particles,
    required this.dt,
    this.achievementBannerText,
  });

  factory GameControllerState.initial() {
    return GameControllerState(
      orbY: 300.0,
      orbVelocity: 0.0,
      gates: [],
      score: 0,
      status: GameStatus.menu,
      elapsedTime: 0.0,
      lastGateSpawnX: 0.0,
      trail: [],
      screenWidth: 0.0,
      screenHeight: 0.0,
      screenShake: 0.0,
      particles: [],
      dt: 0.0166,
      achievementBannerText: null,
    );
  }

  GameControllerState copyWith({
    double? orbY,
    double? orbVelocity,
    List<Gate>? gates,
    int? score,
    GameStatus? status,
    double? elapsedTime,
    double? lastGateSpawnX,
    List<Offset>? trail,
    double? screenWidth,
    double? screenHeight,
    double? screenShake,
    List<GameParticle>? particles,
    double? dt,
    String? achievementBannerText,
    bool clearBanner = false,
  }) {
    return GameControllerState(
      orbY: orbY ?? this.orbY,
      orbVelocity: orbVelocity ?? this.orbVelocity,
      gates: gates ?? this.gates,
      score: score ?? this.score,
      status: status ?? this.status,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      lastGateSpawnX: lastGateSpawnX ?? this.lastGateSpawnX,
      trail: trail ?? this.trail,
      screenWidth: screenWidth ?? this.screenWidth,
      screenHeight: screenHeight ?? this.screenHeight,
      screenShake: screenShake ?? this.screenShake,
      particles: particles ?? this.particles,
      dt: dt ?? this.dt,
      achievementBannerText: clearBanner ? null : (achievementBannerText ?? this.achievementBannerText),
    );
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, GameControllerState>((ref) {
  return GameController(ref);
});

class GameController extends StateNotifier<GameControllerState> {
  final Ref _ref;
  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  final Random _random = Random();
  double _lastGapCenterY = 300.0;

  static const double gateWidth = 60.0;

  GameController(this._ref) : super(GameControllerState.initial());

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void setupScreenDimensions(double width, double height) {
    if (state.screenWidth == width && state.screenHeight == height) return;
    state = state.copyWith(
      screenWidth: width,
      screenHeight: height,
    );
  }

  void startGame() {
    if (state.screenWidth == 0.0 || state.screenHeight == 0.0) return;

    _ticker?.dispose();
    _lastElapsed = Duration.zero;
    _lastGapCenterY = state.screenHeight / 2.0;

    final gates = <Gate>[];
    final tier = GameConstants.getTier(0);
    final palette = GamePalette.getPaletteForScore(0);
    
    double startX = state.screenWidth + 100.0;
    for (int i = 0; i < 4; i++) {
      double gateX = startX + i * tier.spawnDistance;
      double gapY = _generateNextGapY(state.screenHeight, tier.gapHeight);
      gates.add(Gate(
        id: 'gate_$i',
        x: gateX,
        gapY: gapY,
        gapHeight: tier.gapHeight,
        color: palette.gateGradient[0],
      ));
    }

    state = GameControllerState(
      orbY: state.screenHeight / 2.0,
      orbVelocity: 0.0,
      gates: gates,
      score: 0,
      status: GameStatus.playing,
      elapsedTime: 0.0,
      lastGateSpawnX: gates.last.x,
      trail: [],
      screenWidth: state.screenWidth,
      screenHeight: state.screenHeight,
      screenShake: 0.0,
      particles: [],
      dt: 0.0166,
      achievementBannerText: null,
    );

    _ticker = Ticker(_tick)..start();
  }

  void flap() {
    if (state.status != GameStatus.playing) return;

    // Check & update hasPlayedBefore setting
    final settings = _ref.read(settingsProvider);
    if (!settings.hasPlayedBefore) {
      _ref.read(settingsProvider.notifier).setHasPlayedBefore(true);
    }

    // Play tactile feedback
    if (settings.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    double impulseVelocity = -GameConstants.flapImpulse;
    impulseVelocity = impulseVelocity.clamp(-GameConstants.maxUpwardVelocity, GameConstants.terminalVelocity);

    state = state.copyWith(
      orbVelocity: impulseVelocity,
    );
  }

  double _generateNextGapY(double screenHeight, double gapHeight) {
    final double maxDelta = screenHeight * GameConstants.maxGapDeltaPercent;

    final double minY = (GameConstants.safeZoneTop + gapHeight / 2)
        .clamp(0.0, screenHeight);
    final double maxY = (screenHeight - GameConstants.safeZoneBottom - gapHeight / 2)
        .clamp(0.0, screenHeight);

    final double rawOffset = (_random.nextDouble() * 2 - 1) * maxDelta;
    double newCenterY = (_lastGapCenterY + rawOffset).clamp(minY, maxY);

    _lastGapCenterY = newCenterY;
    return newCenterY - gapHeight / 2;
  }

  void _checkUnlocksAsync(int score, double survivalTime) {
    Future.microtask(() async {
      // 1. Check skins
      final skinsNotifier = _ref.read(orbSkinsProvider.notifier);
      final unlockedSkins = await skinsNotifier.checkUnlocks(score);
      for (final skinName in unlockedSkins) {
        _showBanner('Skin Unlocked: $skinName');
      }

      // 2. Check achievements
      final achievementsNotifier = _ref.read(achievementsProvider.notifier);
      final unlockedAchievements = await achievementsNotifier.checkUnlocks(
        score: score,
        survivalTime: survivalTime,
      );
      for (final achTitle in unlockedAchievements) {
        _showBanner('Achievement Unlocked:\n$achTitle');
      }
    });
  }

  void _showBanner(String text) {
    state = state.copyWith(achievementBannerText: text);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && state.achievementBannerText == text) {
        state = state.copyWith(clearBanner: true);
      }
    });
  }

  void _tick(Duration elapsed) {
    if (state.status != GameStatus.playing) {
      _ticker?.stop();
      return;
    }

    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    double dt = (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;

    final double clampedDt = dt.clamp(0.0, 1.0 / 30.0);
    final double newElapsedTime = state.elapsedTime + clampedDt;
    final tier = GameConstants.getTier(state.score);
    final palette = GamePalette.getPaletteForScore(state.score);

    double velocity = state.orbVelocity + GameConstants.gravity * clampedDt;
    velocity = velocity.clamp(-GameConstants.maxUpwardVelocity, GameConstants.terminalVelocity);

    double orbY = state.orbY + velocity * clampedDt;

    bool outOfBounds = false;
    if (orbY - GameConstants.orbRadius <= 0) {
      orbY = GameConstants.orbRadius;
      outOfBounds = true;
    } else if (orbY + GameConstants.orbRadius >= state.screenHeight) {
      orbY = state.screenHeight - GameConstants.orbRadius;
      outOfBounds = true;
    }

    final double orbX = state.screenWidth * GameConstants.orbStartXPercent;
    final newTrail = List<Offset>.from(state.trail)..add(Offset(orbX, orbY));
    if (newTrail.length > GameConstants.trailBufferLength) {
      newTrail.removeAt(0);
    }

    final updatedGates = <Gate>[];
    int scoreIncrement = 0;
    bool passedAGate = false;
    double maxGateX = 0.0;

    for (final gate in state.gates) {
      double newGateX = gate.x - tier.scrollSpeed * clampedDt;
      if (newGateX > maxGateX) {
        maxGateX = newGateX;
      }
    }

    for (final gate in state.gates) {
      double newGateX = gate.x - tier.scrollSpeed * clampedDt;
      bool passed = gate.passed;

      if (!passed && gate.x >= orbX && newGateX < orbX) {
        passed = true;
        scoreIncrement++;
        passedAGate = true;
      }

      if (newGateX + gateWidth < 0) {
        double spawnX = maxGateX + tier.spawnDistance;
        double gapY = _generateNextGapY(state.screenHeight, tier.gapHeight);
        
        updatedGates.add(Gate(
          id: gate.id,
          x: spawnX,
          gapY: gapY,
          gapHeight: tier.gapHeight,
          color: palette.gateGradient[0],
          passed: false,
        ));
        maxGateX = spawnX;
      } else {
        updatedGates.add(gate.copyWith(
          x: newGateX,
          passed: passed,
          color: palette.gateGradient[0],
          gapHeight: tier.gapHeight,
        ));
      }
    }

    int newScore = state.score + scoreIncrement;
    if (scoreIncrement > 0) {
      _ref.read(highScoreProvider.notifier).updateHighScore(newScore);
      _checkUnlocksAsync(newScore, newElapsedTime);
    }

    bool collided = outOfBounds;
    if (!collided) {
      for (final gate in updatedGates) {
        if (gate.x <= orbX + GameConstants.orbRadius && gate.x + gateWidth >= orbX - GameConstants.orbRadius) {
          bool topCollide = _checkCircleRectCollision(
            orbX, orbY, GameConstants.orbRadius,
            gate.x, 0.0, gateWidth, gate.gapY,
          );
          bool bottomCollide = _checkCircleRectCollision(
            orbX, orbY, GameConstants.orbRadius,
            gate.x, gate.gapY + gate.gapHeight, gateWidth, state.screenHeight - (gate.gapY + gate.gapHeight),
          );

          if (topCollide || bottomCollide) {
            collided = true;
            break;
          }
        }
      }
    }

    final updatedParticles = <GameParticle>[];
    for (final p in state.particles) {
      final newRemaining = p.remainingLifetime - clampedDt;
      if (newRemaining > 0) {
        updatedParticles.add(p.copyWith(
          x: p.x + p.vx * clampedDt,
          y: p.y + p.vy * clampedDt,
          remainingLifetime: newRemaining,
        ));
      }
    }

    if (passedAGate) {
      for (int i = 0; i < 10; i++) {
        double angle = _random.nextDouble() * 2 * pi;
        double speed = 60.0 + _random.nextDouble() * 100.0;
        Color pColor = palette.particleColors[_random.nextInt(palette.particleColors.length)];
        updatedParticles.add(GameParticle(
          x: orbX,
          y: orbY,
          vx: cos(angle) * speed - tier.scrollSpeed * 0.3,
          vy: sin(angle) * speed,
          color: pColor,
          size: 3.0 + _random.nextDouble() * 4.0,
          maxLifetime: GameConstants.particleLifetime,
          remainingLifetime: GameConstants.particleLifetime,
        ));
      }
    }

    if (collided) {
      _ticker?.stop();
      
      final settings = _ref.read(settingsProvider);
      if (settings.hapticsEnabled) {
        HapticFeedback.mediumImpact();
      }

      // Check unlocks at game over (for survival time, etc.)
      _checkUnlocksAsync(newScore, newElapsedTime);

      // Save score to local leaderboard
      Future.microtask(() {
        _ref.read(leaderboardProvider.notifier).addScore(newScore);
      });

      final List<GameParticle> collisionParticles = List<GameParticle>.from(updatedParticles);
      for (int i = 0; i < 25; i++) {
        double angle = _random.nextDouble() * 2 * pi;
        double speed = 100.0 + _random.nextDouble() * 250.0;
        Color pColor = palette.particleColors[_random.nextInt(palette.particleColors.length)];
        collisionParticles.add(GameParticle(
          x: orbX,
          y: orbY,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          color: pColor,
          size: 4.0 + _random.nextDouble() * 6.0,
          maxLifetime: GameConstants.collisionParticleLifetime,
          remainingLifetime: GameConstants.collisionParticleLifetime,
        ));
      }

      state = state.copyWith(
        orbY: orbY,
        orbVelocity: 0.0,
        status: GameStatus.gameOver,
        screenShake: 1.0,
        particles: collisionParticles,
        gates: updatedGates,
        dt: clampedDt,
      );

      _startGameOverTicker();
      return;
    }

    double newShake = state.screenShake - clampedDt * 3.0;
    if (newShake < 0.0) newShake = 0.0;

    state = state.copyWith(
      orbY: orbY,
      orbVelocity: velocity,
      gates: updatedGates,
      score: newScore,
      elapsedTime: newElapsedTime,
      trail: newTrail,
      screenShake: newShake,
      particles: updatedParticles,
      dt: clampedDt,
    );
  }

  bool _checkCircleRectCollision(
      double cx, double cy, double r, double rx, double ry, double rw, double rh) {
    double closestX = cx.clamp(rx, rx + rw);
    double closestY = cy.clamp(ry, ry + rh);

    double dx = cx - closestX;
    double dy = cy - closestY;
    double distanceSquared = dx * dx + dy * dy;

    return distanceSquared < r * r;
  }

  void _startGameOverTicker() {
    _lastElapsed = Duration.zero;
    _ticker = Ticker((elapsed) {
      if (state.status != GameStatus.gameOver) {
        _ticker?.stop();
        return;
      }
      if (_lastElapsed == Duration.zero) {
        _lastElapsed = elapsed;
        return;
      }
      double dt = (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
      _lastElapsed = elapsed;
      final double clampedDt = dt.clamp(0.0, 1.0 / 30.0);

      double newShake = state.screenShake - clampedDt * 3.3;
      if (newShake < 0.0) newShake = 0.0;

      final updatedParticles = <GameParticle>[];
      for (final p in state.particles) {
        final newRemaining = p.remainingLifetime - clampedDt;
        if (newRemaining > 0) {
          updatedParticles.add(p.copyWith(
            x: p.x + p.vx * clampedDt,
            y: p.y + p.vy * clampedDt,
            remainingLifetime: newRemaining,
          ));
        }
      }

      state = state.copyWith(
        screenShake: newShake,
        particles: updatedParticles,
        dt: clampedDt,
      );

      if (newShake == 0.0 && updatedParticles.isEmpty) {
        _ticker?.stop();
      }
    })..start();
  }

  void resetToMenu() {
    _ticker?.dispose();
    state = GameControllerState.initial().copyWith(
      screenWidth: state.screenWidth,
      screenHeight: state.screenHeight,
    );
  }
}

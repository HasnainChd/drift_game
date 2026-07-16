class GameConstants {
  static const double gravity = 1400.0;          // constant downward pull, px/s^2
  static const double flapImpulse = 480.0;       // upward velocity set on each tap, px/s
  static const double terminalVelocity = 620.0;  // max downward speed, px/s
  static const double maxUpwardVelocity = 480.0; // caps how fast it can move upward (= flapImpulse, no need to exceed it)
  static const double orbRadius = 16.0;
  static const double orbStartXPercent = 0.25;

  static const double baseScrollSpeed = 200.0;
  static const double baseGateGapHeight = 260.0;
  static const double baseGateSpawnDistance = 400.0;

  static const double safeZoneTop = 60.0;
  static const double safeZoneBottom = 60.0;

  static const double maxGapDeltaPercent = 0.22; // keep the reachability constraint from before

  static const int trailBufferLength = 8;
  static const double particleLifetime = 0.4;
  static const double collisionParticleLifetime = 0.8;

  static GameTier getTier(int score) {
    if (score < 15) {
      return const GameTier(tier: 1, scrollSpeed: 200.0, gapHeight: 260.0, spawnDistance: 400.0, name: 'Vortex');
    } else if (score < 30) {
      return const GameTier(tier: 2, scrollSpeed: 230.0, gapHeight: 235.0, spawnDistance: 380.0, name: 'Nebula');
    } else if (score < 50) {
      return const GameTier(tier: 3, scrollSpeed: 260.0, gapHeight: 210.0, spawnDistance: 355.0, name: 'Supernova');
    } else {
      return const GameTier(tier: 4, scrollSpeed: 290.0, gapHeight: 190.0, spawnDistance: 330.0, name: 'Singularity');
    }
  }
}

class GameTier {
  final int tier;
  final double scrollSpeed;
  final double gapHeight;
  final double spawnDistance;
  final String name;

  const GameTier({
    required this.tier,
    required this.scrollSpeed,
    required this.gapHeight,
    required this.spawnDistance,
    required this.name,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/models/score_entry.dart';
import 'package:drift_game/providers/leaderboard_provider.dart';

class LeaderboardSheet extends ConsumerWidget {
  final int? currentRunScore; // Optional flag to highlight current score if they just finished

  const LeaderboardSheet({
    super.key,
    this.currentRunScore,
  });

  String _getRelativeTime(String timestampStr) {
    try {
      final date = DateTime.parse(timestampStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      return '${diff.inDays} days ago';
    } catch (_) {
      return 'Recently';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(leaderboardProvider);
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
                const Text(
                  'TOP DRIFTERS',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
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
            if (scores.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'No scores recorded yet.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14.0,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scores.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                itemBuilder: (context, index) {
                  final entry = scores[index];
                  final rank = index + 1;
                  final isHighlight = currentRunScore != null && entry.score == currentRunScore;

                  // Unique rank colors for top 3
                  final rankColor = rank == 1
                      ? const Color(0xFFFFD700) // Gold
                      : rank == 2
                          ? const Color(0xFFC0C0C0) // Silver
                          : rank == 3
                              ? const Color(0xFFCD7F32) // Bronze
                              : Colors.white54;

                  return Container(
                    decoration: BoxDecoration(
                      color: isHighlight
                          ? palette.orbColor.withOpacity(0.12)
                          : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isHighlight
                            ? palette.orbColor
                            : Colors.white.withOpacity(0.06),
                        width: isHighlight ? 1.5 : 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      children: [
                        // Rank Circle
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: rankColor,
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w900,
                              color: rankColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Date / Timestamp
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getRelativeTime(entry.timestamp),
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white54,
                                ),
                              ),
                              if (isHighlight) ...[
                                const SizedBox(height: 2.0),
                                Text(
                                  'NEW PERSONAL SCORE!',
                                  style: TextStyle(
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w900,
                                    color: palette.orbColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Score Display
                        Text(
                          '${entry.score}',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            color: rank == 1 ? const Color(0xFFFFD700) : Colors.white,
                          ),
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

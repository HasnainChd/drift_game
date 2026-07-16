import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift_game/core/theme.dart';
import 'package:drift_game/models/orb_skin.dart';
import 'package:drift_game/providers/orb_skins_provider.dart';

class SkinsSheet extends ConsumerWidget {
  const SkinsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orbSkinsState = ref.watch(orbSkinsProvider);
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
                  'ORB COSMOS',
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orbSkinsState.skins.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final skin = orbSkinsState.skins[index];
                final isSelected = skin.id == orbSkinsState.selectedSkinId;

                return GestureDetector(
                  onTap: skin.isUnlocked
                      ? () {
                          ref.read(orbSkinsProvider.notifier).selectSkin(skin.id);
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(skin.primaryColorValue).withOpacity(0.12)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: isSelected
                            ? Color(skin.primaryColorValue)
                            : Colors.white.withOpacity(0.08),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(skin.primaryColorValue).withOpacity(0.2),
                                blurRadius: 10.0,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Orb Preview
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: skin.isUnlocked
                                    ? Color(skin.primaryColorValue)
                                    : Colors.white24,
                                boxShadow: skin.isUnlocked
                                    ? [
                                        BoxShadow(
                                          color: Color(skin.glowColorValue),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            if (!skin.isUnlocked)
                              const Icon(
                                Icons.lock,
                                color: Colors.white54,
                                size: 14.0,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          skin.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: skin.isUnlocked ? Colors.white : Colors.white38,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          skin.isUnlocked
                              ? (isSelected ? 'SELECTED' : 'UNLOCKED')
                              : 'SCORE ${skin.unlockScoreThreshold}',
                          style: TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isSelected
                                ? Color(skin.primaryColorValue)
                                : (skin.isUnlocked ? Colors.white38 : Colors.white24),
                          ),
                        ),
                      ],
                    ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hint_result.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/puzzle_tier.dart';

/// Bottom sheet that lets the user pick a puzzle difficulty tier.
/// Matches the design language of the theme picker on the home screen.
class DifficultyPickerSheet extends StatelessWidget {
  final ValueChanged<PuzzleTier> onSelected;

  const DifficultyPickerSheet({super.key, required this.onSelected});

  /// Map a user-facing tier to the engine Difficulty used for its
  /// accent color in AppColors.difficultyColor.
  Difficulty _accentDifficulty(PuzzleTier tier) {
    switch (tier) {
      case PuzzleTier.easy:
        return Difficulty.easy;
      case PuzzleTier.medium:
        return Difficulty.medium;
      case PuzzleTier.hard:
        return Difficulty.hard;
      case PuzzleTier.killer:
        return Difficulty.evil;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Choose Difficulty',
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.fixedText,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: PuzzleTier.values.map((tier) {
              final accent = AppColors.difficultyColor(_accentDifficulty(tier));
              return GestureDetector(
                onTap: () => onSelected(tier),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.gridBorderThin),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            tier.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.fixedText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tier.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Serif',
                          color: colors.candidateText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

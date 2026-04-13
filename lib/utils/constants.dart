import 'package:flutter/material.dart';
import '../models/hint_result.dart';
import '../providers/theme_provider.dart';

class AppColors {
  /// Get colors from the active theme config.
  static ThemeConfig of(BuildContext context) {
    // This can be called without context for static access (tests, etc.)
    throw UnimplementedError('Use AppColors.from(config) instead');
  }

  // Difficulty colors stay constant across themes
  static Color difficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF81C784);
      case Difficulty.medium:
        return const Color(0xFFFFD54F);
      case Difficulty.hard:
        return const Color(0xFFFFB74D);
      case Difficulty.expert:
        return const Color(0xFFE57373);
      case Difficulty.evil:
        return const Color(0xFFCE93D8);
    }
  }

  static String difficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
      case Difficulty.evil:
        return 'Evil';
    }
  }
}

class GridConstants {
  static const int gridSize = 9;
  static const int boxSize = 3;
  static const double thickBorder = 2.5;
  static const double thinBorder = 1.5;
}

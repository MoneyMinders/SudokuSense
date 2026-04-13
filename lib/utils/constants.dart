import 'package:flutter/material.dart';
import '../models/hint_result.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1A237E);
  static const Color selectedCell = Color(0xFFBBDEFB);
  static const Color highlightedRegion = Color(0xFFF5F5F5);
  static const Color fixedText = Color(0xFF212121);
  static const Color userText = Color(0xFF1565C0);
  static const Color errorBackground = Color(0x33F44336);
  static const Color hintHighlight = Color(0x4DFFEB3B);
  static const Color gridBorderThick = Color(0xFF212121);
  static const Color gridBorderThin = Color(0xFFBDBDBD);
  static const Color candidateText = Color(0xFF757575);

  static Color difficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.amber.shade700;
      case Difficulty.hard:
        return Colors.orange;
      case Difficulty.expert:
        return Colors.red;
      case Difficulty.evil:
        return Colors.purple;
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
  static const double thickBorder = 2.0;
  static const double thinBorder = 0.5;
}

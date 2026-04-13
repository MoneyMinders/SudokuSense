import 'package:flutter/material.dart';
import '../models/hint_result.dart';

class AppColors {
  // Dark theme colors — soft pastel accents on dark surface
  static const Color primaryBlue = Color(0xFF9FA8DA);    // Soft indigo pastel
  static const Color selectedCell = Color(0xFF2A2D3E);   // Subtle dark highlight
  static const Color highlightedRegion = Color(0xFF1A1C2A); // Very subtle region
  static const Color fixedText = Color(0xFFE0E0E0);     // Light gray for clues
  static const Color userText = Color(0xFF9FA8DA);       // Pastel indigo for user values
  static const Color errorBackground = Color(0x33EF5350); // Muted red tint
  static const Color hintHighlight = Color(0x3381C784);  // Soft green tint
  static const Color gridBorderThick = Color(0xFF5C6BC0); // Indigo border
  static const Color gridBorderThin = Color(0xFF333333); // Subtle dark gray
  static const Color candidateText = Color(0xFF787878);  // Muted gray
  static const Color cellBackground = Color(0xFF1E1E2E); // Dark cell bg
  static const Color surfaceColor = Color(0xFF121212);   // App background

  static Color difficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF81C784);  // Pastel green
      case Difficulty.medium:
        return const Color(0xFFFFD54F);  // Soft amber
      case Difficulty.hard:
        return const Color(0xFFFFB74D);  // Soft orange
      case Difficulty.expert:
        return const Color(0xFFE57373);  // Soft red
      case Difficulty.evil:
        return const Color(0xFFCE93D8);  // Pastel purple
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

import '../models/hint_result.dart';

/// User-facing difficulty tier for a generated puzzle.
enum PuzzleTier { easy, medium, hard, killer }

extension PuzzleTierX on PuzzleTier {
  String get label {
    switch (this) {
      case PuzzleTier.easy:
        return 'Easy';
      case PuzzleTier.medium:
        return 'Medium';
      case PuzzleTier.hard:
        return 'Hard';
      case PuzzleTier.killer:
        return 'Killer';
    }
  }

  String get subtitle {
    switch (this) {
      case PuzzleTier.easy:
        return 'Singles only';
      case PuzzleTier.medium:
        return 'Pairs, triples';
      case PuzzleTier.hard:
        return 'X-Wing, Swordfish';
      case PuzzleTier.killer:
        return 'Chains & wings';
    }
  }

  /// Target number of blank cells when generating a puzzle of this tier.
  int get targetBlanks {
    switch (this) {
      case PuzzleTier.easy:
        return 35;
      case PuzzleTier.medium:
        return 45;
      case PuzzleTier.hard:
        return 52;
      case PuzzleTier.killer:
        return 55;
    }
  }
}

/// Classify a puzzle by the hardest engine strategy its solution requires.
/// Returns null if [steps] is empty (engine stuck, not classifiable).
PuzzleTier? classifyTier(List<HintResult> steps) {
  if (steps.isEmpty) return null;
  var max = Difficulty.easy;
  for (final s in steps) {
    if (s.difficulty.index > max.index) max = s.difficulty;
  }
  switch (max) {
    case Difficulty.easy:
      return PuzzleTier.easy;
    case Difficulty.medium:
      return PuzzleTier.medium;
    case Difficulty.hard:
      return PuzzleTier.hard;
    case Difficulty.expert:
    case Difficulty.evil:
      return PuzzleTier.killer;
  }
}

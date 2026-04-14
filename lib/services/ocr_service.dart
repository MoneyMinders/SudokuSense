import 'dart:typed_data';

import '../models/board.dart';
import '../utils/grid_parser.dart';
import 'image_preprocessor.dart';
import 'ocr_strategy.dart';

class OcrService {
  final OcrStrategy _strategy = OcrStrategy();

  /// Number of OCR passes for consensus voting.
  static const int _runs = 2;

  /// Recognize a Sudoku grid from raw image bytes.
  /// Runs OCR multiple times on original + multiple preprocessed variants,
  /// then uses cell-level majority voting for a stable result.
  Future<Board?> recognizeFromBytes(Uint8List imageBytes) async {
    // Build preprocessing variants upfront.
    final variants = <Uint8List>[imageBytes];
    final pp1 = ImagePreprocessor.preprocessBytes(imageBytes);
    if (pp1 != null) variants.add(pp1);
    final pp2 = ImagePreprocessor.preprocessBytes(imageBytes, highContrast: true);
    if (pp2 != null) variants.add(pp2);

    // Launch all OCR runs in parallel across all variants.
    final futures = <Future<List<List<int>>?>>[];
    for (int i = 0; i < _runs; i++) {
      for (final variant in variants) {
        futures.add(_extractGrid(variant));
      }
    }

    final results = await Future.wait(futures);
    final grids = results.whereType<List<List<int>>>().toList();

    if (grids.isEmpty) return null;

    if (grids.length == 1) {
      return Board.fromGrid(grids.first);
    }

    // Majority vote across all grids for each cell.
    final consensus = _majorityVote(grids);
    return Board.fromGrid(consensus);
  }

  /// Run OCR on a single image variant and parse into a grid.
  Future<List<List<int>>?> _extractGrid(Uint8List imageBytes) async {
    final digits = await _strategy.extractDigits(imageBytes);
    if (digits.isEmpty) return null;
    return GridParser.toGrid(digits);
  }

  /// Cell-level majority voting: for each cell, pick the value that
  /// appears most often across all runs. Ties break toward non-zero
  /// (prefer detecting a digit over missing it).
  List<List<int>> _majorityVote(List<List<List<int>>> grids) {
    final result = List.generate(9, (_) => List.filled(9, 0));

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final votes = <int, int>{};
        for (final grid in grids) {
          final v = grid[r][c];
          votes[v] = (votes[v] ?? 0) + 1;
        }

        // Find the value with the most votes.
        int bestVal = 0;
        int bestCount = 0;
        for (final entry in votes.entries) {
          if (entry.value > bestCount ||
              (entry.value == bestCount && entry.key != 0)) {
            bestVal = entry.key;
            bestCount = entry.value;
          }
        }

        // Only accept if a non-zero value appears in majority of runs.
        if (bestVal != 0 && bestCount >= (grids.length / 2).ceil()) {
          result[r][c] = bestVal;
        }
      }
    }

    return result;
  }

}

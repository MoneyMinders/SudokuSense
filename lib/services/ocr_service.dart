import 'dart:typed_data';

import '../models/board.dart';
import '../utils/grid_parser.dart';
import 'image_preprocessor.dart';
import 'ocr_strategy.dart';

class OcrService {
  final OcrStrategy _strategy = OcrStrategy();

  /// Recognize a Sudoku grid from raw image bytes.
  /// Runs OCR on both the original and a preprocessed version,
  /// then picks whichever detects more valid digits.
  Future<Board?> recognizeFromBytes(Uint8List imageBytes) async {
    // Run OCR on original image
    final originalDigits = await _strategy.extractDigits(imageBytes);

    // Preprocess and run OCR on cleaned image
    final preprocessedBytes = ImagePreprocessor.preprocessBytes(imageBytes);
    List<RecognizedDigit>? preprocessedDigits;
    if (preprocessedBytes != null) {
      preprocessedDigits = await _strategy.extractDigits(preprocessedBytes);
    }

    // Pick the result with more digits detected
    final digits = _pickBest(originalDigits, preprocessedDigits);
    if (digits == null || digits.isEmpty) return null;

    final grid = GridParser.toGrid(digits);
    if (grid == null) return null;

    return Board.fromGrid(grid);
  }

  /// Pick the digit list that produces a more valid sudoku grid.
  List<RecognizedDigit>? _pickBest(
    List<RecognizedDigit>? a,
    List<RecognizedDigit>? b,
  ) {
    if (a == null || a.isEmpty) return b;
    if (b == null || b.isEmpty) return a;

    final gridA = GridParser.toGrid(a);
    final gridB = GridParser.toGrid(b);

    if (gridA == null) return b;
    if (gridB == null) return a;

    final countA = gridA.expand((r) => r).where((v) => v != 0).length;
    final countB = gridB.expand((r) => r).where((v) => v != 0).length;

    if (countA > 35 && countB <= 35) return b;
    if (countB > 35 && countA <= 35) return a;

    return countA >= countB ? a : b;
  }
}

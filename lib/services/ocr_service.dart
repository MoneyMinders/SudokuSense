import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/board.dart';
import '../utils/grid_parser.dart';
import 'image_preprocessor.dart';
import 'cell_ocr_service.dart';

class OcrService {
  static const double _minConfidence = 0.3;

  /// Recognize a Sudoku grid from a photo.
  /// Runs three strategies in parallel and picks the best result:
  /// 1. Whole-image ML Kit on original
  /// 2. Whole-image ML Kit on preprocessed image
  /// 3. Cell-by-cell ML Kit (crop each of 81 cells individually)
  Future<Board?> recognizeFromImage(String imagePath) async {
    // Run all three strategies
    final results = await Future.wait([
      _wholeImageOcr(imagePath),
      _preprocessedOcr(imagePath),
      CellOcrService().recognizeFromImage(imagePath),
    ]);

    // Pick the board with the most filled cells
    Board? best;
    int bestCount = 0;

    for (final board in results) {
      if (board == null) continue;
      final count = _countFilled(board);
      if (count > bestCount) {
        bestCount = count;
        best = board;
      }
    }

    return best;
  }

  int _countFilled(Board board) {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board.getCell(r, c).value != null) count++;
      }
    }
    return count;
  }

  /// Strategy 1: Run ML Kit on the original image.
  Future<Board?> _wholeImageOcr(String imagePath) async {
    final digits = await _extractDigits(imagePath);
    if (digits.isEmpty) return null;
    final grid = GridParser.toGrid(digits);
    if (grid == null) return null;
    return Board.fromGrid(grid);
  }

  /// Strategy 2: Preprocess then run ML Kit.
  Future<Board?> _preprocessedOcr(String imagePath) async {
    final preprocessedPath = await ImagePreprocessor.preprocess(imagePath);
    if (preprocessedPath == null) return null;
    final digits = await _extractDigits(preprocessedPath);
    if (digits.isEmpty) return null;
    final grid = GridParser.toGrid(digits);
    if (grid == null) return null;
    return Board.fromGrid(grid);
  }

  /// Extract digits from an image using ML Kit text recognition.
  Future<List<RecognizedDigit>> _extractDigits(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final digits = <RecognizedDigit>[];
      final digitPattern = RegExp(r'[1-9]');

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            if (element.symbols.isNotEmpty) {
              for (final symbol in element.symbols) {
                final text = symbol.text.trim();
                if (text.length == 1 && digitPattern.hasMatch(text)) {
                  if (symbol.confidence != null &&
                      symbol.confidence! < _minConfidence) {
                    continue;
                  }
                  final box = symbol.boundingBox;
                  digits.add(RecognizedDigit(
                    value: int.parse(text),
                    centerX: box.center.dx,
                    centerY: box.center.dy,
                    confidence: symbol.confidence,
                  ));
                }
              }
            } else {
              final text = element.text.trim();
              if (text.length == 1 && digitPattern.hasMatch(text)) {
                if (element.confidence != null &&
                    element.confidence! < _minConfidence) {
                  continue;
                }
                final box = element.boundingBox;
                digits.add(RecognizedDigit(
                  value: int.parse(text),
                  centerX: box.center.dx,
                  centerY: box.center.dy,
                  confidence: element.confidence,
                ));
              } else if (text.length > 1) {
                final box = element.boundingBox;
                final charWidth = box.width / text.length;
                for (int i = 0; i < text.length; i++) {
                  final ch = text[i];
                  if (digitPattern.hasMatch(ch)) {
                    digits.add(RecognizedDigit(
                      value: int.parse(ch),
                      centerX: box.left + charWidth * (i + 0.5),
                      centerY: box.center.dy,
                      confidence: element.confidence,
                    ));
                  }
                }
              }
            }
          }
        }
      }

      return digits;
    } catch (_) {
      return [];
    } finally {
      textRecognizer.close();
    }
  }
}

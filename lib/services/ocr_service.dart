import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/board.dart';
import '../utils/grid_parser.dart';
import 'image_preprocessor.dart';

class OcrService {
  static const double _minConfidence = 0.3;

  /// Recognize a Sudoku grid from a photo.
  /// Runs OCR on both the original and a preprocessed version,
  /// then picks whichever detects more valid digits.
  Future<Board?> recognizeFromImage(String imagePath) async {
    // Run OCR on original image
    final originalDigits = await _extractDigits(imagePath);

    // Preprocess and run OCR on cleaned image
    final preprocessedPath = await ImagePreprocessor.preprocess(imagePath);
    List<RecognizedDigit>? preprocessedDigits;
    if (preprocessedPath != null) {
      preprocessedDigits = await _extractDigits(preprocessedPath);
    }

    // Pick the result with more digits detected (better recognition)
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

    // Try both and see which produces a grid with more filled cells
    final gridA = GridParser.toGrid(a);
    final gridB = GridParser.toGrid(b);

    if (gridA == null) return b;
    if (gridB == null) return a;

    final countA = gridA.expand((r) => r).where((v) => v != 0).length;
    final countB = gridB.expand((r) => r).where((v) => v != 0).length;

    // Prefer the one with more digits, but cap at 35 (typical max for a puzzle)
    // If one has way too many, prefer the other
    if (countA > 35 && countB <= 35) return b;
    if (countB > 35 && countA <= 35) return a;

    return countA >= countB ? a : b;
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

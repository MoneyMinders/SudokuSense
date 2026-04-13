import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/board.dart';
import '../utils/grid_parser.dart';

class OcrService {
  /// Minimum confidence to accept a recognized digit (Android only).
  /// On iOS, confidence is null so all digits are accepted.
  static const double _minConfidence = 0.4;

  /// Recognize a Sudoku grid from a photo and return a [Board],
  /// or null if recognition fails.
  Future<Board?> recognizeFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);

      final digits = <RecognizedDigit>[];
      final digitPattern = RegExp(r'[1-9]');

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            // Drill down to individual symbols for precise positions.
            // MLKit sometimes groups nearby digits into one element.
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
              // iOS fallback: symbols list may be empty, use element level.
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
                // Multi-char element without symbols: extract individual digits
                // and estimate positions by subdividing the bounding box.
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

      if (digits.isEmpty) return null;

      final grid = GridParser.toGrid(digits);
      if (grid == null) return null;

      return Board.fromGrid(grid);
    } catch (_) {
      return null;
    } finally {
      textRecognizer.close();
    }
  }
}

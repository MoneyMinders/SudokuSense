import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/board.dart';
import '../utils/grid_parser.dart';

class OcrService {
  /// Recognize a Sudoku grid from a photo and return a [Board],
  /// or null if recognition fails.
  Future<Board?> recognizeFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Collect every single-digit text element with its bounding box.
      final digits = <RecognizedDigit>[];

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            final text = element.text.trim();
            // Accept single digits 1-9.
            if (text.length == 1 && RegExp(r'[1-9]').hasMatch(text)) {
              final box = element.boundingBox;
              digits.add(RecognizedDigit(
                value: int.parse(text),
                centerX: box.center.dx,
                centerY: box.center.dy,
              ));
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

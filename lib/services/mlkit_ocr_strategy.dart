import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../utils/grid_parser.dart';
import 'ocr_strategy.dart';

OcrStrategy createOcrStrategy() => MlKitOcrStrategy();

class MlKitOcrStrategy implements OcrStrategy {
  static const double _minConfidence = 0.5;

  @override
  Future<List<RecognizedDigit>> extractDigits(Uint8List imageBytes) async {
    // ML Kit requires a file path, so write bytes to a temp file.
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/ocr_input_${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(imageBytes);

    try {
      return await _extractFromPath(tempFile.path);
    } finally {
      try { await tempFile.delete(); } catch (_) {}
    }
  }

  Future<List<RecognizedDigit>> _extractFromPath(String imagePath) async {
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

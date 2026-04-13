import 'dart:typed_data';

import '../utils/grid_parser.dart';

// Conditional imports: the correct implementation is chosen at compile time.
import 'mlkit_ocr_strategy.dart' if (dart.library.js_interop) 'tesseract_ocr_strategy.dart' as platform_ocr;

/// Contract for platform-specific OCR digit extraction.
abstract class OcrStrategy {
  /// Extract recognized digits from raw image bytes.
  Future<List<RecognizedDigit>> extractDigits(Uint8List imageBytes);

  /// Factory that returns the correct platform implementation.
  factory OcrStrategy() => platform_ocr.createOcrStrategy();
}

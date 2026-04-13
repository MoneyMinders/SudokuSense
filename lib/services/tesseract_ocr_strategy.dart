import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../utils/grid_parser.dart';
import 'ocr_strategy.dart';

OcrStrategy createOcrStrategy() => TesseractOcrStrategy();

class TesseractOcrStrategy implements OcrStrategy {
  @override
  Future<List<RecognizedDigit>> extractDigits(Uint8List imageBytes) async {
    // Create a Blob URL from the image bytes so Tesseract.js can read it.
    final blob = web.Blob(
      [imageBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final blobUrl = web.URL.createObjectURL(blob);

    try {
      final result = await _tesseractRecognize(blobUrl.toJS, 'eng'.toJS).toDart;
      return _parseResult(result);
    } finally {
      web.URL.revokeObjectURL(blobUrl);
    }
  }

  /// Parse Tesseract.js result into RecognizedDigits.
  List<RecognizedDigit> _parseResult(TesseractResult result) {
    final digits = <RecognizedDigit>[];
    final digitPattern = RegExp(r'[1-9]');

    final data = result.data;
    final symbols = data.symbols;

    for (int i = 0; i < symbols.length; i++) {
      final symbol = symbols[i];
      final text = symbol.text.toDart.trim();
      if (text.length != 1 || !digitPattern.hasMatch(text)) continue;

      final confidence = symbol.confidence.toDartDouble / 100.0;
      if (confidence < 0.3) continue;

      final bbox = symbol.bbox;

      digits.add(RecognizedDigit(
        value: int.parse(text),
        centerX: (bbox.x0.toDartDouble + bbox.x1.toDartDouble) / 2,
        centerY: (bbox.y0.toDartDouble + bbox.y1.toDartDouble) / 2,
        confidence: confidence,
      ));
    }

    return digits;
  }
}

// -- JS interop types for Tesseract.js result structure --

@JS('Tesseract.recognize')
external JSPromise<TesseractResult> _tesseractRecognize(
    JSString image, JSString lang);

extension type TesseractResult(JSObject _) implements JSObject {
  external TesseractData get data;
}

extension type TesseractData(JSObject _) implements JSObject {
  external JSArray<TesseractSymbol> get symbols;
}

extension type TesseractSymbol(JSObject _) implements JSObject {
  external JSString get text;
  external JSNumber get confidence;
  external TesseractBBox get bbox;
}

extension type TesseractBBox(JSObject _) implements JSObject {
  external JSNumber get x0;
  external JSNumber get y0;
  external JSNumber get x1;
  external JSNumber get y1;
}

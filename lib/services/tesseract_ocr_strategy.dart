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
      final result = await _runTesseract(blobUrl);
      return _parseResult(result);
    } finally {
      web.URL.revokeObjectURL(blobUrl);
    }
  }

  /// Call Tesseract.js recognize() and return the raw result object.
  Future<JSObject> _runTesseract(String imageUrl) {
    final completer = Completer<JSObject>();

    final promise = _tesseractRecognize(imageUrl.toJS, 'eng'.toJS);
    promise.thenOrCatch(
      ((JSObject result) {
        completer.complete(result);
      }).toJS,
      ((JSAny error) {
        completer.completeError('Tesseract.js error: $error');
      }).toJS,
    );

    return completer.future;
  }

  /// Parse Tesseract.js result into RecognizedDigits.
  List<RecognizedDigit> _parseResult(JSObject result) {
    final digits = <RecognizedDigit>[];
    final digitPattern = RegExp(r'[1-9]');

    final data = result.getProperty('data'.toJS) as JSObject;
    final symbols = data.getProperty('symbols'.toJS) as JSArray;

    for (int i = 0; i < symbols.length; i++) {
      final symbol = symbols[i] as JSObject;
      final text = (symbol.getProperty('text'.toJS) as JSString).toDart.trim();
      if (text.length != 1 || !digitPattern.hasMatch(text)) continue;

      final confidence =
          (symbol.getProperty('confidence'.toJS) as JSNumber).toDartDouble / 100.0;
      if (confidence < 0.3) continue;

      final bbox = symbol.getProperty('bbox'.toJS) as JSObject;
      final x0 = (bbox.getProperty('x0'.toJS) as JSNumber).toDartDouble;
      final y0 = (bbox.getProperty('y0'.toJS) as JSNumber).toDartDouble;
      final x1 = (bbox.getProperty('x1'.toJS) as JSNumber).toDartDouble;
      final y1 = (bbox.getProperty('y1'.toJS) as JSNumber).toDartDouble;

      digits.add(RecognizedDigit(
        value: int.parse(text),
        centerX: (x0 + x1) / 2,
        centerY: (y0 + y1) / 2,
        confidence: confidence,
      ));
    }

    return digits;
  }
}

/// JS interop binding for Tesseract.recognize()
@JS('Tesseract.recognize')
external JSPromise<JSObject> _tesseractRecognize(JSString image, JSString lang);

/// Extension to use Promise.then/catch from Dart.
extension on JSPromise<JSObject> {
  void thenOrCatch(JSFunction onResolve, JSFunction onReject) {
    final thenResult = callMethod('then'.toJS, onResolve) as JSPromise;
    thenResult.callMethod('catch'.toJS, onReject);
  }
}

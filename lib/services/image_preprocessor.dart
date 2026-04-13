import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Preprocesses a Sudoku photo for better OCR accuracy.
/// Pipeline: load → grayscale → contrast boost → adaptive threshold → save.
class ImagePreprocessor {
  /// Process the image and return the path to the cleaned version.
  /// Returns null if processing fails.
  static Future<String?> preprocess(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return null;

      // Resize if too large (ML Kit works better with reasonable sizes)
      if (image.width > 1500 || image.height > 1500) {
        final scale = 1500 / max(image.width, image.height);
        image = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
          interpolation: img.Interpolation.linear,
        );
      }

      // Convert to grayscale
      image = img.grayscale(image);

      // Boost contrast — makes digits stand out from paper
      image = img.contrast(image, contrast: 150);

      // Normalize brightness
      image = img.normalize(image, min: 0, max: 255);

      // Apply a slight sharpening to make digit edges crisp
      image = img.convolution(image, filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0,
      ], div: 1);

      // Adaptive threshold — handles shadows and uneven lighting
      image = _adaptiveThreshold(image, blockSize: 15, c: 10);

      // Save processed image to temp file
      final tempDir = Directory.systemTemp;
      final outputPath = '${tempDir.path}/sudoku_preprocessed.png';
      await File(outputPath).writeAsBytes(img.encodePng(image));

      return outputPath;
    } catch (e) {
      return null;
    }
  }

  /// Simple adaptive thresholding: for each pixel, compare to the mean
  /// of its surrounding block. If darker than mean - c, set to black.
  static img.Image _adaptiveThreshold(
    img.Image src, {
    int blockSize = 15,
    int c = 10,
  }) {
    final w = src.width;
    final h = src.height;
    final half = blockSize ~/ 2;

    // Build integral image for fast block-mean computation
    final integral = List.generate(h + 1, (_) => List.filled(w + 1, 0));
    for (int y = 0; y < h; y++) {
      int rowSum = 0;
      for (int x = 0; x < w; x++) {
        final pixel = src.getPixel(x, y);
        final gray = pixel.r.toInt();
        rowSum += gray;
        integral[y + 1][x + 1] = integral[y][x + 1] + rowSum;
      }
    }

    final result = img.Image(width: w, height: h);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        // Block boundaries (clamped to image edges)
        final y1 = max(0, y - half);
        final y2 = min(h - 1, y + half);
        final x1 = max(0, x - half);
        final x2 = min(w - 1, x + half);

        final count = (y2 - y1 + 1) * (x2 - x1 + 1);
        final blockSum = integral[y2 + 1][x2 + 1] -
            integral[y1][x2 + 1] -
            integral[y2 + 1][x1] +
            integral[y1][x1];
        final mean = blockSum ~/ count;

        final pixel = src.getPixel(x, y);
        final gray = pixel.r.toInt();

        // If pixel is darker than local mean minus constant, it's "ink"
        if (gray < mean - c) {
          result.setPixelRgb(x, y, 0, 0, 0); // Black
        } else {
          result.setPixelRgb(x, y, 255, 255, 255); // White
        }
      }
    }

    return result;
  }
}

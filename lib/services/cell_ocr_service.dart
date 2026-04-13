import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/board.dart';

/// Cell-by-cell OCR: detects grid boundary, crops each of 81 cells,
/// runs ML Kit on each one individually for much higher accuracy.
class CellOcrService {
  /// Recognize a Sudoku grid by cropping and scanning each cell individually.
  Future<Board?> recognizeFromImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return null;

      // Step 1: Preprocess — grayscale + contrast
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 130);

      // Step 2: Find the grid boundary
      final gridRect = _detectGridBounds(image);
      if (gridRect == null) return null;

      // Step 3: Crop to just the grid
      final gridImage = img.copyCrop(
        image,
        x: gridRect.left,
        y: gridRect.top,
        width: gridRect.width,
        height: gridRect.height,
      );

      // Step 4: Divide into 81 cells and classify each
      final grid = List.generate(9, (_) => List.filled(9, 0));
      final cellW = gridImage.width / 9;
      final cellH = gridImage.height / 9;

      // Margin to trim grid lines from cell edges (percentage of cell size)
      final marginX = (cellW * 0.12).round();
      final marginY = (cellH * 0.12).round();

      final tempDir = Directory.systemTemp;
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      try {
        for (int row = 0; row < 9; row++) {
          for (int col = 0; col < 9; col++) {
            final x = (col * cellW + marginX).round();
            final y = (row * cellH + marginY).round();
            final w = (cellW - marginX * 2).round();
            final h = (cellH - marginY * 2).round();

            if (w <= 0 || h <= 0) continue;

            // Crop individual cell
            var cellImage = img.copyCrop(gridImage, x: x, y: y, width: w, height: h);

            // Check if cell has content (enough dark pixels = digit present)
            if (!_hasContent(cellImage)) continue;

            // Enhance cell for better single-digit recognition
            cellImage = _enhanceCell(cellImage);

            // Save cell to temp file for ML Kit
            final cellPath = '${tempDir.path}/cell_${row}_$col.png';
            await File(cellPath).writeAsBytes(img.encodePng(cellImage));

            // Run ML Kit on this single cell
            final digit = await _recognizeCell(textRecognizer, cellPath);
            if (digit != null) {
              grid[row][col] = digit;
            }

            // Clean up temp file
            try { await File(cellPath).delete(); } catch (_) {}
          }
        }
      } finally {
        textRecognizer.close();
      }

      // Validate — remove duplicates in rows/cols/boxes
      _removeDuplicates(grid);

      // Check we got a reasonable number of digits
      final count = grid.expand((r) => r).where((v) => v != 0).length;
      if (count < 8) return null;

      return Board.fromGrid(grid);
    } catch (e) {
      return null;
    }
  }

  /// Detect the grid boundary by finding the largest dark rectangular region.
  /// Uses projection analysis: count dark pixels per row and column to find
  /// where the grid lines are densest.
  _Rect? _detectGridBounds(img.Image image) {
    final w = image.width;
    final h = image.height;

    // Calculate threshold for "dark" pixel
    final threshold = 128;

    // Count dark pixels per row
    final rowDark = List.filled(h, 0);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (image.getPixel(x, y).r.toInt() < threshold) rowDark[y]++;
      }
    }

    // Count dark pixels per column
    final colDark = List.filled(w, 0);
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        if (image.getPixel(x, y).r.toInt() < threshold) colDark[y]++;
      }
    }

    // Find grid boundaries: rows/cols with above-average dark pixel density
    final avgRowDark = rowDark.reduce((a, b) => a + b) / h;
    final avgColDark = colDark.reduce((a, b) => a + b) / w;

    int top = 0, bottom = h - 1, left = 0, right = w - 1;

    // Find first/last rows with significant dark content
    for (int y = 0; y < h; y++) {
      if (rowDark[y] > avgRowDark * 0.5) { top = y; break; }
    }
    for (int y = h - 1; y >= 0; y--) {
      if (rowDark[y] > avgRowDark * 0.5) { bottom = y; break; }
    }
    for (int x = 0; x < w; x++) {
      if (colDark[x] > avgColDark * 0.5) { left = x; break; }
    }
    for (int x = w - 1; x >= 0; x--) {
      if (colDark[x] > avgColDark * 0.5) { right = x; break; }
    }

    // Add small padding
    final pad = 5;
    top = max(0, top - pad);
    left = max(0, left - pad);
    bottom = min(h - 1, bottom + pad);
    right = min(w - 1, right + pad);

    final gridW = right - left;
    final gridH = bottom - top;

    // Sanity check — grid should be roughly square and big enough
    if (gridW < w * 0.3 || gridH < h * 0.3) return null;

    // Make it square (use the smaller dimension)
    final side = min(gridW, gridH);
    final cx = left + gridW ~/ 2;
    final cy = top + gridH ~/ 2;

    return _Rect(
      left: max(0, cx - side ~/ 2),
      top: max(0, cy - side ~/ 2),
      width: min(side, w - max(0, cx - side ~/ 2)),
      height: min(side, h - max(0, cy - side ~/ 2)),
    );
  }

  /// Check if a cell image contains a digit (has enough dark pixels).
  bool _hasContent(img.Image cell) {
    int darkPixels = 0;
    final total = cell.width * cell.height;

    for (int y = 0; y < cell.height; y++) {
      for (int x = 0; x < cell.width; x++) {
        if (cell.getPixel(x, y).r.toInt() < 128) darkPixels++;
      }
    }

    // If more than 3% of pixels are dark, there's likely a digit
    return darkPixels > total * 0.03;
  }

  /// Enhance a single cell image for digit recognition.
  img.Image _enhanceCell(img.Image cell) {
    // Resize to a standard size for consistent recognition
    var enhanced = img.copyResize(cell, width: 80, height: 80,
        interpolation: img.Interpolation.linear);

    // Boost contrast
    enhanced = img.contrast(enhanced, contrast: 160);

    // Add white border (padding) — helps ML Kit read single digits
    final padded = img.Image(width: 120, height: 120);
    img.fill(padded, color: img.ColorRgb8(255, 255, 255));
    img.compositeImage(padded, enhanced, dstX: 20, dstY: 20);

    return padded;
  }

  /// Run ML Kit on a single cell image and return the recognized digit (1-9).
  Future<int?> _recognizeCell(TextRecognizer recognizer, String cellPath) async {
    try {
      final inputImage = InputImage.fromFilePath(cellPath);
      final result = await recognizer.processImage(inputImage);

      // Look for a single digit in the result
      final digitPattern = RegExp(r'[1-9]');

      for (final block in result.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            // Check symbols first
            if (element.symbols.isNotEmpty) {
              for (final symbol in element.symbols) {
                final text = symbol.text.trim();
                if (text.length == 1 && digitPattern.hasMatch(text)) {
                  return int.parse(text);
                }
              }
            }
            // Fallback to element text
            final text = element.text.trim();
            if (text.length == 1 && digitPattern.hasMatch(text)) {
              return int.parse(text);
            }
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Remove duplicate values in rows, columns, and boxes.
  void _removeDuplicates(List<List<int>> grid) {
    // Rows
    for (int r = 0; r < 9; r++) {
      final seen = <int>{};
      for (int c = 0; c < 9; c++) {
        final v = grid[r][c];
        if (v != 0 && !seen.add(v)) grid[r][c] = 0;
      }
    }
    // Columns
    for (int c = 0; c < 9; c++) {
      final seen = <int>{};
      for (int r = 0; r < 9; r++) {
        final v = grid[r][c];
        if (v != 0 && !seen.add(v)) grid[r][c] = 0;
      }
    }
    // Boxes
    for (int br = 0; br < 3; br++) {
      for (int bc = 0; bc < 3; bc++) {
        final seen = <int>{};
        for (int r = br * 3; r < br * 3 + 3; r++) {
          for (int c = bc * 3; c < bc * 3 + 3; c++) {
            final v = grid[r][c];
            if (v != 0 && !seen.add(v)) grid[r][c] = 0;
          }
        }
      }
    }
  }
}

class _Rect {
  final int left, top, width, height;
  const _Rect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

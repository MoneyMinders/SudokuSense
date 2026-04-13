import 'dart:math';

/// A digit recognized by OCR with its spatial position.
class RecognizedDigit {
  final int value;
  final double centerX;
  final double centerY;

  const RecognizedDigit({
    required this.value,
    required this.centerX,
    required this.centerY,
  });
}

/// Converts a list of [RecognizedDigit]s into a 9x9 int grid.
///
/// The algorithm:
///  1. Determine the bounding rectangle of all digits.
///  2. Divide into a 9x9 grid of equal-sized cells.
///  3. Assign each digit to the cell whose center is closest.
///  4. If multiple digits map to the same cell, keep the one closest to the
///     cell center.
class GridParser {
  /// Returns a 9x9 grid (0 = empty) or null if the input is insufficient.
  static List<List<int>>? toGrid(List<RecognizedDigit> digits) {
    if (digits.length < 8) return null; // Too few digits to be a valid puzzle.

    // 1. Find the bounding box of all detected digits.
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final d in digits) {
      if (d.centerX < minX) minX = d.centerX;
      if (d.centerX > maxX) maxX = d.centerX;
      if (d.centerY < minY) minY = d.centerY;
      if (d.centerY > maxY) maxY = d.centerY;
    }

    final width = maxX - minX;
    final height = maxY - minY;

    // Degenerate case: all digits at the same point.
    if (width < 1 || height < 1) return null;

    // 2. Expand the bounding box by half a cell on each side so that the
    //    outermost digits sit in the center of their cells, not on the edge.
    final cellW = width / 8; // 9 cells span 8 gaps between centers.
    final cellH = height / 8;
    final gridMinX = minX - cellW / 2;
    final gridMinY = minY - cellH / 2;
    final gridW = width + cellW;
    final gridH = height + cellH;

    // 3. Assign each digit to the nearest cell.
    //    Map: (row, col) -> (digit, distance).
    final assigned = <(int, int), (RecognizedDigit, double)>{};

    for (final d in digits) {
      // Normalise position into 0..9 range.
      final nx = (d.centerX - gridMinX) / gridW * 9;
      final ny = (d.centerY - gridMinY) / gridH * 9;

      int col = nx.floor().clamp(0, 8);
      int row = ny.floor().clamp(0, 8);

      // Distance to cell center.
      final cellCenterX = (col + 0.5);
      final cellCenterY = (row + 0.5);
      final dist = _distance(nx, ny, cellCenterX, cellCenterY);

      final key = (row, col);
      if (!assigned.containsKey(key) || dist < assigned[key]!.$2) {
        assigned[key] = (d, dist);
      }
    }

    // 4. Build the grid.
    final grid = List.generate(9, (_) => List.filled(9, 0));
    for (final entry in assigned.entries) {
      final row = entry.key.$1;
      final col = entry.key.$2;
      grid[row][col] = entry.value.$1.value;
    }

    return grid;
  }

  static double _distance(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }
}

import 'dart:math';

/// A digit recognized by OCR with its spatial position.
class RecognizedDigit {
  final int value;
  final double centerX;
  final double centerY;
  final double? confidence;

  const RecognizedDigit({
    required this.value,
    required this.centerX,
    required this.centerY,
    this.confidence,
  });
}

/// Converts a list of [RecognizedDigit]s into a 9x9 int grid.
///
/// Pipeline:
///  1. Detect the grid region (filter out UI chrome, headers, number pads).
///  2. Cluster X/Y positions into 9 columns and 9 rows.
///  3. Assign each digit to the nearest cell.
///  4. Validate sudoku constraints and resolve conflicts.
class GridParser {
  /// Returns a 9x9 grid (0 = empty) or null if the input is insufficient.
  static List<List<int>>? toGrid(List<RecognizedDigit> digits) {
    if (digits.length < 8) return null;

    // Step 1: Isolate the grid region from surrounding UI.
    var gridDigits = _isolateGridRegion(digits);
    if (gridDigits.length < 8) return null;

    // Step 2: Cluster into 9 rows and 9 columns.
    final xs = gridDigits.map((d) => d.centerX).toList();
    final ys = gridDigits.map((d) => d.centerY).toList();

    final colCenters = _kMeansClusters(xs, 9);
    final rowCenters = _kMeansClusters(ys, 9);
    if (colCenters == null || rowCenters == null) return null;

    colCenters.sort();
    rowCenters.sort();

    // Step 3: Reject outliers — digits too far from any cell center.
    final avgColGap = (colCenters.last - colCenters.first) / 8;
    final avgRowGap = (rowCenters.last - rowCenters.first) / 8;
    final maxDist = min(avgColGap, avgRowGap) * 0.45;

    gridDigits = gridDigits.where((d) {
      final col = _nearestIndex(colCenters, d.centerX);
      final row = _nearestIndex(rowCenters, d.centerY);
      return _distToCluster(
            d.centerX, d.centerY, colCenters[col], rowCenters[row],
          ) <
          maxDist;
    }).toList();

    if (gridDigits.length < 8) return null;

    // Re-cluster after outlier removal for tighter centers.
    final xs2 = gridDigits.map((d) => d.centerX).toList();
    final ys2 = gridDigits.map((d) => d.centerY).toList();
    final colCenters2 = _kMeansClusters(xs2, 9);
    final rowCenters2 = _kMeansClusters(ys2, 9);
    if (colCenters2 == null || rowCenters2 == null) return null;
    colCenters2.sort();
    rowCenters2.sort();

    // Step 4: Assign digits to cells.
    final assigned = <(int, int), (RecognizedDigit, double)>{};
    for (final d in gridDigits) {
      final col = _nearestIndex(colCenters2, d.centerX);
      final row = _nearestIndex(rowCenters2, d.centerY);
      final dist = _distToCluster(
        d.centerX, d.centerY, colCenters2[col], rowCenters2[row],
      );

      final key = (row, col);
      final existing = assigned[key];
      if (existing == null || dist < existing.$2) {
        assigned[key] = (d, dist);
      }
    }

    // Step 5: Build and validate.
    final grid = List.generate(9, (_) => List.filled(9, 0));
    for (final entry in assigned.entries) {
      grid[entry.key.$1][entry.key.$2] = entry.value.$1.value;
    }

    if (!_isValid(grid)) {
      _resolveConflicts(grid, assigned);
    }

    return grid;
  }

  // ---------------------------------------------------------------------------
  // Grid region isolation
  // ---------------------------------------------------------------------------

  /// Finds the subset of digits that belong to the actual sudoku grid,
  /// filtering out UI elements like headers, footers, and number pads.
  ///
  /// Uses a density-based sliding window: the grid is the densest roughly-square
  /// cluster of digits in the image.
  static List<RecognizedDigit> _isolateGridRegion(List<RecognizedDigit> digits) {
    // If few enough digits that they could all be grid digits, skip filtering.
    if (digits.length <= 81) {
      // Still apply aspect-ratio filtering if the Y range is much larger than X.
      return _aspectFilter(digits);
    }

    // Estimate grid width from the middle 50% of digits (by Y) to avoid
    // header/footer influence on the X range estimate.
    final byY = List<RecognizedDigit>.from(digits)
      ..sort((a, b) => a.centerY.compareTo(b.centerY));

    final midStart = digits.length ~/ 4;
    final midEnd = 3 * digits.length ~/ 4;
    final midDigits = byY.sublist(midStart, midEnd);

    double midMinX = double.infinity, midMaxX = double.negativeInfinity;
    for (final d in midDigits) {
      if (d.centerX < midMinX) midMinX = d.centerX;
      if (d.centerX > midMaxX) midMaxX = d.centerX;
    }
    final estimatedGridWidth = midMaxX - midMinX;
    if (estimatedGridWidth < 1) return digits;

    // The grid is square, so scan a window of this height through Y.
    final windowH = estimatedGridWidth * 1.15;

    final yMin = byY.first.centerY;
    final yMax = byY.last.centerY;

    // Slide the window in small steps to find the densest region.
    final steps = 40;
    final step = max(1.0, (yMax - yMin - windowH) / steps);

    List<RecognizedDigit>? bestWindow;
    int bestCount = 0;

    for (double yStart = yMin - step;
        yStart + windowH <= yMax + step * 2;
        yStart += step) {
      final yEnd = yStart + windowH;
      final inWindow = digits
          .where((d) => d.centerY >= yStart && d.centerY <= yEnd)
          .toList();
      if (inWindow.length > bestCount) {
        bestCount = inWindow.length;
        bestWindow = inWindow;
      }
    }

    return bestWindow ?? digits;
  }

  /// Remove digits that fall far outside a square aspect ratio.
  /// If the Y span is much larger than X span (or vice versa), trim extremes.
  static List<RecognizedDigit> _aspectFilter(List<RecognizedDigit> digits) {
    if (digits.length < 8) return digits;

    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final d in digits) {
      if (d.centerX < minX) minX = d.centerX;
      if (d.centerX > maxX) maxX = d.centerX;
      if (d.centerY < minY) minY = d.centerY;
      if (d.centerY > maxY) maxY = d.centerY;
    }

    final w = maxX - minX;
    final h = maxY - minY;
    if (w < 1 || h < 1) return digits;

    // If roughly square already, no filtering needed.
    final ratio = h / w;
    if (ratio < 1.3 && ratio > 0.7) return digits;

    // Trim the longer axis to match the shorter.
    if (h > w) {
      // Too tall — trim Y. Center the square window on the Y median.
      final ys = digits.map((d) => d.centerY).toList()..sort();
      final medianY = ys[ys.length ~/ 2];
      final halfSize = w * 0.6;
      return digits
          .where(
              (d) => d.centerY >= medianY - halfSize && d.centerY <= medianY + halfSize)
          .toList();
    } else {
      // Too wide — trim X.
      final xs = digits.map((d) => d.centerX).toList()..sort();
      final medianX = xs[xs.length ~/ 2];
      final halfSize = h * 0.6;
      return digits
          .where(
              (d) => d.centerX >= medianX - halfSize && d.centerX <= medianX + halfSize)
          .toList();
    }
  }

  // ---------------------------------------------------------------------------
  // K-means clustering
  // ---------------------------------------------------------------------------

  /// 1-D k-means. Returns [k] sorted cluster centers, or null if insufficient.
  static List<double>? _kMeansClusters(List<double> values, int k) {
    if (values.length < k) return null;

    final sorted = List<double>.from(values)..sort();
    final lo = sorted.first;
    final hi = sorted.last;
    final span = hi - lo;
    if (span < 1) return null;

    var centers = List.generate(k, (i) => lo + span * i / (k - 1));

    for (int iter = 0; iter < 50; iter++) {
      final sums = List.filled(k, 0.0);
      final counts = List.filled(k, 0);

      for (final v in values) {
        final idx = _nearestIndex(centers, v);
        sums[idx] += v;
        counts[idx]++;
      }

      var converged = true;
      final newCenters = List<double>.filled(k, 0);
      for (int i = 0; i < k; i++) {
        newCenters[i] = counts[i] > 0 ? sums[i] / counts[i] : centers[i];
        if ((newCenters[i] - centers[i]).abs() > 0.5) converged = false;
      }

      centers = newCenters;
      if (converged) break;
    }

    final sortedCenters = List<double>.from(centers)..sort();
    final avgGap = (sortedCenters.last - sortedCenters.first) / (k - 1);

    // If two clusters collapsed together, fall back to even spacing.
    for (int i = 1; i < k; i++) {
      if ((sortedCenters[i] - sortedCenters[i - 1]) < avgGap * 0.3) {
        return _evenlySpaced(lo, hi, k);
      }
    }

    return sortedCenters;
  }

  static List<double> _evenlySpaced(double lo, double hi, int k) {
    final cellSize = (hi - lo) / (k - 1);
    return List.generate(k, (i) => lo + cellSize * i);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static int _nearestIndex(List<double> centers, double value) {
    int best = 0;
    double bestDist = (centers[0] - value).abs();
    for (int i = 1; i < centers.length; i++) {
      final d = (centers[i] - value).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  static double _distToCluster(double x, double y, double cx, double cy) {
    final dx = x - cx;
    final dy = y - cy;
    return sqrt(dx * dx + dy * dy);
  }

  // ---------------------------------------------------------------------------
  // Sudoku validation & conflict resolution
  // ---------------------------------------------------------------------------

  static bool _isValid(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      final seen = <int>{};
      for (int c = 0; c < 9; c++) {
        final v = grid[r][c];
        if (v != 0 && !seen.add(v)) return false;
      }
    }
    for (int c = 0; c < 9; c++) {
      final seen = <int>{};
      for (int r = 0; r < 9; r++) {
        final v = grid[r][c];
        if (v != 0 && !seen.add(v)) return false;
      }
    }
    for (int br = 0; br < 3; br++) {
      for (int bc = 0; bc < 3; bc++) {
        final seen = <int>{};
        for (int r = br * 3; r < br * 3 + 3; r++) {
          for (int c = bc * 3; c < bc * 3 + 3; c++) {
            final v = grid[r][c];
            if (v != 0 && !seen.add(v)) return false;
          }
        }
      }
    }
    return true;
  }

  static void _resolveConflicts(
    List<List<int>> grid,
    Map<(int, int), (RecognizedDigit, double)> assigned,
  ) {
    _resolveGroup(grid, assigned, _rowCells);
    _resolveGroup(grid, assigned, _colCells);
    _resolveGroup(grid, assigned, _boxCells);
  }

  static Iterable<List<(int, int)>> _rowCells() sync* {
    for (int r = 0; r < 9; r++) {
      yield [for (int c = 0; c < 9; c++) (r, c)];
    }
  }

  static Iterable<List<(int, int)>> _colCells() sync* {
    for (int c = 0; c < 9; c++) {
      yield [for (int r = 0; r < 9; r++) (r, c)];
    }
  }

  static Iterable<List<(int, int)>> _boxCells() sync* {
    for (int br = 0; br < 3; br++) {
      for (int bc = 0; bc < 3; bc++) {
        yield [
          for (int r = br * 3; r < br * 3 + 3; r++)
            for (int c = bc * 3; c < bc * 3 + 3; c++) (r, c),
        ];
      }
    }
  }

  static void _resolveGroup(
    List<List<int>> grid,
    Map<(int, int), (RecognizedDigit, double)> assigned,
    Iterable<List<(int, int)>> Function() groupFn,
  ) {
    for (final cells in groupFn()) {
      final byValue = <int, List<(int, int)>>{};
      for (final cell in cells) {
        final v = grid[cell.$1][cell.$2];
        if (v != 0) {
          (byValue[v] ??= []).add(cell);
        }
      }
      for (final entry in byValue.entries) {
        if (entry.value.length <= 1) continue;
        (int, int)? bestCell;
        double bestScore = double.negativeInfinity;
        for (final cell in entry.value) {
          final data = assigned[cell];
          if (data == null) continue;
          final conf = data.$1.confidence ?? 0.8;
          final dist = data.$2;
          final score = conf - dist * 0.001;
          if (score > bestScore) {
            bestScore = score;
            bestCell = cell;
          }
        }
        for (final cell in entry.value) {
          if (cell != bestCell) {
            grid[cell.$1][cell.$2] = 0;
          }
        }
      }
    }
  }
}

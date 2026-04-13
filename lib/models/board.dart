import 'cell.dart';

class Board {
  final List<List<Cell>> cells;

  Board(this.cells);

  factory Board.empty() {
    return Board(
      List.generate(9, (_) => List.generate(9, (_) => Cell.empty())),
    );
  }

  /// Create board from int grid. 0 = empty, 1-9 = fixed values.
  factory Board.fromGrid(List<List<int>> grid) {
    return Board(
      List.generate(9, (r) => List.generate(9, (c) {
        final v = grid[r][c];
        return v == 0 ? Cell.empty() : Cell.fixed(v);
      })),
    );
  }

  /// Deep copy the entire board.
  Board deepCopy() {
    return Board(
      List.generate(9, (r) => List.generate(9, (c) =>
        cells[r][c].copyWith())),
    );
  }

  /// Convert to int grid (0 for empty).
  List<List<int>> toGrid() {
    return List.generate(9, (r) =>
      List.generate(9, (c) => cells[r][c].value ?? 0));
  }

  /// Check if board has no duplicate values in any row/col/box.
  bool isValid() {
    for (int i = 0; i < 9; i++) {
      if (_hasDuplicates(getRow(i)) ||
          _hasDuplicates(getCol(i)) ||
          _hasDuplicates(getBox(i))) {
        return false;
      }
    }
    return true;
  }

  bool _hasDuplicates(List<Cell> cells) {
    final values = cells
        .where((c) => c.value != null)
        .map((c) => c.value!);
    return values.length != values.toSet().length;
  }

  /// Check if all cells are filled and valid.
  bool isComplete() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (cells[r][c].value == null) return false;
      }
    }
    return isValid();
  }

  /// Set value on a non-fixed cell.
  void setValue(int row, int col, int value) {
    final cell = cells[row][col];
    if (!cell.isFixed) {
      cell.value = value;
      cell.candidates.clear();
    }
  }

  /// Clear a non-fixed cell.
  void clearCell(int row, int col) {
    final cell = cells[row][col];
    if (!cell.isFixed) {
      cell.value = null;
    }
  }

  /// Get candidates for a cell based on current board state.
  Set<int> getCandidatesForCell(int row, int col) {
    if (cells[row][col].value != null) return {};
    final used = <int>{};
    for (final c in getRow(row)) {
      if (c.value != null) used.add(c.value!);
    }
    for (final c in getCol(col)) {
      if (c.value != null) used.add(c.value!);
    }
    for (final c in getBox(boxIndexOf(row, col))) {
      if (c.value != null) used.add(c.value!);
    }
    return {for (int n = 1; n <= 9; n++) if (!used.contains(n)) n};
  }

  Cell getCell(int row, int col) => cells[row][col];

  void setCell(int row, int col, Cell cell) => cells[row][col] = cell;

  /// Get all cells in a row.
  List<Cell> getRow(int row) => cells[row];

  /// Get all cells in a column.
  List<Cell> getCol(int col) => [for (int r = 0; r < 9; r++) cells[r][col]];

  /// Get all cells in a 3x3 box (boxIndex 0-8, left-to-right, top-to-bottom).
  List<Cell> getBox(int boxIndex) {
    final startRow = (boxIndex ~/ 3) * 3;
    final startCol = (boxIndex % 3) * 3;
    return [
      for (int r = startRow; r < startRow + 3; r++)
        for (int c = startCol; c < startCol + 3; c++) cells[r][c],
    ];
  }

  /// Get (row, col) positions for all cells in a row.
  List<(int, int)> getRowPositions(int row) =>
      [for (int c = 0; c < 9; c++) (row, c)];

  /// Get (row, col) positions for all cells in a column.
  List<(int, int)> getColPositions(int col) =>
      [for (int r = 0; r < 9; r++) (r, col)];

  /// Get (row, col) positions for all cells in a box.
  List<(int, int)> getBoxPositions(int boxIndex) {
    final startRow = (boxIndex ~/ 3) * 3;
    final startCol = (boxIndex % 3) * 3;
    return [
      for (int r = startRow; r < startRow + 3; r++)
        for (int c = startCol; c < startCol + 3; c++) (r, c),
    ];
  }

  /// Get the box index (0-8) for a given (row, col).
  static int boxIndexOf(int row, int col) => (row ~/ 3) * 3 + (col ~/ 3);

  /// Populate candidates for all empty cells based on current board state.
  void calculateCandidates() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = cells[r][c];
        if (cell.value != null) {
          cell.candidates.clear();
          continue;
        }
        final used = <int>{};
        for (final peer in getRow(r)) {
          if (peer.value != null) used.add(peer.value!);
        }
        for (final peer in getCol(c)) {
          if (peer.value != null) used.add(peer.value!);
        }
        for (final peer in getBox(boxIndexOf(r, c))) {
          if (peer.value != null) used.add(peer.value!);
        }
        cell.candidates = {for (int n = 1; n <= 9; n++) if (!used.contains(n)) n};
      }
    }
  }

  @override
  String toString() {
    final buf = StringBuffer();
    for (int r = 0; r < 9; r++) {
      buf.writeln(cells[r].map((c) => c.toString()).join(' '));
    }
    return buf.toString();
  }
}

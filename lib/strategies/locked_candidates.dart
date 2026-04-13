import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

/// Pointing: A candidate in a box is confined to one row or column.
/// Eliminate that candidate from the rest of that row/col outside the box.
class LockedCandidatesPointingStrategy extends Strategy {
  @override
  String get name => 'Locked Candidates (Pointing)';

  @override
  Difficulty get difficulty => Difficulty.medium;

  @override
  HintResult? apply(Board board) {
    for (int box = 0; box < 9; box++) {
      final boxPositions = board.getBoxPositions(box);

      for (int num = 1; num <= 9; num++) {
        // Find all positions in this box where num is a candidate.
        final positions = <(int, int)>[];
        for (final pos in boxPositions) {
          final cell = board.getCell(pos.$1, pos.$2);
          if (cell.value == null && cell.candidates.contains(num)) {
            positions.add(pos);
          }
        }
        if (positions.length < 2) continue;

        // Check if all confined to one row.
        final rows = positions.map((p) => p.$1).toSet();
        if (rows.length == 1) {
          final row = rows.first;
          final eliminations = <Elimination>[];
          for (final pos in board.getRowPositions(row)) {
            if (Board.boxIndexOf(pos.$1, pos.$2) == box) continue;
            final cell = board.getCell(pos.$1, pos.$2);
            if (cell.value == null && cell.candidates.contains(num)) {
              eliminations.add(
                Elimination(row: pos.$1, col: pos.$2, value: num),
              );
            }
          }
          if (eliminations.isNotEmpty) {
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'In box ${box + 1}, the candidate $num is confined to '
                  'row ${row + 1}. It can be removed from the rest of '
                  'row ${row + 1} outside this box.',
              eliminations: eliminations,
              highlightedCells: positions,
            );
          }
        }

        // Check if all confined to one column.
        final cols = positions.map((p) => p.$2).toSet();
        if (cols.length == 1) {
          final col = cols.first;
          final eliminations = <Elimination>[];
          for (final pos in board.getColPositions(col)) {
            if (Board.boxIndexOf(pos.$1, pos.$2) == box) continue;
            final cell = board.getCell(pos.$1, pos.$2);
            if (cell.value == null && cell.candidates.contains(num)) {
              eliminations.add(
                Elimination(row: pos.$1, col: pos.$2, value: num),
              );
            }
          }
          if (eliminations.isNotEmpty) {
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'In box ${box + 1}, the candidate $num is confined to '
                  'column ${col + 1}. It can be removed from the rest of '
                  'column ${col + 1} outside this box.',
              eliminations: eliminations,
              highlightedCells: positions,
            );
          }
        }
      }
    }
    return null;
  }
}

/// Claiming: A candidate in a row/col is confined to one box.
/// Eliminate that candidate from the rest of that box.
class LockedCandidatesClaimingStrategy extends Strategy {
  @override
  String get name => 'Locked Candidates (Claiming)';

  @override
  Difficulty get difficulty => Difficulty.medium;

  @override
  HintResult? apply(Board board) {
    // Check rows.
    for (int row = 0; row < 9; row++) {
      for (int num = 1; num <= 9; num++) {
        final positions = <(int, int)>[];
        for (final pos in board.getRowPositions(row)) {
          final cell = board.getCell(pos.$1, pos.$2);
          if (cell.value == null && cell.candidates.contains(num)) {
            positions.add(pos);
          }
        }
        if (positions.length < 2) continue;

        final boxes = positions.map((p) => Board.boxIndexOf(p.$1, p.$2)).toSet();
        if (boxes.length == 1) {
          final box = boxes.first;
          final eliminations = <Elimination>[];
          for (final pos in board.getBoxPositions(box)) {
            if (pos.$1 == row) continue; // Same row, skip.
            final cell = board.getCell(pos.$1, pos.$2);
            if (cell.value == null && cell.candidates.contains(num)) {
              eliminations.add(
                Elimination(row: pos.$1, col: pos.$2, value: num),
              );
            }
          }
          if (eliminations.isNotEmpty) {
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'In row ${row + 1}, the candidate $num is confined to '
                  'box ${box + 1}. It can be removed from the rest of '
                  'box ${box + 1} outside this row.',
              eliminations: eliminations,
              highlightedCells: positions,
            );
          }
        }
      }
    }

    // Check columns.
    for (int col = 0; col < 9; col++) {
      for (int num = 1; num <= 9; num++) {
        final positions = <(int, int)>[];
        for (final pos in board.getColPositions(col)) {
          final cell = board.getCell(pos.$1, pos.$2);
          if (cell.value == null && cell.candidates.contains(num)) {
            positions.add(pos);
          }
        }
        if (positions.length < 2) continue;

        final boxes = positions.map((p) => Board.boxIndexOf(p.$1, p.$2)).toSet();
        if (boxes.length == 1) {
          final box = boxes.first;
          final eliminations = <Elimination>[];
          for (final pos in board.getBoxPositions(box)) {
            if (pos.$2 == col) continue; // Same column, skip.
            final cell = board.getCell(pos.$1, pos.$2);
            if (cell.value == null && cell.candidates.contains(num)) {
              eliminations.add(
                Elimination(row: pos.$1, col: pos.$2, value: num),
              );
            }
          }
          if (eliminations.isNotEmpty) {
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'In column ${col + 1}, the candidate $num is confined to '
                  'box ${box + 1}. It can be removed from the rest of '
                  'box ${box + 1} outside this column.',
              eliminations: eliminations,
              highlightedCells: positions,
            );
          }
        }
      }
    }

    return null;
  }
}

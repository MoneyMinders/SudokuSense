import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class NakedTripleStrategy extends Strategy {
  @override
  String get name => 'Naked Triple';

  @override
  Difficulty get difficulty => Difficulty.medium;

  @override
  HintResult? apply(Board board) {
    for (int r = 0; r < 9; r++) {
      final result = _checkUnit(board, board.getRowPositions(r), 'row ${r + 1}');
      if (result != null) return result;
    }
    for (int c = 0; c < 9; c++) {
      final result = _checkUnit(board, board.getColPositions(c), 'column ${c + 1}');
      if (result != null) return result;
    }
    for (int b = 0; b < 9; b++) {
      final result = _checkUnit(board, board.getBoxPositions(b), 'box ${b + 1}');
      if (result != null) return result;
    }
    return null;
  }

  HintResult? _checkUnit(
    Board board,
    List<(int, int)> positions,
    String unitName,
  ) {
    // Gather unsolved cells with 2 or 3 candidates.
    final unsolved = <(int, int)>[];
    for (final pos in positions) {
      final cell = board.getCell(pos.$1, pos.$2);
      if (cell.value == null && cell.candidates.length >= 2 && cell.candidates.length <= 3) {
        unsolved.add(pos);
      }
    }

    // Try every combination of 3 cells.
    for (int i = 0; i < unsolved.length; i++) {
      for (int j = i + 1; j < unsolved.length; j++) {
        for (int k = j + 1; k < unsolved.length; k++) {
          final c1 = board.getCell(unsolved[i].$1, unsolved[i].$2).candidates;
          final c2 = board.getCell(unsolved[j].$1, unsolved[j].$2).candidates;
          final c3 = board.getCell(unsolved[k].$1, unsolved[k].$2).candidates;

          final union = {...c1, ...c2, ...c3};
          if (union.length != 3) continue;

          // Found a naked triple. Check for eliminations.
          final tripleCells = {unsolved[i], unsolved[j], unsolved[k]};
          final eliminations = <Elimination>[];
          for (final pos in positions) {
            if (tripleCells.contains(pos)) continue;
            final cell = board.getCell(pos.$1, pos.$2);
            if (cell.value != null) continue;
            for (final val in union) {
              if (cell.candidates.contains(val)) {
                eliminations.add(
                  Elimination(row: pos.$1, col: pos.$2, value: val),
                );
              }
            }
          }

          if (eliminations.isNotEmpty) {
            final tripleStr = '{${(union.toList()..sort()).join(',')}}';
            final p1 = unsolved[i];
            final p2 = unsolved[j];
            final p3 = unsolved[k];
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'Cells (${p1.$1 + 1},${p1.$2 + 1}), '
                  '(${p2.$1 + 1},${p2.$2 + 1}), and '
                  '(${p3.$1 + 1},${p3.$2 + 1}) in $unitName have '
                  'candidates that together form the triple $tripleStr. '
                  'These numbers can be removed from all other cells in '
                  'this $unitName.',
              eliminations: eliminations,
              highlightedCells: [p1, p2, p3],
            );
          }
        }
      }
    }
    return null;
  }
}

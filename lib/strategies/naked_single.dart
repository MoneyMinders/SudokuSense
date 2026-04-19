import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class NakedSingleStrategy extends Strategy {
  @override
  String get name => 'Naked Single';

  @override
  Difficulty get difficulty => Difficulty.easy;

  @override
  HintResult? apply(Board board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = board.getCell(r, c);
        if (cell.value != null) continue;
        if (cell.candidates.length == 1) {
          final value = cell.candidates.first;

          // Collect digits already present in the cell's row, column, and box
          // so the explanation can show exactly what rules out every other value.
          final rowVals = <int>{};
          for (final rc in board.getRow(r)) {
            if (rc.value != null) rowVals.add(rc.value!);
          }
          final colVals = <int>{};
          for (final cc in board.getCol(c)) {
            if (cc.value != null) colVals.add(cc.value!);
          }
          final boxVals = <int>{};
          for (final bc in board.getBox(Board.boxIndexOf(r, c))) {
            if (bc.value != null) boxVals.add(bc.value!);
          }

          String fmt(Set<int> s) =>
              s.isEmpty ? '{}' : '{${(s.toList()..sort()).join(', ')}}';

          return HintResult(
            strategyName: name,
            difficulty: difficulty,
            explanation:
                'R${r + 1}C${c + 1} must be $value. The cell shares its row '
                'with ${fmt(rowVals)}, its column with ${fmt(colVals)}, and its '
                '3×3 box with ${fmt(boxVals)}. Those three constraints together '
                'already use every digit except $value, so $value is the only '
                'value that can legally sit in this cell.',
            placements: [
              Placement(row: r, col: c, value: value),
            ],
            highlightedCells: [(r, c)],
          );
        }
      }
    }
    return null;
  }
}

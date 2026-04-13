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
          return HintResult(
            strategyName: name,
            difficulty: difficulty,
            explanation:
                'Cell (${r + 1},${c + 1}) can only be $value — all other '
                'numbers are already present in its row, column, or box.',
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

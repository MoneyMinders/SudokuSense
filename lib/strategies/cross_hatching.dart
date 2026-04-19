import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class CrossHatchingStrategy extends Strategy {
  @override
  String get name => 'Cross-Hatching';

  @override
  Difficulty get difficulty => Difficulty.easy;

  @override
  HintResult? apply(Board board) {
    for (int num = 1; num <= 9; num++) {
      for (int box = 0; box < 9; box++) {
        final positions = board.getBoxPositions(box);
        final boxCells = board.getBox(box);

        // Skip if number already placed in this box.
        if (boxCells.any((c) => c.value == num)) continue;

        // Find which cells in this box could hold this number.
        final possiblePositions = <(int, int)>[];
        for (final pos in positions) {
          final cell = board.getCell(pos.$1, pos.$2);
          if (cell.value != null) continue;
          if (!cell.candidates.contains(num)) continue;
          possiblePositions.add(pos);
        }

        if (possiblePositions.length == 1) {
          final target = possiblePositions.first;
          return HintResult(
            strategyName: name,
            difficulty: difficulty,
            explanation:
                'Box ${box + 1} still needs a $num somewhere. Scanning the rows '
                'and columns that pass through this box, every empty cell except '
                'R${target.$1 + 1}C${target.$2 + 1} lies on a row or column that '
                'already contains $num. R${target.$1 + 1}C${target.$2 + 1} is the '
                'only position left inside the box where $num can legally be '
                'placed, so $num goes there.',
            placements: [
              Placement(row: target.$1, col: target.$2, value: num),
            ],
            highlightedCells: possiblePositions,
          );
        }
      }
    }
    return null;
  }
}

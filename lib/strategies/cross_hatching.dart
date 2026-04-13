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
                'The number $num can only go in row ${target.$1 + 1}, '
                'column ${target.$2 + 1} of box ${box + 1} because $num '
                'already appears in all other possible rows and columns.',
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

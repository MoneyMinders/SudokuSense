import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class HiddenSingleStrategy extends Strategy {
  @override
  String get name => 'Hidden Single';

  @override
  Difficulty get difficulty => Difficulty.easy;

  @override
  HintResult? apply(Board board) {
    // Check rows
    for (int r = 0; r < 9; r++) {
      final result = _checkUnit(
        board,
        board.getRowPositions(r),
        'row ${r + 1}',
      );
      if (result != null) return result;
    }

    // Check columns
    for (int c = 0; c < 9; c++) {
      final result = _checkUnit(
        board,
        board.getColPositions(c),
        'column ${c + 1}',
      );
      if (result != null) return result;
    }

    // Check boxes
    for (int b = 0; b < 9; b++) {
      final result = _checkUnit(
        board,
        board.getBoxPositions(b),
        'box ${b + 1}',
      );
      if (result != null) return result;
    }

    return null;
  }

  HintResult? _checkUnit(
    Board board,
    List<(int, int)> positions,
    String unitName,
  ) {
    for (int num = 1; num <= 9; num++) {
      final cellsWithCandidate = <(int, int)>[];
      for (final pos in positions) {
        final cell = board.getCell(pos.$1, pos.$2);
        if (cell.value == num) {
          cellsWithCandidate.clear();
          break; // Already placed
        }
        if (cell.value == null && cell.candidates.contains(num)) {
          cellsWithCandidate.add(pos);
        }
      }
      if (cellsWithCandidate.length == 1) {
        final target = cellsWithCandidate.first;
        return HintResult(
          strategyName: name,
          difficulty: difficulty,
          explanation:
              'In $unitName, the number $num can only go in cell '
              '(${target.$1 + 1},${target.$2 + 1}).',
          placements: [
            Placement(row: target.$1, col: target.$2, value: num),
          ],
          highlightedCells: cellsWithCandidate,
        );
      }
    }
    return null;
  }
}

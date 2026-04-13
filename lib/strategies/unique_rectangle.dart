import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class UniqueRectangleStrategy extends Strategy {
  @override
  String get name => 'Unique Rectangle';

  @override
  Difficulty get difficulty => Difficulty.hard;

  @override
  HintResult? apply(Board board) {
    // Find all unsolved cells with exactly 2 candidates
    final biValueCells = <(int, int, Set<int>)>[];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final cell = board.getCell(r, c);
        if (cell.value == null && cell.candidates.length == 2) {
          biValueCells.add((r, c, Set<int>.from(cell.candidates)));
        }
      }
    }

    // Type 1: Find 3 bi-value cells with same 2 candidates forming 3 corners of a rectangle
    // The 4th corner must contain those candidates (plus possibly others)
    for (var i = 0; i < biValueCells.length; i++) {
      for (var j = i + 1; j < biValueCells.length; j++) {
        for (var k = j + 1; k < biValueCells.length; k++) {
          final cells = [biValueCells[i], biValueCells[j], biValueCells[k]];
          final cands0 = cells[0].$3;
          final cands1 = cells[1].$3;
          final cands2 = cells[2].$3;

          // All 3 must have the same 2 candidates
          if (!_setsEqual(cands0, cands1) || !_setsEqual(cands0, cands2)) {
            continue;
          }

          final pair = cands0;

          // Check if they form 3 corners of a rectangle (2 rows, 2 columns)
          final rows = {cells[0].$1, cells[1].$1, cells[2].$1};
          final cols = {cells[0].$2, cells[1].$2, cells[2].$2};

          if (rows.length != 2 || cols.length != 2) continue;

          final rowList = rows.toList();
          final colList = cols.toList();

          // Find which corner is missing
          final allCorners = <(int, int)>[
            (rowList[0], colList[0]),
            (rowList[0], colList[1]),
            (rowList[1], colList[0]),
            (rowList[1], colList[1]),
          ];

          final existingCorners = cells.map((c) => (c.$1, c.$2)).toSet();
          final missingCorner = allCorners
              .where((corner) => !existingCorners.contains(corner))
              .first;

          // Rectangle must span exactly 2 boxes
          final boxIndices = allCorners
              .map((c) => board.getBoxIndex(c.$1, c.$2))
              .toSet();
          if (boxIndices.length != 2) continue;

          // Check the 4th cell
          final fourthCell =
              board.getCell(missingCorner.$1, missingCorner.$2);
          if (fourthCell.value != null) continue;
          if (fourthCell.candidates.length <= 2) continue;

          // The 4th cell must contain both candidates of the pair
          if (!fourthCell.candidates.containsAll(pair)) continue;

          // Eliminate the pair candidates from the 4th cell
          final eliminations = <(int, int), Set<int>>{
            missingCorner: Set<int>.from(pair),
          };

          final highlightCells = [
            ...existingCorners,
            missingCorner,
          ];

          final pairList = pair.toList()..sort();
          return HintResult(
            strategyName: name,
            difficulty: difficulty,
            explanation:
                'Cells R${rowList[0] + 1}C${colList[0] + 1}, R${rowList[0] + 1}C${colList[1] + 1}, '
                'R${rowList[1] + 1}C${colList[0] + 1}, R${rowList[1] + 1}C${colList[1] + 1} form '
                'a Unique Rectangle with candidates {${pairList.join(', ')}}. '
                'Three corners are bi-value, so the fourth corner at '
                'R${missingCorner.$1 + 1}C${missingCorner.$2 + 1} '
                'cannot have only {${pairList.join(', ')}} (would create a deadly pattern). '
                '${pairList.join(' and ')} can be eliminated from that cell.',
            highlightCells: highlightCells,
            eliminations: eliminations,
          );
        }
      }
    }

    return null;
  }

  bool _setsEqual(Set<int> a, Set<int> b) {
    return a.length == b.length && a.containsAll(b);
  }
}

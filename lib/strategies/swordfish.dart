import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class SwordfishStrategy extends Strategy {
  @override
  String get name => 'Swordfish';

  @override
  Difficulty get difficulty => Difficulty.hard;

  @override
  HintResult? apply(Board board) {
    final rowResult = _findSwordfish(board, isRowBased: true);
    if (rowResult != null) return rowResult;
    return _findSwordfish(board, isRowBased: false);
  }

  HintResult? _findSwordfish(Board board, {required bool isRowBased}) {
    for (var digit = 1; digit <= 9; digit++) {
      // Find lines where digit appears in 2-3 cells
      final candidateLines = <int, List<int>>{};

      for (var line = 0; line < 9; line++) {
        final positions = <int>[];
        for (var cross = 0; cross < 9; cross++) {
          final row = isRowBased ? line : cross;
          final col = isRowBased ? cross : line;
          final cell = board.getCell(row, col);
          if (cell.value == null && cell.candidates.contains(digit)) {
            positions.add(cross);
          }
        }
        if (positions.length >= 2 && positions.length <= 3) {
          candidateLines[line] = positions;
        }
      }

      final lines = candidateLines.keys.toList();
      if (lines.length < 3) continue;

      // Check all triples of lines
      for (var i = 0; i < lines.length; i++) {
        for (var j = i + 1; j < lines.length; j++) {
          for (var k = j + 1; k < lines.length; k++) {
            final line1 = lines[i];
            final line2 = lines[j];
            final line3 = lines[k];

            // Collect all cross-positions used
            final crossPositions = <int>{
              ...candidateLines[line1]!,
              ...candidateLines[line2]!,
              ...candidateLines[line3]!,
            };

            // Must span exactly 3 cross-positions
            if (crossPositions.length != 3) continue;

            final crossList = crossPositions.toList()..sort();
            final highlightedCells = <(int, int)>[];
            final eliminations = <Elimination>[];

            // Highlight the swordfish cells
            for (final line in [line1, line2, line3]) {
              for (final cross in candidateLines[line]!) {
                final row = isRowBased ? line : cross;
                final col = isRowBased ? cross : line;
                highlightedCells.add((row, col));
              }
            }

            // Eliminate from other cells in the 3 cross-lines
            for (final cross in crossList) {
              for (var line = 0; line < 9; line++) {
                if (line == line1 || line == line2 || line == line3) continue;
                final row = isRowBased ? line : cross;
                final col = isRowBased ? cross : line;
                final cell = board.getCell(row, col);
                if (cell.value == null && cell.candidates.contains(digit)) {
                  eliminations.add(
                    Elimination(row: row, col: col, value: digit),
                  );
                }
              }
            }

            if (eliminations.isNotEmpty) {
              final lineLabel = isRowBased ? 'rows' : 'columns';
              final crossLabel = isRowBased ? 'columns' : 'rows';

              final linesStr =
                  [line1, line2, line3].map((l) => l + 1).join(', ');
              final crossStr = crossList.map((c) => c + 1).join(', ');
              return HintResult(
                strategyName: name,
                difficulty: difficulty,
                explanation:
                    'Swordfish on digit $digit. Across $lineLabel $linesStr, '
                    'every occurrence of $digit lies within the same three '
                    '$crossLabel $crossStr. Each of those $lineLabel needs one '
                    '$digit and the only cells available fall inside those '
                    'three $crossLabel — by pigeonhole, the three copies of '
                    '$digit are distributed one per $crossLabel. That fills every '
                    'permitted slot for $digit in $crossLabel $crossStr, so '
                    '$digit cannot appear in any other cell of those '
                    '$crossLabel and is eliminated from them.',
                highlightedCells: highlightedCells,
                eliminations: eliminations,
              );
            }
          }
        }
      }
    }
    return null;
  }
}

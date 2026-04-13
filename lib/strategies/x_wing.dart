import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class XWingStrategy extends Strategy {
  @override
  String get name => 'X-Wing';

  @override
  Difficulty get difficulty => Difficulty.hard;

  @override
  HintResult? apply(Board board) {
    // Check row-based X-Wings
    final rowResult = _findXWing(board, isRowBased: true);
    if (rowResult != null) return rowResult;

    // Check column-based X-Wings
    return _findXWing(board, isRowBased: false);
  }

  HintResult? _findXWing(Board board, {required bool isRowBased}) {
    for (var digit = 1; digit <= 9; digit++) {
      // Find all lines where digit appears in exactly 2 cells
      final linesWithTwo = <int, List<int>>{};

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
        if (positions.length == 2) {
          linesWithTwo[line] = positions;
        }
      }

      // Check all pairs of lines
      final lines = linesWithTwo.keys.toList();
      for (var i = 0; i < lines.length; i++) {
        for (var j = i + 1; j < lines.length; j++) {
          final line1 = lines[i];
          final line2 = lines[j];
          final pos1 = linesWithTwo[line1]!;
          final pos2 = linesWithTwo[line2]!;

          // Check if they share the same 2 cross-positions
          if (pos1[0] == pos2[0] && pos1[1] == pos2[1]) {
            final cross1 = pos1[0];
            final cross2 = pos1[1];

            // Find eliminations in the two cross-lines
            final eliminations = <Elimination>[];
            final highlightedCells = <(int, int)>[];

            // Add the 4 X-Wing cells to highlights
            for (final line in [line1, line2]) {
              for (final cross in [cross1, cross2]) {
                final row = isRowBased ? line : cross;
                final col = isRowBased ? cross : line;
                highlightedCells.add((row, col));
              }
            }

            // Eliminate from other cells in the two cross-lines
            for (final cross in [cross1, cross2]) {
              for (var line = 0; line < 9; line++) {
                if (line == line1 || line == line2) continue;
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
              final l1 = isRowBased ? 'R${line1 + 1}' : 'C${line1 + 1}';
              final l2 = isRowBased ? 'R${line2 + 1}' : 'C${line2 + 1}';
              final c1 = isRowBased ? 'C${cross1 + 1}' : 'R${cross1 + 1}';
              final c2 = isRowBased ? 'C${cross2 + 1}' : 'R${cross2 + 1}';

              return HintResult(
                strategyName: name,
                difficulty: difficulty,
                explanation:
                    'Number $digit forms an X-Wing pattern in $lineLabel $l1 and $l2, $crossLabel $c1 and $c2. '
                    '$digit can be eliminated from all other cells in $crossLabel $c1 and $c2.',
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

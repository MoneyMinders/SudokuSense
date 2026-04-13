import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class SkyscraperStrategy extends Strategy {
  @override
  String get name => 'Skyscraper';

  @override
  Difficulty get difficulty => Difficulty.hard;

  @override
  HintResult? apply(Board board) {
    final rowResult = _findSkyscraper(board, isRowBased: true);
    if (rowResult != null) return rowResult;
    return _findSkyscraper(board, isRowBased: false);
  }

  bool _seeEachOther((int, int) a, (int, int) b) {
    if (a.$1 == b.$1) return true; // same row
    if (a.$2 == b.$2) return true; // same col
    if ((a.$1 ~/ 3 == b.$1 ~/ 3) && (a.$2 ~/ 3 == b.$2 ~/ 3)) return true; // same box
    return false;
  }

  HintResult? _findSkyscraper(Board board, {required bool isRowBased}) {
    for (var digit = 1; digit <= 9; digit++) {
      // Find lines where digit appears in exactly 2 cells
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

      final lines = linesWithTwo.keys.toList();
      for (var i = 0; i < lines.length; i++) {
        for (var j = i + 1; j < lines.length; j++) {
          final line1 = lines[i];
          final line2 = lines[j];
          final pos1 = linesWithTwo[line1]!;
          final pos2 = linesWithTwo[line2]!;

          // We need exactly one matching cross-position (the base)
          // and one non-matching (the roofs)
          for (var swap = 0; swap < 2; swap++) {
            final a1 = swap == 0 ? pos1[0] : pos1[1];
            final a2 = swap == 0 ? pos1[1] : pos1[0];

            for (var swap2 = 0; swap2 < 2; swap2++) {
              final b1 = swap2 == 0 ? pos2[0] : pos2[1];
              final b2 = swap2 == 0 ? pos2[1] : pos2[0];

              // a1 and b1 are the base (must be same cross-position)
              // a2 and b2 are the roofs (must be different cross-positions)
              if (a1 != b1) continue;
              if (a2 == b2) continue; // That would be an X-Wing

              final roof1Row = isRowBased ? line1 : a2;
              final roof1Col = isRowBased ? a2 : line1;
              final roof2Row = isRowBased ? line2 : b2;
              final roof2Col = isRowBased ? b2 : line2;
              final roof1 = (roof1Row, roof1Col);
              final roof2 = (roof2Row, roof2Col);

              // Eliminate digit from cells that see both roof cells
              final eliminations = <(int, int), Set<int>>{};
              for (var r = 0; r < 9; r++) {
                for (var c = 0; c < 9; c++) {
                  final pos = (r, c);
                  if (pos == roof1 || pos == roof2) continue;
                  final cell = board.getCell(r, c);
                  if (cell.value != null || !cell.candidates.contains(digit)) {
                    continue;
                  }
                  if (_seeEachOther(pos, roof1) && _seeEachOther(pos, roof2)) {
                    eliminations[pos] = {digit};
                  }
                }
              }

              if (eliminations.isNotEmpty) {
                final base1Row = isRowBased ? line1 : a1;
                final base1Col = isRowBased ? a1 : line1;
                final base2Row = isRowBased ? line2 : b1;
                final base2Col = isRowBased ? b1 : line2;

                final highlightCells = [
                  (base1Row, base1Col),
                  roof1,
                  (base2Row, base2Col),
                  roof2,
                ];

                return HintResult(
                  strategyName: name,
                  difficulty: difficulty,
                  explanation:
                      'Number $digit forms a Skyscraper pattern. '
                      'Two ${isRowBased ? "rows" : "columns"} each have $digit in exactly 2 cells, '
                      'sharing a base at ${isRowBased ? "column" : "row"} ${a1 + 1}. '
                      'The roof cells at R${roof1.$1 + 1}C${roof1.$2 + 1} and '
                      'R${roof2.$1 + 1}C${roof2.$2 + 1} eliminate $digit from cells that see both.',
                  highlightCells: highlightCells,
                  eliminations: eliminations,
                );
              }
            }
          }
        }
      }
    }
    return null;
  }
}

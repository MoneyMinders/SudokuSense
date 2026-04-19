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
    if (a.$1 == b.$1) return true;
    if (a.$2 == b.$2) return true;
    if ((a.$1 ~/ 3 == b.$1 ~/ 3) && (a.$2 ~/ 3 == b.$2 ~/ 3)) return true;
    return false;
  }

  HintResult? _findSkyscraper(Board board, {required bool isRowBased}) {
    for (var digit = 1; digit <= 9; digit++) {
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

          for (var swap = 0; swap < 2; swap++) {
            final a1 = swap == 0 ? pos1[0] : pos1[1];
            final a2 = swap == 0 ? pos1[1] : pos1[0];

            for (var swap2 = 0; swap2 < 2; swap2++) {
              final b1 = swap2 == 0 ? pos2[0] : pos2[1];
              final b2 = swap2 == 0 ? pos2[1] : pos2[0];

              if (a1 != b1) continue;
              if (a2 == b2) continue;

              final roof1Row = isRowBased ? line1 : a2;
              final roof1Col = isRowBased ? a2 : line1;
              final roof2Row = isRowBased ? line2 : b2;
              final roof2Col = isRowBased ? b2 : line2;
              final roof1 = (roof1Row, roof1Col);
              final roof2 = (roof2Row, roof2Col);

              final eliminations = <Elimination>[];
              for (var r = 0; r < 9; r++) {
                for (var c = 0; c < 9; c++) {
                  final pos = (r, c);
                  if (pos == roof1 || pos == roof2) continue;
                  final cell = board.getCell(r, c);
                  if (cell.value != null || !cell.candidates.contains(digit)) {
                    continue;
                  }
                  if (_seeEachOther(pos, roof1) && _seeEachOther(pos, roof2)) {
                    eliminations.add(
                      Elimination(row: r, col: c, value: digit),
                    );
                  }
                }
              }

              if (eliminations.isNotEmpty) {
                final base1Row = isRowBased ? line1 : a1;
                final base1Col = isRowBased ? a1 : line1;
                final base2Row = isRowBased ? line2 : b1;
                final base2Col = isRowBased ? b1 : line2;

                final highlightedCells = [
                  (base1Row, base1Col),
                  roof1,
                  (base2Row, base2Col),
                  roof2,
                ];

                final axis = isRowBased ? 'rows' : 'columns';
                final baseAxis = isRowBased ? 'column' : 'row';
                return HintResult(
                  strategyName: name,
                  difficulty: difficulty,
                  explanation:
                      'Skyscraper on digit $digit. Two $axis each restrict '
                      '$digit to just two cells, and those cells share one '
                      'endpoint at $baseAxis ${a1 + 1} (the "base"). Since '
                      'each of those $axis needs one $digit, the two bases '
                      'cannot both be $digit — at least one of the opposite '
                      'ends, the "roofs" at R${roof1.$1 + 1}C${roof1.$2 + 1} '
                      'and R${roof2.$1 + 1}C${roof2.$2 + 1}, must be $digit. '
                      'Any cell that sees both roofs would conflict with '
                      'whichever roof is the $digit, so $digit can be removed '
                      'from every cell seeing both roofs.',
                  highlightedCells: highlightedCells,
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

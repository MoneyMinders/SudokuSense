import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class WWingStrategy extends Strategy {
  @override
  String get name => 'W-Wing';

  @override
  Difficulty get difficulty => Difficulty.expert;

  @override
  HintResult? apply(Board board) {
    // Find all bi-value cells
    final biCells = <(int, int)>[];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final cell = board.getCell(r, c);
        if (cell.value == null && cell.candidates.length == 2) {
          biCells.add((r, c));
        }
      }
    }

    // Try all pairs of identical bi-value cells
    for (var i = 0; i < biCells.length; i++) {
      for (var j = i + 1; j < biCells.length; j++) {
        final cell1Pos = biCells[i];
        final cell2Pos = biCells[j];
        final cell1 = board.getCell(cell1Pos.$1, cell1Pos.$2);
        final cell2 = board.getCell(cell2Pos.$1, cell2Pos.$2);

        if (!_setsEqual(cell1.candidates, cell2.candidates)) continue;
        if (_seeEachOther(cell1Pos, cell2Pos)) continue;

        final cands = cell1.candidates.toList();

        for (var ci = 0; ci < 2; ci++) {
          final a = cands[ci];
          final b = cands[1 - ci];

          final strongLinks = _findStrongLinks(board, a);

          for (final link in strongLinks) {
            final linkEnd1 = link.$1;
            final linkEnd2 = link.$2;

            final end1SeesCell1 = _seeEachOther(linkEnd1, cell1Pos);
            final end1SeesCell2 = _seeEachOther(linkEnd1, cell2Pos);
            final end2SeesCell1 = _seeEachOther(linkEnd2, cell1Pos);
            final end2SeesCell2 = _seeEachOther(linkEnd2, cell2Pos);

            bool connected = false;
            if (end1SeesCell1 && end2SeesCell2 &&
                linkEnd1 != cell1Pos && linkEnd2 != cell2Pos) {
              connected = true;
            } else if (end1SeesCell2 && end2SeesCell1 &&
                linkEnd1 != cell2Pos && linkEnd2 != cell1Pos) {
              connected = true;
            }

            if (!connected) continue;

            final eliminations = <Elimination>[];
            for (var r = 0; r < 9; r++) {
              for (var c = 0; c < 9; c++) {
                final pos = (r, c);
                if (pos == cell1Pos || pos == cell2Pos) continue;
                if (pos == linkEnd1 || pos == linkEnd2) continue;
                final cell = board.getCell(r, c);
                if (cell.value != null || !cell.candidates.contains(b)) {
                  continue;
                }
                if (_seeEachOther(pos, cell1Pos) &&
                    _seeEachOther(pos, cell2Pos)) {
                  eliminations.add(Elimination(row: r, col: c, value: b));
                }
              }
            }

            if (eliminations.isNotEmpty) {
              return HintResult(
                strategyName: name,
                difficulty: difficulty,
                explanation:
                    'W-Wing on {${cands.join(', ')}}. R${cell1Pos.$1 + 1}C${cell1Pos.$2 + 1} '
                    'and R${cell2Pos.$1 + 1}C${cell2Pos.$2 + 1} each can only '
                    'be $a or $b, and they do not see each other directly. A '
                    'strong link on $a connects them through the pair '
                    'R${linkEnd1.$1 + 1}C${linkEnd1.$2 + 1} ↔ '
                    'R${linkEnd2.$1 + 1}C${linkEnd2.$2 + 1} — a unit where $a '
                    'must be in one of exactly those two cells. If both '
                    'bi-value cells were $a, the strong link between them '
                    'would be impossible to satisfy. So at least one of the '
                    'bi-value cells must be $b, and any cell that sees both '
                    'of them cannot itself be $b.',
                highlightedCells: [cell1Pos, cell2Pos, linkEnd1, linkEnd2],
                eliminations: eliminations,
              );
            }
          }
        }
      }
    }

    return null;
  }

  List<((int, int), (int, int))> _findStrongLinks(Board board, int digit) {
    final links = <((int, int), (int, int))>[];
    final seen = <String>{};

    void checkUnit(List<(int, int)> positions) {
      final withDigit = <(int, int)>[];
      for (final pos in positions) {
        final cell = board.getCell(pos.$1, pos.$2);
        if (cell.value == null && cell.candidates.contains(digit)) {
          withDigit.add(pos);
        }
      }
      if (withDigit.length == 2) {
        final key = '${withDigit[0]}-${withDigit[1]}';
        if (seen.add(key)) {
          links.add((withDigit[0], withDigit[1]));
        }
      }
    }

    for (var i = 0; i < 9; i++) {
      checkUnit(board.getRowPositions(i));
      checkUnit(board.getColPositions(i));
    }
    for (var box = 0; box < 9; box++) {
      checkUnit(board.getBoxPositions(box));
    }

    return links;
  }

  bool _seeEachOther((int, int) a, (int, int) b) {
    if (a.$1 == b.$1) return true;
    if (a.$2 == b.$2) return true;
    if ((a.$1 ~/ 3 == b.$1 ~/ 3) && (a.$2 ~/ 3 == b.$2 ~/ 3)) return true;
    return false;
  }

  bool _setsEqual(Set<int> a, Set<int> b) {
    return a.length == b.length && a.containsAll(b);
  }
}

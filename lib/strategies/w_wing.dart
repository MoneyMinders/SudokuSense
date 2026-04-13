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

        // Must have identical candidates
        if (!_setsEqual(cell1.candidates, cell2.candidates)) continue;

        // Must NOT share a unit (otherwise simpler techniques apply)
        if (_seeEachOther(cell1Pos, cell2Pos)) continue;

        final cands = cell1.candidates.toList();

        // Try each candidate as the strong link candidate (a),
        // the other is the elimination candidate (b)
        for (var ci = 0; ci < 2; ci++) {
          final a = cands[ci];
          final b = cands[1 - ci];

          // Find a strong link on candidate a that connects to both cells
          // Strong link: a unit where candidate a appears in exactly 2 cells
          final strongLinks = _findStrongLinks(board, a);

          for (final link in strongLinks) {
            final linkEnd1 = link.$1;
            final linkEnd2 = link.$2;

            // One end must see cell1, the other must see cell2
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

            // Eliminate b from cells that see both bi-value cells
            final eliminations = <(int, int), Set<int>>{};
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
                  eliminations[pos] = {b};
                }
              }
            }

            if (eliminations.isNotEmpty) {
              return HintResult(
                strategyName: name,
                difficulty: difficulty,
                explanation:
                    'W-Wing: Bi-value cells R${cell1Pos.$1 + 1}C${cell1Pos.$2 + 1} '
                    'and R${cell2Pos.$1 + 1}C${cell2Pos.$2 + 1} both have '
                    'candidates {${cands.join(', ')}}. They are connected by a '
                    'strong link on $a between R${linkEnd1.$1 + 1}C${linkEnd1.$2 + 1} '
                    'and R${linkEnd2.$1 + 1}C${linkEnd2.$2 + 1}. '
                    'Candidate $b can be eliminated from cells seeing both bi-value cells.',
                highlightCells: [cell1Pos, cell2Pos, linkEnd1, linkEnd2],
                eliminations: eliminations,
              );
            }
          }
        }
      }
    }

    return null;
  }

  /// Find all strong links for a candidate: pairs of cells in a unit
  /// where the candidate appears in exactly 2 cells.
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
    for (var br = 0; br < 9; br += 3) {
      for (var bc = 0; bc < 9; bc += 3) {
        checkUnit(board.getBoxPositions(br, bc));
      }
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

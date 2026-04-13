import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class XYZWingStrategy extends Strategy {
  @override
  String get name => 'XYZ-Wing';

  @override
  Difficulty get difficulty => Difficulty.expert;

  @override
  HintResult? apply(Board board) {
    // Find tri-value cells (pivots) and bi-value cells (pincers)
    final triCells = <(int, int)>[];
    final biCells = <(int, int)>[];

    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final cell = board.getCell(r, c);
        if (cell.value != null) continue;
        if (cell.candidates.length == 3) triCells.add((r, c));
        if (cell.candidates.length == 2) biCells.add((r, c));
      }
    }

    for (final pivot in triCells) {
      final pivotCands = board.getCell(pivot.$1, pivot.$2).candidates;
      final candList = pivotCands.toList();

      // Try each candidate as z
      for (final z in candList) {
        final others = candList.where((c) => c != z).toList();
        final x = others[0];
        final y = others[1];

        // Find pincers: one with {x,z}, one with {y,z}, both see pivot
        final pincersXZ = <(int, int)>[];
        final pincersYZ = <(int, int)>[];

        for (final cell in biCells) {
          if (!_seeEachOther(pivot, cell)) continue;
          final cands = board.getCell(cell.$1, cell.$2).candidates;
          if (cands.contains(x) && cands.contains(z) && cands.length == 2) {
            pincersXZ.add(cell);
          }
          if (cands.contains(y) && cands.contains(z) && cands.length == 2) {
            pincersYZ.add(cell);
          }
        }

        for (final p1 in pincersXZ) {
          for (final p2 in pincersYZ) {
            if (p1 == p2) continue;

            // z can be eliminated from cells that see ALL THREE
            final eliminations = <(int, int), Set<int>>{};
            for (var r = 0; r < 9; r++) {
              for (var c = 0; c < 9; c++) {
                final pos = (r, c);
                if (pos == pivot || pos == p1 || pos == p2) continue;
                final cell = board.getCell(r, c);
                if (cell.value != null || !cell.candidates.contains(z)) {
                  continue;
                }
                if (_seeEachOther(pos, pivot) &&
                    _seeEachOther(pos, p1) &&
                    _seeEachOther(pos, p2)) {
                  eliminations[pos] = {z};
                }
              }
            }

            if (eliminations.isNotEmpty) {
              return HintResult(
                strategyName: name,
                difficulty: difficulty,
                explanation:
                    'XYZ-Wing: Pivot R${pivot.$1 + 1}C${pivot.$2 + 1} has '
                    'candidates {$x, $y, $z}. '
                    'Pincer R${p1.$1 + 1}C${p1.$2 + 1} has {$x, $z}, '
                    'Pincer R${p2.$1 + 1}C${p2.$2 + 1} has {$y, $z}. '
                    'Candidate $z can be eliminated from cells seeing all three.',
                highlightCells: [pivot, p1, p2],
                eliminations: eliminations,
              );
            }
          }
        }
      }
    }

    return null;
  }

  bool _seeEachOther((int, int) a, (int, int) b) {
    if (a.$1 == b.$1) return true;
    if (a.$2 == b.$2) return true;
    if ((a.$1 ~/ 3 == b.$1 ~/ 3) && (a.$2 ~/ 3 == b.$2 ~/ 3)) return true;
    return false;
  }
}

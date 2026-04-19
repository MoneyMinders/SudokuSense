import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class XYWingStrategy extends Strategy {
  @override
  String get name => 'XY-Wing';

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

    // Try each bi-value cell as pivot
    for (final pivot in biCells) {
      final pivotCands = board.getCell(pivot.$1, pivot.$2).candidates;
      final x = pivotCands.first;
      final y = pivotCands.last;

      // Find pincers that see the pivot
      final pincersXZ = <(int, int)>[]; // cells with {x, z}
      final pincersYZ = <(int, int)>[]; // cells with {y, z}

      for (final cell in biCells) {
        if (cell == pivot) continue;
        if (!_seeEachOther(pivot, cell)) continue;

        final cands = board.getCell(cell.$1, cell.$2).candidates;
        if (cands.contains(x) && !cands.contains(y)) {
          pincersXZ.add(cell);
        } else if (cands.contains(y) && !cands.contains(x)) {
          pincersYZ.add(cell);
        }
      }

      // Try all pairs of pincers
      for (final p1 in pincersXZ) {
        final p1Cands = board.getCell(p1.$1, p1.$2).candidates;
        final z1 = p1Cands.firstWhere((c) => c != x);

        for (final p2 in pincersYZ) {
          final p2Cands = board.getCell(p2.$1, p2.$2).candidates;
          final z2 = p2Cands.firstWhere((c) => c != y);

          if (z1 != z2) continue;
          final z = z1;

          // Eliminate z from cells that see both pincers
          final eliminations = <Elimination>[];
          for (var r = 0; r < 9; r++) {
            for (var c = 0; c < 9; c++) {
              final pos = (r, c);
              if (pos == pivot || pos == p1 || pos == p2) continue;
              final cell = board.getCell(r, c);
              if (cell.value != null || !cell.candidates.contains(z)) continue;
              if (_seeEachOther(pos, p1) && _seeEachOther(pos, p2)) {
                eliminations.add(Elimination(row: r, col: c, value: z));
              }
            }
          }

          if (eliminations.isNotEmpty) {
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'XY-Wing. The pivot R${pivot.$1 + 1}C${pivot.$2 + 1} can only '
                  'be $x or $y. Pincer R${p1.$1 + 1}C${p1.$2 + 1} can only be '
                  '$x or $z, and pincer R${p2.$1 + 1}C${p2.$2 + 1} can only be '
                  '$y or $z. If the pivot is $x, pincer1 is forced to $z. If '
                  'the pivot is $y, pincer2 is forced to $z. Either way, one of '
                  'the two pincers is $z — so any cell that sees both pincers '
                  'shares a unit with the eventual $z and cannot itself be $z.',
              highlightedCells: [pivot, p1, p2],
              eliminations: eliminations,
            );
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

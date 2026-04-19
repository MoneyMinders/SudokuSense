import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class HiddenPairStrategy extends Strategy {
  @override
  String get name => 'Hidden Pair';

  @override
  Difficulty get difficulty => Difficulty.medium;

  @override
  HintResult? apply(Board board) {
    for (int r = 0; r < 9; r++) {
      final result = _checkUnit(board, board.getRowPositions(r), 'row ${r + 1}');
      if (result != null) return result;
    }
    for (int c = 0; c < 9; c++) {
      final result = _checkUnit(board, board.getColPositions(c), 'column ${c + 1}');
      if (result != null) return result;
    }
    for (int b = 0; b < 9; b++) {
      final result = _checkUnit(board, board.getBoxPositions(b), 'box ${b + 1}');
      if (result != null) return result;
    }
    return null;
  }

  HintResult? _checkUnit(
    Board board,
    List<(int, int)> positions,
    String unitName,
  ) {
    // Map each candidate value to the positions where it appears.
    final candidatePositions = <int, List<(int, int)>>{};
    for (final pos in positions) {
      final cell = board.getCell(pos.$1, pos.$2);
      if (cell.value != null) continue;
      for (final cand in cell.candidates) {
        candidatePositions.putIfAbsent(cand, () => []).add(pos);
      }
    }

    // Find two candidates that appear in exactly the same two cells.
    final candidates = candidatePositions.keys.toList()..sort();
    for (int i = 0; i < candidates.length; i++) {
      final posI = candidatePositions[candidates[i]]!;
      if (posI.length != 2) continue;
      for (int j = i + 1; j < candidates.length; j++) {
        final posJ = candidatePositions[candidates[j]]!;
        if (posJ.length != 2) continue;

        // Check if same two cells.
        if (posI[0] == posJ[0] && posI[1] == posJ[1]) {
          final pairValues = {candidates[i], candidates[j]};
          final cell1 = board.getCell(posI[0].$1, posI[0].$2);
          final cell2 = board.getCell(posI[1].$1, posI[1].$2);

          // Build eliminations: remove everything except the pair values.
          final eliminations = <Elimination>[];
          for (final cand in cell1.candidates) {
            if (!pairValues.contains(cand)) {
              eliminations.add(
                Elimination(row: posI[0].$1, col: posI[0].$2, value: cand),
              );
            }
          }
          for (final cand in cell2.candidates) {
            if (!pairValues.contains(cand)) {
              eliminations.add(
                Elimination(row: posI[1].$1, col: posI[1].$2, value: cand),
              );
            }
          }

          if (eliminations.isNotEmpty) {
            final pairStr = '{${(pairValues.toList()..sort()).join(',')}}';
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'Within $unitName, the two digits $pairStr appear as '
                  'candidates only in R${posI[0].$1 + 1}C${posI[0].$2 + 1} and '
                  'R${posI[1].$1 + 1}C${posI[1].$2 + 1}. Since every digit must '
                  'occur exactly once in the $unitName, both digits are forced '
                  'into this pair of cells — one each. That means these two '
                  'cells are fully committed to $pairStr, and any other '
                  'candidate listed inside them can be safely eliminated.',
              eliminations: eliminations,
              highlightedCells: [posI[0], posI[1]],
            );
          }
        }
      }
    }
    return null;
  }
}

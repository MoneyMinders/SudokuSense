import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class HiddenTripleStrategy extends Strategy {
  @override
  String get name => 'Hidden Triple';

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
    // Map each candidate to positions where it appears.
    final candidatePositions = <int, Set<(int, int)>>{};
    for (final pos in positions) {
      final cell = board.getCell(pos.$1, pos.$2);
      if (cell.value != null) continue;
      for (final cand in cell.candidates) {
        candidatePositions.putIfAbsent(cand, () => {}).add(pos);
      }
    }

    // Find candidates that appear in 2 or 3 cells (potential hidden triple members).
    final eligibleCandidates = candidatePositions.entries
        .where((e) => e.value.length >= 2 && e.value.length <= 3)
        .map((e) => e.key)
        .toList()
      ..sort();

    // Try every combination of 3 candidates.
    for (int i = 0; i < eligibleCandidates.length; i++) {
      for (int j = i + 1; j < eligibleCandidates.length; j++) {
        for (int k = j + 1; k < eligibleCandidates.length; k++) {
          final c1 = eligibleCandidates[i];
          final c2 = eligibleCandidates[j];
          final c3 = eligibleCandidates[k];

          final unionPositions = {
            ...candidatePositions[c1]!,
            ...candidatePositions[c2]!,
            ...candidatePositions[c3]!,
          };

          if (unionPositions.length != 3) continue;

          // Found a hidden triple: candidates {c1,c2,c3} appear only in these 3 cells.
          // Remove all other candidates from these cells.
          final tripleValues = {c1, c2, c3};
          final eliminations = <Elimination>[];
          for (final pos in unionPositions) {
            final cell = board.getCell(pos.$1, pos.$2);
            for (final cand in cell.candidates) {
              if (!tripleValues.contains(cand)) {
                eliminations.add(
                  Elimination(row: pos.$1, col: pos.$2, value: cand),
                );
              }
            }
          }

          if (eliminations.isNotEmpty) {
            final tripleStr = '{${(tripleValues.toList()..sort()).join(',')}}';
            final posList = unionPositions.toList();
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'In $unitName, candidates $tripleStr only appear in cells '
                  '${posList.map((p) => '(${p.$1 + 1},${p.$2 + 1})').join(', ')}. '
                  'All other candidates can be removed from these cells.',
              eliminations: eliminations,
              highlightedCells: posList,
            );
          }
        }
      }
    }
    return null;
  }
}

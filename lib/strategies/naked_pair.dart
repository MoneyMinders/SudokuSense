import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class NakedPairStrategy extends Strategy {
  @override
  String get name => 'Naked Pair';

  @override
  Difficulty get difficulty => Difficulty.medium;

  @override
  HintResult? apply(Board board) {
    // Check rows
    for (int r = 0; r < 9; r++) {
      final result = _checkUnit(
        board,
        board.getRowPositions(r),
        'row ${r + 1}',
      );
      if (result != null) return result;
    }

    // Check columns
    for (int c = 0; c < 9; c++) {
      final result = _checkUnit(
        board,
        board.getColPositions(c),
        'column ${c + 1}',
      );
      if (result != null) return result;
    }

    // Check boxes
    for (int b = 0; b < 9; b++) {
      final result = _checkUnit(
        board,
        board.getBoxPositions(b),
        'box ${b + 1}',
      );
      if (result != null) return result;
    }

    return null;
  }

  HintResult? _checkUnit(
    Board board,
    List<(int, int)> positions,
    String unitName,
  ) {
    // Find cells with exactly 2 candidates.
    final pairCells = <(int, int), Set<int>>{};
    for (final pos in positions) {
      final cell = board.getCell(pos.$1, pos.$2);
      if (cell.value == null && cell.candidates.length == 2) {
        pairCells[pos] = cell.candidates;
      }
    }

    // Find two cells with the same pair.
    final entries = pairCells.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      for (int j = i + 1; j < entries.length; j++) {
        if (entries[i].value.length == 2 &&
            entries[i].value.containsAll(entries[j].value)) {
          final pair = entries[i].value;
          final pos1 = entries[i].key;
          final pos2 = entries[j].key;

          // Check if there are eliminations to make.
          final eliminations = <Elimination>[];
          for (final pos in positions) {
            if (pos == pos1 || pos == pos2) continue;
            final cell = board.getCell(pos.$1, pos.$2);
            if (cell.value != null) continue;
            for (final val in pair) {
              if (cell.candidates.contains(val)) {
                eliminations.add(
                  Elimination(row: pos.$1, col: pos.$2, value: val),
                );
              }
            }
          }

          if (eliminations.isNotEmpty) {
            final pairStr = '{${(pair.toList()..sort()).join(',')}}';
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'In $unitName, R${pos1.$1 + 1}C${pos1.$2 + 1} and '
                  'R${pos2.$1 + 1}C${pos2.$2 + 1} both hold only the two '
                  'candidates $pairStr. Two cells that can each only take one '
                  'of two values must between them cover both values — so $pairStr '
                  'are locked into these two cells. No other cell in this '
                  '$unitName can use either value, and they are removed as '
                  'candidates from the rest of the $unitName.',
              eliminations: eliminations,
              highlightedCells: [pos1, pos2],
            );
          }
        }
      }
    }
    return null;
  }
}

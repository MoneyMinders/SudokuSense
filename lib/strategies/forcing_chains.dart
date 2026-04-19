import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class ForcingChainsStrategy extends Strategy {
  static const int _maxChainLength = 20;

  @override
  String get name => 'Forcing Chains';

  @override
  Difficulty get difficulty => Difficulty.evil;

  @override
  HintResult? apply(Board board) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final cell = board.getCell(r, c);
        if (cell.value != null || cell.candidates.length != 2) continue;

        final startPos = (r, c);
        final cands = cell.candidates.toList();
        final a = cands[0];
        final b = cands[1];

        final resultA = _traceImplications(board, startPos, a);
        final resultB = _traceImplications(board, startPos, b);

        if (resultA == null || resultB == null) {
          // Contradiction found
          if (resultA == null && resultB != null) {
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'Forcing Chain from R${r + 1}C${c + 1}. Tentatively placing '
                  '$a here forces a sequence of candidate eliminations and '
                  'forced placements across the board that eventually empties '
                  'some cell of all its candidates, or forces the same digit '
                  'into two peers — a contradiction. Since $a is impossible, '
                  'and the cell only accepts $a or $b, the cell must be $b.',
              highlightedCells: [startPos],
              placements: [Placement(row: r, col: c, value: b)],
            );
          }
          if (resultB == null && resultA != null) {
            return HintResult(
              strategyName: name,
              difficulty: difficulty,
              explanation:
                  'Forcing Chain from R${r + 1}C${c + 1}. Tentatively placing '
                  '$b here forces a chain of deductions that ends in a '
                  'contradiction — some peer unit can no longer place one of '
                  'its required digits. Since $b is impossible, and the cell '
                  'only accepts $a or $b, the cell must be $a.',
              highlightedCells: [startPos],
              placements: [Placement(row: r, col: c, value: a)],
            );
          }
          continue;
        }

        // Check if both paths agree on any cell placement
        final eliminations = <Elimination>[];
        final highlightedCells = <(int, int)>[startPos];

        for (final posA in resultA.keys) {
          if (resultB.containsKey(posA)) {
            final valA = resultA[posA]!;
            final valB = resultB[posA]!;
            if (valA == valB) {
              final targetCell = board.getCell(posA.$1, posA.$2);
              if (targetCell.value != null) continue;
              for (final cand in targetCell.candidates) {
                if (cand != valA) {
                  eliminations.add(
                    Elimination(row: posA.$1, col: posA.$2, value: cand),
                  );
                }
              }
              if (eliminations.isNotEmpty) {
                highlightedCells.add(posA);
              }
            }
          }
        }

        if (eliminations.isNotEmpty) {
          return HintResult(
            strategyName: name,
            difficulty: difficulty,
            explanation:
                'Forcing Chain from R${r + 1}C${c + 1}. Whichever of its two '
                'candidates ($a or $b) is eventually placed, tracing the '
                'implications forward leads to the same forced digit in '
                '${highlightedCells.skip(1).map((p) => "R${p.$1 + 1}C${p.$2 + 1}").join(", ")}. '
                'Since both branches agree, that placement is settled '
                'regardless of how R${r + 1}C${c + 1} resolves, and every '
                'other candidate in those cells can be removed.',
            highlightedCells: highlightedCells,
            eliminations: eliminations,
          );
        }
      }
    }

    return null;
  }

  /// Trace implications of setting a cell to a value.
  /// Returns a map of cell positions to forced values, or null if contradiction.
  Map<(int, int), int>? _traceImplications(
    Board board,
    (int, int) startPos,
    int startValue,
  ) {
    final sim = board.deepCopy();
    final forced = <(int, int), int>{};
    final queue = <((int, int), int)>[(startPos, startValue)];
    var steps = 0;

    while (queue.isNotEmpty && steps < _maxChainLength) {
      final (pos, value) = queue.removeAt(0);
      steps++;

      final cell = sim.getCell(pos.$1, pos.$2);
      if (cell.value != null) {
        if (cell.value != value) return null;
        continue;
      }

      if (!cell.candidates.contains(value)) return null;

      cell.value = value;
      cell.candidates.clear();
      forced[pos] = value;

      final peers = _getPeers(pos);
      for (final peer in peers) {
        final peerCell = sim.getCell(peer.$1, peer.$2);
        if (peerCell.value != null) {
          if (peerCell.value == value) return null;
          continue;
        }
        peerCell.candidates.remove(value);
        if (peerCell.candidates.isEmpty) return null;
        if (peerCell.candidates.length == 1) {
          queue.add((peer, peerCell.candidates.first));
        }
      }

      // Check for hidden singles in affected units
      final units = _getUnits(pos);
      for (final unit in units) {
        for (var digit = 1; digit <= 9; digit++) {
          final cellsWithDigit = <(int, int)>[];
          bool alreadyPlaced = false;
          for (final uPos in unit) {
            final uCell = sim.getCell(uPos.$1, uPos.$2);
            if (uCell.value == digit) {
              alreadyPlaced = true;
              break;
            }
            if (uCell.value == null && uCell.candidates.contains(digit)) {
              cellsWithDigit.add(uPos);
            }
          }
          if (!alreadyPlaced && cellsWithDigit.length == 1) {
            final target = cellsWithDigit.first;
            final tCell = sim.getCell(target.$1, target.$2);
            if (tCell.value == null) {
              queue.add((target, digit));
            }
          }
        }
      }
    }

    return forced;
  }

  List<(int, int)> _getPeers((int, int) pos) {
    final peers = <(int, int)>{};
    final (row, col) = pos;

    for (var c = 0; c < 9; c++) {
      if (c != col) peers.add((row, c));
    }
    for (var r = 0; r < 9; r++) {
      if (r != row) peers.add((r, col));
    }
    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    for (var r = startRow; r < startRow + 3; r++) {
      for (var c = startCol; c < startCol + 3; c++) {
        if (r != row || c != col) peers.add((r, c));
      }
    }

    return peers.toList();
  }

  List<List<(int, int)>> _getUnits((int, int) pos) {
    final (row, col) = pos;
    final units = <List<(int, int)>>[];

    units.add(List.generate(9, (c) => (row, c)));
    units.add(List.generate(9, (r) => (r, col)));

    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    final box = <(int, int)>[];
    for (var r = startRow; r < startRow + 3; r++) {
      for (var c = startCol; c < startCol + 3; c++) {
        box.add((r, c));
      }
    }
    units.add(box);

    return units;
  }
}

import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class ALSXZStrategy extends Strategy {
  @override
  String get name => 'ALS-XZ';

  @override
  Difficulty get difficulty => Difficulty.expert;

  @override
  HintResult? apply(Board board) {
    // Collect all ALS (Almost Locked Sets) from rows, cols, and boxes
    final allALS = <_ALS>[];

    for (var row = 0; row < 9; row++) {
      _findALSInUnit(board, board.getRowPositions(row), allALS);
    }
    for (var col = 0; col < 9; col++) {
      _findALSInUnit(board, board.getColPositions(col), allALS);
    }
    for (var box = 0; box < 9; box++) {
      _findALSInUnit(board, board.getBoxPositions(box), allALS);
    }

    // Deduplicate
    final uniqueALS = <_ALS>[];
    final seen = <String>{};
    for (final als in allALS) {
      if (seen.add(als.key)) {
        uniqueALS.add(als);
      }
    }

    // Try all pairs
    for (var i = 0; i < uniqueALS.length; i++) {
      for (var j = i + 1; j < uniqueALS.length; j++) {
        final alsA = uniqueALS[i];
        final alsB = uniqueALS[j];

        if (alsA.cells.any((c) => alsB.cells.contains(c))) continue;

        final commonCands = alsA.candidates.intersection(alsB.candidates);
        if (commonCands.length < 2) continue;

        // Find restricted common candidate (RCC) x
        for (final x in commonCands) {
          final aCellsWithX = alsA.cells
              .where((pos) =>
                  board.getCell(pos.$1, pos.$2).candidates.contains(x))
              .toList();
          final bCellsWithX = alsB.cells
              .where((pos) =>
                  board.getCell(pos.$1, pos.$2).candidates.contains(x))
              .toList();

          if (aCellsWithX.isEmpty || bCellsWithX.isEmpty) continue;

          bool isRestricted = true;
          for (final ac in aCellsWithX) {
            for (final bc in bCellsWithX) {
              if (!_seeEachOther(ac, bc)) {
                isRestricted = false;
                break;
              }
            }
            if (!isRestricted) break;
          }
          if (!isRestricted) continue;

          // Find unrestricted common candidates z
          for (final z in commonCands) {
            if (z == x) continue;

            final aCellsWithZ = alsA.cells
                .where((pos) =>
                    board.getCell(pos.$1, pos.$2).candidates.contains(z))
                .toList();
            final bCellsWithZ = alsB.cells
                .where((pos) =>
                    board.getCell(pos.$1, pos.$2).candidates.contains(z))
                .toList();

            if (aCellsWithZ.isEmpty || bCellsWithZ.isEmpty) continue;

            final allZCells = [...aCellsWithZ, ...bCellsWithZ];
            final eliminations = <Elimination>[];

            for (var r = 0; r < 9; r++) {
              for (var c = 0; c < 9; c++) {
                final pos = (r, c);
                if (alsA.cells.contains(pos) || alsB.cells.contains(pos)) {
                  continue;
                }
                final cell = board.getCell(r, c);
                if (cell.value != null || !cell.candidates.contains(z)) {
                  continue;
                }
                if (allZCells.every((zCell) => _seeEachOther(pos, zCell))) {
                  eliminations.add(Elimination(row: r, col: c, value: z));
                }
              }
            }

            if (eliminations.isNotEmpty) {
              return HintResult(
                strategyName: name,
                difficulty: difficulty,
                explanation:
                    'ALS-XZ: Set A (${_formatCells(alsA.cells)}) with candidates '
                    '{${(alsA.candidates.toList()..sort()).join(', ')}} and '
                    'Set B (${_formatCells(alsB.cells)}) with candidates '
                    '{${(alsB.candidates.toList()..sort()).join(', ')}} share restricted '
                    'common candidate $x. Unrestricted common candidate $z '
                    'can be eliminated from cells that see all $z-cells in both sets.',
                highlightedCells: [...alsA.cells, ...alsB.cells],
                eliminations: eliminations,
              );
            }
          }
        }
      }
    }

    return null;
  }

  void _findALSInUnit(
    Board board,
    List<(int, int)> unitPositions,
    List<_ALS> results,
  ) {
    final unsolved = <(int, int)>[];
    for (final pos in unitPositions) {
      final cell = board.getCell(pos.$1, pos.$2);
      if (cell.value == null && cell.candidates.isNotEmpty) {
        unsolved.add(pos);
      }
    }

    final maxSize = unsolved.length < 4 ? unsolved.length : 4;
    for (var size = 1; size <= maxSize; size++) {
      _generateSubsets(board, unsolved, size, 0, [], results);
    }
  }

  void _generateSubsets(
    Board board,
    List<(int, int)> cells,
    int targetSize,
    int startIndex,
    List<(int, int)> current,
    List<_ALS> results,
  ) {
    if (current.length == targetSize) {
      final allCands = <int>{};
      for (final pos in current) {
        allCands.addAll(board.getCell(pos.$1, pos.$2).candidates);
      }
      if (allCands.length == targetSize + 1) {
        results.add(_ALS(List.from(current), Set.from(allCands)));
      }
      return;
    }

    for (var i = startIndex; i < cells.length; i++) {
      current.add(cells[i]);
      _generateSubsets(board, cells, targetSize, i + 1, current, results);
      current.removeLast();
    }
  }

  String _formatCells(List<(int, int)> cells) {
    return cells.map((c) => 'R${c.$1 + 1}C${c.$2 + 1}').join(', ');
  }

  bool _seeEachOther((int, int) a, (int, int) b) {
    if (a.$1 == b.$1) return true;
    if (a.$2 == b.$2) return true;
    if ((a.$1 ~/ 3 == b.$1 ~/ 3) && (a.$2 ~/ 3 == b.$2 ~/ 3)) return true;
    return false;
  }
}

class _ALS {
  final List<(int, int)> cells;
  final Set<int> candidates;

  _ALS(this.cells, this.candidates);

  String get key {
    final sorted = List<(int, int)>.from(cells)
      ..sort((a, b) {
        final r = a.$1.compareTo(b.$1);
        return r != 0 ? r : a.$2.compareTo(b.$2);
      });
    return sorted.map((c) => '${c.$1},${c.$2}').join('|');
  }
}

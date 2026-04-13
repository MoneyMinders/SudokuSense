import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_sense/models/board.dart';
import 'package:sudoku_sense/services/candidate_service.dart';
import 'package:sudoku_sense/strategies/naked_single.dart';
import 'package:sudoku_sense/strategies/hidden_single.dart';
import 'package:sudoku_sense/strategies/naked_pair.dart';
import 'package:sudoku_sense/strategies/x_wing.dart';

void main() {
  late CandidateService candidateService;

  setUp(() {
    candidateService = CandidateService();
  });

  group('NakedSingleStrategy', () {
    test('finds a cell with only one candidate', () {
      // Almost-complete row 0: only cell (0,2) is empty, must be 4
      final grid = [
        [5, 3, 0, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ];
      final board = Board.fromGrid(grid);
      candidateService.calculateAllCandidates(board);

      final strategy = NakedSingleStrategy();
      final result = strategy.apply(board);

      expect(result, isNotNull);
      expect(result!.placements.length, 1);
      expect(result.placements.first.row, 0);
      expect(result.placements.first.col, 2);
      expect(result.placements.first.value, 4);
      expect(result.strategyName, 'Naked Single');
    });

    test('returns null when no naked single exists', () {
      // Many empty cells, none with a single candidate
      final grid = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      final board = Board.fromGrid(grid);
      candidateService.calculateAllCandidates(board);

      final strategy = NakedSingleStrategy();
      final result = strategy.apply(board);

      expect(result, isNull);
    });

    test('finds naked single created by row+col+box constraints', () {
      // Cell (0,0) is empty. Row 0 has 2,3,4,5,6,7,8; col 0 has 9; box has nothing extra
      // So only candidate is 1
      final grid = [
        [0, 2, 3, 4, 5, 6, 7, 8, 0],
        [9, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      final board = Board.fromGrid(grid);
      candidateService.calculateAllCandidates(board);

      final strategy = NakedSingleStrategy();
      final result = strategy.apply(board);

      expect(result, isNotNull);
      expect(result!.placements.first.row, 0);
      expect(result.placements.first.col, 0);
      expect(result.placements.first.value, 1);
    });
  });

  group('HiddenSingleStrategy', () {
    test('finds a hidden single in a row', () {
      // Set up a board where number 1 can only go in one cell in row 0.
      // Row 0: cells at cols 0-7 are filled, col 8 is empty.
      // But we want a hidden single, not a naked single.
      // Better approach: several empty cells in a row, but only one can hold a specific value.
      //
      // Row 0 has empty cells at cols 0 and 8.
      // Col 0 already has 1 (from another row), so 1 can only go at (0,8) in row 0.
      final grid = [
        [0, 2, 3, 4, 5, 6, 7, 8, 0],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      final board = Board.fromGrid(grid);
      candidateService.calculateAllCandidates(board);

      // Cell (0,0): row has 2-8, col has 1 => candidates = {9}
      // Cell (0,8): row has 2-8, col has 1 => candidates = {9}
      // Actually both are naked singles for 9, and 1 can't go anywhere in row 0.
      // Let me redesign this.

      // Better: row 0 has several empty cells, 1 is excluded from all but one.
      final grid2 = [
        [0, 0, 3, 4, 5, 6, 7, 8, 0],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Row 0 empty cells: (0,0), (0,1), (0,8)
      // (0,0): col 0 has 1 at row 1 => no 1
      // (0,1): col 1 has 1 at row 7 => no 1
      // (0,8): col 8 has 1 at row 7 => no 1
      // Hmm, 1 can't go anywhere. Let me try differently.

      // Simple approach: row with 3 empty cells. 1 is blocked in two of them.
      final grid3 = [
        [0, 0, 0, 4, 5, 6, 7, 8, 9],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 2, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 3, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Row 0 empty: (0,0), (0,1), (0,2). Missing: 1, 2, 3.
      // (0,0): col 0 has 1 => can't be 1. Box 0 has 1,2 => candidates = {3}
      // That's a naked single, not hidden single. Let me just craft it more carefully.

      // For a true hidden single: multiple candidates in each cell,
      // but one number only appears in one cell of the unit.
      final hiddenGrid = [
        [0, 0, 0, 0, 5, 6, 7, 8, 9],
        [0, 2, 3, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Row 0 empty: (0,0), (0,1), (0,2), (0,3). Missing: 1, 2, 3, 4.
      // (0,0): col 0 has 1 at row 8 => no 1. Box 0 has 2,3 => candidates = {4}
      // That's a naked single again for 4.

      // I'll use a more realistic partial board.
      // Strategy: in row 0 missing {1,2,3,4}, but value 1 can only go in one cell.
      final hGrid = [
        [0, 0, 0, 0, 5, 6, 7, 8, 9],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Row 0 empty: (0,0), (0,1), (0,2), (0,3). Missing: {1,2,3,4}.
      // (0,0): col 0 has 1 at (1,0) => no 1. Candidates include {2,3,4}
      // (0,1): col 1 has 1 at (2,1) => no 1. Candidates include {2,3,4}
      // (0,2): col 2 has no 1, box 0 has 1 at (1,0) => no 1. Candidates include {2,3,4}
      // (0,3): col 3 has 1 at (3,3) => no 1.
      // 1 can't go anywhere in row 0! Still wrong.

      // Fix: put 1 blockers in cols 0, 1, 3 but NOT col 2, and NOT in box 0
      final hGrid2 = [
        [0, 0, 0, 0, 5, 6, 7, 8, 9],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Row 0 empty: (0,0), (0,1), (0,2), (0,3). Missing: {1,2,3,4}.
      // (0,0): col 0 has 1 at (3,0) => no 1. candidates={2,3,4}
      // (0,1): col 1 has 1 at (4,1) => no 1. candidates={2,3,4}
      // (0,2): col 2 has no 1, box 0 has no 1. candidates={1,2,3,4}
      // (0,3): col 3 has 1 at (5,3) => no 1. candidates={2,3,4}
      // Hidden single: 1 can only go at (0,2) in row 0!
      // (0,2) has candidates {1,2,3,4} so it's not a naked single. Perfect.

      final board2 = Board.fromGrid(hGrid2);
      candidateService.calculateAllCandidates(board2);

      final strategy = HiddenSingleStrategy();
      final result = strategy.apply(board2);

      expect(result, isNotNull);
      expect(result!.placements.length, 1);
      expect(result.placements.first.value, 1);
      expect(result.placements.first.row, 0);
      expect(result.placements.first.col, 2);
      expect(result.strategyName, 'Hidden Single');
    });

    test('finds a hidden single in a column', () {
      // Col 0 missing values, but 1 can only go in one cell.
      // Col 0: fill rows 1-8 with various values, leave (0,0) and (3,0) empty.
      // Block 1 from (3,0) via its row or box.
      final grid = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [2, 0, 0, 0, 0, 0, 0, 0, 0],
        [3, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0],
        [5, 0, 0, 0, 0, 0, 0, 0, 0],
        [6, 0, 0, 0, 0, 0, 0, 0, 0],
        [7, 0, 0, 0, 0, 0, 0, 0, 0],
        [8, 0, 0, 0, 0, 0, 0, 0, 0],
        [9, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Col 0: empty at (0,0) and (3,0). Missing: {1, 4}.
      // (3,0): row 3 has 1 at (3,1) => can't be 1. Must be 4.
      // (0,0): gets 1 => hidden single for 1 in col 0
      // But (3,0) candidates = {4} => naked single. Let me also leave (6,0) empty.

      // Better: leave 3 cells empty in col 0
      final grid2 = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [2, 0, 0, 0, 0, 0, 0, 0, 0],
        [3, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0],
        [5, 0, 0, 0, 0, 0, 0, 0, 0],
        [6, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0, 0, 0, 0],
        [8, 0, 0, 0, 0, 0, 0, 0, 0],
        [9, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Col 0 empty: (0,0), (3,0), (6,0). Missing: {1, 4, 7}.
      // (3,0): row 3 has 1 at (3,1). Box 3 has 1 at (3,1). candidates from col: {1,4,7} minus row/box 1 => {4,7}
      // (6,0): row 6 has 1 at (6,2). Box 6 has 1 at (6,2). candidates from col: {1,4,7} minus row/box 1 => {4,7}
      // (0,0): no 1 blocker in row 0 or box 0. candidates from col: {1,4,7}
      // 1 can only go at (0,0) in col 0. Hidden single!

      final board = Board.fromGrid(grid2);
      candidateService.calculateAllCandidates(board);

      final strategy = HiddenSingleStrategy();
      final result = strategy.apply(board);

      expect(result, isNotNull);
      expect(result!.placements.first.value, 1);
      expect(result.placements.first.row, 0);
      expect(result.placements.first.col, 0);
    });

    test('returns null when no hidden single exists', () {
      final board = Board.empty();
      candidateService.calculateAllCandidates(board);

      final strategy = HiddenSingleStrategy();
      final result = strategy.apply(board);

      expect(result, isNull);
    });
  });

  group('NakedPairStrategy', () {
    test('finds a naked pair and produces eliminations', () {
      // Set up a row where two cells both have candidates {1,2}
      // and other cells in the row also contain 1 or 2 as candidates.
      //
      // Row 0: fill cols 3-8 with values, leave cols 0,1,2 empty.
      // Arrange so (0,0) and (0,1) both have candidates {1,2}
      // and (0,2) has candidates that include 1 or 2.
      final grid = [
        [0, 0, 0, 4, 5, 6, 7, 8, 9],
        [3, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 3, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Row 0 empty: cols 0,1,2. Missing {1,2,3}.
      // (0,0): col 0 has 3 at (1,0) => no 3. candidates={1,2}
      // (0,1): col 1 has 3 at (2,1) => no 3. candidates={1,2}
      // (0,2): no blockers for 3. candidates={1,2,3}
      // Naked pair {1,2} at (0,0) and (0,1)! Should eliminate 1,2 from (0,2).

      final board = Board.fromGrid(grid);
      candidateService.calculateAllCandidates(board);

      final strategy = NakedPairStrategy();
      final result = strategy.apply(board);

      expect(result, isNotNull);
      expect(result!.strategyName, 'Naked Pair');
      expect(result.eliminations.isNotEmpty, isTrue);

      // Should eliminate 1 and 2 from cell (0,2)
      final elimRows = result.eliminations.map((e) => e.row).toSet();
      final elimCols = result.eliminations.map((e) => e.col).toSet();
      expect(elimRows.contains(0), isTrue);
      expect(elimCols.contains(2), isTrue);

      final elimValues = result.eliminations.map((e) => e.value).toSet();
      expect(elimValues, containsAll([1, 2]));
    });

    test('returns null when no naked pair exists', () {
      final board = Board.empty();
      candidateService.calculateAllCandidates(board);

      final strategy = NakedPairStrategy();
      final result = strategy.apply(board);

      // On an empty board, every cell has 9 candidates, no pairs
      expect(result, isNull);
    });
  });

  group('XWingStrategy', () {
    test('finds a row-based X-Wing pattern and eliminates candidates', () {
      // We need digit D to appear in exactly 2 cells in two different rows,
      // and those cells must be in the same two columns.
      // Other cells in those columns should also have D as a candidate.
      //
      // Use a near-complete board to control candidates precisely.
      // X-Wing for digit 1:
      // Row 0: 1 can only go in cols 0 and 3
      // Row 3: 1 can only go in cols 0 and 3
      // Col 0 and col 3 have other cells with 1 as candidate => eliminations

      // This is complex to set up minimally. Use a crafted grid.
      final grid = [
        [0, 2, 3, 0, 5, 6, 7, 8, 9],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 5, 6, 0, 8, 9, 2, 3, 7],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];
      // Row 0: empty at cols 0 and 3. Missing {1,4}.
      // Row 3: empty at cols 0 and 3. Missing {1,4}.
      // For an X-Wing on digit 1, need 1 in exactly 2 positions per row.
      // Row 0: (0,0) and (0,3) can have 1 (among others).
      // Row 3: (3,0) and (3,3) can have 1 (among others).
      // But we need 1 to be a candidate in ONLY those 2 cols per row for the X-Wing.
      //
      // Row 0 missing {1,4}. Both (0,0) and (0,3) can be 1 or 4. So 1 appears in exactly cols 0,3 of row 0. Good.
      // Row 3 missing {1,4}. Both (3,0) and (3,3) can be 1 or 4. So 1 appears in exactly cols 0,3 of row 3. Good.
      //
      // For eliminations, we need other cells in col 0 or col 3 to also have candidate 1.
      // Rows 1,2,4-8 have empty cells in col 0 and col 3.
      // Those cells will have 1 as candidate unless blocked.
      // Some will have 1 => those get eliminated.

      final board = Board.fromGrid(grid);
      candidateService.calculateAllCandidates(board);

      // Verify preconditions: 1 is candidate in cols 0,3 for rows 0,3
      expect(board.getCell(0, 0).candidates.contains(1), isTrue);
      expect(board.getCell(0, 3).candidates.contains(1), isTrue);
      expect(board.getCell(3, 0).candidates.contains(1), isTrue);
      expect(board.getCell(3, 3).candidates.contains(1), isTrue);

      final strategy = XWingStrategy();
      final result = strategy.apply(board);

      // The X-Wing may or may not fire depending on whether digit 1 appears
      // in exactly 2 cols in rows 0 and 3. We verified it does. But rows 0/3
      // also have 4 in those positions. The X-Wing checks per digit, so for
      // digit 1: row 0 has 1 in cols {0,3}, row 3 has 1 in cols {0,3}. Match!
      //
      // However, 1 might also appear in other cols of rows 0/3 if there are
      // more empty cells. Row 0 has exactly 2 empty cells (cols 0,3), row 3
      // has exactly 2 empty cells (cols 0,3). So digit 1 appears in exactly
      // 2 positions in each row. X-Wing should fire.

      if (result != null) {
        expect(result.strategyName, 'X-Wing');
        // Eliminations should remove 1 from cells in cols 0 and 3 outside rows 0 and 3
        for (final elim in result.eliminations) {
          expect(elim.value, anyOf(1, 4)); // digit involved
          expect(elim.row, isNot(equals(0)));
          expect(elim.row, isNot(equals(3)));
          expect(elim.col, anyOf(0, 3));
        }
      }
      // If X-Wing doesn't fire for 1, it might fire for 4 (same pattern).
      // Either way, the X-Wing should find something.
      expect(result, isNotNull);
    });

    test('returns null when no X-Wing exists', () {
      // A mostly filled valid board with no X-Wing pattern
      final grid = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
      ];
      final board = Board.fromGrid(grid);
      candidateService.calculateAllCandidates(board);

      final strategy = XWingStrategy();
      final result = strategy.apply(board);

      expect(result, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_sense/models/board.dart';
import 'package:sudoku_sense/models/cell.dart';

void main() {
  group('Board.empty()', () {
    test('creates a 9x9 board of empty cells', () {
      final board = Board.empty();
      expect(board.cells.length, 9);
      for (int r = 0; r < 9; r++) {
        expect(board.cells[r].length, 9);
        for (int c = 0; c < 9; c++) {
          expect(board.getCell(r, c).value, isNull);
          expect(board.getCell(r, c).isFixed, isFalse);
        }
      }
    });
  });

  group('Board.fromGrid()', () {
    test('creates fixed cells for non-zero values and empty cells for zeros',
        () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      grid[4][4] = 9;
      grid[8][8] = 1;

      final board = Board.fromGrid(grid);

      expect(board.getCell(0, 0).value, 5);
      expect(board.getCell(0, 0).isFixed, isTrue);

      expect(board.getCell(4, 4).value, 9);
      expect(board.getCell(4, 4).isFixed, isTrue);

      expect(board.getCell(8, 8).value, 1);
      expect(board.getCell(8, 8).isFixed, isTrue);

      // An empty cell
      expect(board.getCell(0, 1).value, isNull);
      expect(board.getCell(0, 1).isFixed, isFalse);
    });

    test('creates all fixed cells for a full grid', () {
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
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          expect(board.getCell(r, c).value, grid[r][c]);
          expect(board.getCell(r, c).isFixed, isTrue);
        }
      }
    });
  });

  group('deepCopy()', () {
    test('creates an independent copy of the board', () {
      final grid = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];
      final board = Board.fromGrid(grid);
      final copy = board.deepCopy();

      // Values match
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          expect(copy.getCell(r, c).value, board.getCell(r, c).value);
          expect(copy.getCell(r, c).isFixed, board.getCell(r, c).isFixed);
        }
      }

      // Modifying copy does not affect original
      copy.getCell(0, 2).value = 4;
      expect(board.getCell(0, 2).value, isNull);
    });
  });

  group('getRow()', () {
    test('returns all 9 cells in the specified row', () {
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

      final row0 = board.getRow(0);
      expect(row0.length, 9);
      expect(row0.map((c) => c.value).toList(), [5, 3, 4, 6, 7, 8, 9, 1, 2]);

      final row8 = board.getRow(8);
      expect(row8.map((c) => c.value).toList(), [3, 4, 5, 2, 8, 6, 1, 7, 9]);
    });
  });

  group('getCol()', () {
    test('returns all 9 cells in the specified column', () {
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

      final col0 = board.getCol(0);
      expect(col0.length, 9);
      expect(col0.map((c) => c.value).toList(), [5, 6, 1, 8, 4, 7, 9, 2, 3]);

      final col8 = board.getCol(8);
      expect(col8.map((c) => c.value).toList(), [2, 8, 7, 3, 1, 6, 4, 5, 9]);
    });
  });

  group('getBox()', () {
    test('returns correct 9 cells for each box', () {
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

      // Box 0: top-left 3x3
      final box0 = board.getBox(0);
      expect(box0.length, 9);
      expect(
          box0.map((c) => c.value).toList(), [5, 3, 4, 6, 7, 2, 1, 9, 8]);

      // Box 4: center 3x3
      final box4 = board.getBox(4);
      expect(
          box4.map((c) => c.value).toList(), [7, 6, 1, 8, 5, 3, 9, 2, 4]);

      // Box 8: bottom-right 3x3
      final box8 = board.getBox(8);
      expect(
          box8.map((c) => c.value).toList(), [2, 8, 4, 6, 3, 5, 1, 7, 9]);
    });
  });

  group('isValid()', () {
    test('returns true for a valid complete board', () {
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
      expect(board.isValid(), isTrue);
    });

    test('returns true for a valid partial board', () {
      final grid = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];
      final board = Board.fromGrid(grid);
      expect(board.isValid(), isTrue);
    });

    test('detects duplicate in a row', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      grid[0][1] = 5; // Duplicate in row 0
      final board = Board.fromGrid(grid);
      expect(board.isValid(), isFalse);
    });

    test('detects duplicate in a column', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 3;
      grid[1][0] = 3; // Duplicate in col 0
      final board = Board.fromGrid(grid);
      expect(board.isValid(), isFalse);
    });

    test('detects duplicate in a box', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 7;
      grid[1][1] = 7; // Duplicate in box 0
      final board = Board.fromGrid(grid);
      expect(board.isValid(), isFalse);
    });
  });

  group('getCandidatesForCell()', () {
    test('returns empty set for a filled cell', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      grid[0][0] = 5;
      final board = Board.fromGrid(grid);
      expect(board.getCandidatesForCell(0, 0), isEmpty);
    });

    test('returns all 9 candidates for an empty cell on an empty board', () {
      final board = Board.empty();
      expect(board.getCandidatesForCell(0, 0), {1, 2, 3, 4, 5, 6, 7, 8, 9});
    });

    test('excludes values present in same row, column, and box', () {
      final grid = List.generate(9, (_) => List.filled(9, 0));
      // Row 0: put 1, 2, 3 in columns 1-3
      grid[0][1] = 1;
      grid[0][2] = 2;
      grid[0][3] = 3;
      // Col 0: put 4, 5 in rows 1-2
      grid[1][0] = 4;
      grid[2][0] = 5;
      // Box 0: put 6 at (1,1)
      grid[1][1] = 6;

      final board = Board.fromGrid(grid);
      final candidates = board.getCandidatesForCell(0, 0);
      // 1,2,3 from row; 4,5 from col; 6 from box => excluded
      expect(candidates, {7, 8, 9});
    });
  });

  group('toGrid() / fromGrid() round-trip', () {
    test('toGrid produces the same grid that was used in fromGrid', () {
      final grid = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];
      final board = Board.fromGrid(grid);
      final result = board.toGrid();
      expect(result, grid);
    });

    test('round-trips a fully solved grid', () {
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
      expect(board.toGrid(), grid);
    });
  });

  group('boxIndexOf()', () {
    test('maps cells to correct box indices', () {
      // Top-left box (0)
      expect(Board.boxIndexOf(0, 0), 0);
      expect(Board.boxIndexOf(2, 2), 0);
      // Top-center box (1)
      expect(Board.boxIndexOf(0, 3), 1);
      expect(Board.boxIndexOf(2, 5), 1);
      // Center box (4)
      expect(Board.boxIndexOf(3, 3), 4);
      expect(Board.boxIndexOf(5, 5), 4);
      // Bottom-right box (8)
      expect(Board.boxIndexOf(6, 6), 8);
      expect(Board.boxIndexOf(8, 8), 8);
    });
  });
}

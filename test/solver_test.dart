import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_sense/models/board.dart';
import 'package:sudoku_sense/services/solver_service.dart';

void main() {
  final easyPuzzle = [
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

  final easySolution = [
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

  late SolverService solver;

  setUp(() {
    solver = SolverService();
  });

  group('Solver finds correct solutions', () {
    test('solves the easy puzzle correctly', () {
      final board = Board.fromGrid(easyPuzzle);
      final result = solver.solve(board);

      expect(result.solution, isNotNull);
      expect(result.isValid, isTrue);
      expect(result.solution!.toGrid(), easySolution);
    });

    test('solutionCount is 1 for a valid unique puzzle', () {
      final board = Board.fromGrid(easyPuzzle);
      final result = solver.solve(board);

      expect(result.solutionCount, 1);
      expect(result.hasUniqueSolution, isTrue);
    });
  });

  group('Invalid puzzles', () {
    test('solutionCount is 0 for a puzzle with conflicting values', () {
      // Two 5s in the first row
      final invalidPuzzle = [
        [5, 5, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 0, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];

      final board = Board.fromGrid(invalidPuzzle);
      final result = solver.solve(board);

      expect(result.solutionCount, 0);
      expect(result.isValid, isFalse);
      expect(result.solution, isNull);
    });

    test('solutionCount is 0 for conflicting values in a column', () {
      // Two 6s in column 0
      final invalidPuzzle = [
        [6, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 0, 0],
        [8, 0, 0, 0, 0, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];

      final board = Board.fromGrid(invalidPuzzle);
      final result = solver.solve(board);

      expect(result.solutionCount, 0);
      expect(result.isValid, isFalse);
    });

    test('solutionCount is 0 for conflicting values in a box', () {
      // Two 5s in box 0
      final invalidPuzzle = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [0, 5, 0, 1, 9, 0, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 0],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];

      final board = Board.fromGrid(invalidPuzzle);
      final result = solver.solve(board);

      expect(result.solutionCount, 0);
      expect(result.isValid, isFalse);
    });
  });

  group('Multiple solutions', () {
    test('solutionCount >= 2 for a puzzle with many clues removed', () {
      // Remove several clues from the easy puzzle to create ambiguity
      final ambiguousPuzzle = [
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];

      final board = Board.fromGrid(ambiguousPuzzle);
      final result = solver.solve(board);

      // Solver caps at 2, so solutionCount should be 2
      expect(result.solutionCount, 2);
      expect(result.hasUniqueSolution, isFalse);
      expect(result.isValid, isTrue);
      expect(result.solution, isNotNull);
    });
  });

  group('Edge cases', () {
    test('solves an empty board (finds a valid solution)', () {
      final emptyGrid = List.generate(9, (_) => List.filled(9, 0));
      final board = Board.fromGrid(emptyGrid);
      final result = solver.solve(board);

      // An empty board has many solutions; solver should find at least one
      expect(result.solution, isNotNull);
      expect(result.isValid, isTrue);
      expect(result.solutionCount, 2); // Capped at 2
    });

    test('already-solved board returns itself as solution', () {
      final board = Board.fromGrid(easySolution);
      final result = solver.solve(board);

      expect(result.solutionCount, 1);
      expect(result.hasUniqueSolution, isTrue);
      expect(result.solution!.toGrid(), easySolution);
    });
  });
}

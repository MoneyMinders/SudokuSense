import 'dart:math';
import '../models/board.dart';
import '../services/solver_service.dart';
import '../services/candidate_service.dart';
import '../services/hint_service.dart';
import '../models/hint_result.dart';
import '../data/practice_puzzles.dart';

/// Generates practice puzzles dynamically by creating random boards
/// and finding states where specific techniques are needed.
class PracticeGenerator {
  static final _random = Random();
  static final _solver = SolverService();
  static final _hintService = HintService();

  /// Generate a practice puzzle for a given technique.
  /// Returns null if unable to generate after max attempts.
  static PracticePuzzle? generateForTechnique(String techniqueName, int index) {
    // Try up to 50 random puzzles to find one where this technique applies
    for (int attempt = 0; attempt < 50; attempt++) {
      final grid = _generateRandomGrid();
      if (grid == null) continue;

      final board = Board.fromGrid(grid);
      CandidateService().calculateAllCandidates(board);

      final hint = _hintService.findHint(board);
      if (hint == null) continue;

      // Check if the hint uses the target technique
      if (hint.strategyName == techniqueName && hint.placements.isNotEmpty) {
        final p = hint.placements.first;
        return PracticePuzzle(
          id: '${techniqueName}_gen_$index',
          grid: grid,
          answerRow: p.row,
          answerCol: p.col,
          answerValue: p.value,
          explanation: hint.explanation,
        );
      }
    }
    return null;
  }

  /// Generate a random valid puzzle grid with ~28-35 clues.
  static List<List<int>>? _generateRandomGrid() {
    // Step 1: Fill a random complete grid
    final grid = List.generate(9, (_) => List.filled(9, 0));
    if (!_fillGrid(grid)) return null;

    // Step 2: Remove cells to create puzzle
    final positions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r, c));
      }
    }
    positions.shuffle(_random);

    // Remove cells (aim for 28-35 clues remaining)
    final targetRemove = 46 + _random.nextInt(8); // remove 46-53 cells
    int removed = 0;

    for (final (r, c) in positions) {
      if (removed >= targetRemove) break;
      final backup = grid[r][c];
      grid[r][c] = 0;

      // Check unique solution
      final board = Board.fromGrid(grid);
      final result = _solver.solve(board);
      if (result.solutionCount != 1) {
        grid[r][c] = backup; // Put it back
      } else {
        removed++;
      }
    }

    return removed >= 30 ? grid : null;
  }

  static bool _fillGrid(List<List<int>> grid) {
    for (int i = 0; i < 81; i++) {
      final row = i ~/ 9;
      final col = i % 9;
      if (grid[row][col] == 0) {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        numbers.shuffle(_random);
        for (final value in numbers) {
          if (_canPlace(grid, row, col, value)) {
            grid[row][col] = value;
            if (_isGridFull(grid) || _fillGrid(grid)) return true;
          }
        }
        grid[row][col] = 0;
        return false;
      }
    }
    return true;
  }

  static bool _canPlace(List<List<int>> grid, int row, int col, int value) {
    if (grid[row].contains(value)) return false;
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == value) return false;
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  static bool _isGridFull(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) return false;
      }
    }
    return true;
  }
}

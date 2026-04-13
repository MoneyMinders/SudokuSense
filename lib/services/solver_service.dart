import '../models/board.dart';

class SolverResult {
  final Board? solution;
  final int solutionCount;
  final bool isValid;
  final bool hasUniqueSolution;

  const SolverResult({
    this.solution,
    required this.solutionCount,
    required this.isValid,
    required this.hasUniqueSolution,
  });
}

class SolverService {
  SolverResult solve(Board board) {
    final workBoard = board.deepCopy();

    // Validate the initial board
    if (!workBoard.isValid()) {
      return const SolverResult(
        solution: null,
        solutionCount: 0,
        isValid: false,
        hasUniqueSolution: false,
      );
    }

    final solutions = <Board>[];
    _solve(workBoard, solutions, 2);

    return SolverResult(
      solution: solutions.isNotEmpty ? solutions.first : null,
      solutionCount: solutions.length,
      isValid: solutions.isNotEmpty,
      hasUniqueSolution: solutions.length == 1,
    );
  }

  /// Backtracking solver with constraint propagation.
  /// Stops after finding [maxSolutions] solutions.
  bool _solve(Board board, List<Board> solutions, int maxSolutions) {
    if (solutions.length >= maxSolutions) return true;

    // Find the empty cell with the fewest candidates (MRV heuristic)
    int bestRow = -1;
    int bestCol = -1;
    int bestCount = 10;

    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (board.getCell(row, col).value == null) {
          final candidates = board.getCandidatesForCell(row, col);
          if (candidates.isEmpty) return false; // Dead end
          if (candidates.length < bestCount) {
            bestCount = candidates.length;
            bestRow = row;
            bestCol = col;
            if (bestCount == 1) break; // Can't do better than 1
          }
        }
      }
      if (bestCount == 1) break;
    }

    // All cells filled — found a solution
    if (bestRow == -1) {
      solutions.add(board.deepCopy());
      return solutions.length >= maxSolutions;
    }

    final candidates = board.getCandidatesForCell(bestRow, bestCol);

    for (final value in candidates) {
      board.getCell(bestRow, bestCol).value = value;

      if (_solve(board, solutions, maxSolutions)) {
        board.getCell(bestRow, bestCol).value = null;
        return true;
      }

      board.getCell(bestRow, bestCol).value = null;
    }

    return false;
  }
}

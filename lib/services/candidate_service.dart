import '../models/board.dart';

class CandidateService {
  /// Fills candidates for every empty cell based on current values
  /// in the same row, column, and box.
  void calculateAllCandidates(Board board) {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final cell = board.getCell(row, col);
        if (cell.value == null) {
          cell.candidates = calculateCandidates(board, row, col);
        } else {
          cell.candidates.clear();
        }
      }
    }
  }

  /// Returns the set of valid candidates for a single cell
  /// based on current board state.
  Set<int> calculateCandidates(Board board, int row, int col) {
    return board.getCandidatesForCell(row, col);
  }
}

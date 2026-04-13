import 'dart:math';

import 'package:flutter/foundation.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../models/hint_result.dart';
import '../services/solver_service.dart';
import '../services/candidate_service.dart';
import '../services/hint_service.dart';

/// Snapshot of board state for undo support.
class BoardState {
  final Board board;

  BoardState(this.board);
}

class PuzzleProvider extends ChangeNotifier {
  Board _board = Board.empty();
  Board? _solution;
  int? _solutionCount;
  int? _selectedRow;
  int? _selectedCol;
  bool _pencilMode = false;
  bool _setupMode = false;
  int? _digitFirst; // "Select Digit First" mode: selected digit to place
  final List<BoardState> _history = [];
  final List<BoardState> _redoStack = [];
  HintResult? _activeHint;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------
  Board get board => _board;
  Board? get solution => _solution;
  int? get solutionCount => _solutionCount;
  int? get selectedRow => _selectedRow;
  int? get selectedCol => _selectedCol;
  bool get pencilMode => _pencilMode;
  bool get setupMode => _setupMode;
  int? get digitFirst => _digitFirst;
  HintResult? get activeHint => _activeHint;
  bool get canUndo => _history.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  /// Fraction of the board that is filled (0.0 to 1.0).
  double get progress {
    int filled = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_board.getCell(r, c).value != null) filled++;
      }
    }
    return filled / 81;
  }

  /// Whether the puzzle is fully and correctly solved.
  bool get isSolved => _board.isComplete();

  // ---------------------------------------------------------------------------
  // Puzzle lifecycle
  // ---------------------------------------------------------------------------

  /// Enter setup mode for manual puzzle entry.
  void startSetupMode() {
    _board = Board.empty();
    _solution = null;
    _solutionCount = null;
    _history.clear();
    _activeHint = null;
    _selectedRow = null;
    _selectedCol = null;
    _pencilMode = false;
    _setupMode = true;
    notifyListeners();
  }

  /// Finish setup mode: mark all entered values as fixed, solve, calculate candidates.
  /// Returns null on success, or an error message string.
  String? finishSetup() {
    // Mark all entered values as fixed clues.
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board.getCell(r, c);
        if (cell.value != null) {
          cell.isFixed = true;
        }
      }
    }

    // Validate and solve.
    final solver = SolverService();
    final result = solver.solve(_board);
    _solution = result.solution;
    _solutionCount = result.solutionCount;

    if (result.solutionCount == 0) {
      // Undo the fixed marking so user can edit.
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          _board.getCell(r, c).isFixed = false;
        }
      }
      notifyListeners();
      return 'Invalid puzzle — no solution exists.';
    }

    _setupMode = false;
    CandidateService().calculateAllCandidates(_board);
    notifyListeners();

    if (result.solutionCount >= 2) {
      return 'Warning: Multiple solutions detected — not a standard Sudoku.';
    }
    return null;
  }

  /// Load a puzzle from an int grid where 0 = empty.
  void loadPuzzle(List<List<int>> grid) {
    _board = Board.fromGrid(grid);
    _history.clear();
    _activeHint = null;
    _selectedRow = null;
    _selectedCol = null;
    _pencilMode = false;

    // Solve to get the reference solution and validate uniqueness.
    final solver = SolverService();
    final result = solver.solve(_board);
    _solution = result.solution;
    _solutionCount = result.solutionCount;

    // Calculate candidates for all empty cells.
    CandidateService().calculateAllCandidates(_board);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void selectCell(int row, int col) {
    _selectedRow = row;
    _selectedCol = col;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRow = null;
    _selectedCol = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Value entry
  // ---------------------------------------------------------------------------

  /// Set a value on the currently selected cell.
  /// In pencil mode this toggles a candidate instead.
  /// In setup mode, places values as clues (not fixed until finishSetup).
  void setValue(int value) {
    if (_selectedRow == null || _selectedCol == null) return;
    final row = _selectedRow!;
    final col = _selectedCol!;
    final cell = _board.getCell(row, col);
    if (cell.isFixed) return;

    if (_pencilMode && !_setupMode) {
      toggleCandidate(value);
      return;
    }

    // Save state for undo before mutating.
    _pushHistory();

    cell.value = value;
    cell.candidates.clear();

    // In setup mode, skip solution checking.
    if (_setupMode) {
      notifyListeners();
      return;
    }

    // Check against the solution if available.
    if (_solution != null) {
      final solutionValue = _solution!.getCell(row, col).value;
      cell.isError = (solutionValue != null && value != solutionValue);
    }

    // Recalculate candidates for all empty cells since a new value was placed.
    CandidateService().calculateAllCandidates(_board);

    notifyListeners();
  }

  /// Toggle a single candidate in the selected cell.
  void toggleCandidate(int value) {
    if (_selectedRow == null || _selectedCol == null) return;
    final row = _selectedRow!;
    final col = _selectedCol!;
    final cell = _board.getCell(row, col);
    if (cell.isFixed || cell.value != null) return;

    if (cell.candidates.contains(value)) {
      cell.candidates.remove(value);
    } else {
      cell.candidates.add(value);
    }
    notifyListeners();
  }

  /// Clear the value (or candidates) on the selected cell.
  void clearSelectedCell() {
    if (_selectedRow == null || _selectedCol == null) return;
    final row = _selectedRow!;
    final col = _selectedCol!;
    final cell = _board.getCell(row, col);
    if (cell.isFixed) return;

    _pushHistory();

    cell.value = null;
    cell.isError = false;

    // Recalculate candidates for all empty cells.
    CandidateService().calculateAllCandidates(_board);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Pencil mode
  // ---------------------------------------------------------------------------

  void togglePencilMode() {
    _pencilMode = !_pencilMode;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Hints
  // ---------------------------------------------------------------------------

  /// Find the next logical hint on the current board.
  HintResult? getHint() {
    _activeHint = HintService().findHint(_board);
    notifyListeners();
    return _activeHint;
  }

  /// Apply the given hint: place values and/or eliminate candidates.
  void applyHint(HintResult hint) {
    _pushHistory();

    // Apply placements.
    for (final placement in hint.placements) {
      final cell = _board.getCell(placement.row, placement.col);
      if (!cell.isFixed) {
        cell.value = placement.value;
        cell.candidates.clear();
      }
    }

    // Apply eliminations.
    for (final elim in hint.eliminations) {
      final cell = _board.getCell(elim.row, elim.col);
      cell.candidates.remove(elim.value);
    }

    // Only recalculate candidates if placements were made (new values affect
    // peer candidates). Skip recalculation for elimination-only hints to
    // preserve the logical deductions.
    if (hint.placements.isNotEmpty) {
      CandidateService().calculateAllCandidates(_board);
    }

    _activeHint = null;
    notifyListeners();
  }

  void clearActiveHint() {
    _activeHint = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Auto-solve
  // ---------------------------------------------------------------------------

  /// Fill every empty cell with the value from the stored solution.
  void autoSolve() {
    if (_solution == null) return;

    _pushHistory();

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board.getCell(r, c);
        if (cell.value == null) {
          cell.value = _solution!.getCell(r, c).value;
          cell.candidates.clear();
          cell.isError = false;
        }
      }
    }

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Undo
  // ---------------------------------------------------------------------------

  /// Undo the last user action by restoring the previous board state.
  void undo() {
    if (_history.isEmpty) return;
    _redoStack.add(BoardState(_board.deepCopy()));
    final previous = _history.removeLast();
    _board = previous.board;
    _activeHint = null;
    notifyListeners();
  }

  /// Redo a previously undone action.
  void redo() {
    if (_redoStack.isEmpty) return;
    _history.add(BoardState(_board.deepCopy()));
    final next = _redoStack.removeLast();
    _board = next.board;
    _activeHint = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// Check every user-entered value against the solution.
  /// Marks incorrect cells with [Cell.isError] = true.
  /// Returns true if no errors were found.
  bool validate() {
    if (_solution == null) return true;

    bool clean = true;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board.getCell(r, c);
        if (cell.isFixed || cell.value == null) continue;
        final expected = _solution!.getCell(r, c).value;
        if (cell.value != expected) {
          cell.isError = true;
          clean = false;
        } else {
          cell.isError = false;
        }
      }
    }

    notifyListeners();
    return clean;
  }

  // ---------------------------------------------------------------------------
  // Digit-first mode
  // ---------------------------------------------------------------------------

  /// Toggle "Select Digit First" mode. Tap a digit, then tap cells to fill.
  void setDigitFirst(int? digit) {
    _digitFirst = digit;
    notifyListeners();
  }

  /// In digit-first mode, tapping a cell places the pre-selected digit.
  void placeDigitFirst(int row, int col) {
    if (_digitFirst == null) return;
    _selectedRow = row;
    _selectedCol = col;
    setValue(_digitFirst!);
  }

  // ---------------------------------------------------------------------------
  // Clear grid
  // ---------------------------------------------------------------------------

  /// Clear all user-entered values, keep fixed clues.
  void clearGrid() {
    _pushHistory();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board.getCell(r, c);
        if (!cell.isFixed) {
          cell.value = null;
          cell.isError = false;
          cell.candidates.clear();
        }
      }
    }
    CandidateService().calculateAllCandidates(_board);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Random puzzle
  // ---------------------------------------------------------------------------

  /// Generate a random solvable Sudoku puzzle.
  void loadRandomPuzzle() {
    // Start with empty board, solve it, then remove cells
    final fullBoard = Board.empty();
    final solver = SolverService();

    // Solve an empty board to get a random full solution
    final result = solver.solve(fullBoard);
    if (result.solution == null) return;

    final grid = result.solution!.toGrid();
    final random = Random();

    // Remove ~45 cells to create puzzle (leaves ~36 clues)
    final positions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r, c));
      }
    }
    positions.shuffle(random);

    for (int i = 0; i < 45; i++) {
      final (r, c) = positions[i];
      grid[r][c] = 0;
    }

    loadPuzzle(grid);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Push a deep copy of the current board onto the undo stack.
  void _pushHistory() {
    _redoStack.clear(); // Clear redo stack on new action.
    _history.add(BoardState(_board.deepCopy()));
  }
}

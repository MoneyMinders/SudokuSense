import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import '../models/board.dart';
import '../models/cell.dart';
import '../models/hint_result.dart';
import '../services/solver_service.dart';
import '../services/candidate_service.dart';
import '../services/hint_service.dart';
import '../services/storage_service.dart';
import '../utils/puzzle_tier.dart';

/// Snapshot of board state for undo support.
class BoardState {
  final Board board;

  BoardState(this.board);
}

class PuzzleProvider extends ChangeNotifier {
  Board _board = Board.empty();
  Board? _solution;
  int? _solutionCount;
  List<List<int>>? _originalGrid; // The puzzle as originally entered
  String? _currentPuzzleId; // ID for save/load
  int? _selectedRow;
  int? _selectedCol;
  bool _pencilMode = false;
  bool _setupMode = false;
  bool _setupFromOcr = false;
  Uint8List? _ocrImageBytes; // Cropped scan image for peek overlay
  bool _peeking = false; // Whether user is holding the peek button
  int? _digitFirst; // "Select Digit First" mode: selected digit to place
  final List<BoardState> _history = [];
  final List<BoardState> _redoStack = [];
  HintResult? _activeHint;

  // Timer
  final Stopwatch _stopwatch = Stopwatch();
  Duration _savedElapsed = Duration.zero; // accumulated time from previous sessions

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
  bool get setupFromOcr => _setupFromOcr;
  Uint8List? get ocrImageBytes => _ocrImageBytes;
  bool get peeking => _peeking;
  int? get digitFirst => _digitFirst;
  HintResult? get activeHint => _activeHint;
  bool get canUndo => _history.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  Duration get elapsed => _savedElapsed + _stopwatch.elapsed;
  bool get timerRunning => _stopwatch.isRunning;

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
  void startSetupMode({bool fromOcr = false}) {
    _board = Board.empty();
    _solution = null;
    _solutionCount = null;
    _history.clear();
    _activeHint = null;
    _selectedRow = null;
    _selectedCol = null;
    _pencilMode = false;
    _setupMode = true;
    _setupFromOcr = fromOcr;
    notifyListeners();
  }

  /// Finish setup mode: mark all entered values as fixed, solve, calculate candidates.
  /// Returns null on success, or an error message string.
  String? finishSetup() {
    // Count how many clues were entered.
    int clueCount = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_board.getCell(r, c).value != null) clueCount++;
      }
    }

    if (clueCount == 0) {
      return 'Enter at least some clues before starting.';
    }

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
    _ocrImageBytes = null;
    _peeking = false;
    _originalGrid = _board.toGrid();
    _currentPuzzleId = DateTime.now().millisecondsSinceEpoch.toString();
    // Start the timer
    _savedElapsed = Duration.zero;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();
    return null;
  }

  /// Return to setup mode so the user can correct clues (e.g. after OCR).
  /// Un-fixes all clue cells so they become editable again.
  void editClues() {
    _setupMode = true;
    _solution = null;
    _solutionCount = null;
    _history.clear();
    _redoStack.clear();
    _activeHint = null;
    _pencilMode = false;

    // Un-fix all cells and clear user entries (keep only clue values).
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board.getCell(r, c);
        if (cell.isFixed) {
          cell.isFixed = false;
        } else {
          // Clear any user-entered values and pencil marks.
          cell.value = null;
          cell.candidates.clear();
          cell.isError = false;
        }
      }
    }
    notifyListeners();
  }

  /// Load a puzzle from an int grid where 0 = empty.
  void loadPuzzle(List<List<int>> grid, {String? puzzleId}) {
    _board = Board.fromGrid(grid);
    _originalGrid = grid.map((r) => List<int>.from(r)).toList();
    _currentPuzzleId = puzzleId ?? DateTime.now().millisecondsSinceEpoch.toString();
    _history.clear();
    _redoStack.clear();
    _activeHint = null;
    _selectedRow = null;
    _selectedCol = null;
    _pencilMode = false;

    // Solve to get the reference solution and validate uniqueness.
    final solver = SolverService();
    final result = solver.solve(_board);
    _solution = result.solution;
    _solutionCount = result.solutionCount;

    // Start timer
    _savedElapsed = Duration.zero;
    _stopwatch.reset();
    _stopwatch.start();

    notifyListeners();
  }

  /// Pause the timer (when navigating away).
  void pauseTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  /// Resume the timer (when returning to puzzle).
  void resumeTimer() {
    if (!_stopwatch.isRunning && !_setupMode && !isSolved) {
      _stopwatch.start();
    }
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  /// Store the cropped scan image for the peek overlay.
  void setOcrImageBytes(Uint8List? bytes) {
    _ocrImageBytes = bytes;
  }

  /// Toggle the peek overlay on/off (called by long press).
  void setPeeking(bool value) {
    _peeking = value;
    notifyListeners();
  }

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

    // When a digit has been placed in all 9 required positions, it can no
    // longer appear anywhere — purge it from every cell's pencil candidates.
    if (!cell.isError) {
      _cleanupCandidatesIfComplete(value);
    }

    // Stop timer if puzzle is now complete
    if (isSolved) _stopwatch.stop();

    notifyListeners();
  }

  /// If [value] now has 9 placements on the board, remove it from every
  /// other cell's candidate set — those pencil marks are no longer valid.
  void _cleanupCandidatesIfComplete(int value) {
    int count = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_board.getCell(r, c).value == value) count++;
      }
    }
    if (count < 9) return;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board.getCell(r, c);
        if (cell.value == null && cell.candidates.contains(value)) {
          cell.candidates.remove(value);
        }
      }
    }
  }

  /// Toggle a single candidate in the selected cell (pencil mode).
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
    cell.candidates.clear();
    cell.isError = false;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Pencil mode
  // ---------------------------------------------------------------------------

  void togglePencilMode() {
    _pencilMode = !_pencilMode;
    notifyListeners();
  }

  /// Fill all empty cells with their possible candidates (user-triggered).
  void fillPossibilities() {
    _pushHistory();
    CandidateService().calculateAllCandidates(_board);
    notifyListeners();
  }

  /// Clear all pencil marks from the board.
  void clearPencilMarks() {
    _pushHistory();
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = _board.getCell(r, c);
        if (cell.value == null) {
          cell.candidates.clear();
        }
      }
    }
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

    // Don't auto-fill candidates on the user's board.

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

  /// Replay the hint engine from the original puzzle and return the
  /// full ordered list of logical steps the solver would take.
  /// Stops when the puzzle is complete or no further strategy applies.
  List<HintResult> computeSolutionSteps() {
    if (_originalGrid == null) return [];
    return _replaySolution(_originalGrid!);
  }

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

    _stopwatch.stop();
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

  /// Generate a random solvable Sudoku puzzle at the requested [tier].
  /// Produces candidates until one classifies to [tier]; otherwise returns
  /// the closest-tier candidate seen.
  void loadRandomPuzzle({PuzzleTier tier = PuzzleTier.medium}) {
    final random = Random();
    const maxAttempts = 20;

    List<List<int>>? bestFallback;
    int bestDistance = 999;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final grid = _generateCandidate(random, tier.targetBlanks);
      final steps = _replaySolution(grid);
      final candidateTier = classifyTier(steps);

      if (candidateTier == tier) {
        loadPuzzle(grid);
        return;
      }

      // Track closest fallback in case no exact match is found.
      if (candidateTier != null) {
        final dist = (candidateTier.index - tier.index).abs();
        if (dist < bestDistance) {
          bestDistance = dist;
          bestFallback = grid;
        }
      }
    }

    loadPuzzle(bestFallback ?? _generateCandidate(random, tier.targetBlanks));
  }

  /// Build one candidate puzzle grid with the requested blank count.
  List<List<int>> _generateCandidate(Random random, int targetBlanks) {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid, random);

    final positions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        positions.add((r, c));
      }
    }
    positions.shuffle(random);

    int removed = 0;
    for (final (r, c) in positions) {
      if (removed >= targetBlanks) break;
      if (grid[r][c] == 0) continue;

      final backup = grid[r][c];
      grid[r][c] = 0;

      final testBoard = Board.fromGrid(grid);
      final result = SolverService().solve(testBoard);
      if (result.solutionCount != 1) {
        grid[r][c] = backup;
      } else {
        removed++;
      }
    }
    return grid;
  }

  /// Replay the hint engine on [grid] from scratch and return every step.
  List<HintResult> _replaySolution(List<List<int>> grid) {
    final workBoard = Board.fromGrid(grid);
    final service = HintService();
    final steps = <HintResult>[];
    const maxSteps = 200;

    for (int i = 0; i < maxSteps; i++) {
      if (workBoard.isComplete()) break;
      final hint = service.findHint(workBoard);
      if (hint == null) break;
      steps.add(hint);

      for (final p in hint.placements) {
        final cell = workBoard.getCell(p.row, p.col);
        if (!cell.isFixed) {
          cell.value = p.value;
          cell.candidates.clear();
        }
      }
      for (final e in hint.eliminations) {
        workBoard.getCell(e.row, e.col).candidates.remove(e.value);
      }
    }
    return steps;
  }

  /// Fill a 9x9 grid with valid random numbers using backtracking.
  bool _fillGrid(List<List<int>> grid, Random random) {
    for (int i = 0; i < 81; i++) {
      final row = i ~/ 9;
      final col = i % 9;
      if (grid[row][col] == 0) {
        final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        numbers.shuffle(random);
        for (final value in numbers) {
          if (_canPlace(grid, row, col, value)) {
            grid[row][col] = value;
            if (_isGridFull(grid) || _fillGrid(grid, random)) {
              return true;
            }
          }
        }
        grid[row][col] = 0;
        return false;
      }
    }
    return true;
  }

  bool _canPlace(List<List<int>> grid, int row, int col, int value) {
    // Check row
    if (grid[row].contains(value)) return false;
    // Check column
    for (int r = 0; r < 9; r++) {
      if (grid[r][col] == value) return false;
    }
    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (grid[r][c] == value) return false;
      }
    }
    return true;
  }

  bool _isGridFull(List<List<int>> grid) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (grid[r][c] == 0) return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Save / Load
  // ---------------------------------------------------------------------------

  /// Save current puzzle state to device storage.
  Future<void> savePuzzle({String? name}) async {
    if (_originalGrid == null) return;

    final puzzle = SavedPuzzle(
      id: _currentPuzzleId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name ?? 'Puzzle ${DateTime.now().month}/${DateTime.now().day}',
      originalGrid: _originalGrid!,
      currentGrid: _board.toGrid(),
      currentCandidates: _snapshotCandidates(),
      savedAt: DateTime.now(),
      progress: progress,
      elapsed: elapsed,
    );

    await StorageService().save(puzzle);
  }

  /// Snapshot every cell's pencil candidates as a serialisable 9x9 grid.
  List<List<List<int>>> _snapshotCandidates() {
    return List.generate(9, (r) {
      return List.generate(9, (c) {
        final cell = _board.getCell(r, c);
        if (cell.value != null) return <int>[];
        return cell.candidates.toList()..sort();
      });
    });
  }

  /// Load a saved puzzle (resumes from where user left off).
  void loadSavedPuzzle(SavedPuzzle saved) {
    _originalGrid = saved.originalGrid;
    _currentPuzzleId = saved.id;

    // Load original as fixed clues
    final original = Board.fromGrid(saved.originalGrid);

    // Apply current progress on top
    _board = Board.fromGrid(saved.originalGrid);
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final originalVal = saved.originalGrid[r][c];
        final currentVal = saved.currentGrid[r][c];
        final cell = _board.getCell(r, c);

        if (originalVal == 0 && currentVal != 0) {
          // User had entered this value
          cell.value = currentVal;
          cell.isFixed = false;
        }

        // Restore pencil candidates only on cells without a value, so we
        // never resurrect notes the user had cleared by placing a digit.
        if (cell.value == null) {
          final notes = saved.currentCandidates[r][c];
          if (notes.isNotEmpty) {
            cell.candidates = notes.toSet();
          }
        }
      }
    }

    _history.clear();
    _redoStack.clear();
    _activeHint = null;
    _selectedRow = null;
    _selectedCol = null;
    _pencilMode = false;

    final solver = SolverService();
    final result = solver.solve(original);
    _solution = result.solution;
    _solutionCount = result.solutionCount;

    // Resume the timer from where the player left off.
    _savedElapsed = saved.elapsed;
    _stopwatch.reset();
    _stopwatch.start();

    // Don't auto-fill candidates — user does it manually via Fill Notes
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Push a deep copy of the current board onto the undo stack.
  void _pushHistory() {
    _redoStack.clear();
    _history.add(BoardState(_board.deepCopy()));
  }
}

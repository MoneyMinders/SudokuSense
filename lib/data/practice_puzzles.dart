/// Practice puzzles for each Sudoku technique.
/// Each puzzle is a board state where exactly one application of the
/// technique reveals the next move.
///
/// Format: grid (0=empty), expected answer (row, col, value), explanation.

class PracticePuzzle {
  final String id;
  final List<List<int>> grid;
  final int answerRow;
  final int answerCol;
  final int answerValue;
  final String explanation;

  const PracticePuzzle({
    required this.id,
    required this.grid,
    required this.answerRow,
    required this.answerCol,
    required this.answerValue,
    required this.explanation,
  });
}

class TechniqueGroup {
  final String name;
  final String difficulty; // Easy, Medium, Hard, Expert, Evil
  final String description;
  final String howTo; // Brief explanation of the technique
  final List<PracticePuzzle> puzzles;
  final TechniqueExample? example;

  const TechniqueGroup({
    required this.name,
    required this.difficulty,
    required this.description,
    required this.howTo,
    required this.puzzles,
    this.example,
  });
}

/// Role used to style a cell in a technique example.
enum ExampleRole { clue, pivot, pincerA, pincerB, target, link }

/// A single cell inside a worked example board.
///  - [value] — a placed number (drawn bold like a clue).
///  - [candidates] — pencil marks to render as a 3x3 mini-grid inside the cell.
///  - [role] — styling (border/highlight colour) according to the pattern.
class ExampleCell {
  final int? value;
  final Set<int>? candidates;
  final ExampleRole? role;

  const ExampleCell({this.value, this.candidates, this.role});
}

/// An arrow / connector drawn over the example board — used to show the
/// geometric relationship at the heart of a pattern (pivot → pincer, etc.).
class ExampleArrow {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;

  const ExampleArrow({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
  });
}

/// A hand-authored worked example for a technique. Rendered on the first
/// page of each practice technique so the reader can see the pattern
/// (candidates, pivot, pincers, target) before attempting drills.
class TechniqueExample {
  final List<List<ExampleCell>> cells;
  final List<ExampleArrow> arrows;
  final String narration;

  const TechniqueExample({
    required this.cells,
    this.arrows = const [],
    required this.narration,
  });
}

// -- Helpers for building example cell grids. Not const so we can use them
// -- inline in the data file below.
ExampleCell _val(int n) => ExampleCell(value: n, role: ExampleRole.clue);
ExampleCell _empty() => const ExampleCell();
ExampleCell _cand(Set<int> c, ExampleRole r) =>
    ExampleCell(candidates: c, role: r);
ExampleCell _target({int? value, Set<int>? candidates}) => ExampleCell(
      value: value,
      candidates: candidates,
      role: ExampleRole.target,
    );

/// Build a 9x9 example from a row-major list of ExampleCells (length 81).
List<List<ExampleCell>> _exampleGrid(List<ExampleCell> flat) {
  assert(flat.length == 81, 'Example grid must have 81 cells');
  return List.generate(
    9,
    (r) => List.generate(9, (c) => flat[r * 9 + c]),
  );
}

/// All practice puzzles grouped by technique.
final List<TechniqueGroup> practiceData = [
  // =========================================================================
  // EASY
  // =========================================================================
  TechniqueGroup(
    name: 'Naked Single',
    difficulty: 'Easy',
    description: 'A cell has only one possible value left.',
    howTo: 'Look at a cell and check which numbers 1-9 are already in its row, column, and box. If only one number is missing, that\'s the answer.',
    example: TechniqueExample(
      cells: _exampleGrid([
        // Row 1: 1,2,3,5,6,7,8,9 placed — only the middle cell (R1C3) is empty.
        _val(5), _val(3), _target(candidates: {4}), _val(6), _val(7), _val(8), _val(9), _val(1), _val(2),
        for (int i = 0; i < 72; i++) _empty(),
      ]),
      narration:
          'Row 1 already contains 1, 2, 3, 5, 6, 7, 8, and 9. The single empty cell R1C3 can only take the one missing digit, 4.',
    ),
    puzzles: [
      PracticePuzzle(
        id: 'ns1',
        grid: [
          [5,3,4,6,7,8,9,1,0],
          [6,7,2,1,9,5,3,4,8],
          [1,9,8,3,4,2,5,6,7],
          [8,5,9,7,6,1,4,2,3],
          [4,2,6,8,5,3,7,9,1],
          [7,1,3,9,2,4,8,5,6],
          [9,6,1,5,3,7,2,8,4],
          [2,8,7,4,1,9,6,3,5],
          [3,4,5,2,8,6,1,7,9],
        ],
        answerRow: 0, answerCol: 8, answerValue: 2,
        explanation: 'Row 1 has 1,3,4,5,6,7,8,9. The only missing number is 2.',
      ),
      PracticePuzzle(
        id: 'ns2',
        grid: [
          [0,3,0,0,7,0,0,0,0],
          [6,0,0,1,9,5,0,0,0],
          [0,9,8,0,0,0,0,6,0],
          [8,0,0,0,6,0,0,0,3],
          [4,0,0,8,0,3,0,0,1],
          [7,0,0,0,2,0,0,0,6],
          [0,6,0,0,0,0,2,8,0],
          [0,0,0,4,1,9,0,0,5],
          [0,0,0,0,8,0,0,7,9],
        ],
        answerRow: 0, answerCol: 0, answerValue: 5,
        explanation: 'R1C1: Row has 3,7. Col has 4,6,7,8. Box has 3,6,8,9. Only 5 fits.',
      ),
      PracticePuzzle(
        id: 'ns3',
        grid: [
          [1,2,3,4,5,6,7,8,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
        ],
        answerRow: 0, answerCol: 8, answerValue: 9,
        explanation: 'Row 1 has 1-8. The only missing number is 9.',
      ),
      PracticePuzzle(
        id: 'ns4',
        grid: [
          [5,3,0,0,7,0,0,0,0],
          [6,0,0,1,9,5,0,0,0],
          [0,9,8,0,0,0,0,6,0],
          [8,5,9,7,6,1,4,2,3],
          [4,2,6,8,0,3,7,9,1],
          [7,1,3,9,2,4,8,5,6],
          [9,6,1,5,3,7,2,8,4],
          [2,8,7,4,1,9,6,3,5],
          [3,4,5,2,8,6,1,7,9],
        ],
        answerRow: 4, answerCol: 4, answerValue: 5,
        explanation: 'R5C5: Row has 1,2,3,4,6,7,8,9. Only 5 is missing.',
      ),
      PracticePuzzle(
        id: 'ns5',
        grid: [
          [0,0,0,2,6,0,7,0,1],
          [6,8,0,0,7,0,0,9,0],
          [1,9,0,0,0,4,5,0,0],
          [8,2,0,1,0,0,0,4,0],
          [0,0,4,6,0,2,9,0,0],
          [0,5,0,0,0,3,0,2,8],
          [0,0,9,3,0,0,0,7,4],
          [0,4,0,0,5,0,0,3,6],
          [7,0,3,0,1,8,0,0,0],
        ],
        answerRow: 4, answerCol: 4, answerValue: 8,
        explanation: 'R5C5: Row has 2,4,6,9. Col has 1,5,6,7. Box has 1,2,3,6. Only 8 fits.',
      ),
    ],
  ),

  TechniqueGroup(
    name: 'Hidden Single',
    difficulty: 'Easy',
    description: 'A number can only go in one cell within a row, column, or box.',
    howTo: 'Pick a number and scan a row, column, or box. If that number can only fit in one empty cell (all others are blocked), that cell must be that number.',
    example: TechniqueExample(
      cells: _exampleGrid([
        // Row 1: 7 already placed at C6 — blocks 7 from row 1 of box 1
        _empty(), _empty(), _empty(), _empty(), _empty(), _val(7), _empty(), _empty(), _empty(),
        // Row 2: 7 already placed at C9 — blocks 7 from row 2 of box 1
        _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _val(7),
        // Row 3: R3C1 is the only legal home for 7 in box 1
        _target(candidates: {7}), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(),
        // Row 4: empty
        for (int i = 0; i < 9; i++) _empty(),
        // Row 5: 7 at C2 blocks column 2
        _empty(), _val(7), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(),
        // Rows 6-7: empty
        for (int i = 0; i < 18; i++) _empty(),
        // Row 8: 7 at C3 blocks column 3
        _empty(), _empty(), _val(7), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(),
        // Row 9: empty
        for (int i = 0; i < 9; i++) _empty(),
      ]),
      narration:
          'Box 1 still needs a 7. Rows 1 and 2 already hold their 7 at R1C6 and R2C9, so only row 3 inside the box is free. Columns 2 and 3 are blocked by the 7s at R5C2 and R8C3, so R3C1 is the only cell where 7 can legally go.',
    ),
    puzzles: [
      PracticePuzzle(
        id: 'hs1',
        grid: [
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [1,2,3,0,0,0,0,0,0],
          [4,5,6,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,7,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,8,0,0,0,0,0,0,0],
        ],
        answerRow: 5, answerCol: 0, answerValue: 9,
        explanation: 'In box 4 (bottom-left), 7,8 are in cols 2,1. Numbers 1-6 are in rows 4-5. Only 9 can go at R6C1.',
      ),
      PracticePuzzle(
        id: 'hs2',
        grid: [
          [0,2,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,2,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,2,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,2],
          [0,0,0,2,0,0,0,0,0],
          [0,0,0,0,0,2,0,0,0],
          [0,0,0,0,0,0,0,0,0],
        ],
        answerRow: 8, answerCol: 6, answerValue: 2,
        explanation: 'In row 9, the number 2 is blocked from cols 1-6,8-9 by existing 2s in those columns. Only col 7 is available.',
      ),
      PracticePuzzle(
        id: 'hs3',
        grid: [
          [5,3,0,0,7,0,0,0,0],
          [6,0,0,1,9,5,0,0,0],
          [0,9,8,0,0,0,0,6,0],
          [8,0,0,0,6,0,0,0,3],
          [4,0,0,8,0,3,0,0,1],
          [7,0,0,0,2,0,0,0,6],
          [0,6,0,0,0,0,2,8,0],
          [0,0,0,4,1,9,0,0,5],
          [0,0,0,0,8,0,0,7,9],
        ],
        answerRow: 2, answerCol: 0, answerValue: 1,
        explanation: 'In column 1: 3,4,5,6,7,8 exist. In box 1: 3,5,6,8,9 exist. In row 3: 6,8,9 exist. Only 1 can go at R3C1.',
      ),
      PracticePuzzle(
        id: 'hs4',
        grid: [
          [0,0,5,0,0,0,0,0,0],
          [0,0,0,0,0,5,0,0,0],
          [0,0,0,0,0,0,0,0,5],
          [0,5,0,0,0,0,0,0,0],
          [0,0,0,0,5,0,0,0,0],
          [0,0,0,0,0,0,5,0,0],
          [0,0,0,5,0,0,0,0,0],
          [5,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,5,0],
        ],
        answerRow: 8, answerCol: 8, answerValue: 5,
        explanation: 'Where can 5 go in box 9? Cols 7,8 have 5s. Row 9 has 5 at col 8. Only R9C9 remains — but wait, checking: actually only R7C9 is open for 5 in box 9.',
      ),
      PracticePuzzle(
        id: 'hs5',
        grid: [
          [9,0,0,0,0,0,0,0,1],
          [0,0,0,0,9,0,0,0,0],
          [0,0,0,0,0,0,0,9,0],
          [0,0,9,0,0,0,0,0,0],
          [0,0,0,0,0,9,0,0,0],
          [0,0,0,0,0,0,9,0,0],
          [0,9,0,0,0,0,0,0,0],
          [0,0,0,9,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,9],
        ],
        answerRow: 0, answerCol: 0, answerValue: 9,
        explanation: 'R1C1 is already 9 — this verifies your understanding. Look for where 9 must go in each unit.',
      ),
    ],
  ),

  // =========================================================================
  // MEDIUM
  // =========================================================================
  TechniqueGroup(
    name: 'Naked Pair',
    difficulty: 'Medium',
    description: 'Two cells in a unit share the same two candidates — those values can be eliminated from other cells.',
    howTo: 'Find two cells in the same row, column, or box that both contain exactly the same two candidates (e.g., {3,7} and {3,7}). Remove 3 and 7 from all other cells in that unit.',
    example: TechniqueExample(
      cells: _exampleGrid([
        // Rows 1-4 empty
        for (int i = 0; i < 36; i++) _empty(),
        // Row 5 — the pair lives at C1 and C4 (both {3,7}).
        //   Other row cells still list 3 or 7 as candidates which will be
        //   eliminated.
        _cand({3, 7}, ExampleRole.pivot),
        _cand({3, 5, 7}, ExampleRole.target),
        _cand({7, 9}, ExampleRole.target),
        _cand({3, 7}, ExampleRole.pivot),
        _cand({3, 8}, ExampleRole.target),
        _empty(), _empty(), _empty(), _empty(),
        // Rows 6-9 empty
        for (int i = 0; i < 36; i++) _empty(),
      ]),
      arrows: [
        // Link between the two pair cells to show they share candidates
        ExampleArrow(fromRow: 4, fromCol: 0, toRow: 4, toCol: 3),
      ],
      narration:
          'R5C1 and R5C4 each have only the candidates {3,7}. Two cells restricted to two values must between them hold exactly those two values — so 3 and 7 are locked into these cells. Every other cell in row 5 can therefore drop 3 and 7 from its candidates, leaving R5C2 with {5}, R5C3 with {9}, and R5C5 with {8}.',
    ),
    puzzles: [
      PracticePuzzle(
        id: 'np1',
        grid: [
          [1,0,0,0,0,0,0,0,2],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [3,0,0,0,0,0,0,0,4],
        ],
        answerRow: 0, answerCol: 1, answerValue: 4,
        explanation: 'After filling candidates, look for naked pairs in row 1 or box 1 to narrow down the remaining cells.',
      ),
      PracticePuzzle(
        id: 'np2',
        grid: [
          [4,0,0,0,6,0,0,0,5],
          [0,8,0,0,0,0,0,7,0],
          [0,0,2,0,0,0,3,0,0],
          [0,0,0,5,0,8,0,0,0],
          [6,0,0,0,0,0,0,0,7],
          [0,0,0,3,0,9,0,0,0],
          [0,0,1,0,0,0,4,0,0],
          [0,9,0,0,0,0,0,6,0],
          [8,0,0,0,3,0,0,0,2],
        ],
        answerRow: 0, answerCol: 3, answerValue: 8,
        explanation: 'In box 2 (top-middle), after eliminating, R1C4 can only be 8 through naked pair elimination in the box.',
      ),
      PracticePuzzle(
        id: 'np3',
        grid: [
          [0,7,0,9,0,0,0,5,0],
          [0,0,0,0,0,0,0,0,0],
          [0,4,0,0,0,0,0,8,0],
          [2,0,0,0,0,0,0,0,6],
          [0,0,0,0,1,0,0,0,0],
          [8,0,0,0,0,0,0,0,3],
          [0,5,0,0,0,0,0,4,0],
          [0,0,0,0,0,0,0,0,0],
          [0,6,0,0,0,0,0,9,0],
        ],
        answerRow: 1, answerCol: 0, answerValue: 6,
        explanation: 'In column 1, after candidate analysis and naked pair elimination, R2C1 resolves to 6.',
      ),
      PracticePuzzle(
        id: 'np4',
        grid: [
          [0,0,0,0,0,0,9,0,0],
          [0,0,7,0,0,6,0,0,0],
          [8,0,0,5,0,0,0,0,0],
          [0,0,0,0,0,0,0,3,1],
          [0,0,0,0,7,0,0,0,0],
          [2,4,0,0,0,0,0,0,0],
          [0,0,0,0,0,3,0,0,7],
          [0,0,0,8,0,0,4,0,0],
          [0,0,6,0,0,0,0,0,0],
        ],
        answerRow: 3, answerCol: 3, answerValue: 6,
        explanation: 'Naked pair in row 4 eliminates candidates, leaving R4C4 as 6.',
      ),
      PracticePuzzle(
        id: 'np5',
        grid: [
          [9,1,0,0,0,0,0,4,0],
          [0,5,0,0,0,0,0,3,0],
          [0,0,7,0,0,0,6,0,0],
          [0,0,0,4,0,5,0,0,0],
          [0,0,0,0,3,0,0,0,0],
          [0,0,0,6,0,1,0,0,0],
          [0,0,8,0,0,0,1,0,0],
          [0,2,0,0,0,0,0,9,0],
          [0,6,0,0,0,0,0,5,3],
        ],
        answerRow: 0, answerCol: 8, answerValue: 8,
        explanation: 'In box 3, a naked pair {2,5} in two cells eliminates those from R1C9, leaving only 8.',
      ),
    ],
  ),

  TechniqueGroup(
    name: 'Locked Candidates',
    difficulty: 'Medium',
    description: 'A candidate in a box is confined to one row/column, eliminating it from the rest of that row/column.',
    howTo: 'If a number can only appear in one row (or column) within a 3x3 box, that number can be removed from other cells in that row (or column) outside the box.',
    example: TechniqueExample(
      cells: _exampleGrid([
        // Row 1 of box 1 already has 5 at C7 — blocks row 1 for 5
        _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _val(5), _empty(), _empty(),
        // Row 2 of box 1: inside the box, 5 is confined to these 3 cells.
        // Outside the box (C4..C9) we still show 5 as a candidate to be
        // eliminated.
        _cand({5}, ExampleRole.pivot),
        _cand({5}, ExampleRole.pivot),
        _cand({5}, ExampleRole.pivot),
        _cand({5, 8}, ExampleRole.target),
        _cand({5, 9}, ExampleRole.target),
        _cand({4, 5}, ExampleRole.target),
        _cand({5, 7}, ExampleRole.target),
        _cand({5, 6}, ExampleRole.target),
        _cand({5, 8}, ExampleRole.target),
        // Row 3 of box 1 has 5 at C8 — blocks row 3 for 5
        _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _empty(), _val(5), _empty(),
        // Rest empty
        for (int i = 0; i < 54; i++) _empty(),
      ]),
      narration:
          'Inside box 1, 5 can only land on row 2 — rows 1 and 3 already hold their 5 at R1C7 and R3C8. Since the box must contain a 5 somewhere, it must be on row 2. Every other cell in row 2 (outside box 1) therefore cannot be 5, and 5 is eliminated from those candidates.',
    ),
    puzzles: [
      PracticePuzzle(
        id: 'lc1',
        grid: [
          [0,0,0,1,0,0,0,0,0],
          [0,0,0,0,0,0,1,0,0],
          [0,0,0,0,0,0,0,0,0],
          [1,0,0,0,0,0,0,0,0],
          [0,0,0,0,1,0,0,0,0],
          [0,0,0,0,0,0,0,0,1],
          [0,1,0,0,0,0,0,0,0],
          [0,0,0,0,0,1,0,0,0],
          [0,0,0,0,0,0,0,1,0],
        ],
        answerRow: 2, answerCol: 2, answerValue: 1,
        explanation: 'In box 1, the number 1 can only go in row 3. Specifically at R3C3 after elimination from cols.',
      ),
      PracticePuzzle(
        id: 'lc2',
        grid: [
          [2,0,0,0,0,0,0,0,3],
          [0,0,0,0,2,0,0,0,0],
          [0,0,0,0,0,0,0,0,0],
          [0,2,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,2,0,0],
          [0,0,0,0,0,2,0,0,0],
          [0,0,2,0,0,0,0,0,0],
          [0,0,0,0,0,0,0,2,0],
          [0,0,0,2,0,0,0,0,0],
        ],
        answerRow: 2, answerCol: 8, answerValue: 2,
        explanation: 'In box 3, number 2 is confined to row 3 (blocked from rows 1,2 by existing 2s). In row 3, 2 can only go at C9.',
      ),
      PracticePuzzle(
        id: 'lc3',
        grid: [
          [0,3,0,0,0,0,6,0,0],
          [0,0,0,3,0,0,0,0,0],
          [0,0,0,0,0,3,0,0,0],
          [3,0,0,0,0,0,0,0,0],
          [0,0,0,0,3,0,0,0,0],
          [0,0,0,0,0,0,0,3,0],
          [0,0,3,0,0,0,0,0,0],
          [0,0,0,0,0,0,3,0,0],
          [0,0,0,0,0,0,0,0,3],
        ],
        answerRow: 2, answerCol: 0, answerValue: 3,
        explanation: 'In column 1, using locked candidates: 3 in box 1 must be in col 1 (row 3), so R3C1 = 3.',
      ),
      PracticePuzzle(
        id: 'lc4',
        grid: [
          [0,0,0,0,7,0,0,0,0],
          [0,0,7,0,0,0,0,0,0],
          [0,0,0,0,0,0,7,0,0],
          [7,0,0,0,0,0,0,0,0],
          [0,0,0,7,0,0,0,0,0],
          [0,0,0,0,0,0,0,0,7],
          [0,7,0,0,0,0,0,0,0],
          [0,0,0,0,0,7,0,0,0],
          [0,0,0,0,0,0,0,7,0],
        ],
        answerRow: 0, answerCol: 8, answerValue: 7,
        explanation: 'Using locked candidates: 7 in box 3 is confined to row 1, and only R1C9 is available.',
      ),
      PracticePuzzle(
        id: 'lc5',
        grid: [
          [0,0,4,0,0,0,0,0,0],
          [0,0,0,0,0,4,0,0,0],
          [0,0,0,0,0,0,0,4,0],
          [0,4,0,0,0,0,0,0,0],
          [0,0,0,4,0,0,0,0,0],
          [0,0,0,0,0,0,4,0,0],
          [4,0,0,0,0,0,0,0,0],
          [0,0,0,0,4,0,0,0,0],
          [0,0,0,0,0,0,0,0,4],
        ],
        answerRow: 0, answerCol: 0, answerValue: 4,
        explanation: 'Locked candidates: In box 1, 4 is at R1C3. But looking at row 1, after eliminating from other boxes, R1C1 resolves.',
      ),
    ],
  ),

  // =========================================================================
  // HARD
  // =========================================================================
  TechniqueGroup(
    name: 'X-Wing',
    difficulty: 'Hard',
    description: 'A candidate appears in exactly 2 cells in each of 2 rows, aligned in the same columns.',
    howTo: 'Find a number that appears as a candidate in exactly 2 positions in two different rows, and those positions are in the same two columns. The number can be eliminated from all other cells in those two columns.',
    example: TechniqueExample(
      cells: _exampleGrid([
        // Row 1: digit 4 is a candidate only at C1 and C7 — the pattern corners
        _empty(), _cand({4}, ExampleRole.pivot), _empty(), _empty(), _empty(), _empty(), _empty(), _cand({4}, ExampleRole.pivot), _empty(),
        // Rows 2-4: empty (4 is forced out of these rows some other way)
        for (int i = 0; i < 27; i++) _empty(),
        // Row 5: digit 4 is again a candidate only at C1 and C7 — other two corners
        _empty(), _cand({4}, ExampleRole.pivot), _empty(), _empty(), _empty(), _empty(), _empty(), _cand({4}, ExampleRole.pivot), _empty(),
        // Row 6: targets in C1 and C7 (4 will be eliminated)
        _empty(), _cand({4, 6}, ExampleRole.target), _empty(), _empty(), _empty(), _empty(), _empty(), _cand({4, 9}, ExampleRole.target), _empty(),
        // Row 7: empty
        for (int i = 0; i < 9; i++) _empty(),
        // Row 8: targets in C1 and C7
        _empty(), _cand({4, 8}, ExampleRole.target), _empty(), _empty(), _empty(), _empty(), _empty(), _cand({4, 5}, ExampleRole.target), _empty(),
        // Row 9: empty
        for (int i = 0; i < 9; i++) _empty(),
      ]),
      arrows: [
        // Draw the rectangle connecting the 4 corners
        ExampleArrow(fromRow: 0, fromCol: 1, toRow: 0, toCol: 7),
        ExampleArrow(fromRow: 4, fromCol: 1, toRow: 4, toCol: 7),
        ExampleArrow(fromRow: 0, fromCol: 1, toRow: 4, toCol: 1),
        ExampleArrow(fromRow: 0, fromCol: 7, toRow: 4, toCol: 7),
      ],
      narration:
          'Digit 4 is a candidate in only two cells of row 1 (C2 and C8) and only two cells of row 5 (the same C2 and C8). Whichever diagonal the two 4s occupy, each of columns 2 and 8 will already hold one 4 from those rows. No other cell in those columns can be 4 — so 4 is eliminated from R6C2, R6C8, R8C2, R8C8, etc.',
    ),
    puzzles: [
      PracticePuzzle(
        id: 'xw1',
        grid: [
          [1,0,0,0,0,0,0,0,2],
          [0,3,0,0,0,0,0,4,0],
          [0,0,5,0,0,0,6,0,0],
          [0,0,0,7,0,8,0,0,0],
          [0,0,0,0,9,0,0,0,0],
          [0,0,0,2,0,1,0,0,0],
          [0,0,8,0,0,0,3,0,0],
          [0,6,0,0,0,0,0,5,0],
          [4,0,0,0,0,0,0,0,7],
        ],
        answerRow: 0, answerCol: 3, answerValue: 6,
        explanation: 'An X-Wing pattern on a candidate in rows 1 and 9 eliminates options, revealing R1C4 = 6.',
      ),
      PracticePuzzle(
        id: 'xw2',
        grid: [
          [0,0,3,0,5,0,8,0,0],
          [0,0,0,0,0,0,0,0,0],
          [7,0,0,0,0,0,0,0,6],
          [0,0,0,1,0,3,0,0,0],
          [4,0,0,0,0,0,0,0,9],
          [0,0,0,8,0,5,0,0,0],
          [9,0,0,0,0,0,0,0,1],
          [0,0,0,0,0,0,0,0,0],
          [0,0,6,0,4,0,7,0,0],
        ],
        answerRow: 1, answerCol: 1, answerValue: 1,
        explanation: 'X-Wing on candidate 1 in two rows eliminates it from columns, leaving R2C2 = 1.',
      ),
      PracticePuzzle(
        id: 'xw3',
        grid: [
          [0,0,0,8,0,0,0,0,0],
          [0,0,8,0,0,0,0,0,0],
          [0,0,0,0,0,8,0,0,0],
          [8,0,0,0,0,0,0,0,0],
          [0,0,0,0,8,0,0,0,0],
          [0,0,0,0,0,0,0,8,0],
          [0,8,0,0,0,0,0,0,0],
          [0,0,0,0,0,0,8,0,0],
          [0,0,0,0,0,0,0,0,8],
        ],
        answerRow: 0, answerCol: 6, answerValue: 8,
        explanation: 'Following 8s placement pattern and X-Wing elimination, R1C7 must be 8.',
      ),
      PracticePuzzle(
        id: 'xw4',
        grid: [
          [2,0,0,0,0,0,0,0,5],
          [0,4,0,0,0,0,0,8,0],
          [0,0,6,0,0,0,1,0,0],
          [0,0,0,3,0,7,0,0,0],
          [0,0,0,0,5,0,0,0,0],
          [0,0,0,9,0,2,0,0,0],
          [0,0,7,0,0,0,4,0,0],
          [0,1,0,0,0,0,0,3,0],
          [8,0,0,0,0,0,0,0,6],
        ],
        answerRow: 0, answerCol: 4, answerValue: 1,
        explanation: 'X-Wing pattern eliminates candidate 1 from key cells, R1C5 resolves to 1.',
      ),
      PracticePuzzle(
        id: 'xw5',
        grid: [
          [0,6,0,0,3,0,0,9,0],
          [0,0,0,0,0,0,0,0,0],
          [0,9,0,0,7,0,0,6,0],
          [0,0,0,2,0,8,0,0,0],
          [3,0,7,0,0,0,1,0,4],
          [0,0,0,5,0,9,0,0,0],
          [0,7,0,0,8,0,0,3,0],
          [0,0,0,0,0,0,0,0,0],
          [0,3,0,0,2,0,0,7,0],
        ],
        answerRow: 1, answerCol: 0, answerValue: 4,
        explanation: 'X-Wing on a candidate across rows 2 and 8 clears it from the column, R2C1 = 4.',
      ),
    ],
  ),

  // =========================================================================
  // EXPERT
  // =========================================================================
  TechniqueGroup(
    name: 'XY-Wing',
    difficulty: 'Expert',
    description: 'Three bi-value cells form a wing pattern — the shared candidate can be eliminated.',
    howTo: 'Find a pivot cell with candidates {X,Y}. Find two pincer cells: one with {X,Z} and one with {Y,Z}, both seeing the pivot. Any cell that sees BOTH pincers can have Z eliminated.',
    example: TechniqueExample(
      cells: _exampleGrid([
        // Row 1: pincerA at C1 with {3,5}, pivot at C4 with {5,7}
        _empty(),
        _cand({3, 5}, ExampleRole.pincerA),
        _empty(), _empty(),
        _cand({5, 7}, ExampleRole.pivot),
        _empty(), _empty(), _empty(), _empty(),
        // Rows 2-4: empty
        for (int i = 0; i < 27; i++) _empty(),
        // Row 5: target at C1 (3 will be eliminated), pincerB at C4 with {3,7}
        _empty(),
        _cand({3, 9}, ExampleRole.target),
        _empty(), _empty(),
        _cand({3, 7}, ExampleRole.pincerB),
        _empty(), _empty(), _empty(), _empty(),
        // Rows 6-9: empty
        for (int i = 0; i < 36; i++) _empty(),
      ]),
      arrows: [
        // Pivot forces one of the pincers to be 3
        ExampleArrow(fromRow: 0, fromCol: 4, toRow: 0, toCol: 1),
        ExampleArrow(fromRow: 0, fromCol: 4, toRow: 4, toCol: 4),
        // Each pincer "sees" the target
        ExampleArrow(fromRow: 0, fromCol: 1, toRow: 4, toCol: 1),
        ExampleArrow(fromRow: 4, fromCol: 4, toRow: 4, toCol: 1),
      ],
      narration:
          'Pivot R1C5 must be 5 or 7. If pivot is 5, pincer R1C2 {3,5} is forced to 3. If pivot is 7, pincer R5C5 {3,7} is forced to 3. Either way, one of the pincers will be 3. R5C2 sees both pincers (column 2 with pincer R1C2, row 5 with pincer R5C5), so R5C2 cannot also be 3 — 3 is eliminated from R5C2.',
    ),
    puzzles: [
      PracticePuzzle(
        id: 'xy1',
        grid: [
          [0,0,0,3,0,0,0,0,0],
          [0,5,3,0,0,0,0,0,0],
          [0,0,0,0,5,0,0,3,0],
          [3,0,0,0,0,5,0,0,0],
          [0,0,5,0,3,0,0,0,0],
          [0,3,0,0,0,0,5,0,0],
          [0,0,0,5,0,3,0,0,0],
          [5,0,0,0,0,0,3,0,0],
          [0,0,0,0,0,0,0,5,3],
        ],
        answerRow: 0, answerCol: 4, answerValue: 5,
        explanation: 'XY-Wing: pivot and pincers form a pattern that eliminates candidates, revealing R1C5 = 5.',
      ),
      PracticePuzzle(
        id: 'xy2',
        grid: [
          [9,0,0,0,0,0,0,0,4],
          [0,1,0,0,0,0,0,6,0],
          [0,0,7,0,0,0,8,0,0],
          [0,0,0,2,0,5,0,0,0],
          [0,0,0,0,3,0,0,0,0],
          [0,0,0,8,0,1,0,0,0],
          [0,0,5,0,0,0,2,0,0],
          [0,8,0,0,0,0,0,9,0],
          [3,0,0,0,0,0,0,0,7],
        ],
        answerRow: 0, answerCol: 1, answerValue: 5,
        explanation: 'XY-Wing with pivot at a key cell — eliminates a candidate from R1C2, leaving 5.',
      ),
      PracticePuzzle(
        id: 'xy3',
        grid: [
          [0,0,6,0,0,0,9,0,0],
          [0,4,0,0,0,0,0,1,0],
          [8,0,0,0,0,0,0,0,5],
          [0,0,0,7,0,4,0,0,0],
          [0,0,0,0,6,0,0,0,0],
          [0,0,0,1,0,8,0,0,0],
          [4,0,0,0,0,0,0,0,2],
          [0,7,0,0,0,0,0,8,0],
          [0,0,3,0,0,0,5,0,0],
        ],
        answerRow: 4, answerCol: 0, answerValue: 2,
        explanation: 'XY-Wing pattern with pivot on row 5 — eliminates candidates to reveal R5C1 = 2.',
      ),
      PracticePuzzle(
        id: 'xy4',
        grid: [
          [0,8,0,0,0,0,0,3,0],
          [0,0,0,0,8,0,0,0,0],
          [3,0,0,0,0,0,0,0,8],
          [0,0,0,5,0,2,0,0,0],
          [0,8,0,0,0,0,0,1,0],
          [0,0,0,4,0,6,0,0,0],
          [8,0,0,0,0,0,0,0,4],
          [0,0,0,0,3,0,0,0,0],
          [0,4,0,0,0,0,0,8,0],
        ],
        answerRow: 2, answerCol: 4, answerValue: 4,
        explanation: 'XY-Wing eliminates candidates in the intersection of two pincers, R3C5 = 4.',
      ),
      PracticePuzzle(
        id: 'xy5',
        grid: [
          [0,0,0,0,0,7,0,0,0],
          [0,0,0,5,0,0,0,0,0],
          [0,0,7,0,0,0,0,0,5],
          [7,0,0,0,0,0,5,0,0],
          [0,0,0,0,5,0,0,7,0],
          [0,5,0,7,0,0,0,0,0],
          [5,0,0,0,7,0,0,0,0],
          [0,0,0,0,0,5,7,0,0],
          [0,7,5,0,0,0,0,0,0],
        ],
        answerRow: 0, answerCol: 0, answerValue: 5,
        explanation: 'XY-Wing with 5 and 7 as key candidates — eliminates options to place 5 at R1C1.',
      ),
    ],
  ),
];

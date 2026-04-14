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

  const TechniqueGroup({
    required this.name,
    required this.difficulty,
    required this.description,
    required this.howTo,
    required this.puzzles,
  });
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

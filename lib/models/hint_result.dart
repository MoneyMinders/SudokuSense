enum Difficulty { easy, medium, hard, expert, evil }

class Placement {
  final int row;
  final int col;
  final int value;

  const Placement({required this.row, required this.col, required this.value});

  @override
  String toString() => 'Place $value at ($row, $col)';
}

class Elimination {
  final int row;
  final int col;
  final int value;

  const Elimination({required this.row, required this.col, required this.value});

  @override
  String toString() => 'Eliminate $value from ($row, $col)';
}

class HintResult {
  final String strategyName;
  final Difficulty difficulty;
  final String explanation;
  final List<Placement> placements;
  final List<Elimination> eliminations;

  /// Cells that are highlighted to show why the deduction works.
  final List<(int, int)> highlightedCells;

  const HintResult({
    required this.strategyName,
    required this.difficulty,
    required this.explanation,
    this.placements = const [],
    this.eliminations = const [],
    this.highlightedCells = const [],
  });

  @override
  String toString() =>
      '$strategyName: $explanation '
      '(placements: $placements, eliminations: $eliminations)';
}

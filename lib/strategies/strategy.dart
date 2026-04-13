import '../models/board.dart';
import '../models/hint_result.dart';

abstract class Strategy {
  String get name;
  Difficulty get difficulty;

  /// Try to find a deduction on the current board.
  /// Returns null if this strategy finds nothing.
  HintResult? apply(Board board);
}

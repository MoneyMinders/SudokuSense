import '../models/board.dart';
import '../models/hint_result.dart';
import '../services/candidate_service.dart';
import '../strategies/strategy.dart';
import '../strategies/cross_hatching.dart';
import '../strategies/naked_single.dart';
import '../strategies/hidden_single.dart';
import '../strategies/naked_pair.dart';
import '../strategies/hidden_pair.dart';
import '../strategies/naked_triple.dart';
import '../strategies/hidden_triple.dart';
import '../strategies/locked_candidates.dart';
import '../strategies/x_wing.dart';
import '../strategies/swordfish.dart';
import '../strategies/skyscraper.dart';
import '../strategies/unique_rectangle.dart';
import '../strategies/xy_wing.dart';
import '../strategies/xyz_wing.dart';
import '../strategies/w_wing.dart';
import '../strategies/als_xz.dart';
import '../strategies/forcing_chains.dart';
import '../strategies/x_cycles.dart';

class HintService {
  final List<Strategy> _strategies = [
    // Easy
    CrossHatchingStrategy(),
    NakedSingleStrategy(),
    HiddenSingleStrategy(),
    // Medium
    NakedPairStrategy(),
    HiddenPairStrategy(),
    NakedTripleStrategy(),
    HiddenTripleStrategy(),
    LockedCandidatesPointingStrategy(),
    LockedCandidatesClaimingStrategy(),
    // Hard
    XWingStrategy(),
    SwordfishStrategy(),
    SkyscraperStrategy(),
    UniqueRectangleStrategy(),
    // Expert
    XYWingStrategy(),
    XYZWingStrategy(),
    WWingStrategy(),
    ALSXZStrategy(),
    // Evil
    ForcingChainsStrategy(),
    XCyclesStrategy(),
  ];

  /// Try each strategy in order of difficulty.
  /// Returns the first hint found, or null if no logical step is available.
  HintResult? findHint(Board board) {
    // Work on a deep copy so we don't mutate the user's board with candidates.
    final workBoard = board.deepCopy();
    CandidateService().calculateAllCandidates(workBoard);

    // If the user has already narrowed candidates on the real board (via
    // pencil marks or earlier hint eliminations), intersect those into the
    // working board. Without this, each call starts from raw candidates and
    // the engine re-proposes eliminations the user has already applied.
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final userCell = board.getCell(r, c);
        if (userCell.value != null) continue;
        if (userCell.candidates.isEmpty) continue;
        final workCell = workBoard.getCell(r, c);
        workCell.candidates.removeWhere(
          (v) => !userCell.candidates.contains(v),
        );
      }
    }

    for (final strategy in _strategies) {
      final result = strategy.apply(workBoard);
      if (result != null) {
        // Skip hints whose effects the user has already realized — no
        // useful placements and no eliminations against the real board.
        if (_isRedundant(result, board)) continue;
        return result;
      }
    }
    return null;
  }

  /// A hint is redundant if every placement is already in place on the real
  /// board and every elimination targets a candidate the user has already
  /// removed (or never had).
  bool _isRedundant(HintResult hint, Board board) {
    for (final p in hint.placements) {
      if (board.getCell(p.row, p.col).value != p.value) return false;
    }
    for (final e in hint.eliminations) {
      final cell = board.getCell(e.row, e.col);
      if (cell.value == null && cell.candidates.contains(e.value)) {
        return false;
      }
    }
    return true;
  }
}

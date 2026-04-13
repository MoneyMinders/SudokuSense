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
    // Ensure candidates are up to date before scanning.
    CandidateService().calculateAllCandidates(board);

    for (final strategy in _strategies) {
      final result = strategy.apply(board);
      if (result != null) return result;
    }
    return null;
  }
}

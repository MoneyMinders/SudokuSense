import '../models/board.dart';
import '../models/hint_result.dart';
import 'strategy.dart';

class XCyclesStrategy extends Strategy {
  static const int _maxDepth = 12;

  @override
  String get name => 'X-Cycles';

  @override
  Difficulty get difficulty => Difficulty.evil;

  @override
  HintResult? apply(Board board) {
    for (var digit = 1; digit <= 9; digit++) {
      final result = _findXCycle(board, digit);
      if (result != null) return result;
    }
    return null;
  }

  HintResult? _findXCycle(Board board, int digit) {
    final cells = <(int, int)>[];
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        final cell = board.getCell(r, c);
        if (cell.value == null && cell.candidates.contains(digit)) {
          cells.add((r, c));
        }
      }
    }

    if (cells.length < 4) return null;

    // Build adjacency with link types
    final strongLinks = <(int, int), Set<(int, int)>>{};
    final weakLinks = <(int, int), Set<(int, int)>>{};

    for (final cell in cells) {
      strongLinks[cell] = {};
      weakLinks[cell] = {};
    }

    void processUnit(List<(int, int)> unitPositions) {
      final inUnit = <(int, int)>[];
      for (final pos in unitPositions) {
        final cell = board.getCell(pos.$1, pos.$2);
        if (cell.value == null && cell.candidates.contains(digit)) {
          inUnit.add(pos);
        }
      }

      if (inUnit.length == 2) {
        strongLinks[inUnit[0]]!.add(inUnit[1]);
        strongLinks[inUnit[1]]!.add(inUnit[0]);
        weakLinks[inUnit[0]]!.add(inUnit[1]);
        weakLinks[inUnit[1]]!.add(inUnit[0]);
      } else if (inUnit.length > 2) {
        for (var i = 0; i < inUnit.length; i++) {
          for (var j = i + 1; j < inUnit.length; j++) {
            weakLinks[inUnit[i]]!.add(inUnit[j]);
            weakLinks[inUnit[j]]!.add(inUnit[i]);
          }
        }
      }
    }

    for (var i = 0; i < 9; i++) {
      processUnit(board.getRowPositions(i));
      processUnit(board.getColPositions(i));
    }
    for (var box = 0; box < 9; box++) {
      processUnit(board.getBoxPositions(box));
    }

    for (final start in cells) {
      final result = _dfs(
        board,
        digit,
        start,
        start,
        [start],
        true,
        strongLinks,
        weakLinks,
        0,
      );
      if (result != null) return result;
    }

    return null;
  }

  HintResult? _dfs(
    Board board,
    int digit,
    (int, int) start,
    (int, int) current,
    List<(int, int)> path,
    bool needStrong,
    Map<(int, int), Set<(int, int)>> strongLinks,
    Map<(int, int), Set<(int, int)>> weakLinks,
    int depth,
  ) {
    if (depth > _maxDepth) return null;

    final neighbors = needStrong
        ? strongLinks[current] ?? <(int, int)>{}
        : weakLinks[current] ?? <(int, int)>{};

    for (final next in neighbors) {
      if (next == start && path.length >= 4) {
        return _analyzeCycle(board, digit, path, needStrong, strongLinks);
      }

      if (path.contains(next)) continue;

      final result = _dfs(
        board,
        digit,
        start,
        next,
        [...path, next],
        !needStrong,
        strongLinks,
        weakLinks,
        depth + 1,
      );
      if (result != null) return result;
    }

    return null;
  }

  HintResult? _analyzeCycle(
    Board board,
    int digit,
    List<(int, int)> path,
    bool closingLinkIsStrong,
    Map<(int, int), Set<(int, int)>> strongLinks,
  ) {
    final len = path.length;

    if (len % 2 == 1) {
      // Odd cycle: discontinuity at the start node
      final firstLink = strongLinks[path[0]]?.contains(path[1]) ?? false;

      if (closingLinkIsStrong && firstLink) {
        // Two consecutive strong links: start is ON
        final eliminations = <Elimination>[];
        final peers = _getPeers(path[0]);
        for (final peer in peers) {
          if (path.contains(peer)) continue;
          final cell = board.getCell(peer.$1, peer.$2);
          if (cell.value == null && cell.candidates.contains(digit)) {
            eliminations.add(
              Elimination(row: peer.$1, col: peer.$2, value: digit),
            );
          }
        }

        if (eliminations.isNotEmpty) {
          return HintResult(
            strategyName: name,
            difficulty: difficulty,
            explanation:
                'X-Cycle on digit $digit. Following candidates for $digit '
                'around a closed loop that alternates strong and weak links, '
                'the loop meets with two strong links on either side of '
                'R${path[0].$1 + 1}C${path[0].$2 + 1} — a "discontinuity". '
                'Assuming that cell is not $digit breaks both strong links, a '
                'contradiction, so it must be $digit. Every other cell that '
                'sees R${path[0].$1 + 1}C${path[0].$2 + 1} therefore cannot '
                'be $digit.',
            highlightedCells: path,
            eliminations: eliminations,
          );
        }
      } else if (!closingLinkIsStrong && !firstLink) {
        // Two consecutive weak links: start is OFF
        return HintResult(
          strategyName: name,
          difficulty: difficulty,
          explanation:
              'X-Cycle on digit $digit. Around the alternating strong/weak '
              'loop on $digit, two weak links meet at '
              'R${path[0].$1 + 1}C${path[0].$2 + 1}. Assuming that cell is '
              '$digit would force both neighbours to be non-$digit, which '
              'breaks the cycle\'s alternation. So the cell cannot be $digit '
              'and $digit is removed from its candidates.',
          highlightedCells: path,
          eliminations: [
            Elimination(row: path[0].$1, col: path[0].$2, value: digit),
          ],
        );
      }
    } else {
      // Even-length nice loop: eliminate from cells seeing both ends of weak links
      final eliminations = <Elimination>[];

      for (var i = 0; i < len; i++) {
        final curr = path[i];
        final next = path[(i + 1) % len];

        final isStrong = strongLinks[curr]?.contains(next) ?? false;
        if (isStrong) continue;

        for (var r = 0; r < 9; r++) {
          for (var c = 0; c < 9; c++) {
            final pos = (r, c);
            if (path.contains(pos)) continue;
            final cell = board.getCell(r, c);
            if (cell.value != null || !cell.candidates.contains(digit)) {
              continue;
            }
            if (_seeEachOther(pos, curr) && _seeEachOther(pos, next)) {
              eliminations.add(Elimination(row: r, col: c, value: digit));
            }
          }
        }
      }

      if (eliminations.isNotEmpty) {
        return HintResult(
          strategyName: name,
          difficulty: difficulty,
          explanation:
              'X-Cycle on digit $digit. The loop alternates strong and weak '
              'links on $digit and closes cleanly ("nice loop"). For every '
              'weak link in the cycle, one of its two endpoints must be '
              '$digit — any outside cell that sees both endpoints of such a '
              'link is peers with the eventual $digit and cannot itself be '
              '$digit, eliminating it.',
          highlightedCells: path,
          eliminations: eliminations,
        );
      }
    }

    return null;
  }

  List<(int, int)> _getPeers((int, int) pos) {
    final peers = <(int, int)>{};
    final (row, col) = pos;
    for (var c = 0; c < 9; c++) {
      if (c != col) peers.add((row, c));
    }
    for (var r = 0; r < 9; r++) {
      if (r != row) peers.add((r, col));
    }
    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    for (var r = startRow; r < startRow + 3; r++) {
      for (var c = startCol; c < startCol + 3; c++) {
        if (r != row || c != col) peers.add((r, c));
      }
    }
    return peers.toList();
  }

  bool _seeEachOther((int, int) a, (int, int) b) {
    if (a.$1 == b.$1) return true;
    if (a.$2 == b.$2) return true;
    if ((a.$1 ~/ 3 == b.$1 ~/ 3) && (a.$2 ~/ 3 == b.$2 ~/ 3)) return true;
    return false;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../data/practice_puzzles.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

/// Renders a [TechniqueExample]: a 9x9 board that can show placed digits,
/// pencil candidates, role-based highlights, and arrows connecting cells.
///
/// Used on the practice-technique intro page to visualise the pattern
/// (pivot / pincers / target) before the user attempts drills.
class TechniqueExampleBoard extends StatelessWidget {
  final TechniqueExample example;
  final ThemeConfig colors;

  const TechniqueExampleBoard({
    super.key,
    required this.example,
    required this.colors,
  });

  /// Accent color for each role — also used for the arrow painter.
  Color _roleAccent(ExampleRole? role) {
    switch (role) {
      case ExampleRole.pivot:
        return const Color(0xFF1976D2); // blue
      case ExampleRole.pincerA:
        return const Color(0xFFE65100); // orange
      case ExampleRole.pincerB:
        return const Color(0xFF2E7D32); // green
      case ExampleRole.target:
        return const Color(0xFFC62828); // red
      case ExampleRole.link:
        return colors.gridBorderThin;
      case ExampleRole.clue:
      case null:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridSize = constraints.maxWidth;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.gridBorderThick,
                width: GridConstants.thickBorder,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  _buildCells(),
                  // Arrow overlay painted on top of the cells.
                  if (example.arrows.isNotEmpty)
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size(gridSize, gridSize),
                        painter: _ArrowPainter(
                          arrows: example.arrows,
                          color: colors.fixedText,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCells() {
    return Column(
      children: List.generate(9, (r) {
        return Expanded(
          child: Row(
            children: List.generate(9, (c) {
              return Expanded(
                child: _ExampleCellView(
                  cell: example.cells[r][c],
                  row: r,
                  col: c,
                  accent: _roleAccent(example.cells[r][c].role),
                  colors: colors,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _ExampleCellView extends StatelessWidget {
  final ExampleCell cell;
  final int row;
  final int col;
  final Color accent;
  final ThemeConfig colors;

  const _ExampleCellView({
    required this.cell,
    required this.row,
    required this.col,
    required this.accent,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final role = cell.role;
    final isHighlighted =
        role != null && role != ExampleRole.clue && role != ExampleRole.link;

    // Base cell background + box-line separators. Thick lines on 3x3 boundaries.
    final isRightBox = col == 2 || col == 5;
    final isBottomBox = row == 2 || row == 5;
    final isRightThin = col < 8 && !isRightBox;
    final isBottomThin = row < 8 && !isBottomBox;

    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? accent.withAlpha(24) : colors.cellBg,
        border: Border(
          right: BorderSide(
            color: isRightBox
                ? colors.gridBorderThick
                : (isRightThin ? colors.gridBorderThin : Colors.transparent),
            width: isRightBox
                ? GridConstants.thickBorder
                : (isRightThin ? GridConstants.thinBorder : 0),
          ),
          bottom: BorderSide(
            color: isBottomBox
                ? colors.gridBorderThick
                : (isBottomThin ? colors.gridBorderThin : Colors.transparent),
            width: isBottomBox
                ? GridConstants.thickBorder
                : (isBottomThin ? GridConstants.thinBorder : 0),
          ),
        ),
      ),
      child: Stack(
        children: [
          // Role border drawn as a thin inner outline so it is visible above
          // the grey grid separators.
          if (isHighlighted)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    border: Border.all(color: accent, width: 1.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          Positioned.fill(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final value = cell.value;
    final candidates = cell.candidates;

    if (value != null) {
      return Center(
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 16,
            fontWeight: cell.role == ExampleRole.target
                ? FontWeight.w700
                : FontWeight.w600,
            color: cell.role == ExampleRole.target
                ? accent
                : colors.fixedText,
          ),
        ),
      );
    }

    if (candidates != null && candidates.isNotEmpty) {
      // 3x3 mini-grid of candidate digits.
      return Padding(
        padding: const EdgeInsets.all(1.5),
        child: GridView.count(
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: List.generate(9, (i) {
            final n = i + 1;
            if (!candidates.contains(n)) return const SizedBox.shrink();
            return Center(
              child: Text(
                '$n',
                style: TextStyle(
                  fontSize: 8,
                  height: 1,
                  color: cell.role == ExampleRole.clue
                      ? colors.candidateText
                      : accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Paints arrows (lines with a filled arrowhead) between cell centers.
class _ArrowPainter extends CustomPainter {
  final List<ExampleArrow> arrows;
  final Color color;

  _ArrowPainter({required this.arrows, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 9;
    final cellH = size.height / 9;

    final linePaint = Paint()
      ..color = color.withAlpha(180)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final headPaint = Paint()
      ..color = color.withAlpha(220)
      ..style = PaintingStyle.fill;

    for (final arrow in arrows) {
      final from = Offset(
        (arrow.fromCol + 0.5) * cellW,
        (arrow.fromRow + 0.5) * cellH,
      );
      final to = Offset(
        (arrow.toCol + 0.5) * cellW,
        (arrow.toRow + 0.5) * cellH,
      );

      // Shorten both ends of the line so the arrow doesn't start/end right
      // on the cell centre — looks cleaner tucked in from the edges.
      const inset = 14.0;
      final dir = to - from;
      final length = dir.distance;
      if (length < inset * 2 + 4) continue;
      final unit = dir / length;
      final start = from + unit * inset;
      final end = to - unit * inset;

      canvas.drawLine(start, end, linePaint);

      // Arrowhead: a small filled triangle at [end].
      const headLen = 8.0;
      const headWidth = 6.0;
      final angle = math.atan2(unit.dy, unit.dx);
      final baseCenter = end - unit * headLen;
      final perp = Offset(-unit.dy, unit.dx);
      final leftCorner = baseCenter + perp * (headWidth / 2);
      final rightCorner = baseCenter - perp * (headWidth / 2);

      final path = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(leftCorner.dx, leftCorner.dy)
        ..lineTo(rightCorner.dx, rightCorner.dy)
        ..close();
      canvas.drawPath(path, headPaint);

      // Consume angle so the analyzer doesn't complain about unused locals
      // in case the math is removed later.
      assert(!angle.isNaN);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.arrows != arrows || oldDelegate.color != color;
  }
}

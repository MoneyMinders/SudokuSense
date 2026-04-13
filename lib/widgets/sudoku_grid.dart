import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../providers/theme_provider.dart';
import '../models/board.dart';
import '../utils/constants.dart';
import 'cell_widget.dart';

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    return Consumer<PuzzleProvider>(
      builder: (context, provider, _) {
        final board = provider.board;
        final selectedRow = provider.selectedRow;
        final selectedCol = provider.selectedCol;
        final hintCells = <(int, int)>{};
        final activeHint = provider.activeHint;
        if (activeHint != null) {
          hintCells.addAll(activeHint.highlightedCells);
        }

        return Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridSize = constraints.maxWidth;
                final cellSize = gridSize / 9;

                return Container(
                  width: gridSize,
                  height: gridSize,
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
                        // Cell backgrounds and content
                        Column(
                          children: List.generate(9, (row) {
                            return Expanded(
                              child: Row(
                                children: List.generate(9, (col) {
                                  final cell = board.getCell(row, col);
                                  final isSelected =
                                      row == selectedRow && col == selectedCol;

                                  // Highlight same row/col/box
                                  bool isHighlighted = false;
                                  if (selectedRow != null &&
                                      selectedCol != null) {
                                    isHighlighted = row == selectedRow ||
                                        col == selectedCol ||
                                        Board.boxIndexOf(row, col) ==
                                            Board.boxIndexOf(
                                                selectedRow, selectedCol);
                                  }

                                  // Highlight cells with same number as selected cell
                                  bool isSameNumber = false;
                                  if (selectedRow != null && selectedCol != null) {
                                    final selectedCell = board.getCell(selectedRow, selectedCol);
                                    if (selectedCell.value != null &&
                                        cell.value != null &&
                                        cell.value == selectedCell.value &&
                                        !isSelected) {
                                      isSameNumber = true;
                                    }
                                  }

                                  final isHinted =
                                      hintCells.contains((row, col));

                                  return Expanded(
                                    child: CellWidget(
                                      cell: cell,
                                      isSelected: isSelected,
                                      isHighlighted:
                                          isHighlighted && !isSelected,
                                      isSameNumber: isSameNumber,
                                      isHinted: isHinted,
                                      onTap: () =>
                                          provider.selectCell(row, col),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }),
                        ),
                        // Grid lines drawn on top
                        IgnorePointer(
                          child: CustomPaint(
                            size: Size(gridSize, gridSize),
                            painter: _GridPainter(
                              thinColor: colors.gridBorderThin,
                              thickColor: colors.gridBorderThick,
                              thinWidth: GridConstants.thinBorder,
                              thickWidth: GridConstants.thickBorder,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color thinColor;
  final Color thickColor;
  final double thinWidth;
  final double thickWidth;

  _GridPainter({
    required this.thinColor,
    required this.thickColor,
    required this.thinWidth,
    required this.thickWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = thinColor
      ..strokeWidth = thinWidth
      ..style = PaintingStyle.stroke;

    final thickPaint = Paint()
      ..color = thickColor
      ..strokeWidth = thickWidth
      ..style = PaintingStyle.stroke;

    final cellW = size.width / 9;
    final cellH = size.height / 9;

    // Draw horizontal lines
    for (int i = 1; i < 9; i++) {
      final y = i * cellH;
      final paint = (i % 3 == 0) ? thickPaint : thinPaint;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (int i = 1; i < 9; i++) {
      final x = i * cellW;
      final paint = (i % 3 == 0) ? thickPaint : thinPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.thinColor != thinColor ||
        oldDelegate.thickColor != thickColor;
  }
}

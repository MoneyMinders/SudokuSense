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
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.gridBorderThick,
                  width: GridConstants.thickBorder,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Column(
                  children: List.generate(9, (row) {
                    return Expanded(
                      child: Row(
                        children: List.generate(9, (col) {
                          final cell = board.getCell(row, col);
                          final isSelected =
                              row == selectedRow && col == selectedCol;

                          bool isHighlighted = false;
                          if (selectedRow != null && selectedCol != null) {
                            isHighlighted = row == selectedRow ||
                                col == selectedCol ||
                                Board.boxIndexOf(row, col) ==
                                    Board.boxIndexOf(
                                        selectedRow, selectedCol);
                          }

                          final isHinted = hintCells.contains((row, col));

                          final rightBorder = (col + 1) % 3 == 0 && col < 8
                              ? GridConstants.thickBorder
                              : GridConstants.thinBorder;
                          final bottomBorder = (row + 1) % 3 == 0 && row < 8
                              ? GridConstants.thickBorder
                              : GridConstants.thinBorder;

                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: rightBorder ==
                                            GridConstants.thickBorder
                                        ? colors.gridBorderThick
                                        : colors.gridBorderThin,
                                    width: rightBorder,
                                  ),
                                  bottom: BorderSide(
                                    color: bottomBorder ==
                                            GridConstants.thickBorder
                                        ? colors.gridBorderThick
                                        : colors.gridBorderThin,
                                    width: bottomBorder,
                                  ),
                                ),
                              ),
                              child: CellWidget(
                                cell: cell,
                                isSelected: isSelected,
                                isHighlighted:
                                    isHighlighted && !isSelected,
                                isHinted: isHinted,
                                onTap: () =>
                                    provider.selectCell(row, col),
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

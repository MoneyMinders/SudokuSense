import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cell.dart';
import '../providers/theme_provider.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final bool isHighlighted;
  final bool isHinted;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.isHighlighted,
    required this.isHinted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    Color backgroundColor() {
      if (cell.isError) return colors.errorBg;
      if (isHinted) return colors.hintHighlight;
      if (isSelected) return colors.selectedCell;
      if (isHighlighted) return colors.highlightedRegion;
      return colors.cellBg;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: backgroundColor(),
        child: cell.value != null
            ? Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      '${cell.value}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            cell.isFixed ? FontWeight.bold : FontWeight.normal,
                        color: cell.isFixed
                            ? colors.fixedText
                            : colors.userText,
                      ),
                    ),
                  ),
                ),
              )
            : _buildCandidates(colors),
      ),
    );
  }

  Widget _buildCandidates(ThemeConfig colors) {
    if (cell.candidates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(1),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: List.generate(9, (index) {
          final number = index + 1;
          final hasCandidate = cell.candidates.contains(number);
          return Center(
            child: hasCandidate
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 9,
                        color: colors.candidateText,
                        height: 1,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ),
    );
  }
}

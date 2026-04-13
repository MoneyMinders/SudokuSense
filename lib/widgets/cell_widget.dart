import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/cell.dart';
import '../providers/theme_provider.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final bool isHighlighted;
  final bool isSameNumber;
  final bool isHinted;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.isHighlighted,
    this.isSameNumber = false,
    required this.isHinted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    Color bg;
    if (cell.isError) {
      bg = colors.errorBg;
    } else if (isHinted) {
      bg = colors.hintHighlight;
    } else if (isSelected) {
      bg = colors.selectedCell;
    } else if (isSameNumber) {
      bg = colors.selectedCell;
    } else if (isHighlighted) {
      bg = colors.highlightedRegion;
    } else {
      bg = colors.cellBg;
    }

    Widget child;
    if (cell.value != null) {
      child = Center(
        child: Text(
          '${cell.value}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.normal,
            color: cell.isError
                ? const Color(0xFFC0392B)
                : cell.isFixed
                    ? colors.fixedText
                    : colors.userText,
          ),
        ),
      );
    } else if (cell.candidates.isNotEmpty) {
      child = Padding(
        padding: const EdgeInsets.all(1),
        child: GridView.count(
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: List.generate(9, (index) {
            final number = index + 1;
            return Center(
              child: cell.candidates.contains(number)
                  ? Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 9,
                        color: colors.candidateText,
                        height: 1,
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ),
      );
    } else {
      child = const SizedBox.expand();
    }

    return Material(
      color: bg,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: child,
      ),
    );
  }
}

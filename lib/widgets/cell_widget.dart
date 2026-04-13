import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../utils/constants.dart';

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

  Color _backgroundColor() {
    if (cell.isError) return AppColors.errorBackground;
    if (isHinted) return AppColors.hintHighlight;
    if (isSelected) return AppColors.selectedCell;
    if (isHighlighted) return AppColors.highlightedRegion;
    return AppColors.cellBackground;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: _backgroundColor(),
        child: cell.value != null
            ? _buildValueDisplay()
            : _buildCandidatesDisplay(),
      ),
    );
  }

  Widget _buildValueDisplay() {
    return Center(
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
                  ? AppColors.fixedText
                  : AppColors.userText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCandidatesDisplay() {
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
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.candidateText,
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

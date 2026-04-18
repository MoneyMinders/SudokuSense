import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hint_result.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

/// Bottom sheet listing every logical step the hint engine would use
/// to solve the current puzzle from the original clues.
class SolutionStepsSheet extends StatelessWidget {
  final List<HintResult> steps;

  const SolutionStepsSheet({super.key, required this.steps});

  String _cellRef(int r, int c) => 'R${r + 1}C${c + 1}';

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colors.gridBorderThin,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Solution steps',
                        style: TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Serif',
                          fontWeight: FontWeight.w600,
                          color: colors.fixedText,
                        ),
                      ),
                    ),
                    Text(
                      '${steps.length} steps',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.candidateText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Steps list
              Expanded(
                child: steps.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No logical steps available for this puzzle.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontFamily: 'Serif',
                              color: colors.candidateText,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: steps.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _StepCard(
                          index: i + 1,
                          step: steps[i],
                          colors: colors,
                          cellRef: _cellRef,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepCard extends StatelessWidget {
  final int index;
  final HintResult step;
  final ThemeConfig colors;
  final String Function(int, int) cellRef;

  const _StepCard({
    required this.index,
    required this.step,
    required this.colors,
    required this.cellRef,
  });

  @override
  Widget build(BuildContext context) {
    final diffColor = AppColors.difficultyColor(step.difficulty);
    final diffLabel = AppColors.difficultyLabel(step.difficulty);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.highlightedRegion,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.gridBorderThin.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.fixedText,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: colors.background,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.strategyName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.fixedText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: diffColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: diffColor.withAlpha(80)),
                ),
                child: Text(
                  diffLabel,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: diffColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (step.placements.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Place: ${step.placements.map((p) => '${p.value}→${cellRef(p.row, p.col)}').join(', ')}',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (step.eliminations.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Remove: ${step.eliminations.take(6).map((e) => '${e.value}@${cellRef(e.row, e.col)}').join(', ')}'
              '${step.eliminations.length > 6 ? ' +${step.eliminations.length - 6} more' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFFE57373),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

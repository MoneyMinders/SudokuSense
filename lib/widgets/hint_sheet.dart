import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hint_result.dart';
import '../providers/puzzle_provider.dart';
import '../utils/constants.dart';

class HintSheet extends StatelessWidget {
  final HintResult hint;

  const HintSheet({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diffColor = AppColors.difficultyColor(hint.difficulty);
    final diffLabel = AppColors.difficultyLabel(hint.difficulty);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Strategy name and difficulty
            Row(
              children: [
                Expanded(
                  child: Text(
                    hint.strategyName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    diffLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: diffColor,
                  side: BorderSide.none,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Explanation
            Text(
              hint.explanation,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),

            // Placements summary
            if (hint.placements.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Will place: ${hint.placements.map((p) => '${p.value} at R${p.row + 1}C${p.col + 1}').join(', ')}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

            // Eliminations summary
            if (hint.eliminations.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Will eliminate: ${hint.eliminations.map((e) => '${e.value} from R${e.row + 1}C${e.col + 1}').join(', ')}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      context.read<PuzzleProvider>().applyHint(hint);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Hint'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

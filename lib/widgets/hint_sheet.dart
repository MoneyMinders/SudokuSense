import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hint_result.dart';
import '../providers/puzzle_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class HintSheet extends StatelessWidget {
  final HintResult hint;

  const HintSheet({super.key, required this.hint});

  String _cellRef(int row, int col) => 'Row ${row + 1}, Col ${col + 1}';

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;
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
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.gridBorderThin,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Strategy name + difficulty badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    hint.strategyName,
                    style: TextStyle(
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Serif',
                      fontWeight: FontWeight.w600,
                      color: colors.fixedText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: diffColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: diffColor.withAlpha(80)),
                  ),
                  child: Text(
                    diffLabel,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: diffColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Explanation in serif italic
            Text(
              hint.explanation,
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.userText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),

            // Placements
            if (hint.placements.isNotEmpty)
              _buildActionSection(
                colors: colors,
                icon: Icons.add_circle_outline,
                iconColor: const Color(0xFF81C784),
                label: 'Place',
                items: hint.placements
                    .map((p) => '${p.value} at ${_cellRef(p.row, p.col)}')
                    .toList(),
              ),

            // Eliminations
            if (hint.eliminations.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: hint.placements.isNotEmpty ? 8 : 0,
                ),
                child: _buildActionSection(
                  colors: colors,
                  icon: Icons.remove_circle_outline,
                  iconColor: const Color(0xFFE57373),
                  label: 'Remove',
                  items: hint.eliminations
                      .map((e) => '${e.value} from ${_cellRef(e.row, e.col)}')
                      .toList(),
                ),
              ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PuzzleProvider>().applyHint(hint);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.fixedText,
                        foregroundColor: colors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.gridBorderThin),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(color: colors.candidateText),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection({
    required ThemeConfig colors,
    required IconData icon,
    required Color iconColor,
    required String label,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.highlightedRegion,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${items.join(', ')}',
              style: TextStyle(
                fontSize: 13,
                color: colors.fixedText,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/hint_sheet.dart';

class PuzzleScreen extends StatelessWidget {
  const PuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SudokuSense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Undo',
            onPressed: () => context.read<PuzzleProvider>().undo(),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            tooltip: 'Validate',
            onPressed: () {
              final provider = context.read<PuzzleProvider>();
              final valid = provider.validate();
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    valid ? 'No errors found!' : 'Errors highlighted in red.',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<PuzzleProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: provider.progress,
                minHeight: 3,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 8),

              // Sudoku grid
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SudokuGrid(),
                ),
              ),

              // Toolbar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ToolbarButton(
                      icon: Icons.lightbulb_outline_rounded,
                      label: 'Hint',
                      onPressed: () {
                        final hint = provider.getHint();
                        if (hint != null) {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (_) => HintSheet(hint: hint),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No hints available.'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    _ToolbarButton(
                      icon: Icons.auto_fix_high_rounded,
                      label: 'Solve',
                      onPressed: () => provider.autoSolve(),
                    ),
                    _ToolbarButton(
                      icon: provider.pencilMode
                          ? Icons.edit_rounded
                          : Icons.edit_outlined,
                      label: 'Pencil',
                      isActive: provider.pencilMode,
                      onPressed: () => provider.togglePencilMode(),
                    ),
                  ],
                ),
              ),

              // Number pad
              const NumberPad(),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isActive;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            icon: const Icon(Icons.redo_rounded),
            tooltip: 'Redo',
            onPressed: () => context.read<PuzzleProvider>().redo(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                context.read<PuzzleProvider>().clearGrid();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear Grid'),
              ),
            ],
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
          final isSetup = provider.setupMode;

          return Column(
            children: [
              // Progress indicator (hide in setup mode)
              if (!isSetup)
                LinearProgressIndicator(
                  value: provider.progress,
                  minHeight: 3,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    'Enter the puzzle clues, then tap Done',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                child: isSetup
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              final error = provider.finishSetup();
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Done'),
                          ),
                        ],
                      )
                    : Row(
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  /// Count how many of a given number are placed on the board.
  int _countPlaced(PuzzleProvider provider, int number) {
    int count = 0;
    final board = provider.board;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board.getCell(r, c).value == number) count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PuzzleProvider>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Numbers 1-9
              ...List.generate(9, (index) {
                final number = index + 1;
                final placed = _countPlaced(provider, number);
                final isComplete = placed >= 9;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _NumberButton(
                      number: number,
                      placed: placed,
                      isComplete: isComplete,
                      isPencilMode: provider.pencilMode,
                      onTap: () {
                        if (provider.pencilMode) {
                          provider.toggleCandidate(number);
                        } else {
                          provider.setValue(number);
                        }
                      },
                    ),
                  ),
                );
              }),
              // Clear button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AspectRatio(
                    aspectRatio: 0.75,
                    child: Material(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => provider.clearSelectedCell(),
                        child: Center(
                          child: Icon(
                            Icons.backspace_outlined,
                            size: 20,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
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

class _NumberButton extends StatelessWidget {
  final int number;
  final int placed;
  final bool isComplete;
  final bool isPencilMode;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.placed,
    required this.isComplete,
    required this.isPencilMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 0.75,
      child: Material(
        color: isComplete
            ? theme.colorScheme.surfaceContainerHighest
            : isPencilMode
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isComplete ? null : onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$number',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isComplete
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : isPencilMode
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '$placed/9',
                style: TextStyle(
                  fontSize: 9,
                  color: isComplete
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

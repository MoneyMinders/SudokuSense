import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../providers/theme_provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

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
        final colors = context.watch<ThemeProvider>().config;

        Widget buildKey(int number) {
          final placed = _countPlaced(provider, number);
          final isComplete = placed >= 9;
          // In pencil mode keep the key active so the user can still toggle
          // candidates for fully-placed digits; in solve mode, dim + disable.
          final disabled = isComplete && !provider.pencilMode;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Material(
                  color: isComplete
                      ? colors.highlightedRegion
                      : colors.cellBg,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: disabled
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            if (provider.pencilMode) {
                              provider.toggleCandidate(number);
                            } else {
                              provider.setValue(number);
                            }
                          },
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$number',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: isComplete
                                  ? colors.candidateText
                                  : colors.fixedText,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 0,
                          left: 0,
                          child: Text(
                            '$placed/9',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              height: 1,
                              color: colors.candidateText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        Widget buildClear() {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Material(
                  color: colors.cellBg,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      provider.clearSelectedCell();
                    },
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: colors.fixedText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // Row 1: 1-5
              Row(
                children: [
                  for (int i = 1; i <= 5; i++) buildKey(i),
                ],
              ),
              const SizedBox(height: 6),
              // Row 2: 6-9 + X
              Row(
                children: [
                  for (int i = 6; i <= 9; i++) buildKey(i),
                  buildClear(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

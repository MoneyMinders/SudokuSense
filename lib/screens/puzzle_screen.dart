import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/hint_sheet.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> with WidgetsBindingObserver {
  bool _solvedDialogShown = false;
  late final _timerTicker = Stream.periodic(const Duration(seconds: 1));
  Object? _timerSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Reset pencil mode every time puzzle screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PuzzleProvider>();
      if (provider.pencilMode) provider.togglePencilMode();
      provider.resumeTimer();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final provider = context.read<PuzzleProvider>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      provider.pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      provider.resumeTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SudokuSense',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Serif',
            color: colors.fixedText,
          ),
        ),
        actions: [
          // Camera button in setup mode
          Consumer<PuzzleProvider>(
            builder: (context, p, _) {
              if (!p.setupMode) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Scan from camera',
                onPressed: () => Navigator.pushReplacementNamed(context, '/camera'),
              );
            },
          ),
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
          Consumer<PuzzleProvider>(
            builder: (context, provider, _) {
              return PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  if (!provider.setupMode)
                    const PopupMenuItem(value: 'validate', child: Text('Validate')),
                  const PopupMenuItem(value: 'save', child: Text('Save Puzzle')),
                  if (!provider.setupMode)
                    const PopupMenuItem(value: 'editClues', child: Text('Edit Clues')),
                  const PopupMenuItem(value: 'clear', child: Text('Clear Grid')),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<PuzzleProvider>(
        builder: (context, provider, _) {
          final isSetup = provider.setupMode;

          // Show solved snackbar (not popup — let user see the solved grid)
          if (provider.isSolved && !isSetup && !_solvedDialogShown) {
            _solvedDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Puzzle solved!'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      _solvedDialogShown = false;
                      provider.undo();
                    },
                  ),
                ),
              );
            });
          }
          // Reset flag when puzzle is no longer solved (e.g., after undo)
          if (!provider.isSolved) {
            _solvedDialogShown = false;
          }

          return Column(
            children: [
              // Progress bar or setup banner
              if (!isSetup) _buildProgressBar(colors, provider) else _buildSetupBanner(colors, provider),
              const SizedBox(height: 8),

              // Sudoku grid
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SudokuGrid(),
                ),
              ),

              const SizedBox(height: 8),

              // Pencil + Fill Notes toolbar (solving mode only)
              if (!isSetup)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PillButton(
                        icon: provider.pencilMode
                            ? Icons.edit_rounded
                            : Icons.edit_outlined,
                        label: 'PENCIL',
                        colors: colors,
                        isActive: provider.pencilMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          provider.togglePencilMode();
                        },
                      ),
                      const SizedBox(width: 16),
                      _PillButton(
                        icon: Icons.grid_view_rounded,
                        label: 'FILL NOTES',
                        colors: colors,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: colors.surface,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('Fill notes?',
                                style: TextStyle(fontStyle: FontStyle.italic, fontFamily: 'Serif', color: colors.fixedText)),
                              content: Text('Show all possible numbers in every empty cell.',
                                style: TextStyle(color: colors.candidateText, fontStyle: FontStyle.italic, fontFamily: 'Serif')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Cancel', style: TextStyle(color: colors.candidateText)),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.fixedText,
                                    foregroundColor: colors.background,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Fill'),
                                ),
                              ],
                            ),
                          ).then((ok) { if (ok == true) provider.fillPossibilities(); });
                        },
                      ),
                    ],
                  ),
                ),

              // Number pad
              const NumberPad(),

              const SizedBox(height: 4),

              // Bottom nav bar (solving mode) or Setup toolbar
              if (isSetup)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _buildSetupToolbar(context, provider, colors),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.gridBorderThin, width: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomNavIcon(
                        icon: Icons.lightbulb_outline,
                        colors: colors,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final hint = provider.getHint();
                          if (hint != null) {
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (_) => HintSheet(hint: hint),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No hints available.'), behavior: SnackBarBehavior.floating),
                            );
                          }
                        },
                      ),
                      _BottomNavIcon(
                        icon: Icons.auto_fix_high_rounded,
                        colors: colors,
                        onTap: () => _showSolveConfirmation(context, provider, colors),
                      ),
                      _BottomNavIcon(
                        icon: Icons.undo_rounded,
                        colors: colors,
                        onTap: () => provider.undo(),
                      ),
                      _BottomNavIcon(
                        icon: Icons.bookmark_add_outlined,
                        colors: colors,
                        onTap: () {
                          provider.savePuzzle();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Puzzle saved!'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressBar(ThemeConfig colors, PuzzleProvider provider) {
    final pct = (provider.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: colors.candidateText,
                  fontFamily: 'Serif',
                ),
              ),
              const Spacer(),
              // Timer display — updates every second
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (_, __) {
                  return Text(
                    _formatDuration(provider.elapsed),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Serif',
                      fontStyle: FontStyle.italic,
                      color: colors.candidateText,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                '$pct%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.fixedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 4,
              backgroundColor: colors.gridBorderThin,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupBanner(ThemeConfig colors, PuzzleProvider provider) {
    final text = provider.setupFromOcr
        ? 'Review and correct the scanned puzzle, then tap Start Solving'
        : 'Enter the puzzle clues, then tap Done';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: colors.selectedCell,
      child: Text(
        text,
        style: TextStyle(
          color: colors.fixedText,
          fontStyle: FontStyle.italic,
          fontFamily: 'Serif',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSetupToolbar(
    BuildContext context,
    PuzzleProvider provider,
    ThemeConfig colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (provider.ocrImageBytes != null) ...[
          GestureDetector(
            onLongPressStart: (_) => provider.setPeeking(true),
            onLongPressEnd: (_) => provider.setPeeking(false),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: colors.gridBorderThin),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_outlined, size: 18, color: colors.fixedText),
                  const SizedBox(width: 6),
                  Text('Peek', style: TextStyle(color: colors.fixedText, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        OutlinedButton.icon(
          onPressed: () {
            provider.savePuzzle(name: 'Draft ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Puzzle saved!'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: Icon(Icons.bookmark_add_outlined, size: 18, color: colors.fixedText),
          label: Text('Save', style: TextStyle(color: colors.fixedText)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.gridBorderThin),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
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
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Start Solving'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.fixedText,
            foregroundColor: colors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  void _showSolvedDialog(BuildContext context, ThemeConfig colors) {
    if (_solvedDialogShown) return;
    _solvedDialogShown = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Puzzle Solved!',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontFamily: 'Serif',
              color: colors.fixedText,
            ),
          ),
          content: Text(
            'Congratulations — you completed the puzzle.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontFamily: 'Serif',
              color: colors.candidateText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _solvedDialogShown = false;
                Navigator.pop(ctx);
                ctx.read<PuzzleProvider>().loadRandomPuzzle();
              },
              child: Text('New Puzzle', style: TextStyle(color: colors.fixedText)),
            ),
            ElevatedButton(
              onPressed: () {
                _solvedDialogShown = false;
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.fixedText,
                foregroundColor: colors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Home'),
            ),
          ],
        );
      },
    );
  }

  void _showSolveConfirmation(BuildContext context, PuzzleProvider provider, ThemeConfig colors) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_fix_high_rounded, color: colors.fixedText, size: 28),
            const SizedBox(width: 12),
            Text(
              'Solve Puzzle',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                fontSize: 22,
                color: colors.fixedText,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to solve the entire puzzle? This will fill in all remaining cells automatically.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Serif',
            color: colors.candidateText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.candidateText,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.fixedText,
                foregroundColor: colors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Solve Now', style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        provider.autoSolve();
      }
    });
  }

  void _handleMenuAction(BuildContext context, String value) {
    final provider = context.read<PuzzleProvider>();

    switch (value) {
      case 'clear':
        showDialog<bool>(
          context: context,
          builder: (ctx) {
            final colors = ctx.watch<ThemeProvider>().config;
            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Clear Grid?',
                style: TextStyle(color: colors.fixedText),
              ),
              content: Text(
                'This will remove all your entries and pencil marks. Fixed clues will be kept.',
                style: TextStyle(color: colors.candidateText),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.candidateText),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.fixedText,
                    foregroundColor: colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Clear'),
                ),
              ],
            );
          },
        ).then((confirmed) {
          if (confirmed == true) {
            provider.clearGrid();
          }
        });
      case 'save':
        provider.savePuzzle();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Puzzle saved!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      case 'editClues':
        provider.editClues();
      case 'validate':
        final valid = provider.validate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              valid ? 'No errors found!' : 'Errors highlighted.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }
}

/// Pill-shaped button for PENCIL / FILL NOTES toolbar
class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeConfig colors;
  final VoidCallback onTap;
  final bool isActive;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? colors.selectedCell : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colors.fixedText),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                  color: colors.fixedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation icon (Hint, Solve, Undo, Save)
class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final ThemeConfig colors;
  final VoidCallback onTap;

  const _BottomNavIcon({
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22, color: colors.fixedText),
      onPressed: onTap,
      splashRadius: 24,
    );
  }
}

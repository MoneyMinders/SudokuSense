import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/practice_puzzles.dart';
import '../models/board.dart';
import '../providers/theme_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../providers/puzzle_provider.dart';

class PracticePuzzleScreen extends StatefulWidget {
  final TechniqueGroup group;

  const PracticePuzzleScreen({super.key, required this.group});

  @override
  State<PracticePuzzleScreen> createState() => _PracticePuzzleScreenState();
}

class _PracticePuzzleScreenState extends State<PracticePuzzleScreen> {
  int _currentIndex = 0;
  bool _solved = false;
  bool _showHowTo = false;

  PracticePuzzle get _puzzle => widget.group.puzzles[_currentIndex];

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  void _loadPuzzle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PuzzleProvider>();
      provider.loadPuzzle(_puzzle.grid);
      setState(() => _solved = false);
    });
  }

  void _checkAnswer(int row, int col, int value) {
    if (row == _puzzle.answerRow &&
        col == _puzzle.answerCol &&
        value == _puzzle.answerValue) {
      HapticFeedback.heavyImpact();
      setState(() => _solved = true);
    } else {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not quite — try again or tap "Show How" for help.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _nextPuzzle() {
    if (_currentIndex < widget.group.puzzles.length - 1) {
      setState(() {
        _currentIndex++;
        _showHowTo = false;
      });
      _loadPuzzle();
    } else {
      // All done
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All ${widget.group.name} puzzles completed!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;
    final total = widget.group.puzzles.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.group.name,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Serif',
            color: colors.fixedText,
          ),
        ),
        iconTheme: IconThemeData(color: colors.fixedText),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1}/$total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.candidateText,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress dots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                return Container(
                  width: i == _currentIndex ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i < _currentIndex
                        ? colors.accent
                        : i == _currentIndex
                            ? colors.fixedText
                            : colors.gridBorderThin,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Instruction
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              _solved
                  ? 'Correct!'
                  : 'Find the cell and value using ${widget.group.name}.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                fontSize: 14,
                color: _solved ? const Color(0xFF4CAF50) : colors.candidateText,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 4),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IgnorePointer(
                ignoring: _solved,
                child: const SudokuGrid(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Number pad for answering
          if (!_solved)
            _buildNumberPad(colors)
          else
            _buildSuccessCard(colors),

          const SizedBox(height: 8),

          // How-to / explanation
          if (_showHowTo || _solved)
            _buildExplanation(colors),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                if (!_solved && !_showHowTo)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _showHowTo = true),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.gridBorderThin),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text('Show How',
                          style: TextStyle(color: colors.fixedText)),
                    ),
                  ),
                if (!_solved && _showHowTo)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reveal answer
                        final p = context.read<PuzzleProvider>();
                        p.selectCell(_puzzle.answerRow, _puzzle.answerCol);
                        p.setValue(_puzzle.answerValue);
                        setState(() => _solved = true);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.gridBorderThin),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text('Reveal Answer',
                          style: TextStyle(color: colors.fixedText)),
                    ),
                  ),
                if (_solved) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPuzzle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.fixedText,
                        foregroundColor: colors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentIndex < total - 1 ? 'Next Puzzle' : 'Finish',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNumberPad(ThemeConfig colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (i) {
              final num = i + 1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: Material(
                      color: colors.cellBg,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          final p = context.read<PuzzleProvider>();
                          if (p.selectedRow != null && p.selectedCol != null) {
                            _checkAnswer(p.selectedRow!, p.selectedCol!, num);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tap a cell first, then enter the number.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Text('$num',
                              style: TextStyle(fontSize: 20, color: colors.fixedText)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(4, (i) {
              final num = i + 6;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: Material(
                      color: colors.cellBg,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          final p = context.read<PuzzleProvider>();
                          if (p.selectedRow != null && p.selectedCol != null) {
                            _checkAnswer(p.selectedRow!, p.selectedCol!, num);
                          }
                        },
                        child: Center(
                          child: Text('$num',
                              style: TextStyle(fontSize: 20, color: colors.fixedText)),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard(ThemeConfig colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1A4CAF50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x334CAF50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'R${_puzzle.answerRow + 1}C${_puzzle.answerCol + 1} = ${_puzzle.answerValue}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.fixedText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanation(ThemeConfig colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.highlightedRegion,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showHowTo && !_solved) ...[
            Text(
              'How to use ${widget.group.name}:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.fixedText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.group.howTo,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.candidateText,
                height: 1.4,
              ),
            ),
          ],
          if (_solved) ...[
            Text(
              _puzzle.explanation,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.candidateText,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

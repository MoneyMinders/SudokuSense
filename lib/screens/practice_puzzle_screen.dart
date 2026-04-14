import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/practice_puzzles.dart';
import '../models/board.dart';
import '../models/hint_result.dart';
import '../providers/theme_provider.dart';
import '../services/hint_service.dart';
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
  bool _showHint = false;
  HintResult? _hintResult;

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
      setState(() {
        _solved = false;
        _showHint = false;
        _hintResult = null;
      });
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
        _showHint = false;
        _hintResult = null;
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

          // Hint / explanation
          if (_showHint || _solved)
            _buildExplanation(colors),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                if (!_solved && !_showHint)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Run the real hint engine on this puzzle
                        final board = Board.fromGrid(_puzzle.grid);
                        final hint = HintService().findHint(board);
                        setState(() {
                          _showHint = true;
                          _hintResult = hint;
                        });
                        // Highlight the target cell
                        if (hint != null && hint.placements.isNotEmpty) {
                          context.read<PuzzleProvider>().selectCell(
                            hint.placements.first.row,
                            hint.placements.first.col,
                          );
                        }
                      },
                      icon: Icon(Icons.lightbulb_outline, size: 16, color: colors.fixedText),
                      label: Text('Hint', style: TextStyle(color: colors.fixedText)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.gridBorderThin),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                if (!_solved && _showHint) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
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
                      child: Text('Reveal', style: TextStyle(color: colors.fixedText)),
                    ),
                  ),
                ],
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
    // Use the real hint engine result if available, otherwise fallback to static
    final hintText = _hintResult?.explanation ?? _puzzle.explanation;
    final strategyName = _hintResult?.strategyName ?? widget.group.name;

    String? placementText;
    if (_hintResult != null && _hintResult!.placements.isNotEmpty) {
      placementText = _hintResult!.placements
          .map((p) => 'Place ${p.value} at Row ${p.row + 1}, Column ${p.col + 1}')
          .join('\n');
    }
    String? eliminationText;
    if (_hintResult != null && _hintResult!.eliminations.isNotEmpty) {
      eliminationText = _hintResult!.eliminations
          .map((e) => 'Remove ${e.value} from Row ${e.row + 1}, Column ${e.col + 1}')
          .join('\n');
    }

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
          // Strategy name
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: colors.accent),
              const SizedBox(width: 8),
              Text(
                strategyName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Serif',
                  color: colors.fixedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Explanation from hint engine
          Text(
            hintText,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontFamily: 'Serif',
              color: colors.candidateText,
              height: 1.5,
            ),
          ),

          // Placements
          if (placementText != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x1A4CAF50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.add_circle_outline, size: 14, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      placementText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.fixedText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Eliminations
          if (eliminationText != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0x1AE57373),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.remove_circle_outline, size: 14, color: Color(0xFFE57373)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      eliminationText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.fixedText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

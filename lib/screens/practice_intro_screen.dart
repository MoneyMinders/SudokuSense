import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/practice_puzzles.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'practice_puzzle_screen.dart';

/// First page for each practice technique: definition + worked example.
/// The user taps "Start Practice" to move on to the drill puzzles.
class PracticeIntroScreen extends StatelessWidget {
  final TechniqueGroup group;

  const PracticeIntroScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;
    final diff = _difficultyFromLabel(group.difficulty);
    final diffColor = AppColors.difficultyColor(diff);
    final example = group.puzzles.isNotEmpty ? group.puzzles.first : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: colors.fixedText),
        title: Text(
          'Practice',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Serif',
            color: colors.fixedText,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Title + difficulty badge
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.w600,
                    color: colors.fixedText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: diffColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: diffColor.withAlpha(80)),
                ),
                child: Text(
                  group.difficulty,
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

          // Definition
          _sectionHeader('Definition', colors),
          const SizedBox(height: 6),
          Text(
            group.description,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontFamily: 'Serif',
              color: colors.fixedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // How it works
          _sectionHeader('How it works', colors),
          const SizedBox(height: 6),
          Text(
            group.howTo,
            style: TextStyle(
              fontSize: 14,
              color: colors.fixedText,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),

          // Example
          if (example != null) ...[
            _sectionHeader('Example', colors),
            const SizedBox(height: 10),
            _ExampleBoard(
              grid: example.grid,
              highlightRow: example.answerRow,
              highlightCol: example.answerCol,
              answerValue: example.answerValue,
              colors: colors,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.highlightedRegion,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                example.explanation,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Serif',
                  color: colors.candidateText,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Start button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: group.puzzles.isEmpty
                  ? null
                  : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticePuzzleScreen(group: group),
                        ),
                      );
                    },
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                'Start Practice — ${group.puzzles.length} puzzles',
                style: const TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.fixedText,
                foregroundColor: colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text, ThemeConfig colors) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
        color: colors.candidateText,
      ),
    );
  }

  Difficulty _difficultyFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      case 'expert':
        return Difficulty.expert;
      case 'evil':
        return Difficulty.evil;
      default:
        return Difficulty.medium;
    }
  }
}

/// Static, read-only 9x9 grid for the worked example.
/// The target cell (where the technique places a value) is highlighted
/// and shows the answer in bold.
class _ExampleBoard extends StatelessWidget {
  final List<List<int>> grid;
  final int highlightRow;
  final int highlightCol;
  final int answerValue;
  final ThemeConfig colors;

  const _ExampleBoard({
    required this.grid,
    required this.highlightRow,
    required this.highlightCol,
    required this.answerValue,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.gridBorderThick,
            width: GridConstants.thickBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: List.generate(9, (r) {
            return Expanded(
              child: Row(
                children: List.generate(9, (c) {
                  final value = grid[r][c];
                  final isTarget = r == highlightRow && c == highlightCol;
                  final displayValue = isTarget ? answerValue : value;

                  // Box borders to make 3x3 groups visible.
                  final isRightBox = c == 2 || c == 5;
                  final isBottomBox = r == 2 || r == 5;
                  final isRightThin = c < 8 && !isRightBox;
                  final isBottomThin = r < 8 && !isBottomBox;

                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isTarget
                            ? colors.hintHighlight
                            : colors.cellBg,
                        border: Border(
                          right: BorderSide(
                            color: isRightBox
                                ? colors.gridBorderThick
                                : (isRightThin ? colors.gridBorderThin : Colors.transparent),
                            width: isRightBox
                                ? GridConstants.thickBorder
                                : (isRightThin ? GridConstants.thinBorder : 0),
                          ),
                          bottom: BorderSide(
                            color: isBottomBox
                                ? colors.gridBorderThick
                                : (isBottomThin ? colors.gridBorderThin : Colors.transparent),
                            width: isBottomBox
                                ? GridConstants.thickBorder
                                : (isBottomThin ? GridConstants.thinBorder : 0),
                          ),
                        ),
                      ),
                      child: Center(
                        child: displayValue == 0
                            ? const SizedBox.shrink()
                            : Text(
                                '$displayValue',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isTarget ? FontWeight.w700 : FontWeight.w500,
                                  color: isTarget
                                      ? const Color(0xFF2E7D32)
                                      : colors.fixedText,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}

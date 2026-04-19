import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/practice_puzzles.dart';
import '../providers/theme_provider.dart';
import 'practice_intro_screen.dart';

class PracticeListScreen extends StatelessWidget {
  const PracticeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    // Group by difficulty
    final grouped = <String, List<TechniqueGroup>>{};
    for (final g in practiceData) {
      (grouped[g.difficulty] ??= []).add(g);
    }
    final order = ['Easy', 'Medium', 'Hard', 'Expert', 'Evil'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Practice',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Serif',
            fontSize: 22,
            color: colors.fixedText,
          ),
        ),
        iconTheme: IconThemeData(color: colors.fixedText),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 4),
            child: Text(
              'Master each technique with focused puzzles.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.candidateText,
                fontSize: 14,
              ),
            ),
          ),
          for (final diff in order)
            if (grouped.containsKey(diff)) ...[
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8, left: 4),
                child: Text(
                  diff.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    color: colors.candidateText,
                  ),
                ),
              ),
              for (final group in grouped[diff]!)
                _TechniqueCard(group: group, colors: colors),
            ],
        ],
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final TechniqueGroup group;
  final ThemeConfig colors;

  const _TechniqueCard({required this.group, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.gridBorderThin, width: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PracticeIntroScreen(group: group),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Serif',
                        fontWeight: FontWeight.w600,
                        color: colors.fixedText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      group.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.candidateText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    '${group.puzzles.length}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.fixedText,
                    ),
                  ),
                  Text(
                    'puzzles',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.candidateText,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: colors.candidateText, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Change Theme',
            onPressed: () => _showThemePicker(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Grid icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.fixedText, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grid_on_rounded,
                    size: 40,
                    color: colors.fixedText,
                  ),
                ),
                const SizedBox(height: 24),
                // Serif italic title
                Text(
                  'SudokuSense',
                  style: TextStyle(
                    fontSize: 32,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: colors.fixedText,
                    fontFamily: 'Serif',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A quiet space for focus and clarity.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: colors.candidateText,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 56),

                // Primary action — Scan Page (most prominent)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/camera'),
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: const Text(
                      'Scan Page',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                const SizedBox(height: 12),

                // Secondary actions row — Manual Entry & Random
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<PuzzleProvider>().startSetupMode();
                            Navigator.pushNamed(context, '/puzzle');
                          },
                          icon: Icon(Icons.edit_outlined, size: 16, color: colors.fixedText),
                          label: Text(
                            'Manual',
                            style: TextStyle(fontSize: 14, color: colors.fixedText),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.gridBorderThin),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<PuzzleProvider>().loadRandomPuzzle();
                            Navigator.pushNamed(context, '/puzzle');
                          },
                          icon: Icon(Icons.shuffle_rounded, size: 16, color: colors.fixedText),
                          label: Text(
                            'Random',
                            style: TextStyle(fontSize: 14, color: colors.fixedText),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.gridBorderThin),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tertiary — Library (text button, least prominent)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/saved'),
                    icon: Icon(Icons.bookmark_outline, size: 16, color: colors.candidateText),
                    label: Text(
                      'Saved Puzzles',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.candidateText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, tp, _) {
            final screenWidth = MediaQuery.of(context).size.width;
            // 4 columns on wider screens, 3 on narrow
            final crossCount = screenWidth > 360 ? 4 : 3;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 16),
                    child: Text(
                      'Choose Theme',
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Serif',
                        color: tp.config.fixedText,
                      ),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: crossCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.85,
                    children: AppTheme.values.map((appTheme) {
                      final config = ThemeProvider.themes[appTheme]!;
                      final isSelected = tp.currentTheme == appTheme;
                      return GestureDetector(
                        onTap: () => themeProvider.setTheme(appTheme),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: config.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? config.accent
                                  : config.gridBorderThin,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: config.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                config.name,
                                style: TextStyle(
                                  color: config.fixedText,
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

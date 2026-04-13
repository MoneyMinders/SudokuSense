import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';

class SavedPuzzlesScreen extends StatefulWidget {
  const SavedPuzzlesScreen({super.key});

  @override
  State<SavedPuzzlesScreen> createState() => _SavedPuzzlesScreenState();
}

class _SavedPuzzlesScreenState extends State<SavedPuzzlesScreen> {
  List<SavedPuzzle>? _puzzles;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final puzzles = await StorageService().loadAll();
    if (mounted) setState(() => _puzzles = puzzles);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Library',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Serif',
            color: colors.fixedText,
          ),
        ),
        iconTheme: IconThemeData(color: colors.fixedText),
      ),
      body: _puzzles == null
          ? Center(
              child: CircularProgressIndicator(
                color: colors.accent,
                strokeWidth: 2,
              ),
            )
          : _puzzles!.isEmpty
              ? _buildEmptyState(colors)
              : _buildPuzzleList(colors),
    );
  }

  Widget _buildEmptyState(ThemeConfig colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 56,
              color: colors.candidateText,
            ),
            const SizedBox(height: 20),
            Text(
              'No saved puzzles yet',
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.fixedText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the save icon while solving to save your progress.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontFamily: 'Serif',
                color: colors.candidateText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleList(ThemeConfig colors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _puzzles!.length,
      itemBuilder: (context, index) {
        final puzzle = _puzzles![index];
        final progressPct = (puzzle.progress * 100).round();

        return Dismissible(
          key: Key(puzzle.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: colors.errorBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.delete_outline, color: colors.fixedText),
          ),
          onDismissed: (_) {
            final removed = _puzzles!.removeAt(index);
            setState(() {});
            StorageService().delete(removed.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${removed.name} deleted'),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () async {
                    await StorageService().save(removed);
                    _load();
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.gridBorderThin, width: 1),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                context.read<PuzzleProvider>().loadSavedPuzzle(puzzle);
                Navigator.pushReplacementNamed(context, '/puzzle');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Progress ring
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: puzzle.progress,
                            strokeWidth: 2.5,
                            backgroundColor: colors.gridBorderThin,
                            color: colors.accent,
                          ),
                          Text(
                            '$progressPct%',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.candidateText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            puzzle.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.fixedText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(puzzle.savedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.candidateText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.candidateText,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

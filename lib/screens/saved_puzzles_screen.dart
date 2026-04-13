import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Puzzles')),
      body: _puzzles == null
          ? const Center(child: CircularProgressIndicator())
          : _puzzles!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved puzzles yet',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the save icon while solving to save your progress',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _puzzles!.length,
                  itemBuilder: (context, index) {
                    final puzzle = _puzzles![index];
                    final progressPct = (puzzle.progress * 100).round();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                value: puzzle.progress,
                                strokeWidth: 3,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                            Text(
                              '$progressPct%',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        title: Text(puzzle.name),
                        subtitle: Text(
                          _formatDate(puzzle.savedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await StorageService().delete(puzzle.id);
                            _load();
                          },
                        ),
                        onTap: () {
                          context.read<PuzzleProvider>().loadSavedPuzzle(puzzle);
                          Navigator.pushReplacementNamed(context, '/puzzle');
                        },
                      ),
                    );
                  },
                ),
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

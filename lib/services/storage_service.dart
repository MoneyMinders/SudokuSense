import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPuzzle {
  final String id;
  final String name;
  final List<List<int>> originalGrid;
  final List<List<int>> currentGrid;
  // 9x9 of pencil-mark candidate lists. Empty inner list = no notes for that
  // cell. Stored so that resuming a puzzle preserves the player's pencil
  // work exactly as it was when they left.
  final List<List<List<int>>> currentCandidates;
  final DateTime savedAt;
  final double progress;
  final Duration elapsed;

  SavedPuzzle({
    required this.id,
    required this.name,
    required this.originalGrid,
    required this.currentGrid,
    required this.savedAt,
    required this.progress,
    this.elapsed = Duration.zero,
    List<List<List<int>>>? currentCandidates,
  }) : currentCandidates = currentCandidates ?? _emptyCandidates();

  static List<List<List<int>>> _emptyCandidates() => List.generate(
        9,
        (_) => List.generate(9, (_) => <int>[]),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'originalGrid': originalGrid,
    'currentGrid': currentGrid,
    'currentCandidates': currentCandidates,
    'savedAt': savedAt.toIso8601String(),
    'progress': progress,
    'elapsedMs': elapsed.inMilliseconds,
  };

  factory SavedPuzzle.fromJson(Map<String, dynamic> json) {
    final rawCandidates = json['currentCandidates'] as List?;
    final candidates = rawCandidates == null
        ? _emptyCandidates()
        : List<List<List<int>>>.generate(
            9,
            (r) => List<List<int>>.generate(
              9,
              (c) => ((rawCandidates[r] as List)[c] as List).cast<int>().toList(),
            ),
          );

    return SavedPuzzle(
      id: json['id'] as String,
      name: json['name'] as String,
      originalGrid: (json['originalGrid'] as List)
          .map((row) => (row as List).cast<int>().toList())
          .toList(),
      currentGrid: (json['currentGrid'] as List)
          .map((row) => (row as List).cast<int>().toList())
          .toList(),
      currentCandidates: candidates,
      savedAt: DateTime.parse(json['savedAt'] as String),
      progress: (json['progress'] as num).toDouble(),
      // Pre-existing saves have no elapsed field — fall back to zero.
      elapsed: Duration(
        milliseconds: (json['elapsedMs'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

class StorageService {
  static const _key = 'saved_puzzles';

  Future<List<SavedPuzzle>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data
        .map((s) => SavedPuzzle.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  Future<void> save(SavedPuzzle puzzle) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();

    // Update if exists, otherwise add
    final idx = all.indexWhere((p) => p.id == puzzle.id);
    if (idx >= 0) {
      all[idx] = puzzle;
    } else {
      all.insert(0, puzzle);
    }

    await prefs.setStringList(
      _key,
      all.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all.removeWhere((p) => p.id == id);
    await prefs.setStringList(
      _key,
      all.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  /// Save the selected theme.
  Future<void> saveTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', themeName);
  }

  Future<String?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_theme');
  }
}

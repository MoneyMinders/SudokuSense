import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPuzzle {
  final String id;
  final String name;
  final List<List<int>> originalGrid;
  final List<List<int>> currentGrid;
  final DateTime savedAt;
  final double progress;

  SavedPuzzle({
    required this.id,
    required this.name,
    required this.originalGrid,
    required this.currentGrid,
    required this.savedAt,
    required this.progress,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'originalGrid': originalGrid,
    'currentGrid': currentGrid,
    'savedAt': savedAt.toIso8601String(),
    'progress': progress,
  };

  factory SavedPuzzle.fromJson(Map<String, dynamic> json) {
    return SavedPuzzle(
      id: json['id'] as String,
      name: json['name'] as String,
      originalGrid: (json['originalGrid'] as List)
          .map((row) => (row as List).cast<int>().toList())
          .toList(),
      currentGrid: (json['currentGrid'] as List)
          .map((row) => (row as List).cast<int>().toList())
          .toList(),
      savedAt: DateTime.parse(json['savedAt'] as String),
      progress: (json['progress'] as num).toDouble(),
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

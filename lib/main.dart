import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/puzzle_provider.dart';
import 'app.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PuzzleProvider(),
      child: const SudokuSenseApp(),
    ),
  );
}

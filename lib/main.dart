import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/puzzle_provider.dart';
import 'providers/theme_provider.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PuzzleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const SudokuSenseApp(),
    ),
  );
}

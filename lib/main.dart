import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/puzzle_provider.dart';
import 'providers/theme_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PuzzleProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const SudokuSenseApp(),
    ),
  );
}

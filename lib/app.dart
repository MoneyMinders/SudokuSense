import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/puzzle_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/saved_puzzles_screen.dart';

class SudokuSenseApp extends StatelessWidget {
  const SudokuSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'SudokuSense',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          darkTheme: themeProvider.isLightTheme ? null : themeProvider.themeData,
          theme: themeProvider.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/camera': (context) => const CameraScreen(),
            '/puzzle': (context) => const PuzzleScreen(),
            '/saved': (context) => const SavedPuzzlesScreen(),
          },
        );
      },
    );
  }
}

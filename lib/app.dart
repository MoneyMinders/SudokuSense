import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/puzzle_screen.dart';
import 'screens/camera_screen.dart';

class SudokuSenseApp extends StatelessWidget {
  const SudokuSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SudokuSense',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9FA8DA), // Soft indigo pastel
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1E1E1E),
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9FA8DA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/puzzle': (context) => const PuzzleScreen(),
      },
    );
  }
}

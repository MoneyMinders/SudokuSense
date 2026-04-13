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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
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

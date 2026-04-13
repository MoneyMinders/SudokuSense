import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_sense/app.dart';
import 'package:sudoku_sense/providers/puzzle_provider.dart';
import 'package:sudoku_sense/providers/theme_provider.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PuzzleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const SudokuSenseApp(),
      ),
    );
    expect(find.text('SudokuSense'), findsOneWidget);
  });
}

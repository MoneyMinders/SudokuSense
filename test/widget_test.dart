import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sudoku_sense/app.dart';
import 'package:sudoku_sense/providers/puzzle_provider.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PuzzleProvider(),
        child: const SudokuSenseApp(),
      ),
    );
    expect(find.text('SudokuSense'), findsOneWidget);
  });
}

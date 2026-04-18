# SudokuSense

A Flutter Sudoku app with camera scanning, a logic-based hint engine, and practice drills for specific techniques.

Live web demo: **https://moneyminders.github.io/SudokuSense/**

## Features

- **Camera scan** — Snap a photo of a printed sudoku and the app OCRs it into a playable grid. Uses Google ML Kit on mobile, Tesseract.js on web. Multi-variant preprocessing + parallel consensus voting for stable results.
- **Logical hint engine** — Finds the next move with named strategies: Naked/Hidden Single, Naked/Hidden Pair & Triple, Locked Candidates, X-Wing, Swordfish, Skyscraper, XY-Wing, XYZ-Wing, W-Wing, ALS-XZ, Unique Rectangle, Forcing Chains, X-Cycles.
- **Practice mode** — Drills grouped by technique so you can learn one strategy at a time.
- **Pencil marks** — Toggle candidate notes, Fill-Notes to auto-populate possibles.
- **Random puzzles** — Generated with a uniqueness-preserving backtracking solver.
- **Setup mode** — Manually enter a puzzle or review/correct an OCR scan before solving.
- **Save / resume** — Puzzles persist across sessions with elapsed timer.
- **Light + dark themes**.

## Build & run

```bash
# Dev on Chrome
flutter run -d chrome

# Dev on Android device
flutter run -d <device-id>

# Release APK (also copied to iCloud/SudokuSense/)
make apk

# Release iOS
make ios
```

## Platforms

| Platform | OCR engine | Status |
|----------|-----------|--------|
| Android  | ML Kit    | Working |
| iOS      | ML Kit    | Working |
| Web      | Tesseract.js | Working |

## Deployment

GitHub Actions auto-deploys the web build to GitHub Pages on every push to `main`. Workflow: [.github/workflows/deploy-web.yml](.github/workflows/deploy-web.yml).

## Project structure

```
lib/
  models/          Board, Cell, HintResult
  providers/       PuzzleProvider (state), ThemeProvider
  services/        SolverService, HintService, OCR strategies, image preprocessing
  screens/         Home, Puzzle, Camera, Practice, Saved
  widgets/         SudokuGrid, CellWidget, NumberPad, HintSheet
  strategies/      One file per hint technique
  utils/           GridParser (OCR → 9x9), constants
```

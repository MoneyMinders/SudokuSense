# SudokuSense — Handoff Document

## What Is This

A Sudoku solver helper app. Click a photo of a Sudoku puzzle (or enter manually), and the app detects the numbers, lets you solve it with intelligent hints explaining each logical step, or auto-solves it. Built in one session on April 14, 2026.

**Repo**: https://github.com/MoneyMinders/SudokuSense  
**Web**: http://187.127.131.123:3001/ (VPS) + https://moneyminders.github.io/SudokuSense/ (GitHub Pages)  
**Package**: `com.sahilgakhar.sudoku_sense`

---

## Architecture

**Frontend-only Flutter app** — no backend, everything on-device.

| Layer | Tech |
|-------|------|
| Framework | Flutter (Dart) |
| State | Provider (`PuzzleProvider`, `ThemeProvider`) |
| OCR | Google ML Kit Text Recognition |
| Image Processing | `image` package (Dart) |
| Storage | SharedPreferences (saved puzzles, theme preference) |
| Typography | Google Fonts (EB Garamond) |
| Platforms | Android, iOS, Web |

---

## How to Run

```bash
# Development (hot reload)
flutter run

# Release APK (Android)
flutter build apk --release

# Install on connected phone
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Web build
flutter build web --release

# Web build for GitHub Pages (needs base-href)
flutter build web --release --base-href="/SudokuSense/"
```

---

## How to Deploy

### VPS (http://187.127.131.123:3001/)
```bash
flutter build web --release
rsync -az --delete build/web/ root@187.127.131.123:/home/apps/SudokuSense/web-dist/
ssh root@187.127.131.123 "cd /home/apps/SudokuSense && ./scripts/vps-deploy.sh web-restart"
```

### GitHub Pages
```bash
flutter build web --release --base-href="/SudokuSense/"
git checkout gh-pages
rm -rf docs && cp -r build/web docs
git add docs && git commit -m "deploy: update web build" && git push
git checkout main
```

### Phone (via USB)
```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Phone (via iCloud)
```bash
flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk ~/Library/Mobile\ Documents/com~apple~CloudDocs/SudokuSense.apk
```

---

## Key Decisions

### No Backend
Everything runs on-device. OCR, solving, hints — all pure Dart/ML Kit. No server costs, works offline. The only "server" is the static web deploy on VPS nginx.

### Paper/Kindle Theme as Default
The app uses a warm paper aesthetic (like solving on actual newsprint). `#CCC7BF` background, `#3C3C3C` charcoal ink, serif italic typography (EB Garamond). 7 additional dark themes available via palette icon.

### Candidates Not Auto-Filled
Pencil marks (candidate numbers) are NEVER auto-populated. The user must explicitly tap "Fill Notes" (with confirmation popup) or manually toggle candidates via Pencil mode. The hint engine calculates candidates internally on a deep copy — never mutates the user's board.

### OCR Pipeline (3 Strategies)
OCR runs three approaches in parallel and picks the best result:
1. **Whole-image ML Kit** on original photo
2. **Whole-image ML Kit** on preprocessed image (grayscale → contrast → sharpen → adaptive threshold)
3. **Cell-by-cell ML Kit** — detect grid bounds, crop 81 individual cells, run ML Kit on each with white padding

After OCR, opens in **setup mode** so user can correct any misread digits before solving.

### Solver Algorithm
1. **On puzzle load**: Backtracking solver with MRV heuristic finds solution(s). Stops at 2 to detect multiple solutions.
2. **On hint request**: Hint engine runs 20 strategies in difficulty order (Easy→Evil) on a deep copy of the board. Verifies result against stored solution.
3. **On auto-solve**: Fills all cells from stored solution. Pushes history so undo works.

### Random Puzzle Generator
Uses proper algorithm from 101computing.net: fill grid randomly with backtracking, then remove cells one by one while checking that the puzzle still has exactly one unique solution.

### Timer
Starts when solving begins (after "Start Solving" or loading a puzzle). Pauses on app background or navigate away. Stops on solve. Displays as `MM:SS` next to progress bar.

---

## 20 Sudoku Strategies (Priority Order)

| # | Strategy | Difficulty | Type |
|---|----------|-----------|------|
| 1 | Cross-Hatching | Easy | Placement |
| 2 | Naked Single | Easy | Placement |
| 3 | Hidden Single | Easy | Placement |
| 4 | Naked Pair | Medium | Elimination |
| 5 | Hidden Pair | Medium | Elimination |
| 6 | Naked Triple | Medium | Elimination |
| 7 | Hidden Triple | Medium | Elimination |
| 8 | Locked Candidates (Pointing) | Medium | Elimination |
| 9 | Locked Candidates (Claiming) | Medium | Elimination |
| 10 | X-Wing | Hard | Elimination |
| 11 | Swordfish | Hard | Elimination |
| 12 | Skyscraper | Hard | Elimination |
| 13 | Unique Rectangle | Hard | Elimination |
| 14 | XY-Wing | Expert | Elimination |
| 15 | XYZ-Wing | Expert | Elimination |
| 16 | W-Wing | Expert | Elimination |
| 17 | ALS-XZ | Expert | Elimination |
| 18 | Forcing Chains | Evil | Placement |
| 19 | X-Cycles | Evil | Elimination |

Rule: Always exhaust simpler strategies before trying complex ones.

---

## File Structure

```
lib/
├── main.dart                    # Entry point, MultiProvider setup
├── app.dart                     # MaterialApp, routing, theme consumer
├── models/
│   ├── cell.dart                # Cell: value, candidates, isFixed, isError
│   ├── board.dart               # 9x9 board with all helpers
│   └── hint_result.dart         # HintResult, Placement, Elimination, Difficulty
├── services/
│   ├── ocr_service.dart         # 3-strategy OCR orchestrator
│   ├── cell_ocr_service.dart    # Cell-by-cell OCR (crop 81 cells individually)
│   ├── image_preprocessor.dart  # Grayscale, contrast, adaptive threshold
│   ├── solver_service.dart      # Backtracking solver with MRV, solution counting
│   ├── hint_service.dart        # Chains 20 strategies, works on deep copy
│   ├── candidate_service.dart   # Calculates candidates from board state
│   └── storage_service.dart     # SharedPreferences save/load
├── strategies/                  # 20 strategy files, each extends Strategy
├── providers/
│   ├── puzzle_provider.dart     # All puzzle state, timer, undo/redo
│   └── theme_provider.dart      # 8 themes, persistence
├── screens/
│   ├── home_screen.dart         # Scan Page, Manual, Random, Library
│   ├── camera_screen.dart       # Image picker + crop + OCR
│   ├── puzzle_screen.dart       # Main solving screen
│   └── saved_puzzles_screen.dart
├── widgets/
│   ├── sudoku_grid.dart         # 9x9 grid with CustomPaint lines
│   ├── cell_widget.dart         # Material+InkWell cell rendering
│   ├── number_pad.dart          # 2-row number pad (1-5, 6-9+X)
│   └── hint_sheet.dart          # Bottom sheet with strategy explanation
└── utils/
    ├── constants.dart           # GridConstants, AppColors helpers
    └── grid_parser.dart         # K-means clustering, OCR→grid mapping
```

---

## Known Issues & Bugs Fixed

### Fixed
- **Grid only showed 3 rows** — thin borders invisible in Paper theme. Fixed by using CustomPaint for grid lines + darker border color.
- **Cells not tappable** — GestureDetector didn't register taps on empty cells. Fixed with Material+InkWell.
- **Hint filled all candidates** — `findHint()` mutated the user's board. Fixed to work on deep copy.
- **Apply Hint filled candidates** — `applyHint()` called `calculateAllCandidates`. Removed.
- **Saved puzzles showed candidates** — `loadSavedPuzzle()` called `calculateAllCandidates`. Removed.
- **Forcing Chains returned Elimination instead of Placement** — contradiction branch now correctly places the surviving value.
- **Random generator created invalid puzzles** — now uses proper fill→remove algorithm with uniqueness check.
- **Image picker "already active" crash** — added `_picking` guard flag.
- **R8 build failure** — ML Kit missing classes. Added ProGuard keep rules.
- **GitHub Pages blank page** — needed `--base-href="/SudokuSense/"`.

### Known Limitations
- **OCR accuracy ~70-85%** — ML Kit struggles with some fonts/angles. User corrects in setup mode.
- **Camera OCR not available on Web** — web uses manual entry only.
- **No TFLite digit classifier** — would improve OCR to ~99% accuracy but requires training a model.
- **Unique Rectangle only Type 1** — Types 2-6 not implemented.
- **No difficulty levels for random puzzles** — all random puzzles are same difficulty (~36 clues).

---

## Themes (8 total)

| Theme | Accent | Background |
|-------|--------|------------|
| Paper (default) | `#3C3C3C` charcoal | `#CCC7BF` warm gray |
| Midnight Purple | `#7C6BF0` purple | `#0D0F1A` navy |
| Dracula | `#FF79C6` pink | `#1A1B26` dark |
| Monokai Gold | `#FFD866` gold | `#0D0D0D` black |
| Crimson Night | `#EF5350` red | `#0D0D0D` black |
| Mint Fresh | `#80CBC4` teal | `#0D1010` dark |
| Solarized | `#FFB74D` amber | `#0D0D0A` dark |
| One Dark | `#56B6C2` cyan | `#1B1F23` dark |

---

## Deploy Checklist

Every time code changes, deploy to all three targets:

```bash
# 1. Phone (via USB)
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb shell am force-stop com.sahilgakhar.sudoku_sense
adb shell am start -n com.sahilgakhar.sudoku_sense/.MainActivity

# 2. VPS (http://187.127.131.123:3001/)
flutter build web --release
rsync -az --delete build/web/ root@187.127.131.123:/home/apps/SudokuSense/web-dist/
ssh root@187.127.131.123 "cd /home/apps/SudokuSense && ./scripts/vps-deploy.sh web-restart"

# 3. GitHub Pages (https://moneyminders.github.io/SudokuSense/)
flutter build web --release --base-href="/SudokuSense/"
git checkout gh-pages
rm -rf docs && cp -r build/web docs
git add docs && git commit -m "deploy: update web build" && git push
git checkout main

# 4. Git (always push code)
git add -A && git commit -m "description" && git push
```

**IMPORTANT**: GitHub Pages needs `--base-href="/SudokuSense/"` but VPS does NOT (it serves from root). So you need two separate web builds — one for VPS (no base-href) and one for GitHub Pages (with base-href).

---

## App Icon
Generated via Google Gemini — pencil on a Sudoku grid on aged paper. Cropped square from `Screenshot 2026-04-14 at 2.22.26 AM.png`. Processed with `flutter_launcher_icons` with adaptive icon background `#CCC7BF`.

---

## What's Next (Potential Improvements)

- [ ] TFLite MNIST model for 99% OCR accuracy on cropped cells
- [ ] Difficulty selector for random puzzles (Easy/Medium/Hard/Expert)
- [ ] Puzzle timer saved with puzzle progress
- [ ] Animations on solve/hint apply
- [ ] Share puzzle as image
- [ ] Puzzle statistics (times, hints used, completion rate)
- [ ] Corner-drag UI for perspective correction before OCR
- [ ] Unique Rectangle Types 2-6

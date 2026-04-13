import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

enum AppTheme {
  kindlePaper,
  midnightPurple,
  draculaPink,
  monokaiGold,
  crimsonNight,
  mintFresh,
  solarizedAmber,
  oneDarkCyan,
}

class ThemeConfig {
  final String name;
  final Color accent;
  final Color accentDim;
  final Color surface;
  final Color background;
  final Color cellBg;
  final Color selectedCell;
  final Color highlightedRegion;
  final Color gridBorderThick;
  final Color gridBorderThin;
  final Color fixedText;
  final Color userText;
  final Color candidateText;
  final Color errorBg;
  final Color hintHighlight;

  const ThemeConfig({
    required this.name,
    required this.accent,
    required this.accentDim,
    required this.surface,
    required this.background,
    required this.cellBg,
    required this.selectedCell,
    required this.highlightedRegion,
    required this.gridBorderThick,
    required this.gridBorderThin,
    required this.fixedText,
    required this.userText,
    required this.candidateText,
    required this.errorBg,
    required this.hintHighlight,
  });
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.kindlePaper;

  AppTheme get currentTheme => _currentTheme;

  /// Load the persisted theme from device storage.
  Future<void> loadSavedTheme() async {
    final name = await StorageService().loadTheme();
    if (name != null) {
      final match = AppTheme.values.where(
        (t) => themes[t]!.name == name,
      );
      if (match.isNotEmpty) {
        _currentTheme = match.first;
        notifyListeners();
      }
    }
  }

  void setTheme(AppTheme theme) {
    _currentTheme = theme;
    StorageService().saveTheme(themes[theme]!.name);
    notifyListeners();
  }

  ThemeConfig get config => themes[_currentTheme]!;

  bool get isLightTheme => _currentTheme == AppTheme.kindlePaper;

  ThemeData get themeData {
    final c = config;
    final brightness = isLightTheme ? Brightness.light : Brightness.dark;
    final roundedShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.accent,
        brightness: brightness,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: c.background,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: c.surface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: roundedShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: roundedShape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: roundedShape),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  ThemeMode get themeMode =>
      isLightTheme ? ThemeMode.light : ThemeMode.dark;

  static const Map<AppTheme, ThemeConfig> themes = {
    // Warm paper theme — like solving on a newspaper/Kindle
    AppTheme.kindlePaper: ThemeConfig(
      name: 'Paper',
      accent: Color(0xFF3C3C3C),       // Dark charcoal ink
      accentDim: Color(0xFF8A8A84),    // Muted gray
      surface: Color(0xFFD5D0C8),      // Warm gray paper
      background: Color(0xFFCCC7BF),   // Muted warm gray — like the mockup
      cellBg: Color(0xFFDAD5CD),       // Slightly lighter for cells
      selectedCell: Color(0xFFC0BAB0),  // Subtle darker highlight
      highlightedRegion: Color(0xFFD0CBC3), // Very subtle tint
      gridBorderThick: Color(0xFF2C2C2C),  // Near-black, like newspaper lines
      gridBorderThin: Color(0xFF706B65),   // Darker — clearly visible cell borders
      fixedText: Color(0xFF1A1A1A),     // Near-black — printed ink
      userText: Color(0xFF4A4A4A),      // Dark gray — pencil marks
      candidateText: Color(0xFF9A9590), // Faded pencil
      errorBg: Color(0x55C0392B),       // Visible red tint for errors
      hintHighlight: Color(0x33558B2F), // Soft green for hints
    ),

    // Inspired by VS Code / Cursor dark themes
    AppTheme.midnightPurple: ThemeConfig(
      name: 'Midnight Purple',
      accent: Color(0xFF7C6BF0),
      accentDim: Color(0xFF3D3578),
      surface: Color(0xFF1A1A2E),
      background: Color(0xFF0D0F1A),
      cellBg: Color(0xFF16182A),
      selectedCell: Color(0xFF2A2550),
      highlightedRegion: Color(0xFF131525),
      gridBorderThick: Color(0xFF7C6BF0),
      gridBorderThin: Color(0xFF2A2A40),
      fixedText: Color(0xFFE0E0E0),
      userText: Color(0xFF7C6BF0),
      candidateText: Color(0xFF6A6A80),
      errorBg: Color(0x33EF5350),
      hintHighlight: Color(0x3381C784),
    ),

    AppTheme.draculaPink: ThemeConfig(
      name: 'Dracula',
      accent: Color(0xFFFF79C6),
      accentDim: Color(0xFF7A3A5E),
      surface: Color(0xFF21222C),
      background: Color(0xFF1A1B26),
      cellBg: Color(0xFF1E1F2B),
      selectedCell: Color(0xFF3A2040),
      highlightedRegion: Color(0xFF1C1D28),
      gridBorderThick: Color(0xFFFF79C6),
      gridBorderThin: Color(0xFF2A2B36),
      fixedText: Color(0xFFF8F8F2),
      userText: Color(0xFFFF79C6),
      candidateText: Color(0xFF6272A4),
      errorBg: Color(0x33FF5555),
      hintHighlight: Color(0x3350FA7B),
    ),

    AppTheme.monokaiGold: ThemeConfig(
      name: 'Monokai Gold',
      accent: Color(0xFFFFD866),
      accentDim: Color(0xFF7A6830),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF0D0D0D),
      cellBg: Color(0xFF181818),
      selectedCell: Color(0xFF2A2500),
      highlightedRegion: Color(0xFF141414),
      gridBorderThick: Color(0xFFFFD866),
      gridBorderThin: Color(0xFF2A2A2A),
      fixedText: Color(0xFFE0E0E0),
      userText: Color(0xFFFFD866),
      candidateText: Color(0xFF707070),
      errorBg: Color(0x33F92672),
      hintHighlight: Color(0x33A6E22E),
    ),

    AppTheme.crimsonNight: ThemeConfig(
      name: 'Crimson Night',
      accent: Color(0xFFEF5350),
      accentDim: Color(0xFF7A2A28),
      surface: Color(0xFF1A1A1A),
      background: Color(0xFF0D0D0D),
      cellBg: Color(0xFF171717),
      selectedCell: Color(0xFF2A1515),
      highlightedRegion: Color(0xFF141212),
      gridBorderThick: Color(0xFFEF5350),
      gridBorderThin: Color(0xFF2A2A2A),
      fixedText: Color(0xFFE0E0E0),
      userText: Color(0xFFEF5350),
      candidateText: Color(0xFF707070),
      errorBg: Color(0x33FF8A80),
      hintHighlight: Color(0x3381C784),
    ),

    AppTheme.mintFresh: ThemeConfig(
      name: 'Mint Fresh',
      accent: Color(0xFF80CBC4),
      accentDim: Color(0xFF3A6360),
      surface: Color(0xFF1A1E1E),
      background: Color(0xFF0D1010),
      cellBg: Color(0xFF151A1A),
      selectedCell: Color(0xFF1A2A28),
      highlightedRegion: Color(0xFF121616),
      gridBorderThick: Color(0xFF80CBC4),
      gridBorderThin: Color(0xFF2A2E2E),
      fixedText: Color(0xFFE0E0E0),
      userText: Color(0xFF80CBC4),
      candidateText: Color(0xFF607070),
      errorBg: Color(0x33EF5350),
      hintHighlight: Color(0x3380CBC4),
    ),

    AppTheme.solarizedAmber: ThemeConfig(
      name: 'Solarized',
      accent: Color(0xFFFFB74D),
      accentDim: Color(0xFF7A5825),
      surface: Color(0xFF1C1C18),
      background: Color(0xFF0D0D0A),
      cellBg: Color(0xFF181815),
      selectedCell: Color(0xFF2A2410),
      highlightedRegion: Color(0xFF141412),
      gridBorderThick: Color(0xFFFFB74D),
      gridBorderThin: Color(0xFF2A2A25),
      fixedText: Color(0xFFE0E0E0),
      userText: Color(0xFFFFB74D),
      candidateText: Color(0xFF707060),
      errorBg: Color(0x33DC322F),
      hintHighlight: Color(0x33859900),
    ),

    AppTheme.oneDarkCyan: ThemeConfig(
      name: 'One Dark',
      accent: Color(0xFF56B6C2),
      accentDim: Color(0xFF2A5860),
      surface: Color(0xFF21252B),
      background: Color(0xFF1B1F23),
      cellBg: Color(0xFF1E2228),
      selectedCell: Color(0xFF1A2830),
      highlightedRegion: Color(0xFF1C2025),
      gridBorderThick: Color(0xFF56B6C2),
      gridBorderThin: Color(0xFF2C3138),
      fixedText: Color(0xFFABB2BF),
      userText: Color(0xFF56B6C2),
      candidateText: Color(0xFF636D7C),
      errorBg: Color(0x33E06C75),
      hintHighlight: Color(0x3398C379),
    ),
  };
}

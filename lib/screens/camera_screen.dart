import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/puzzle_provider.dart';
import '../providers/theme_provider.dart';
import '../services/ocr_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _processing = false;
  bool _picking = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    if (_picking) return;
    _picking = true;

    final picker = ImagePicker();
    final XFile? image;
    try {
      image = await picker.pickImage(source: source);
    } catch (e) {
      _picking = false;
      return;
    }
    _picking = false;

    if (image == null || !mounted) return;

    // Let the user crop to just the grid area for better OCR accuracy.
    final colors = context.read<ThemeProvider>().config;
    final cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop to grid',
          toolbarColor: colors.background,
          toolbarWidgetColor: colors.fixedText,
          activeControlsWidgetColor: colors.accent,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: 'Crop to grid',
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
        ),
      ],
    );

    if (cropped == null || !mounted) return;

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      final board = await OcrService().recognizeFromImage(cropped.path);

      if (!mounted) return;

      if (board != null) {
        // Load in setup mode so user can correct any OCR errors
        final provider = context.read<PuzzleProvider>();
        provider.startSetupMode(fromOcr: true);
        // Pre-fill the board with OCR results
        final grid = board.toGrid();
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            if (grid[r][c] != 0) {
              provider.selectCell(r, c);
              provider.setValue(grid[r][c]);
            }
          }
        }
        provider.clearSelection();
        Navigator.pushReplacementNamed(context, '/puzzle');
      } else {
        setState(() {
          _processing = false;
          _errorMessage =
              'Could not detect a Sudoku puzzle. Try again with a clearer image.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _errorMessage = 'Recognition failed. Try entering the puzzle manually.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().config;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Scan Puzzle',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontFamily: 'Serif',
            color: colors.fixedText,
          ),
        ),
        iconTheme: IconThemeData(color: colors.fixedText),
      ),
      body: _processing
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: colors.accent,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Processing image...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Serif',
                      color: colors.candidateText,
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.document_scanner_rounded,
                      size: 72,
                      color: colors.candidateText,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Take a photo of a Sudoku puzzle\nor pick one from your gallery.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Serif',
                        color: colors.fixedText,
                        height: 1.5,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.fixedText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text(
                          'Take Photo',
                          style: TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.fixedText,
                          foregroundColor: colors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                          color: colors.fixedText,
                        ),
                        label: Text(
                          'Pick from Gallery',
                          style: TextStyle(
                            fontSize: 15,
                            color: colors.fixedText,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.gridBorderThin),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

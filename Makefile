ICLOUD_DIR = $(HOME)/Library/Mobile Documents/com~apple~CloudDocs/SudokuSense

# Build release APK + copy to iCloud
apk:
	flutter build apk --release
	@mkdir -p "$(ICLOUD_DIR)"
	@rm -f "$(ICLOUD_DIR)"/SudokuSense*.apk 2>/dev/null || true
	cp build/app/outputs/flutter-apk/app-release.apk "$(ICLOUD_DIR)/SudokuSense-$(shell date +%Y%m%d-%H%M).apk"
	@echo "APK copied to iCloud"

# Build release iOS
ios:
	flutter build ios --release

.PHONY: apk ios

ICLOUD_DIR = $(HOME)/Library/Mobile Documents/com~apple~CloudDocs/SudokuSense

# Build release APK + copy to iCloud (fixed filename — always latest)
apk:
	flutter build apk --release
	@mkdir -p "$(ICLOUD_DIR)"
	cp build/app/outputs/flutter-apk/app-release.apk "$(ICLOUD_DIR)/SudokuSense.apk"
	@echo "✅ APK copied to iCloud → Files app on your phone"

# Build release iOS
ios:
	flutter build ios --release

.PHONY: apk ios

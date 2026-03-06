# Variables
FLUTTER_DIR = frontend
DEVICE_ID = 39261FDJG000F0

.PHONY: help run-dev run-prod build-prod build-apk clean reverse

# Show help
help:
	@echo "Available commands:"
	@echo "  make run-dev     - Run in development environment (includes adb reverse)"
	@echo "  make run-prod    - Run with production configuration"
	@echo "  make build-prod  - Build production App Bundle (.aab) for Google Play"
	@echo "  make build-apk   - Build production APK (.apk) for direct install"
	@echo "  make reverse     - Setup Android port forwarding (8080)"
	@echo "  make clean       - Clean build artifacts"

# Run in development environment (includes adb reverse)
run-dev: reverse
	cd $(FLUTTER_DIR) && flutter run -d $(DEVICE_ID) -t lib/main_dev.dart

# Run with production configuration
run-prod:
	cd $(FLUTTER_DIR) && flutter run -d $(DEVICE_ID) -t lib/main_prod.dart

# Build production App Bundle (.aab)
build-prod:
	cd $(FLUTTER_DIR) && flutter build appbundle --release -t lib/main_prod.dart

# Build production APK (.apk) for direct install/testing
build-apk:
	cd $(FLUTTER_DIR) && flutter build apk --release -t lib/main_prod.dart

# Android port forwarding
reverse:
	@adb -s $(DEVICE_ID) reverse tcp:8080 tcp:8080 || echo "ADB reverse failed (No device connected?)"

# Clean build artifacts
clean:
	cd $(FLUTTER_DIR) && flutter clean && flutter pub get

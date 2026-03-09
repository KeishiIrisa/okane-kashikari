# Variables
FLUTTER_DIR = frontend
DEVICE_ID = 39261FDJG000F0

.PHONY: help run-dev run-prod build-prod build-apk clean reverse run-server run-server-bg bump-version

# Show help
help:
	@echo "Available commands:"
	@echo "  make run-dev       - Run in development environment (includes adb reverse)"
	@echo "  make run-prod      - Run with production configuration"
	@echo "  make run-server    - Start server with Docker Compose (foreground)"
	@echo "  run-server-bg - Start server with Docker Compose (background)"
	@echo "  db-shell      - Connect to PostgreSQL shell inside Docker"
	@echo "  generate-icons - Generate app icons from assets/icons/app_icon.png"
	@echo "  generate-splash - Generate splash screens from assets/icons/splash_icon.png"
	@echo "  bump-version   - Increment build number (+N) in pubspec.yaml"
	@echo "  build-prod    - Build production App Bundle (.aab) for Google Play"
	@echo "  make build-apk     - Build production APK (.apk) for direct install"
	@echo "  make reverse       - Setup Android port forwarding (8080)"
	@echo "  make clean         - Clean build artifacts"

# Run in development environment (includes adb reverse)
run-dev: reverse
	cd $(FLUTTER_DIR) && flutter run -d $(DEVICE_ID) -t lib/main_dev.dart

# Run with production configuration
run-prod:
	cd $(FLUTTER_DIR) && flutter run -d $(DEVICE_ID) -t lib/main_prod.dart

# Build production App Bundle (.aab)
build-prod:
	cd $(FLUTTER_DIR) && flutter clean && flutter pub get && flutter build appbundle --release -t lib/main_prod.dart

# Build production APK (.apk) for direct install/testing
build-apk:
	cd $(FLUTTER_DIR) && flutter build apk --release -t lib/main_prod.dart

# Android port forwarding
reverse:
	@adb -s $(DEVICE_ID) reverse tcp:8080 tcp:8080 || echo "ADB reverse failed (No device connected?)"

# Start server with Docker Compose (foreground, logs visible)
run-server:
	docker compose up --build

# Start server with Docker Compose (background)
run-server-bg:
	docker compose up --build -d

# Connect to the database shell
db-shell:
	docker compose exec db psql -U postgres -d okane

# Bump build number (+N) in pubspec.yaml
bump-version:
	@CURRENT=$$(grep '^version:' $(FLUTTER_DIR)/pubspec.yaml | sed 's/version: //'); \
	NAME=$$(echo $$CURRENT | cut -d'+' -f1); \
	BUILD=$$(echo $$CURRENT | cut -d'+' -f2); \
	NEXT=$$((BUILD + 1)); \
	NEW="$$NAME+$$NEXT"; \
	sed -i '' "s/^version: .*/version: $$NEW/" $(FLUTTER_DIR)/pubspec.yaml; \
	echo "version: $$CURRENT → $$NEW"

# Generate App Icons
generate-icons:
	cd $(FLUTTER_DIR) && dart run flutter_launcher_icons

# Generate Splash Screens
generate-splash:
	cd $(FLUTTER_DIR) && dart run flutter_native_splash:create

# Clean build artifacts
clean:
	cd $(FLUTTER_DIR) && flutter clean && flutter pub get

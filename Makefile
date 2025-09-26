# Cursor Remote Control - Makefile
# This Makefile helps install and manage the Cursor Remote Control CLI tool

.PHONY: help install uninstall build test clean dev remoteme start stop restart status

# Default target
help:
	@echo "Cursor Remote Control - Available commands:"
	@echo ""
	@echo "  make remoteme    - Build the Flutter app and prepare system"
	@echo "  make remoteme serve - Start the server (remoteme serve)"
	@echo "  make start       - Start the server only"
	@echo "  make stop        - Stop the server"
	@echo "  make restart     - Restart the server"
	@echo "  make build       - Build the Flutter app"
	@echo "  make install     - Install the CLI tool globally"
	@echo "  make uninstall   - Remove the CLI tool from global installation"
	@echo "  make test        - Test the installation"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make status      - Show system status"
	@echo "  make help        - Show this help message"
	@echo ""
	@echo "Quick start:"
	@echo "  make remoteme    # Start everything and build Flutter app"

# Install the CLI tool globally
install:
	@echo "🔧 Installing Remoteme CLI globally..."
	cd server && npm install
	cd server && sudo npm link
	@echo "✅ Installation complete!"
	@echo ""
	@echo "Usage:"
	@echo "  remoteme serve                    # Start server in current directory"
	@echo "  remoteme serve --port=8080        # Start on custom port"
	@echo "  remoteme --help                   # Show help"

# Uninstall the CLI tool
uninstall:
	@echo "🗑️  Uninstalling Remoteme CLI..."
	sudo npm unlink -g remoteme
	@echo "✅ Uninstallation complete!"

# Build the Flutter app
build:
	@echo "📱 Building Flutter app..."
	cd cursor_remote_app && fvm flutter build apk --debug
	@echo "✅ Flutter app built successfully!"

# Start development server
dev:
	@echo "🚀 Starting development server..."
	cd server && npm run dev

# Test the installation
test:
	@echo "🧪 Testing installation..."
	@which remoteme || (echo "❌ remoteme not found in PATH" && exit 1)
	@echo "✅ remoteme found in PATH"
	@remoteme --help > /dev/null && echo "✅ CLI help command works" || (echo "❌ CLI help command failed" && exit 1)
	@echo "✅ Installation test passed!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cd cursor_remote_app && fvm flutter clean
	cd server && rm -rf node_modules package-lock.json
	@echo "✅ Clean complete!"

# Install Flutter dependencies
flutter-deps:
	@echo "📱 Installing Flutter dependencies..."
	cd cursor_remote_app && fvm flutter pub get
	@echo "✅ Flutter dependencies installed!"

# Install server dependencies
server-deps:
	@echo "🔧 Installing server dependencies..."
	cd server && npm install
	@echo "✅ Server dependencies installed!"

# Full setup (install everything)
setup: server-deps flutter-deps install
	@echo "🎉 Full setup complete!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Build the Flutter app: make build"
	@echo "2. Install on your device: make install-device"
	@echo "3. Start the server: cursor-remote serve"

# Install Flutter app on connected device
install-device:
	@echo "📱 Installing Flutter app on connected device..."
	@which fvm > /dev/null || (echo "❌ FVM not found. Please install FVM first." && exit 1)
	cd cursor_remote_app && fvm flutter run
	@echo "✅ Flutter app installed on device!"

# Show current status
status:
	@echo "📊 Cursor Remote Control Status:"
	@echo ""
	@echo "CLI Tool:"
	@which remoteme > /dev/null && echo "✅ remoteme installed globally" || echo "❌ remoteme not installed"
	@echo ""
	@echo "Flutter App:"
	@cd cursor_remote_app && fvm flutter doctor --version > /dev/null 2>&1 && echo "✅ Flutter environment ready" || echo "❌ Flutter environment not ready"
	@echo ""
	@echo "Server Dependencies:"
	@cd server && [ -d "node_modules" ] && echo "✅ Server dependencies installed" || echo "❌ Server dependencies not installed"
	@echo ""
	@echo "Server Status:"
	@pgrep -f "node.*index.js" > /dev/null && echo "✅ Server is running" || echo "❌ Server is not running"
	@echo ""
	@echo "Connected Devices:"
	@adb devices | grep -v "List of devices" | grep -v "^$$" | wc -l | xargs -I {} echo "📱 {} device(s) connected"

# Main command - start everything
remoteme: build
	@echo "🎉 Remote Cursor system is ready!"
	@echo ""
	@echo "📱 Flutter app built and ready"
	@echo "🔗 Connect your Flutter app to: http://YOUR_IP:3000"
	@echo ""
	@echo "To start server: make remoteme serve"
	@echo "To install on device: make install-device"

# Start the server
remoteme serve:
	@echo "🚀 Starting Cursor Remote Control server..."
	@pgrep -f "node.*index.js" > /dev/null && echo "⚠️  Server already running" || (cd server && remoteme serve)
	@echo "✅ Server started on port 3000"

# Start the server (alias)
start: remoteme serve

# Stop the server
stop:
	@echo "🛑 Stopping Cursor Remote Control server..."
	@pkill -f "node.*index.js" && echo "✅ Server stopped" || echo "⚠️  No server running"

# Restart the server
restart: stop start
	@echo "🔄 Server restarted"

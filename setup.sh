#!/bin/bash
# Setup script: creates Flutter project structure and copies source files

echo "=== Logical Trap - Flutter Setup ==="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found! Please install Flutter SDK first."
    echo "   Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"

# Create temp Flutter project
TEMP_DIR=$(mktemp -d)
echo "📁 Creating temp project in $TEMP_DIR..."

flutter create --org com.logicaltrap --project-name logical_trap_game "$TEMP_DIR/logical_trap_temp"

echo "✅ Flutter project created"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"

# Copy our source files
echo "📁 Copying source files..."
cp -r "$PROJECT_DIR/lib/"* "$TEMP_DIR/logical_trap_temp/lib/"
cp "$PROJECT_DIR/pubspec.yaml" "$TEMP_DIR/logical_trap_temp/"
if [ -d "$PROJECT_DIR/assets" ]; then
    cp -r "$PROJECT_DIR/assets" "$TEMP_DIR/logical_trap_temp/"
fi

echo "✅ Source files copied"

# Move temp project to current directory
echo "📁 Moving project to $PROJECT_DIR..."
rm -rf "$PROJECT_DIR/android" "$PROJECT_DIR/ios" "$PROJECT_DIR/test" "$PROJECT_DIR/.dart_tool" "$PROJECT_DIR/.flutter-plugins" "$PROJECT_DIR/*.iml" 2>/dev/null || true

cp -r "$TEMP_DIR/logical_trap_temp/"* "$PROJECT_DIR/"
cp -r "$TEMP_DIR/logical_trap_temp/".[!.]* "$PROJECT_DIR/" 2>/dev/null || true

# Clean up
rm -rf "$TEMP_DIR"

echo "✅ Project structure ready!"

# Get dependencies
cd "$PROJECT_DIR"
flutter pub get

echo ""
echo "=== Setup Complete! ==="
echo "Run 'cd $PROJECT_DIR && flutter run' to test"
echo "Run 'flutter build apk' to build APK"

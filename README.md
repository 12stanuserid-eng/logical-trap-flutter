# Logical Trap - Flutter Edition 🧩

A Brain Test style tricky puzzle game built with Flutter.

## Features
- 🧠 49 tricky puzzles (lateral thinking, math, word, logic, observation)
- 🎨 Interactive visual scenes with emoji, shapes, and animations
- 🔄 Tap-correct, tap-count interactions
- 🌐 Bilingual (English + Hindi)
- 💡 Hint system
- ❤️ Lives system with streak bonuses

## Setup & Run

```bash
# Clone the repo
git clone https://github.com/12stanuserid-eng/logical-trap-game.git
cd logical-trap-game

# Run setup (generates android/ios platform files)
chmod +x setup.sh
./setup.sh

# Or manually:
flutter create --org com.logicaltrap --project-name logical_trap_game .
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
# APK at: build/app/outputs/flutter-apk/app-release.apk
```

## Play Store Release
1. Generate a keystore: `keytool -genkey -v -keystore upload-keystore.jks ...`
2. Create `android/key.properties` with keystore details
3. Build release: `flutter build appbundle`
4. Upload to Play Console

# Rangers of Shadow Deep — Companion App

A companion app for [Rangers of Shadow Deep](https://onepage_rules.com/collections/rangers-of-shadow-deep), a solo/co-op tabletop miniatures game. Manage your rangers, track companions, record sessions, and browse rules reference — all from your phone.

## Features

- **Rangers** — Create and manage rangers with stat allocation, equipment, skills, and heroic abilities
- **Companions** — Recruit, level up, and track progression for companion types (Knight, Rogue, Hound, etc.)
- **Sessions** — Set up missions, record in-game events (kills, injuries, loot), and run post-game wrap-up
- **Reference** — Browse rules, spells, skills, magic items, treasure tables, and more with search
- **Settings** — Light/dark/system theme, data backup/restore

## Tech Stack

| Layer | Choice |
|-------|--------|
| UI | Material 3, `go_router` |
| State | Riverpod (`flutter_riverpod` + code generation) |
| Database | Drift (SQLite) |
| Serialization | Freezed + `json_serializable` |
| Fonts | Google Fonts |

## Prerequisites

- Flutter SDK 3.44+
- Android SDK (API 36 for emulator)
- Java 21+

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation (Drift, Freezed, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Launch on connected device/emulator
flutter run
```

### Using the dev scripts

Two convenience scripts run the app inside a Podman container with an Android emulator:

```bash
# One-shot: starts emulator, runs app, exits
./scripts/dev.sh

# Compose-based: keeps container running
./scripts/dev-compose.sh
```

Both scripts require KVM access (`/dev/kvm`) and an X11 socket for the emulator GUI.

## Project Structure

```
lib/
├── app.dart                    # MaterialApp.router setup
├── main.dart                   # Entry point
├── router.dart                 # GoRouter configuration
├── data/
│   ├── database/               # Drift database, tables, providers
│   ├── repositories/           # Data access layer
│   └── services/               # Backup, post-game logic, rules reference
├── domain/
│   └── constants/              # Game data (stats, equipment, spells, tables)
└── ui/
    ├── core/                   # Theme, navigation, shared widgets
    └── features/
        ├── companions/         # Companion management
        ├── rangers/            # Ranger creation wizard & detail
        ├── reference/          # Rules browser with search
        ├── session/            # Mission tracking & post-game
        └── settings/           # App settings
```

## Building

### Direct (Flutter installed locally)

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

### Via Podman container

The project includes a `flutter-dev` container for environments without a local Flutter SDK. Use these scripts or the equivalent `podman` commands:

```bash
# Build APK
./scripts/build-apk.sh

# Build App Bundle
./scripts/build-aab.sh
```

These scripts mount the project and a persistent pub cache volume into the `flutter-dev` container, then run the equivalent `flutter build` commands. APK/AAB output lands in `build/app/outputs/flutter-apk/` or `build/app/outputs/bundle/` respectively.

## License

Private — not affiliated with One Page Rules.

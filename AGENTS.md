# AGENTS.md

## Flutter Dev Environment

Flutter is **not installed locally**. All Flutter commands must be run via a **Podman container**.

### Container Details
- **Image**: `firechain-flutter-dev` (locally built)
- **Flutter version**: 3.44.4
- **Android SDK**: API 36
- **Java**: OpenJDK 21

### Running Flutter Commands

Use this pattern for any `flutter` or `dart` command:

```bash
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  firechain-flutter-dev \
  flutter <command>
```

Replace `flutter <command>` with `dart <command>` for Dart-only operations.

### Common Commands

```bash
# Create project (run from /home/bigbrotha/Projects/mobile/)
podman run --rm \
  -v /home/bigbrotha/Projects/mobile:/workspace \
  -w /workspace \
  --entrypoint="" \
  -v pub-cache:/root/.pub-cache \
  firechain-flutter-dev \
  flutter create rangers_mobile

# Install dependencies
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  firechain-flutter-dev \
  flutter pub get

# Run code generation (freezed, drift, etc.)
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  firechain-flutter-dev \
  dart run build_runner build --delete-conflicting-outputs

# Analyze
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  firechain-flutter-dev \
  flutter analyze
```

### Notes
- The `pub-cache` volume persists packages across container runs
- The container is ephemeral (`--rm` flag) — no need to manage container lifecycle
- All file changes happen on the host filesystem via the bind mount
- If the container image needs rebuilding: `podman build -t firechain-flutter-dev .` from `/home/bigbrotha/Projects/mobile/`

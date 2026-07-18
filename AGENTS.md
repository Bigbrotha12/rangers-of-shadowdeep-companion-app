# AGENTS.md

## Flutter Dev Environment

Flutter is **not installed locally**. All Flutter commands must be run via a **Podman container**.

### Container Details
- **Image**: `flutter-dev` (locally built)
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
  flutter-dev \
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
  flutter-dev \
  flutter create rangers_mobile

# Install dependencies
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  flutter-dev \
  flutter pub get

# Run code generation (freezed, drift, etc.)
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  flutter-dev \
  dart run build_runner build --delete-conflicting-outputs

# Analyze
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  flutter-dev \
  flutter analyze

# Run tests
podman run --rm \
  -v /home/bigbrotha/Projects/mobile/rangers-mobile:/workspace/rangers-mobile \
  -w /workspace/rangers-mobile \
  -v pub-cache:/root/.pub-cache \
  --entrypoint="" \
  flutter-dev \
  flutter test
```

### Notes
- The `pub-cache` volume persists packages across container runs
- The container is ephemeral (`--rm` flag) — no need to manage container lifecycle
- All file changes happen on the host filesystem via the bind mount
- If the container image needs rebuilding: `podman build -t flutter-dev .` from `/home/bigbrotha/Projects/mobile/`

### Direct Flutter (no container)

Flutter is also available directly on the host at `/home/bigbrotha/Projects/flutter/bin/flutter`.

When running tests directly (not via the Podman container), the system is missing `libsqlite3.so` (only `libsqlite3.so.0` is installed). To work around this, set `LD_LIBRARY_PATH` before running `flutter test`:

```bash
# Run all tests (direct, no container)
LD_LIBRARY_PATH=/tmp/opencode/lib:$LD_LIBRARY_PATH flutter test
```

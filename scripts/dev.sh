#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
IMAGE="${FLUTTER_DEV_IMAGE:-firechain-flutter-dev}"
PUB_CACHE_VOLUME="${PUB_CACHE_VOLUME:-pub-cache}"

# Start emulator + flutter run inside the container
# Mounts X11 socket for emulator GUI, KVM for acceleration, and port 5555 for ADB
exec podman run --rm \
  -v "$PROJECT_DIR:/workspace/$PROJECT_NAME" \
  -w "/workspace/$PROJECT_NAME" \
  -v "$PUB_CACHE_VOLUME:/root/.pub-cache" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY="${DISPLAY:-:0}" \
  --device /dev/kvm:/dev/kvm \
  --privileged \
  -p 5555:5555 \
  --entrypoint="" \
  "$IMAGE" \
  bash -c '
    set -e
    echo "=== Starting emulator ==="
    start-emulator 2>/dev/null || {
      echo "start-emulator not found, starting manually..."
      if adb get-state 2>/dev/null | grep -q device; then
        echo "Emulator already running."
      else
        nohup emulator -avd pixel -no-audio -no-boot-anim -no-window \
          -gpu swiftshader_indirect -port 5554 \
          >/tmp/emulator.log 2>&1 &
        echo "Waiting for device..."
        adb wait-for-device
        while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '"'"'\r'"'"')" != "1" ]; do
          sleep 2
        done
        echo "Emulator ready!"
      fi
    }
    flutter pub get
    echo ""
    echo "=== Running app on emulator ==="
    flutter run "$@"
  ' -- "$@"
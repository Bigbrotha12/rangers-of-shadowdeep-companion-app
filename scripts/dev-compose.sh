#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PARENT_DIR="$(dirname "$PROJECT_DIR")"
COMPOSE_FILE="$PARENT_DIR/docker-compose.yaml"
SERVICE_NAME="flutter-dev"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Error: docker-compose.yaml not found at $COMPOSE_FILE"
  echo "Run this script from within the project directory structure."
  exit 1
fi

# Check KVM availability
if [ ! -c /dev/kvm ] && [ ! -w /dev/kvm ]; then
  echo "Warning: /dev/kvm not available. Emulator will be slow without hardware acceleration."
  echo "  On Linux: sudo usermod -aG kvm \$USER && sudo chmod 666 /dev/kvm"
fi

# Allow root in the container to connect to the host X server
xhost +SI:localuser:root 2>/dev/null || true

# Start container in background (if not already running)
if ! podman ps --format '{{.Names}}' 2>/dev/null | grep -q "^${SERVICE_NAME}$"; then
  echo "=== Starting flutter-dev container ==="
  podman-compose -f "$COMPOSE_FILE" up -d
fi

# Start emulator and run app in a single session
echo "=== Starting emulator (pixel, API 36) ==="
podman exec -it -w "/workspace/$PROJECT_NAME" "$SERVICE_NAME" bash -c '
  set -e

  TIMEOUT_DEVICE=120
  TIMEOUT_BOOT=1800

  if ! adb get-state 2>/dev/null | grep -q device; then
    # Create AVD if it does not exist
    if ! avdmanager list avd -c 2>/dev/null | grep -q pixel; then
      echo "Creating AVD (pixel, API 36)..."
      echo no | avdmanager create avd -n pixel \
        -k "system-images;android-36;google_apis;x86_64" \
        --device "pixel_6" --force
    fi

    # Ensure ADB server is running and flush stale state
    adb start-server 2>/dev/null || true
    adb devices -l 2>/dev/null > /dev/null

    # Start emulator in background
    nohup emulator -avd pixel -no-audio -no-boot-anim \
      -gpu swiftshader_indirect \
      -port 5554 \
      >/tmp/emulator.log 2>&1 &
    EMULATOR_PID=$!

    echo "Waiting for device (timeout: ${TIMEOUT_DEVICE}s)..."
    for i in $(seq 1 $TIMEOUT_DEVICE); do
      if ! kill -0 $EMULATOR_PID 2>/dev/null; then
        echo "ERROR: Emulator process died. Last log lines:"
        tail -20 /tmp/emulator.log
        exit 1
      fi
      if adb get-state 2>/dev/null | grep -q device; then
        echo "Device found!"
        break
      fi
      sleep 1
    done
    if ! adb get-state 2>/dev/null | grep -q device; then
      echo "Timed out waiting for device (${TIMEOUT_DEVICE}s). Emulator log:"
      tail -30 /tmp/emulator.log
      exit 1
    fi

    echo "Waiting for boot to complete (timeout: ${TIMEOUT_BOOT}s)..."
    echo "  (without KVM acceleration, this can take 10-30 minutes)"
    for i in $(seq 1 $TIMEOUT_BOOT); do
      if ! kill -0 $EMULATOR_PID 2>/dev/null; then
        echo "ERROR: Emulator process died during boot. Last log lines:"
        tail -20 /tmp/emulator.log
        exit 1
      fi
      status=$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d "\r")
      if [ "$status" = "1" ]; then
        echo "Emulator ready!"
        break
      fi
      if [ $((i % 15)) -eq 0 ]; then
        bootanim=$(adb shell getprop init.svc.bootanim 2>/dev/null | tr -d "\r")
        elapsed=$((i * 2))
        echo "  [${elapsed}s] Still booting... (bootanim=$bootanim)"
      fi
      sleep 2
    done
    if [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d "\r")" != "1" ]; then
      echo "Timed out waiting for boot. Emulator log:"
      tail -30 /tmp/emulator.log
      exit 1
    fi
  fi

  echo "=== Running app on emulator ==="
  flutter run "$@"
'

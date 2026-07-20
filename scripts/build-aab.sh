#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
IMAGE="${FLUTTER_DEV_IMAGE:-flutter-dev}"
PUB_CACHE_VOLUME="${PUB_CACHE_VOLUME:-pub-cache}"

exec podman run --rm \
  -v "$PROJECT_DIR:/workspace/$PROJECT_NAME" \
  -w "/workspace/$PROJECT_NAME" \
  -v "$PUB_CACHE_VOLUME:/root/.pub-cache" \
  --entrypoint="" \
  "$IMAGE" \
  flutter build appbundle --release "$@"

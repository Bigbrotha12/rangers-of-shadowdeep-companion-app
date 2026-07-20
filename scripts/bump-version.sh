#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC="$PROJECT_DIR/pubspec.yaml"
VERSION_FILE="$PROJECT_DIR/lib/version.dart"

VERSION_REGEX='^[0-9]+\.[0-9]+\.[0-9]+$'

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  echo "  version: semver string (e.g., 1.2.3)" >&2
  exit 1
fi

NEW_VERSION="$1"

if [[ ! "$NEW_VERSION" =~ $VERSION_REGEX ]]; then
  echo "Error: '$NEW_VERSION' is not a valid semver (expected X.Y.Z)" >&2
  exit 1
fi

# Extract current build number (+N) from pubspec.yaml, default to +1
CURRENT_VERSION_LINE=$(grep '^version:' "$PUBSPEC")
BUILD_NUMBER=$(echo "$CURRENT_VERSION_LINE" | sed -n 's/.*+\([0-9]*\).*/\1/p')
BUILD_NUMBER="${BUILD_NUMBER:-1}"

# Update pubspec.yaml
sed -i "s/^version: .*/version: $NEW_VERSION+$BUILD_NUMBER # Sync with lib\/version.dart/" "$PUBSPEC"

# Update lib/version.dart
sed -i "s/^const String appVersion = '.*';/const String appVersion = '$NEW_VERSION';/" "$VERSION_FILE"

echo "Updated version to $NEW_VERSION+$BUILD_NUMBER"

# Commit, tag, and release
cd "$PROJECT_DIR"

git add "$PUBSPEC" "$VERSION_FILE"
git commit -m "chore: bump version to $NEW_VERSION"

TAG="v$NEW_VERSION"
git tag "$TAG"

git push origin main
git push origin "$TAG"

gh release create "$TAG" \
  --title "$TAG" \
  --notes "Version $NEW_VERSION" \
  --generate-notes

echo "GitHub release $TAG created"

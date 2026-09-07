#!/usr/bin/env bash
set -Eeuo pipefail

TARGET_DIR="${TARGET_DIR:-/config/music_assistant/custom_components/hallow}"
REPO_URL="${REPO_URL:-https://github.com/your-user/hallow-music-assistant-provider.git}"
BRANCH="${BRANCH:-main}"
AUTO_UPDATE="${AUTO_UPDATE:-true}"
SOURCE_DIR="${SOURCE_DIR:-}"
VERSION_FILE="${TARGET_DIR}/.hallow_version"
TMP_DIR="/tmp/hallow-provider"

mkdir -p "$(dirname "$TARGET_DIR")"

install_from_repo() {
  rm -rf "$TMP_DIR"
  git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR"

  if [ ! -d "$TMP_DIR/hallow" ]; then
    echo "Repository does not contain the expected hallow/ directory"
    exit 1
  fi

  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  cp -a "$TMP_DIR/hallow/." "$TARGET_DIR/"

  echo "${BRANCH}" > "$VERSION_FILE"
  echo "Installed Hallow provider from git repo: $REPO_URL"
}

if [ -n "$SOURCE_DIR" ] && [ -d "$SOURCE_DIR" ]; then
  echo "Installing provider from local source directory: $SOURCE_DIR"
  rm -rf "$TARGET_DIR"
  mkdir -p "$TARGET_DIR"
  cp -a "$SOURCE_DIR/." "$TARGET_DIR/"
  echo "local" > "$VERSION_FILE"
  exit 0
fi

if [ -d "$TARGET_DIR" ] && [ -f "$TARGET_DIR/manifest.json" ]; then
  echo "Provider already installed at $TARGET_DIR"
  if [ "$AUTO_UPDATE" = "true" ] && [ -n "$REPO_URL" ]; then
    echo "Checking for update..."
    if git ls-remote --exit-code "$REPO_URL" >/dev/null 2>&1; then
      install_from_repo
    fi
  fi
  exit 0
fi

install_from_repo

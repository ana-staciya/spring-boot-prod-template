#!/usr/bin/env sh
set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROPS_FILE="$SCRIPT_DIR/gradle/wrapper/gradle-wrapper.properties"

if [ ! -f "$PROPS_FILE" ]; then
  echo "Missing $PROPS_FILE"
  exit 1
fi

DIST_URL=$(sed -n 's/^distributionUrl=//p' "$PROPS_FILE")
DIST_URL=$(printf '%s' "$DIST_URL" | sed 's/\\:/:/g')

if [ -z "$DIST_URL" ]; then
  echo "distributionUrl is not set in $PROPS_FILE"
  exit 1
fi

DIST_ZIP=$(basename "$DIST_URL")
DIST_BASE="${DIST_ZIP%.zip}"
DIST_ROOT="$DIST_BASE"

case "$DIST_ROOT" in
  *-bin) DIST_ROOT="${DIST_ROOT%-bin}" ;;
  *-all) DIST_ROOT="${DIST_ROOT%-all}" ;;
esac

GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"
DIST_DIR="$GRADLE_USER_HOME/wrapper/dists/$DIST_BASE"
ZIP_PATH="$DIST_DIR/$DIST_ZIP"
GRADLE_HOME="$DIST_DIR/$DIST_ROOT"

download_dist() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$DIST_URL" -o "$ZIP_PATH"
    return
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -q "$DIST_URL" -O "$ZIP_PATH"
    return
  fi
  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "Invoke-WebRequest -Uri '$DIST_URL' -OutFile '$ZIP_PATH'"
    return
  fi
  echo "No downloader found (curl, wget, or powershell)."
  exit 1
}

extract_dist() {
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$ZIP_PATH" -d "$DIST_DIR"
    return
  fi
  if command -v python >/dev/null 2>&1; then
    python - "$ZIP_PATH" "$DIST_DIR" <<'PY'
import sys
import zipfile

zip_path, dest_dir = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(zip_path, "r") as zip_ref:
    zip_ref.extractall(dest_dir)
PY
    return
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$ZIP_PATH" "$DIST_DIR" <<'PY'
import sys
import zipfile

zip_path, dest_dir = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(zip_path, "r") as zip_ref:
    zip_ref.extractall(dest_dir)
PY
    return
  fi
  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "Expand-Archive -Path '$ZIP_PATH' -DestinationPath '$DIST_DIR' -Force"
    return
  fi
  echo "No unzip tool found (unzip, python, or powershell)."
  exit 1
}

if [ ! -x "$GRADLE_HOME/bin/gradle" ]; then
  mkdir -p "$DIST_DIR"
  if [ ! -f "$ZIP_PATH" ]; then
    echo "Downloading Gradle from $DIST_URL"
    download_dist
  fi
  extract_dist
fi

exec "$GRADLE_HOME/bin/gradle" "$@"

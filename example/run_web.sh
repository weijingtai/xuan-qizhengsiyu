#!/usr/bin/env bash
# Launch the example app in Chrome with a persistent user-data-dir.
# This ensures OPFS/IndexedDB storage survives browser restarts,
# so API keys and other user data are retained.
#
# Usage:
#   ./run_web.sh                  # default port 7357
#   ./run_web.sh 8080             # custom port

set -euo pipefail

PORT="${1:-7357}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_DIR="$SCRIPT_DIR/.chrome-profile"

cd "$SCRIPT_DIR"

flutter run -d chrome \
  --web-port="$PORT" \
  --web-browser-flag="--user-data-dir=$PROFILE_DIR" \
  --web-browser-flag="--disable-web-security"

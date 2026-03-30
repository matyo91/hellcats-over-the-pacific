#!/bin/sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
export HOME="$PROJECT_DIR/.godot-home"
mkdir -p "$HOME"

exec /Applications/Godot.app/Contents/MacOS/Godot \
	--headless \
	--path "$PROJECT_DIR" \
	--script hellcats/tests/test_rng.gd

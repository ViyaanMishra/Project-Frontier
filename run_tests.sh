#!/usr/bin/env bash
# Run Project Frontier headless tests.
# This script imports the project (generating .godot cache) and then runs tests.

set -e

if ! command -v godot &> /dev/null; then
    echo "Godot not found on PATH. Please install Godot 4.4.1 stable."
    exit 1
fi

godot --headless --editor --quit
godot --headless src/tests/test_scene.tscn

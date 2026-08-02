#!/usr/bin/env bash
set -uo pipefail

# Spin up virtual X11 framebuffer in the background
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=$!
sleep 2

# Create a temporary log file to intercept output streams
LOG_FILE=$(mktemp)

# Run the test command, streaming to console AND saving to log file
echo "Starting GameMaker headless test suite..."
set +e
npx @gamemaker/gm-cli@latest run 2>&1 | tee "$LOG_FILE"
TEST_EXIT_CODE=${PIPESTATUS[0]}
set -e

# Clean up Xvfb background process right away
kill "$XVFB_PID" 2>/dev/null || true

# Check if the game logged an internal failure code (e.g. ###game_end###1)
# We use || true so grep's exit code 1 (no match) doesn't trip set -e
if grep -q "###game_end###[1-9]" "$LOG_FILE" || true; then
    if grep -q "###game_end###[1-9]" "$LOG_FILE"; then
        echo "=========================================="
        echo "ERROR: GameMaker internal test failure detected!"
        echo "=========================================="
        rm -f "$LOG_FILE"
        exit 1
    fi
fi

# If CLI wrapper failed, exit with that code
if [ "$TEST_EXIT_CODE" -ne 0 ]; then
    echo "=========================================="
    echo "ERROR: gm-cli exited with code $TEST_EXIT_CODE"
    echo "=========================================="
    rm -f "$LOG_FILE"
    exit "$TEST_EXIT_CODE"
fi

rm -f "$LOG_FILE"
exit 0
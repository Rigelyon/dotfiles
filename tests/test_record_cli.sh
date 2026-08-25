#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../hypr/.config/hypr/scripts" && pwd)"
RECORD_SCRIPT="$SCRIPT_DIR/record.sh"

echo "Running record.sh CLI tests..."

# Test 1: Bash syntax check
bash -n "$RECORD_SCRIPT"
echo "✓ Syntax check passed"

# Test 2: Help flag
output=$("$RECORD_SCRIPT" --help)
if [[ "$output" != *"Usage:"* ]] || [[ "$output" != *"GPU Screen Recorder"* ]]; then
    echo "✗ Failed: --help output did not match expected usage"
    echo "Output was: $output"
    exit 1
fi
echo "✓ Help output passed"

# Test 3: Status flag when idle
status_output=$("$RECORD_SCRIPT" --status || true)
if [[ "$status_output" != "idle" ]]; then
    echo "✗ Failed: expected idle status, got: $status_output"
    exit 1
fi
echo "✓ Status output passed"

# Test 4: Invalid option handling
set +e
invalid_output=$("$RECORD_SCRIPT" --invalid-flag 2>&1)
exit_code=$?
set -e
if [[ $exit_code -eq 0 ]] || [[ "$invalid_output" != *"Unknown option"* ]]; then
    echo "✗ Failed: invalid option should exit with error"
    exit 1
fi
echo "✓ Invalid flag handling passed"

# Test 5: Stop when not running returns non-zero / idle
set +e
"$RECORD_SCRIPT" --stop >/dev/null 2>&1
stop_exit=$?
set -e
if [[ $stop_exit -eq 0 ]]; then
    echo "✗ Failed: stopping when no recording is active should return 1"
    exit 1
fi
echo "✓ Stop on idle passed"

echo "All record.sh CLI tests passed successfully!"

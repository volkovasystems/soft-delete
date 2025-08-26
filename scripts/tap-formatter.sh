#!/usr/bin/env bash

# tap-formatter.sh - Enhanced TAP output formatter for BATS
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

set -euo pipefail

# TAP version
echo "TAP version 14"

# Process BATS output and format as TAP
test_count=0
pass_count=0
fail_count=0
skip_count=0

while IFS= read -r line; do
    case "$line" in
        "✓ "*)
            ((test_count++))
            ((pass_count++))
            test_name="${line#✓ }"
            echo "ok $test_count - $test_name"
            ;;
        "✗ "*)
            ((test_count++))
            ((fail_count++))
            test_name="${line#✗ }"
            echo "not ok $test_count - $test_name"
            ;;
        "- "*)
            ((test_count++))
            ((skip_count++))
            test_name="${line#- }"
            echo "ok $test_count - $test_name # SKIP"
            ;;
        \#*)
            # Pass through comments as diagnostics
            echo "$line"
            ;;
        *)
            # Other output as diagnostics
            if [[ -n "$line" ]]; then
                echo "# $line"
            fi
            ;;
    esac
done

# Print test plan
echo "1..$test_count"

# Add summary as diagnostics
echo "# Test Summary:"
echo "# Total: $test_count"
echo "# Passed: $pass_count"
echo "# Failed: $fail_count"
echo "# Skipped: $skip_count"

# Exit with failure if any tests failed
exit $fail_count

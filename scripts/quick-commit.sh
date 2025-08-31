#!/usr/bin/env bash
#
# quick-commit.sh - Helper script for continuous commit protocol
# 
# Part of the soft-delete project
# Follows the continuous commit protocol defined in .warp/protocols/continuous-commit-protocol.md

# Enable strict mode
set -euo pipefail

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Find VERSION file
if [[ -f "$SCRIPT_DIR/../VERSION" ]]; then
    VERSION_FILE="$SCRIPT_DIR/../VERSION"
else
    VERSION_FILE=""
fi
readonly VERSION_FILE

# Read version from VERSION file
if [[ -f "$VERSION_FILE" ]]; then
    VERSION=$(tr -d '\n\r' < "$VERSION_FILE" | tr -d ' ')
else
    VERSION="0.0.0"  # Fallback version
fi
readonly VERSION

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <action> <component> [description]

Helper for continuous commit protocol that ensures immediate commits with
descriptive WIP (Work in Progress) prefixes.

OPTIONS:
    -h, --help      Show this help message and exit
    -a, --all       Add all changes (git add .)
    -c, --checkpoint Use checkpoint prefix instead of WIP
    -t, --test      Commit test results (use test prefix)
    -f, --files     Only add specific files (space separated, wrapped in quotes)

ARGUMENTS:
    action          What you're doing (implement, fix, update, etc.)
    component       What you're working on (parser, validation, etc.)
    description     Optional detailed description

EXAMPLES:
    $(basename "$0") implement validation "add email format checks"
    $(basename "$0") -c "core functionality complete and tested"
    $(basename "$0") -t "all tests passing (45/45)"
    $(basename "$0") -f "file1.sh file2.sh" fix parser "handle edge cases"

COMMIT MESSAGE FORMATS:
    WIP:         "WIP: <action> <component> - <description>"
    Checkpoint:  "checkpoint: <description>"
    Test:        "test: <description>"

EXIT STATUS:
    0    Success - commit was created
    1    Error - invalid arguments or git operation failed
EOF
}

# Default options
ADD_ALL=true
PREFIX="WIP"
FILES=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -a|--all)
            ADD_ALL=true
            shift
            ;;
        -c|--checkpoint)
            PREFIX="checkpoint"
            shift
            ;;
        -t|--test)
            PREFIX="test"
            shift
            ;;
        -f|--files)
            ADD_ALL=false
            FILES="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Get action, component, and description
ACTION="${1:-}"
COMPONENT="${2:-}"
DESCRIPTION="${3:-}"

# For checkpoint and test prefixes, combine all arguments
if [[ "$PREFIX" == "checkpoint" || "$PREFIX" == "test" ]]; then
    # If checkpoint or test, use a single message
    if [[ -n "$ACTION" ]]; then
        MESSAGE="$ACTION"
        if [[ -n "$COMPONENT" ]]; then
            MESSAGE="$MESSAGE $COMPONENT"
            if [[ -n "$DESCRIPTION" ]]; then
                MESSAGE="$MESSAGE $DESCRIPTION"
            fi
        fi
    else
        echo "Error: Missing message for $PREFIX commit" >&2
        usage
        exit 1
    fi
else
    # For WIP commits, require action and component
    if [[ -z "$ACTION" || -z "$COMPONENT" ]]; then
        echo "Error: For WIP commits, both action and component are required" >&2
        usage
        exit 1
    fi
    
    # Format the message
    if [[ -n "$DESCRIPTION" ]]; then
        MESSAGE="$ACTION $COMPONENT - $DESCRIPTION"
    else
        MESSAGE="$ACTION $COMPONENT"
    fi
fi

# Add files to staging
if [[ "$ADD_ALL" == true ]]; then
    git add .
else
    # shellcheck disable=SC2086
    git add $FILES
fi

# Commit with appropriate prefix
git commit -m "$PREFIX: $MESSAGE"

echo "✅ Committed changes with message: \"$PREFIX: $MESSAGE\""

# Show Git status after commit
git status --short

# If any uncommitted changes remain, show warning
if [[ -n "$(git status --porcelain)" ]]; then
    echo "⚠️  Warning: Uncommitted changes remain. Per continuous commit protocol, these should be committed."
else
    echo "✅ Working directory clean - continuous commit protocol followed."
fi

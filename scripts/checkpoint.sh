#!/usr/bin/env bash
#
# checkpoint.sh - Create checkpoint commits for continuous commit protocol
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
Usage: $(basename "$0") [OPTIONS] <milestone_description>

Creates a checkpoint commit to mark significant development milestones
as part of the continuous commit protocol.

OPTIONS:
    -h, --help          Show this help message and exit
    -t, --tests         Run tests before creating checkpoint
    -v, --verify        Verify working directory is clean before checkpoint

ARGUMENTS:
    milestone_description   Description of the milestone achieved

EXAMPLES:
    $(basename "$0") "core functionality complete with validation"
    $(basename "$0") "all unit tests passing"
    $(basename "$0") -t "feature X implementation ready for review"
    $(basename "$0") -v "deployment scripts tested and working"

CHECKPOINT COMMIT FORMAT:
    "checkpoint: <milestone_description>"

EXIT STATUS:
    0    Success - checkpoint commit was created
    1    Error - invalid arguments, tests failed, or git operation failed
    2    Error - uncommitted changes detected (with -v option)
EOF
}

# Default options
RUN_TESTS=false
VERIFY_CLEAN=false

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -t|--tests)
            RUN_TESTS=true
            shift
            ;;
        -v|--verify)
            VERIFY_CLEAN=true
            shift
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

# Get milestone description
MILESTONE="$*"

if [[ -z "$MILESTONE" ]]; then
    echo "Error: Milestone description is required" >&2
    usage
    exit 1
fi

echo "🏁 Creating checkpoint: $MILESTONE"

# Verify working directory is clean if requested
if [[ "$VERIFY_CLEAN" == true ]]; then
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "❌ Error: Working directory has uncommitted changes" >&2
        echo "Per continuous commit protocol, all changes should be committed before creating checkpoints" >&2
        echo "Uncommitted changes:" >&2
        git status --short >&2
        exit 2
    fi
    echo "✅ Working directory is clean"
fi

# Run tests if requested
if [[ "$RUN_TESTS" == true ]]; then
    echo "🧪 Running tests before checkpoint..."
    if ! make docker-test; then
        echo "❌ Tests failed - checkpoint not created" >&2
        echo "Fix test failures and try again" >&2
        exit 1
    fi
    echo "✅ All tests passed"

    # Commit test results if there are any new reports
    if [[ -n "$(git status --porcelain reports/)" ]]; then
        git add reports/
        git commit -m "test: checkpoint verification - all tests passing"
        echo "📊 Test results committed"
    fi
fi

# Add all changes and create checkpoint commit
git add .

# Check if there are any changes to commit
if [[ -z "$(git diff --cached)" ]]; then
    echo "ℹ️  No changes to commit - checkpoint created without file changes"
    # Create empty commit for checkpoint
    git commit --allow-empty -m "checkpoint: $MILESTONE"
else
    # Create normal commit with changes
    git commit -m "checkpoint: $MILESTONE"
fi

echo "✅ Checkpoint created: \"checkpoint: $MILESTONE\""

# Show current status
echo ""
echo "📈 Recent commits:"
git log --oneline -5

# Show current repository status
echo ""
echo "📊 Repository status:"
git status --short

# If any uncommitted changes remain, show warning
if [[ -n "$(git status --porcelain)" ]]; then
    echo ""
    echo "⚠️  Warning: Uncommitted changes remain after checkpoint."
    echo "Per continuous commit protocol, these should be committed soon."
else
    echo ""
    echo "✅ Working directory clean - ready for next development phase."
fi

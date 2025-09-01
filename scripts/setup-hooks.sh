#!/bin/bash

# Git Hooks Setup Script
# Installs and configures git hooks for the project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.githooks"
GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

log_info "Setting up git hooks for changelog management..."

# Create .git/hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Configure git to use our hooks directory
if git config core.hooksPath >/dev/null 2>&1; then
    current_hooks_path=$(git config core.hooksPath)
    if [[ "$current_hooks_path" != "$HOOKS_DIR" ]]; then
        log_warning "Git hooks path is currently set to: $current_hooks_path"
        log_info "Updating to use project hooks: $HOOKS_DIR"
    fi
fi

git config core.hooksPath "$HOOKS_DIR"
log_success "Configured git to use project hooks directory: $HOOKS_DIR"

# Ensure hooks are executable
if [[ -f "$HOOKS_DIR/pre-commit" ]]; then
    chmod +x "$HOOKS_DIR/pre-commit"
    log_success "Made pre-commit hook executable"
fi

# Test the pre-commit hook
log_info "Testing pre-commit hook..."
if [[ -x "$HOOKS_DIR/pre-commit" ]]; then
    log_success "Pre-commit hook is properly installed and executable"
else
    log_warning "Pre-commit hook not found or not executable"
fi

echo ""
log_success "Git hooks setup completed!"
echo ""
echo "The following hooks are now active:"
echo "  📝 pre-commit: Reminds about changelog updates for significant commits"
echo ""
echo "To disable the hooks temporarily, use:"
echo "  git commit --no-verify"
echo ""
echo "To re-enable hooks after disabling:"
echo "  ./scripts/setup-hooks.sh"

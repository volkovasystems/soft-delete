#!/usr/bin/env bash

# Installation script for soft-delete
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="soft-delete"
readonly SOURCE_SCRIPT="soft-delete.sh"
readonly DEFAULT_PREFIX="/usr/local"
readonly PREFIX="${1:-$DEFAULT_PREFIX}"
readonly BINDIR="${PREFIX}/bin"

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if source script exists
if [[ ! -f "$SOURCE_SCRIPT" ]]; then
    error "Source script '$SOURCE_SCRIPT' not found in current directory"
    exit 1
fi

# Show installation plan
info "Installing $SCRIPT_NAME..."
info "Source: $SOURCE_SCRIPT"
info "Target: $BINDIR/$SCRIPT_NAME"

# Check if target directory exists, create if needed
if [[ ! -d "$BINDIR" ]]; then
    info "Creating directory: $BINDIR"
    if ! mkdir -p "$BINDIR"; then
        error "Failed to create directory: $BINDIR"
        error "Try running with sudo: sudo $0"
        exit 1
    fi
fi

# Copy and make executable
info "Copying script..."
if cp "$SOURCE_SCRIPT" "$BINDIR/$SCRIPT_NAME"; then
    chmod +x "$BINDIR/$SCRIPT_NAME"
    success "Successfully installed $SCRIPT_NAME to $BINDIR/$SCRIPT_NAME"
else
    error "Failed to copy script to $BINDIR"
    error "Try running with sudo: sudo $0"
    exit 1
fi

# Verify installation
if command -v "$SCRIPT_NAME" >/dev/null 2>&1; then
    success "$SCRIPT_NAME is now available in your PATH"
    info "Try running: $SCRIPT_NAME --help"
else
    info "$SCRIPT_NAME installed to $BINDIR"
    info "Make sure $BINDIR is in your PATH to use the command globally"
    info "Or run directly: $BINDIR/$SCRIPT_NAME"
fi

success "Installation complete!"

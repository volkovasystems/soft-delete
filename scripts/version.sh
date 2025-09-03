#!/usr/bin/env bash

# version.sh - Version Management Script
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>
#
# This script manages version numbers following Semantic Versioning 2.0.0
# https://semver.org/spec/v2.0.0.html

set -euo pipefail

# Script metadata
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT
VERSION_FILE="$PROJECT_ROOT/VERSION"
readonly VERSION_FILE

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" >&1
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&1
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Function to display usage information
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [COMMAND] [OPTIONS]

DESCRIPTION:
    Version management utility that follows Semantic Versioning 2.0.0
    Manages the VERSION file as single source of truth for version numbers

COMMANDS:
    show                Show current version
    major               Increment major version (x.0.0)
    minor               Increment minor version (x.y.0)
    patch               Increment patch version (x.y.z)
    set VERSION         Set specific version (e.g., 1.2.3)
    validate VERSION    Validate version format

OPTIONS:
    -h, --help          Show this help message
    -n, --dry-run       Show what would be changed without making changes
    -q, --quiet         Suppress non-error output
    -v, --verbose       Enable verbose output

EXAMPLES:
    $SCRIPT_NAME show           # Display current version
    $SCRIPT_NAME major          # Increment major: 1.2.3 -> 2.0.0
    $SCRIPT_NAME minor          # Increment minor: 1.2.3 -> 1.3.0
    $SCRIPT_NAME patch          # Increment patch: 1.2.3 -> 1.2.4
    $SCRIPT_NAME set 2.1.0      # Set specific version
    $SCRIPT_NAME validate 1.0.0 # Validate version format
    $SCRIPT_NAME -n major       # Dry run major increment

SEMANTIC VERSIONING:
    MAJOR: Incompatible API changes
    MINOR: Backwards-compatible functionality additions
    PATCH: Backwards-compatible bug fixes

VERSION FILE:
    Location: $VERSION_FILE
    Format: MAJOR.MINOR.PATCH (e.g., 1.2.3)

EOF
}

# Function to validate semantic version format
validate_semver() {
    local version="$1"
    local semver_regex='^([0-9]+)\.([0-9]+)\.([0-9]+)$'

    if [[ $version =~ $semver_regex ]]; then
        return 0
    else
        return 1
    fi
}

# Function to read current version
read_version() {
    if [[ ! -f "$VERSION_FILE" ]]; then
        log_error "VERSION file not found: $VERSION_FILE"
        return 1
    fi

    local version
    version=$(tr -d '\n\r' < "$VERSION_FILE" | tr -d ' ')

    if [[ -z "$version" ]]; then
        log_error "VERSION file is empty"
        return 1
    fi

    if ! validate_semver "$version"; then
        log_error "Invalid version format in VERSION file: $version"
        log_error "Expected format: MAJOR.MINOR.PATCH (e.g., 1.2.3)"
        return 1
    fi

    echo "$version"
}

# Function to write version to file
write_version() {
    local new_version="$1"
    local dry_run="${2:-false}"

    if ! validate_semver "$new_version"; then
        log_error "Invalid version format: $new_version"
        log_error "Expected format: MAJOR.MINOR.PATCH (e.g., 1.2.3)"
        return 1
    fi

    if [[ "$dry_run" == "true" ]]; then
        log_info "DRY RUN: Would write '$new_version' to $VERSION_FILE"
        return 0
    fi

    echo "$new_version" > "$VERSION_FILE"
    log_success "Version updated to $new_version"
}

# Function to parse version components
parse_version() {
    local version="$1"
    local semver_regex='^([0-9]+)\.([0-9]+)\.([0-9]+)$'

    if [[ $version =~ $semver_regex ]]; then
        export VERSION_MAJOR="${BASH_REMATCH[1]}"
        export VERSION_MINOR="${BASH_REMATCH[2]}"
        export VERSION_PATCH="${BASH_REMATCH[3]}"
        return 0
    else
        log_error "Failed to parse version: $version"
        return 1
    fi
}

# Function to increment major version
increment_major() {
    local current_version="$1"
    local dry_run="${2:-false}"
    local quiet="${3:-false}"

    parse_version "$current_version"
    local new_major=$((VERSION_MAJOR + 1))
    local new_version="${new_major}.0.0"

    if [[ "$quiet" != "true" ]]; then
        log_info "Incrementing major version: $current_version -> $new_version"
    fi

    write_version "$new_version" "$dry_run"
}

# Function to increment minor version
increment_minor() {
    local current_version="$1"
    local dry_run="${2:-false}"
    local quiet="${3:-false}"

    parse_version "$current_version"
    local new_minor=$((VERSION_MINOR + 1))
    local new_version="${VERSION_MAJOR}.${new_minor}.0"

    if [[ "$quiet" != "true" ]]; then
        log_info "Incrementing minor version: $current_version -> $new_version"
    fi

    write_version "$new_version" "$dry_run"
}

# Function to increment patch version
increment_patch() {
    local current_version="$1"
    local dry_run="${2:-false}"
    local quiet="${3:-false}"

    parse_version "$current_version"
    local new_patch=$((VERSION_PATCH + 1))
    local new_version="${VERSION_MAJOR}.${VERSION_MINOR}.${new_patch}"

    if [[ "$quiet" != "true" ]]; then
        log_info "Incrementing patch version: $current_version -> $new_version"
    fi

    write_version "$new_version" "$dry_run"
}

# Function to set specific version
set_version() {
    local new_version="$1"
    local current_version="$2"
    local dry_run="${3:-false}"
    local quiet="${4:-false}"

    if [[ "$current_version" == "$new_version" ]]; then
        if [[ "$quiet" != "true" ]]; then
            log_warn "Version is already $new_version"
        fi
        return 0
    fi

    if [[ "$quiet" != "true" ]]; then
        log_info "Setting version: $current_version -> $new_version"
    fi

    write_version "$new_version" "$dry_run"
}

# Function to show current version
show_version() {
    local current_version="$1"
    local quiet="${2:-false}"

    if [[ "$quiet" == "true" ]]; then
        echo "$current_version"
    else
        echo "Current version: $current_version"

        parse_version "$current_version"
        echo "  Major: $VERSION_MAJOR"
        echo "  Minor: $VERSION_MINOR"
        echo "  Patch: $VERSION_PATCH"
        echo ""
        echo "Version file: $VERSION_FILE"
    fi
}

# Function to validate version command
validate_version_cmd() {
    local version="$1"
    local quiet="${2:-false}"

    if validate_semver "$version"; then
        if [[ "$quiet" != "true" ]]; then
            log_success "Valid semantic version: $version"
            parse_version "$version"
            echo "  Major: $VERSION_MAJOR"
            echo "  Minor: $VERSION_MINOR"
            echo "  Patch: $VERSION_PATCH"
        fi
        return 0
    else
        log_error "Invalid semantic version: $version"
        log_error "Expected format: MAJOR.MINOR.PATCH (e.g., 1.2.3)"
        return 1
    fi
}

# Main function
main() {
    local command=""
    local dry_run=false
    local quiet=false
    local verbose=false

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            show|major|minor|patch|set|validate)
                command="$1"
                shift
                break
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Default command is show
    if [[ -z "$command" ]]; then
        command="show"
    fi

    # Read current version
    local current_version
    if ! current_version=$(read_version); then
        exit 1
    fi

    # Execute command
    case "$command" in
        show)
            show_version "$current_version" "$quiet"
            ;;
        major)
            increment_major "$current_version" "$dry_run" "$quiet"
            ;;
        minor)
            increment_minor "$current_version" "$dry_run" "$quiet"
            ;;
        patch)
            increment_patch "$current_version" "$dry_run" "$quiet"
            ;;
        set)
            if [[ $# -eq 0 ]]; then
                log_error "set command requires a version argument"
                log_error "Usage: $SCRIPT_NAME set VERSION"
                exit 1
            fi
            local new_version="$1"
            set_version "$new_version" "$current_version" "$dry_run" "$quiet"
            ;;
        validate)
            if [[ $# -eq 0 ]]; then
                log_error "validate command requires a version argument"
                log_error "Usage: $SCRIPT_NAME validate VERSION"
                exit 1
            fi
            local version_to_validate="$1"
            validate_version_cmd "$version_to_validate" "$quiet"
            ;;
        *)
            log_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

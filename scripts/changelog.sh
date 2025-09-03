#!/bin/bash

# Changelog Management Script
# Automates changelog maintenance following strict version-based protocol
# NEVER uses "Unreleased" sections - all entries are version-specific
# Version: 2.0.0
#
# Usage:
#   ./scripts/changelog.sh add "feat: new feature description" [category] [version]
#   ./scripts/changelog.sh new-version 1.2.0
#   ./scripts/changelog.sh validate
#   ./scripts/changelog.sh recent-commits [count]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# Check if changelog exists
check_changelog_exists() {
    if [[ ! -f "$CHANGELOG_FILE" ]]; then
        log_error "CHANGELOG.md not found at: $CHANGELOG_FILE"
        return 1
    fi
}

# Get current version from VERSION file
get_current_version() {
    local version_file="$PROJECT_ROOT/VERSION"
    if [[ -f "$version_file" ]]; then
        cat "$version_file" | tr -d '\n'
    else
        log_warning "VERSION file not found, using 'Unknown'"
        echo "Unknown"
    fi
}

# Get recent commits for changelog
get_recent_commits() {
    local count=${1:-10}
    local format="--pretty=format:%h - %s (%cr) <%an>"

    cd "$PROJECT_ROOT"

    # Get commits since last tagged version
    local last_tag
    last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    if [[ -n "$last_tag" ]]; then
        log_info "Getting commits since tag: $last_tag"
        git log "${last_tag}..HEAD" "$format" --no-merges | head -n "$count"
    else
        log_info "No tags found, getting last $count commits"
        git log "$format" --no-merges -n "$count"
    fi
}

# VERSION FILE PROTECTION - AI SYSTEMS CANNOT CREATE NEW VERSIONS
create_version_section() {
    log_error "PROTOCOL VIOLATION: AI systems cannot create new version sections"
    log_error "Only developers can update version numbers per AI Version Control Protocol"
    log_error "Current version in VERSION file: $(get_current_version)"
    log_info "AI must add entries to existing version: $(get_current_version)"
    log_info "If a new version is needed, ask the developer to:"
    log_info "  1. Update VERSION file using: ./scripts/version.sh major|minor|patch"
    log_info "  2. Create corresponding changelog section if needed"
    return 1
}

# Add entry to specific version section
add_changelog_entry() {
    local entry="$1"
    local category="${2:-}"
    local version="${3:-}"

    check_changelog_exists

    # Get current version if not provided
    if [[ -z "$version" ]]; then
        version=$(get_current_version)
        if [[ "$version" == "Unknown" ]]; then
            log_error "Cannot determine version. Please specify version or ensure VERSION file exists."
            return 1
        fi
    fi

    # Auto-detect category if not provided
    if [[ -z "$category" ]]; then
        if [[ "$entry" =~ ^feat(.*): ]]; then
            category="Added"
        elif [[ "$entry" =~ ^fix(.*): ]]; then
            category="Fixed"
        elif [[ "$entry" =~ ^docs(.*): ]]; then
            category="Changed"
        elif [[ "$entry" =~ ^refactor(.*): ]]; then
            category="Changed"
        elif [[ "$entry" =~ ^security(.*): ]]; then
            category="Security"
        else
            category="Added"
        fi
    fi

    # Create a backup
    cp "$CHANGELOG_FILE" "${CHANGELOG_FILE}.backup"

    # Format the entry based on category
    local formatted_entry
    case "$category" in
        "Added"|"add")
            formatted_entry="- $entry"
            category="Added"
            ;;
        "Changed"|"change")
            formatted_entry="- $entry"
            category="Changed"
            ;;
        "Fixed"|"fix")
            formatted_entry="- $entry"
            category="Fixed"
            ;;
        "Security"|"security")
            formatted_entry="- $entry"
            category="Security"
            ;;
        "Deprecated"|"deprecated")
            formatted_entry="- $entry"
            category="Deprecated"
            ;;
        "Removed"|"removed")
            formatted_entry="- $entry"
            category="Removed"
            ;;
        *)
            formatted_entry="- $entry"
            category="Added"
            ;;
    esac

    # Check if version section exists
    if ! grep -q "## \[$version\]" "$CHANGELOG_FILE"; then
        log_error "Version section [$version] not found in changelog."
        log_info "Please create the version section first using: $0 new-version $version"
        rm -f "${CHANGELOG_FILE}.backup"
        return 1
    fi

    # Add the entry to the appropriate category in the version section
    awk -v version="$version" -v category="$category" -v entry="$formatted_entry" '
    /^## \['"$version"'\]/{in_version=1}
    /^## \[/ && !/^## \['"$version"'\]/{in_version=0}
    in_version && /^### '"$category"'$/{
        print $0
        print entry
        next
    }
    {print}
    ' "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.tmp"
    mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"

    log_success "Added entry to changelog version [$version] under '$category' section"
    log_info "Entry: $formatted_entry"

    # Clean up backup if successful
    rm -f "${CHANGELOG_FILE}.backup"
}

# Validate changelog format (updated for version-based approach)
validate_changelog() {
    check_changelog_exists

    local errors=0

    log_info "Validating changelog format..."

    # Check for required sections
    if ! grep -q "# Changelog" "$CHANGELOG_FILE"; then
        log_error "Missing main 'Changelog' title"
        ((errors++))
    fi

    # Check for "Unreleased" sections (should NOT exist per protocol)
    if grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        log_error "Found FORBIDDEN [Unreleased] section - this violates the changelog protocol"
        log_error "All entries must be associated with specific version numbers"
        ((errors++))
    fi

    # Check for proper version format in sections
    local invalid_versions
    invalid_versions=$(grep "^## \[" "$CHANGELOG_FILE" | grep -v -E "\[[0-9]+\.[0-9]+\.[0-9]+\]" || true)
    if [[ -n "$invalid_versions" ]]; then
        log_error "Found invalid version formats:"
        echo "$invalid_versions"
        ((errors++))
    fi

    # Check for proper date formats
    local invalid_dates
    invalid_dates=$(grep "^## \[" "$CHANGELOG_FILE" | grep -v -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" || true)
    if [[ -n "$invalid_dates" ]]; then
        log_error "Found entries without proper date format (YYYY-MM-DD):"
        echo "$invalid_dates"
        ((errors++))
    fi

    if [[ "$errors" -eq 0 ]]; then
        log_success "Changelog format validation passed!"
        log_success "✓ No forbidden [Unreleased] sections found"
        log_success "✓ All version entries follow semantic versioning"
        log_success "✓ All dates follow ISO 8601 format (YYYY-MM-DD)"
        return 0
    else
        log_error "Changelog validation failed with $errors error(s)"
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
Changelog Management Script (Version-Based Protocol)

IMPORTANT: This script follows a strict protocol - NO "Unreleased" sections are allowed.
All changelog entries must be associated with specific version numbers.

Usage: $0 <command> [arguments]

Commands:
    add <entry> [category] [version]    Add an entry to a specific version section
                                       Categories: Added, Changed, Fixed, Security, Deprecated, Removed
                                       Version defaults to current VERSION file content
                                       Auto-detects category from conventional commit format

    new-version <version> [date]        Create a new version section in changelog
                                       Date format: YYYY-MM-DD (defaults to today)

    validate                           Validate changelog format and protocol compliance
                                       (Checks for forbidden [Unreleased] sections)

    recent-commits [count]             Show recent commits (useful for creating changelog entries)
                                       Default count: 10

    help                              Show this help message

Examples:
    # Create new version section
    $0 new-version 1.2.0

    # Add entries (will auto-detect version from VERSION file)
    $0 add "Add new file deletion feature" Added
    $0 add "feat: improve error handling"    # Auto-detects as Added
    $0 add "fix: resolve permission issue"  # Auto-detects as Fixed

    # Add entry to specific version
    $0 add "Security improvement" Security 1.2.0

    # Check recent commits for reference
    $0 recent-commits 5

    # Validate format
    $0 validate

Protocol Notes:
- All entries must be tied to specific versions
- No [Unreleased] sections are allowed
- Use semantic versioning (X.Y.Z format)
- Use ISO 8601 date format (YYYY-MM-DD)
- Auto-detects conventional commit formats (feat:, fix:, docs:, etc.)
EOF
}

# Main script logic
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        return 1
    fi

    case "$1" in
        "add")
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 add <entry> [category] [version]"
                return 1
            fi
            add_changelog_entry "$2" "${3:-}" "${4:-}"
            ;;
        "new-version")
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 new-version <version> [date]"
                return 1
            fi
            create_version_section "$2" "${3:-}"
            ;;
        "validate")
            validate_changelog
            ;;
        "recent-commits")
            get_recent_commits "${2:-10}"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            show_help
            return 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"

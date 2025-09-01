#!/bin/bash

# Changelog Management Script
# Automates changelog maintenance and ensures proper documentation of changes
#
# Usage:
#   ./scripts/changelog.sh add "feat: new feature description"
#   ./scripts/changelog.sh prepare-release 1.1.0
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

# Add entry to unreleased section
add_changelog_entry() {
    local entry="$1"
    local category="${2:-Added}"
    
    check_changelog_exists
    
    # Create a backup
    cp "$CHANGELOG_FILE" "${CHANGELOG_FILE}.backup"
    
    # Determine the category and format the entry
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
            # Try to auto-detect from conventional commit format
            if [[ "$entry" =~ ^feat(.*): ]]; then
                formatted_entry="- **$(echo "$entry" | sed 's/^feat[^:]*: *//')**: ${entry#*: }"
                category="Added"
            elif [[ "$entry" =~ ^fix(.*): ]]; then
                formatted_entry="- **$(echo "$entry" | sed 's/^fix[^:]*: *//')**: ${entry#*: }"
                category="Fixed"
            elif [[ "$entry" =~ ^docs(.*): ]]; then
                formatted_entry="- **Documentation**: ${entry#*: }"
                category="Changed"
            elif [[ "$entry" =~ ^refactor(.*): ]]; then
                formatted_entry="- **$(echo "$entry" | sed 's/^refactor[^:]*: *//')**: ${entry#*: }"
                category="Changed"
            else
                formatted_entry="- $entry"
                category="Added"
            fi
            ;;
    esac
    
    # Check if [Unreleased] section exists
    if ! grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        # Create [Unreleased] section after the header
        awk '
        /^## \[/ {
            print "## [Unreleased]\n"
            print "### Added\n"
            print $0
            next
        }
        {print}
        ' "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.tmp"
        mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    fi
    
    # Check if the category exists in [Unreleased] section
    if ! awk '/^## \[Unreleased\]/{flag=1; next} /^## \[/{flag=0} flag && /^### '"$category"'/{found=1} END{exit !found}' "$CHANGELOG_FILE"; then
        # Add the category section
        awk '
        /^## \[Unreleased\]/{
            print $0
            getline
            print $0
            print "### '"$category"'\n"
            next
        }
        {print}
        ' "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.tmp"
        mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    fi
    
    # Add the entry to the appropriate category
    awk '
    /^## \[Unreleased\]/{unreleased=1}
    /^## \[/ && !/^## \[Unreleased\]/{unreleased=0}
    unreleased && /^### '"$category"'/{
        print $0
        print "'"$formatted_entry"'"
        category_found=1
        next
    }
    {print}
    ' "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.tmp"
    mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    
    log_success "Added entry to changelog under '$category' section"
    log_info "Entry: $formatted_entry"
    
    # Clean up backup if successful
    rm -f "${CHANGELOG_FILE}.backup"
}

# Prepare release by moving [Unreleased] to versioned section
prepare_release() {
    local version="$1"
    local date="${2:-$(date +%Y-%m-%d)}"
    
    check_changelog_exists
    
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid version format. Use semantic versioning (e.g., 1.2.3)"
        return 1
    fi
    
    # Check if [Unreleased] section exists and has content
    if ! grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        log_error "No [Unreleased] section found in changelog"
        return 1
    fi
    
    # Create backup
    cp "$CHANGELOG_FILE" "${CHANGELOG_FILE}.backup"
    
    # Replace [Unreleased] with the version and add new [Unreleased] section
    awk '
    /^## \[Unreleased\]/{
        print "## [Unreleased]\n"
        print "## ['"$version"'] - '"$date"'"
        next
    }
    {print}
    ' "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.tmp"
    mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    
    log_success "Prepared release $version in changelog"
    log_info "Don't forget to update the VERSION file and create a git tag!"
    
    # Clean up backup
    rm -f "${CHANGELOG_FILE}.backup"
}

# Validate changelog format
validate_changelog() {
    check_changelog_exists
    
    local errors=0
    
    log_info "Validating changelog format..."
    
    # Check for required sections
    if ! grep -q "# Changelog" "$CHANGELOG_FILE"; then
        log_error "Missing main 'Changelog' title"
        ((errors++))
    fi
    
    if ! grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        log_warning "No [Unreleased] section found (this is okay for released projects)"
    fi
    
    # Check for proper version format in sections
    local invalid_versions
    invalid_versions=$(grep "^## \[" "$CHANGELOG_FILE" | grep -v "Unreleased" | grep -v -E "\[[0-9]+\.[0-9]+\.[0-9]+\]" || true)
    if [[ -n "$invalid_versions" ]]; then
        log_error "Found invalid version formats:"
        echo "$invalid_versions"
        ((errors++))
    fi
    
    # Check for proper date formats
    local invalid_dates
    invalid_dates=$(grep "^## \[" "$CHANGELOG_FILE" | grep -v "Unreleased" | grep -v -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" || true)
    if [[ -n "$invalid_dates" ]]; then
        log_error "Found entries without proper date format (YYYY-MM-DD):"
        echo "$invalid_dates"
        ((errors++))
    fi
    
    if [[ "$errors" -eq 0 ]]; then
        log_success "Changelog format validation passed!"
        return 0
    else
        log_error "Changelog validation failed with $errors error(s)"
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
Changelog Management Script

Usage: $0 <command> [arguments]

Commands:
    add <entry> [category]     Add an entry to the [Unreleased] section
                              Categories: Added, Changed, Fixed, Security, Deprecated, Removed
                              If no category is specified, it will try to auto-detect from conventional commits
    
    prepare-release <version> [date]  Move [Unreleased] entries to a versioned release section
                                     Date format: YYYY-MM-DD (defaults to today)
    
    validate                  Validate changelog format
    
    recent-commits [count]    Show recent commits (useful for creating changelog entries)
                             Default count: 10
    
    help                      Show this help message

Examples:
    $0 add "Add new file deletion feature" Added
    $0 add "feat: improve error handling"  # Auto-detects as Added
    $0 add "fix: resolve permission issue" # Auto-detects as Fixed
    $0 prepare-release 1.2.0
    $0 recent-commits 5
    $0 validate

Note: This script automatically detects conventional commit format and categorizes entries appropriately.
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
                log_error "Usage: $0 add <entry> [category]"
                return 1
            fi
            add_changelog_entry "$2" "${3:-}"
            ;;
        "prepare-release")
            if [[ $# -lt 2 ]]; then
                log_error "Usage: $0 prepare-release <version> [date]"
                return 1
            fi
            prepare_release "$2" "${3:-}"
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

#!/usr/bin/env bash
#
# validate-response-completeness.sh - Validate AI response completeness
#
# This script validates that AI responses have properly committed changes
# and updated the changelog as required by the AI Response Completeness Protocol.

set -euo pipefail

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_error() {
    echo -e "${RED}❌ ERROR: $*${NC}" >&2
}

log_success() {
    echo -e "${GREEN}✅ SUCCESS: $*${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $*${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  INFO: $*${NC}"
}

# Usage function
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Validates AI response completeness according to the AI Response Completeness Protocol.

OPTIONS:
    -h, --help          Show this help message and exit
    -v, --verbose       Enable verbose output
    --fix               Attempt to fix violations automatically
    --summary           Show summary report only

VALIDATION CHECKS:
    1. Working directory is clean (no uncommitted changes)
    2. Recent commits follow conventional format
    3. Changelog has been updated for meaningful changes
    4. All protocol requirements are met

EXIT CODES:
    0    All validations passed
    1    Protocol violations found
    2    Critical errors or invalid usage

EXAMPLES:
    $(basename "$0")                # Basic validation
    $(basename "$0") --verbose      # Detailed validation report
    $(basename "$0") --fix          # Attempt to fix violations
    $(basename "$0") --summary      # Summary report only

EOF
}

# Default options
VERBOSE=false
FIX_VIOLATIONS=false
SUMMARY_ONLY=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --fix)
            FIX_VIOLATIONS=true
            shift
            ;;
        --summary)
            SUMMARY_ONLY=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 2
            ;;
    esac
done

# Verbose logging
log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}[DEBUG] $*${NC}" >&2
    fi
}

# Check if we're in a git repository
check_git_repository() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        return 1
    fi
    return 0
}

# Check working directory cleanliness
check_working_directory() {
    log_verbose "Checking working directory cleanliness..."
    
    local status_output
    status_output="$(git status --porcelain)"
    
    if [[ -n "$status_output" ]]; then
        log_error "Working directory has uncommitted changes"
        echo "Uncommitted files:"
        echo "$status_output"
        echo
        log_error "PROTOCOL VIOLATION: AI Response Completeness Protocol requires clean working directory"
        return 1
    else
        log_success "Working directory is clean"
        return 0
    fi
}

# Check recent commit format
check_commit_format() {
    log_verbose "Checking recent commit message format..."
    
    local latest_commit
    latest_commit="$(git log -1 --pretty=format:'%s')"
    
    # Check for conventional commit format
    if [[ "$latest_commit" =~ ^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\(.+\))?!?:\ .+ ]]; then
        log_success "Latest commit follows conventional format: '$latest_commit'"
        return 0
    else
        log_error "Latest commit does not follow conventional format: '$latest_commit'"
        log_error "Expected format: 'type(scope): description'"
        return 1
    fi
}

# Check if changelog was updated for meaningful changes
check_changelog_update() {
    log_verbose "Checking changelog updates..."
    
    # Note: According to our changelog protocol, changes should NOT be documented
    # until they are part of a tagged release. Development changes on develop branch
    # should remain undocumented until the next version is ready.
    
    # Get current branch
    local current_branch
    current_branch="$(git branch --show-current)"
    
    # If we're on develop branch, changelog updates are not required during development
    if [[ "$current_branch" == "develop" ]]; then
        log_info "On develop branch: Changelog updates not required until release"
        log_info "Changes will be documented when next version is tagged"
        return 0
    fi
    
    # For other branches (staging, release, etc.), check for changelog updates
    local recent_commits
    recent_commits="$(git log --oneline -5 --pretty=format:'%s')"
    
    # Check if any meaningful changes were made (not just docs)
    local has_meaningful_changes=false
    while IFS= read -r commit; do
        if [[ "$commit" =~ ^(feat|fix|refactor|perf|test|chore|ci|build):.*$ ]]; then
            has_meaningful_changes=true
            break
        fi
    done <<< "$recent_commits"
    
    if [[ "$has_meaningful_changes" == false ]]; then
        log_info "No meaningful changes detected, changelog update not required"
        return 0
    fi
    
    # Check if changelog has been updated recently
    local changelog_updated=false
    while IFS= read -r commit; do
        if [[ "$commit" =~ ^docs:.*changelog.*$ ]]; then
            changelog_updated=true
            break
        fi
    done <<< "$recent_commits"
    
    if [[ "$changelog_updated" == true ]]; then
        log_success "Changelog updated for meaningful changes"
        return 0
    else
        log_warning "Meaningful changes detected but changelog not updated"
        log_warning "Consider updating changelog if preparing for release"
        return 0  # Warning only, not an error for non-develop branches
    fi
}

# Check if on correct branch
check_branch() {
    log_verbose "Checking current branch..."
    
    local current_branch
    current_branch="$(git branch --show-current)"
    
    if [[ "$current_branch" == "develop" ]]; then
        log_success "On correct branch: develop"
        return 0
    else
        log_warning "Not on develop branch (currently on: $current_branch)"
        log_warning "AI work should typically be done on develop branch"
        return 0  # Warning, not error
    fi
}

# Attempt to fix violations
fix_violations() {
    log_info "Attempting to fix protocol violations..."
    
    local status_output
    status_output="$(git status --porcelain)"
    
    if [[ -n "$status_output" ]]; then
        log_info "Found uncommitted changes, attempting to commit..."
        
        echo "Uncommitted changes found:"
        echo "$status_output"
        echo
        
        read -p "Commit these changes? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            
            echo "Enter commit message (conventional format):"
            read -r commit_message
            
            git commit -m "$commit_message"
            log_success "Changes committed"
            
            # Check if changelog needs updating
            echo "Does this change require a changelog update? (y/N): "
            read -p "" -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Please update CHANGELOG.md manually, then run:"
                log_info "git add CHANGELOG.md"
                log_info "git commit -m 'docs: update changelog for [description]'"
            fi
        else
            log_info "Fix cancelled by user"
            return 1
        fi
    fi
    
    return 0
}

# Generate summary report
generate_summary() {
    echo
    echo "🔍 AI RESPONSE COMPLETENESS VALIDATION SUMMARY"
    echo "=============================================="
    echo "Repository: $(basename "$(git rev-parse --show-toplevel)")"
    echo "Branch: $(git branch --show-current)"
    echo "Latest commit: $(git log -1 --pretty=format:'%h %s')"
    echo "Timestamp: $(date)"
    echo
}

# Main validation function
main() {
    local exit_code=0
    
    if [[ "$SUMMARY_ONLY" == false ]]; then
        echo "🔍 AI Response Completeness Protocol Validation"
        echo "==============================================="
        echo
    fi
    
    # Check if in git repository
    if ! check_git_repository; then
        exit_code=2
    fi
    
    # Run validation checks
    if [[ $exit_code -eq 0 ]]; then
        # Check 1: Working directory cleanliness
        if ! check_working_directory; then
            exit_code=1
        fi
        
        # Check 2: Commit format
        if ! check_commit_format; then
            exit_code=1
        fi
        
        # Check 3: Changelog updates
        if ! check_changelog_update; then
            exit_code=1
        fi
        
        # Check 4: Branch validation (warning only)
        check_branch
    fi
    
    # Attempt fixes if requested
    if [[ "$FIX_VIOLATIONS" == true && $exit_code -ne 0 ]]; then
        if fix_violations; then
            log_info "Re-running validation after fixes..."
            # Re-run basic checks
            if check_working_directory && check_commit_format; then
                exit_code=0
            fi
        fi
    fi
    
    # Generate summary if requested or if there are issues
    if [[ "$SUMMARY_ONLY" == true || $exit_code -ne 0 ]]; then
        generate_summary
    fi
    
    # Final results
    echo
    if [[ $exit_code -eq 0 ]]; then
        log_success "All AI Response Completeness Protocol validations passed"
        log_success "Repository is in compliance"
    else
        log_error "AI Response Completeness Protocol violations found"
        echo
        echo "To fix violations:"
        echo "1. Commit any uncommitted changes: git add . && git commit -m 'type: description'"
        echo "2. Update CHANGELOG.md if needed"
        echo "3. Commit changelog: git add CHANGELOG.md && git commit -m 'docs: update changelog'"
        echo "4. Re-run validation: $0"
        echo
        echo "Or use automatic fix: $0 --fix"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"

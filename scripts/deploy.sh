#!/usr/bin/env bash

# deploy.sh - Deployment Automation Script
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>
# 
# This script automates the deployment process across develop -> staging -> release
# branches with proper version management, tagging, and revert capabilities

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
VERSION_SCRIPT="$SCRIPT_DIR/version.sh"
readonly VERSION_SCRIPT

# Deployment state tracking
DEPLOY_STATE_DIR="$PROJECT_ROOT/.deploy"
readonly DEPLOY_STATE_DIR

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $*" >&1
}

log_debug() {
    if [[ "${VERBOSE:-false}" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*" >&2
    fi
}

# Function to display usage information
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [COMMAND] [OPTIONS]

DESCRIPTION:
    Deployment automation script for managing releases across branches.
    Supports develop -> staging -> release workflow with version management.

DEPLOYMENT COMMANDS:
    deploy-staging          Deploy develop to staging (with version check)
    deploy-release          Deploy staging to release (creates tags, updates master/main)
    deploy-test             Deploy develop to test branch
    deploy-version VERSION  Deploy specific version (staging -> release)

REVERT COMMANDS:
    revert-staging          Revert staging deployment
    revert-release          Revert release deployment
    revert-test             Revert test deployment
    revert-version          Revert version deployment

UTILITY COMMANDS:
    status                  Show deployment status
    cleanup                 Clean up deployment state files

OPTIONS:
    -h, --help              Show this help message
    -n, --dry-run           Show what would be done without making changes
    -v, --verbose           Enable verbose output
    -f, --force             Force deployment (skip some safety checks)
    -y, --yes               Answer yes to all prompts

BRANCHES:
    develop    -> Main development branch (developers work here)
    staging    -> Staging/pre-production environment
    test       -> Testing branch for QA
    release    -> Production release branch
    master     -> Synchronized with release (auto-updated)
    main       -> Synchronized with release (auto-updated)

EXAMPLES:
    # Deploy develop to staging
    $SCRIPT_NAME deploy-staging

    # Deploy staging to release (full production deployment)
    $SCRIPT_NAME deploy-release

    # Deploy specific version
    $SCRIPT_NAME deploy-version 1.2.3

    # Revert last staging deployment
    $SCRIPT_NAME revert-staging

    # Check deployment status
    $SCRIPT_NAME status

WORKFLOW:
    1. Work on develop branch
    2. Deploy to staging: develop -> staging
    3. Test on staging environment
    4. Deploy to release: staging -> release -> master/main (with tags)

EOF
}

# Function to create deployment state directory
create_state_dir() {
    if [[ ! -d "$DEPLOY_STATE_DIR" ]]; then
        mkdir -p "$DEPLOY_STATE_DIR"
        log_debug "Created deployment state directory: $DEPLOY_STATE_DIR"
    fi
}

# Function to save deployment state
save_state() {
    local deployment_type="$1"
    local original_branch="$2"
    local timestamp="$3"
    
    create_state_dir
    
    cat > "$DEPLOY_STATE_DIR/${deployment_type}.state" << EOF
DEPLOYMENT_TYPE="$deployment_type"
ORIGINAL_BRANCH="$original_branch"
TIMESTAMP="$timestamp"
ORIGINAL_VERSION="$(get_current_version)"
CURRENT_COMMIT="$(git rev-parse HEAD)"
EOF
    
    log_debug "Saved deployment state for $deployment_type"
}

# Function to load deployment state
load_state() {
    local deployment_type="$1"
    local state_file="$DEPLOY_STATE_DIR/${deployment_type}.state"
    
    if [[ -f "$state_file" ]]; then
        # shellcheck source=/dev/null
        source "$state_file"
        return 0
    else
        return 1
    fi
}

# Function to remove deployment state
remove_state() {
    local deployment_type="$1"
    local state_file="$DEPLOY_STATE_DIR/${deployment_type}.state"
    
    if [[ -f "$state_file" ]]; then
        rm "$state_file"
        log_debug "Removed deployment state for $deployment_type"
    fi
}

# Function to check if git working directory is clean
check_working_directory() {
    if [[ -n "$(git status --porcelain)" ]]; then
        log_error "Working directory is not clean. Please commit or stash changes first."
        git status --short
        return 1
    fi
    return 0
}

# Function to check remote connectivity and push access
check_remote_access() {
    local remote="origin"
    
    log_step "Checking remote access to $remote..."
    
    if ! git remote get-url "$remote" &>/dev/null; then
        log_error "Remote '$remote' is not configured"
        return 1
    fi
    
    # Test if we can fetch from remote
    if ! git fetch "$remote" --dry-run &>/dev/null; then
        log_error "Cannot fetch from remote '$remote'. Check your network and credentials."
        return 1
    fi
    
    # Test if current branch exists on remote and can be pushed
    local current_branch
    current_branch="$(git branch --show-current)"
    
    if git rev-parse --verify "$remote/$current_branch" &>/dev/null; then
        # Branch exists on remote, check if we can push
        if ! git push "$remote" "$current_branch" --dry-run &>/dev/null; then
            log_error "Cannot push to $remote/$current_branch. Check your permissions."
            return 1
        fi
    fi
    
    log_success "Remote access verified"
    return 0
}

# Function to get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        tr -d '\n\r' < "$VERSION_FILE" | tr -d ' '
    else
        echo "0.0.0"
    fi
}

# Function to check if version was updated
check_version_updated() {
    local source_branch="$1"
    local target_branch="$2"
    
    # Get current version on target branch
    local target_version
    target_version="$(git show "$target_branch:VERSION" 2>/dev/null || echo "0.0.0")"
    
    # Get current version on source branch
    local source_version
    source_version="$(git show "$source_branch:VERSION" 2>/dev/null || echo "0.0.0")"
    
    # Special case for deploy-release: check if develop has newer version than release
    # This handles the case where user updated version on develop but hasn't deployed to staging yet
    if [[ "$source_branch" == "staging" && "$target_branch" == "release" ]]; then
        local develop_version
        develop_version="$(git show "develop:VERSION" 2>/dev/null || echo "0.0.0")"
        
        # If develop has newer version than release, but staging doesn't, suggest deploy-staging first
        if [[ "$develop_version" != "$target_version" && "$source_version" == "$target_version" ]]; then
            log_error "Version updated on develop ($develop_version) but not deployed to staging yet."
            log_error "Staging: $source_version, Release: $target_version"
            log_error "Please deploy to staging first: make deploy-staging"
            return 1
        fi
    fi
    
    if [[ "$source_version" == "$target_version" ]]; then
        log_error "Version not updated. Source ($source_branch): $source_version, Target ($target_branch): $target_version"
        if [[ "$source_branch" == "develop" ]]; then
            log_error "Please update the version before deployment using: ./scripts/version.sh patch|minor|major"
        else
            log_error "Source branch ($source_branch) needs to have a newer version than target ($target_branch)"
        fi
        return 1
    fi
    
    log_info "Version check passed. Source ($source_branch): $source_version, Target ($target_branch): $target_version"
    return 0
}

# Function to ensure branch exists locally and remotely
ensure_branch() {
    local branch_name="$1"
    local remote="${2:-origin}"
    
    # Check if branch exists locally
    if ! git rev-parse --verify "$branch_name" &>/dev/null; then
        # Check if it exists on remote
        if git rev-parse --verify "$remote/$branch_name" &>/dev/null; then
            log_info "Creating local branch '$branch_name' from remote"
            git checkout -b "$branch_name" "$remote/$branch_name"
        else
            log_error "Branch '$branch_name' does not exist locally or remotely"
            return 1
        fi
    fi
    
    return 0
}

# Function to perform force merge (overwrite target with source)
force_merge() {
    local source_branch="$1"
    local target_branch="$2"
    local dry_run="${3:-false}"
    
    log_step "Force merging $source_branch into $target_branch"
    
    if [[ "$dry_run" == "true" ]]; then
        log_info "DRY RUN: Would force merge $source_branch -> $target_branch"
        return 0
    fi
    
    # Ensure both branches exist
    ensure_branch "$source_branch"
    ensure_branch "$target_branch"
    
    # Checkout target branch
    git checkout "$target_branch"
    
    # Reset target branch to match source branch exactly
    git reset --hard "$source_branch"
    
    log_success "Force merged $source_branch into $target_branch"
}

# Function to create and push version tag
create_version_tag() {
    local version="$1"
    local branch="$2"
    local dry_run="${3:-false}"
    
    local tag_name="v$version"
    
    log_step "Creating version tag $tag_name on $branch"
    
    if [[ "$dry_run" == "true" ]]; then
        log_info "DRY RUN: Would create tag $tag_name on $branch"
        return 0
    fi
    
    # Check if tag already exists
    if git tag -l "$tag_name" | grep -q "^$tag_name$"; then
        log_warn "Tag $tag_name already exists, removing it"
        git tag -d "$tag_name"
        git push origin ":refs/tags/$tag_name" 2>/dev/null || true
    fi
    
    # Create tag on current commit
    git tag -a "$tag_name" -m "Release version $version"
    
    # Push tag to remote
    git push origin "$tag_name"
    
    log_success "Created and pushed tag $tag_name"
}

# Function to push branch to remote
push_branch() {
    local branch_name="$1"
    local remote="${2:-origin}"
    local dry_run="${3:-false}"
    
    if [[ "$dry_run" == "true" ]]; then
        log_info "DRY RUN: Would push $branch_name to $remote"
        return 0
    fi
    
    log_step "Pushing $branch_name to $remote"
    git push "$remote" "$branch_name"
    log_success "Pushed $branch_name to $remote"
}

# Function to deploy to staging
deploy_staging() {
    local dry_run="${1:-false}"
    local force="${2:-false}"
    
    log_info "Starting deployment to staging..."
    
    local original_branch
    original_branch="$(git branch --show-current)"
    local timestamp
    timestamp="$(date '+%Y%m%d-%H%M%S')"
    
    # Pre-deployment checks
    if [[ "$force" != "true" ]]; then
        check_working_directory || return 1
        check_remote_access || return 1
        
        # Check version was updated
        if ! check_version_updated "develop" "staging"; then
            return 1
        fi
    fi
    
    # Save state for potential revert
    save_state "staging" "$original_branch" "$timestamp"
    
    # Perform deployment
    force_merge "develop" "staging" "$dry_run"
    
    if [[ "$dry_run" != "true" ]]; then
        push_branch "staging" "origin" "$dry_run"
        log_success "Successfully deployed develop to staging"
    else
        log_success "DRY RUN: Would deploy develop to staging successfully"
    fi
    
    # Return to original branch
    if [[ "$dry_run" != "true" && "$original_branch" != "staging" ]]; then
        git checkout "$original_branch"
    fi
}

# Function to deploy to release
deploy_release() {
    local dry_run="${1:-false}"
    local force="${2:-false}"
    
    log_info "Starting deployment to release..."
    
    local original_branch
    original_branch="$(git branch --show-current)"
    local timestamp
    timestamp="$(date '+%Y%m%d-%H%M%S')"
    
    # Pre-deployment checks
    if [[ "$force" != "true" ]]; then
        check_working_directory || return 1
        check_remote_access || return 1
        
        # Check version was updated
        if ! check_version_updated "staging" "release"; then
            return 1
        fi
    fi
    
    # Save state for potential revert
    save_state "release" "$original_branch" "$timestamp"
    
    # Get version for tagging
    local version
    version="$(git show staging:VERSION 2>/dev/null || echo "0.0.0")"
    
    # Perform deployment to release
    force_merge "staging" "release" "$dry_run"
    
    if [[ "$dry_run" != "true" ]]; then
        push_branch "release" "origin" "$dry_run"
        
        # Create version tag
        create_version_tag "$version" "release" "$dry_run"
        
        # Update master and main branches
        log_step "Updating master and main branches"
        
        ensure_branch "master"
        force_merge "release" "master" "$dry_run"
        push_branch "master" "origin" "$dry_run"
        
        ensure_branch "main"
        force_merge "release" "main" "$dry_run"
        push_branch "main" "origin" "$dry_run"
        
        log_success "Successfully deployed staging to release (v$version)"
        log_success "Updated master and main branches"
    else
        log_success "DRY RUN: Would deploy staging to release (v$version) successfully"
        log_success "DRY RUN: Would update master and main branches"
    fi
    
    # Return to original branch
    if [[ "$dry_run" != "true" && "$original_branch" != "release" ]]; then
        git checkout "$original_branch"
    fi
}

# Function to deploy to test
deploy_test() {
    local dry_run="${1:-false}"
    local force="${2:-false}"
    
    log_info "Starting deployment to test..."
    
    local original_branch
    original_branch="$(git branch --show-current)"
    local timestamp
    timestamp="$(date '+%Y%m%d-%H%M%S')"
    
    # Pre-deployment checks
    if [[ "$force" != "true" ]]; then
        check_working_directory || return 1
        check_remote_access || return 1
    fi
    
    # Save state for potential revert
    save_state "test" "$original_branch" "$timestamp"
    
    # Perform deployment
    force_merge "develop" "test" "$dry_run"
    
    if [[ "$dry_run" != "true" ]]; then
        push_branch "test" "origin" "$dry_run"
        log_success "Successfully deployed develop to test"
    fi
    
    # Return to original branch
    if [[ "$dry_run" != "true" && "$original_branch" != "test" ]]; then
        git checkout "$original_branch"
    fi
}

# Function to deploy specific version
deploy_version() {
    local version="$1"
    local dry_run="${2:-false}"
    local force="${3:-false}"
    
    log_info "Starting deployment of version $version..."
    
    # Validate version format
    if ! "$VERSION_SCRIPT" validate "$version" -q; then
        log_error "Invalid version format: $version"
        return 1
    fi
    
    local original_branch
    original_branch="$(git branch --show-current)"
    local timestamp
    timestamp="$(date '+%Y%m%d-%H%M%S')"
    local original_version
    original_version="$(get_current_version)"
    
    # Pre-deployment checks
    if [[ "$force" != "true" ]]; then
        check_working_directory || return 1
        check_remote_access || return 1
    fi
    
    # Save state for potential revert
    save_state "version" "$original_branch" "$timestamp"
    
    # Update version file
    log_step "Updating version to $version"
    if [[ "$dry_run" != "true" ]]; then
        "$VERSION_SCRIPT" set "$version" -q
        git add "$VERSION_FILE"
        git commit -m "chore: bump version to $version"
    fi
    
    # Deploy to staging first
    log_step "Deploying to staging"
    deploy_staging "$dry_run" "true" # Force to skip checks since we just committed
    
    # Then deploy to release
    log_step "Deploying to release"
    deploy_release "$dry_run" "true" # Force to skip checks
    
    if [[ "$dry_run" != "true" ]]; then
        log_success "Successfully deployed version $version through staging to release"
    fi
    
    # Return to original branch
    if [[ "$dry_run" != "true" && "$original_branch" != "release" ]]; then
        git checkout "$original_branch"
    fi
}

# Function to revert staging deployment
revert_staging() {
    log_info "Reverting staging deployment..."
    
    if ! load_state "staging"; then
        log_error "No staging deployment state found"
        return 1
    fi
    
    log_warn "This will revert staging branch to its previous state"
    log_warn "Original branch: ${ORIGINAL_BRANCH:-unknown}"
    log_warn "Original version: ${ORIGINAL_VERSION:-unknown}"
    log_warn "Deployment timestamp: ${TIMESTAMP:-unknown}"
    
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Revert cancelled"
        return 0
    fi
    
    local current_branch
    current_branch="$(git branch --show-current)"
    
    # Get the commit before our deployment
    log_step "Finding previous staging state..."
    local previous_commit
    previous_commit="$(git log --oneline staging --skip=1 -n 1 | cut -d' ' -f1)" || {
        log_error "Could not find previous commit on staging"
        return 1
    }
    
    # Reset staging to previous state
    log_step "Reverting staging branch"
    git checkout staging
    git reset --hard "$previous_commit"
    push_branch "staging" "origin" "false"
    
    # Return to original branch
    if [[ "$current_branch" != "staging" ]]; then
        git checkout "$current_branch"
    fi
    
    log_success "Staging deployment reverted to $previous_commit"
    remove_state "staging"
}

# Function to revert release deployment
revert_release() {
    log_info "Reverting release deployment..."
    
    if ! load_state "release"; then
        log_error "No release deployment state found"
        return 1
    fi
    
    log_warn "This will revert release, master, and main branches"
    log_warn "This will also remove the version tag if it exists"
    log_warn "Original branch: ${ORIGINAL_BRANCH:-unknown}"
    log_warn "Original version: ${ORIGINAL_VERSION:-unknown}"
    log_warn "Deployment timestamp: ${TIMESTAMP:-unknown}"
    
    read -p "Are you sure? This is a destructive operation (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Revert cancelled"
        return 0
    fi
    
    local current_branch
    current_branch="$(git branch --show-current)"
    
    # Get current version to remove tag
    local current_version
    current_version="$(git show release:VERSION 2>/dev/null || echo "0.0.0")"
    local tag_name="v$current_version"
    
    # Find previous commits
    log_step "Finding previous states..."
    local prev_release_commit
    prev_release_commit="$(git log --oneline release --skip=1 -n 1 | cut -d' ' -f1)" || {
        log_error "Could not find previous release commit"
        return 1
    }
    
    # Remove version tag if it exists
    if git tag -l "$tag_name" | grep -q "^$tag_name$"; then
        log_step "Removing version tag $tag_name"
        git tag -d "$tag_name"
        git push origin ":refs/tags/$tag_name" || true
    fi
    
    # Revert release branch
    log_step "Reverting release branch"
    git checkout release
    git reset --hard "$prev_release_commit"
    push_branch "release" "origin" "false"
    
    # Revert master and main branches
    log_step "Reverting master branch"
    ensure_branch "master"
    force_merge "release" "master" "false"
    push_branch "master" "origin" "false"
    
    log_step "Reverting main branch"
    ensure_branch "main"
    force_merge "release" "main" "false"
    push_branch "main" "origin" "false"
    
    # Return to original branch
    if [[ "$current_branch" != "release" ]]; then
        git checkout "$current_branch"
    fi
    
    log_success "Release deployment reverted (removed tag $tag_name)"
    remove_state "release"
}

# Function to revert test deployment
revert_test() {
    log_info "Reverting test deployment..."
    
    if ! load_state "test"; then
        log_error "No test deployment state found"
        return 1
    fi
    
    log_warn "This will revert test branch to its previous state"
    log_warn "Original branch: $ORIGINAL_BRANCH"
    log_warn "Deployment timestamp: $TIMESTAMP"
    
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Revert cancelled"
        return 0
    fi
    
    local current_branch
    current_branch="$(git branch --show-current)"
    
    # Get the commit before our deployment
    log_step "Finding previous test state..."
    local previous_commit
    previous_commit="$(git log --oneline test --skip=1 -n 1 | cut -d' ' -f1)" || {
        log_error "Could not find previous commit on test"
        return 1
    }
    
    # Reset test to previous state
    log_step "Reverting test branch"
    git checkout test
    git reset --hard "$previous_commit"
    push_branch "test" "origin" "false"
    
    # Return to original branch
    if [[ "$current_branch" != "test" ]]; then
        git checkout "$current_branch"
    fi
    
    log_success "Test deployment reverted to $previous_commit"
    remove_state "test"
}

# Function to revert version deployment
revert_version() {
    log_info "Reverting version deployment..."
    
    if ! load_state "version"; then
        log_error "No version deployment state found"
        return 1
    fi
    
    log_warn "This will revert the version deployment completely"
    log_warn "This includes: version file, staging, release, master, main, and tags"
    log_warn "Original branch: $ORIGINAL_BRANCH"
    log_warn "Original version: $ORIGINAL_VERSION"
    log_warn "Deployment timestamp: $TIMESTAMP"
    
    read -p "Are you sure? This is a very destructive operation (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Revert cancelled"
        return 0
    fi
    
    # First revert release if it has a state
    if load_state "release"; then
        log_step "Reverting release deployment"
        revert_release
    fi
    
    # Then revert staging if it has a state
    if load_state "staging"; then
        log_step "Reverting staging deployment"
        revert_staging
    fi
    
    # Finally, revert the version commit on develop
    log_step "Reverting version commit on develop branch"
    git checkout develop
    
    # Find the version commit (should be the last commit if we just did version deployment)
    local version_commit
    version_commit="$(git log --oneline -1 --grep="chore: bump version" | cut -d' ' -f1)"
    
    if [[ -n "$version_commit" ]]; then
        log_step "Reverting version commit $version_commit"
        git revert --no-edit "$version_commit"
        push_branch "develop" "origin" "false"
    fi
    
    # Return to original branch
    if [[ "$ORIGINAL_BRANCH" != "develop" ]]; then
        git checkout "$ORIGINAL_BRANCH"
    fi
    
    log_success "Version deployment completely reverted"
    remove_state "version"
}

# Function to show deployment status
show_status() {
    log_info "Deployment Status"
    echo "=================="
    
    # Show current branch and version
    local current_branch
    current_branch="$(git branch --show-current)"
    local current_version
    current_version="$(get_current_version)"
    
    echo "Current branch: $current_branch"
    echo "Current version: $current_version"
    echo
    
    # Show active deployment states
    if [[ -d "$DEPLOY_STATE_DIR" ]]; then
        local state_files
        mapfile -t state_files < <(find "$DEPLOY_STATE_DIR" -name "*.state" 2>/dev/null || true)
        
        if [[ ${#state_files[@]} -gt 0 ]]; then
            echo "Active deployments:"
            for state_file in "${state_files[@]}"; do
                local deployment_type
                deployment_type="$(basename "$state_file" .state)"
                echo "  - $deployment_type"
            done
        else
            echo "No active deployments"
        fi
    else
        echo "No active deployments"
    fi
}

# Function to cleanup deployment state
cleanup_state() {
    if [[ -d "$DEPLOY_STATE_DIR" ]]; then
        rm -rf "$DEPLOY_STATE_DIR"
        log_success "Cleaned up deployment state"
    else
        log_info "No deployment state to clean up"
    fi
}

# Main function
main() {
    local command=""
    local dry_run=false
    local force=false
    local verbose=false
    local yes=false
    
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
            -f|--force)
                force=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                export VERBOSE=true
                shift
                ;;
            -y|--yes)
                yes=true
                shift
                ;;
            deploy-staging|deploy-release|deploy-test|deploy-version|revert-staging|revert-release|revert-test|revert-version|status|cleanup)
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
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
    
    # Check if version script exists
    if [[ ! -f "$VERSION_SCRIPT" ]]; then
        log_error "Version script not found: $VERSION_SCRIPT"
        exit 1
    fi
    
    # Execute command
    case "$command" in
        deploy-staging)
            deploy_staging "$dry_run" "$force"
            ;;
        deploy-release)
            deploy_release "$dry_run" "$force"
            ;;
        deploy-test)
            deploy_test "$dry_run" "$force"
            ;;
        deploy-version)
            if [[ $# -eq 0 ]]; then
                log_error "deploy-version command requires a version argument"
                log_error "Usage: $SCRIPT_NAME deploy-version VERSION"
                exit 1
            fi
            local version="$1"
            deploy_version "$version" "$dry_run" "$force"
            ;;
        revert-staging)
            revert_staging
            ;;
        revert-release)
            revert_release
            ;;
        revert-test)
            revert_test
            ;;
        revert-version)
            revert_version
            ;;
        status)
            show_status
            ;;
        cleanup)
            cleanup_state
            ;;
        "")
            log_error "No command specified"
            usage
            exit 1
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

#!/usr/bin/env bash

# version-guard.sh - VERSION file protection and validation system
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

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
    echo -e "${BLUE}[VERSION-GUARD]${NC} $*" >&1
}

log_success() {
    echo -e "${GREEN}[PROTECTED]${NC} $*" >&1
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[BLOCKED]${NC} $*" >&2
}

# Usage function
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [COMMAND] [OPTIONS]

VERSION file protection and validation system.

COMMANDS:
    enable          Enable VERSION file protection
    disable         Disable VERSION file protection  
    check           Check if VERSION file is protected
    validate        Validate current VERSION file integrity
    reset           Reset protection system
    status          Show protection status and file info

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -f, --force     Force operation (use with caution)

PROTECTION FEATURES:
    - File immutability via chattr +i (Linux)
    - Git pre-commit hooks to block unauthorized changes
    - Checksum validation to detect tampering
    - Access logging for audit trails
    - Developer authentication checks

EXAMPLES:
    $SCRIPT_NAME enable          # Enable all protections
    $SCRIPT_NAME check           # Check protection status
    $SCRIPT_NAME validate        # Validate VERSION file integrity
    $SCRIPT_NAME disable --force # Disable protections (requires force)

NOTE: Only authorized developers can modify VERSION file when protected.
EOF
}

# Get current version
get_current_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE" | tr -d '\n\r'
    else
        echo "UNKNOWN"
    fi
}

# Generate checksum for VERSION file
generate_checksum() {
    if [[ -f "$VERSION_FILE" ]]; then
        sha256sum "$VERSION_FILE" | cut -d' ' -f1
    else
        echo "NO_FILE"
    fi
}

# Store protection metadata
store_protection_metadata() {
    local version="$1"
    local checksum="$2"
    local metadata_file="$PROJECT_ROOT/.version-guard"
    
    cat > "$metadata_file" << EOF
# VERSION file protection metadata
# Generated: $(date -Iseconds)
# Protected version: $version
# Checksum: $checksum
# Developer: $(git config user.name 2>/dev/null || echo "UNKNOWN") <$(git config user.email 2>/dev/null || echo "UNKNOWN")>
# Host: $(hostname)
# Timestamp: $(date +%s)
EOF
    
    # Make metadata file readonly
    chmod 444 "$metadata_file" 2>/dev/null || true
}

# Check if we're running in an AI environment
detect_ai_environment() {
    # Check for common AI environment indicators
    local ai_indicators=(
        "WARP_SESSION_ID"          # Warp.dev
        "CURSOR_SESSION"           # Cursor
        "GITHUB_CODESPACES_TOKEN"  # GitHub Codespaces  
        "CODESERVER_"              # VS Code Server
        "REPLIT_"                  # Replit
        "GITPOD_"                  # Gitpod
    )
    
    for indicator in "${ai_indicators[@]}"; do
        if env | grep -q "^$indicator"; then
            return 0  # AI environment detected
        fi
    done
    
    # Check process tree for AI tools
    if pgrep -f "(cursor|code-server|warp)" >/dev/null 2>&1; then
        return 0  # AI environment detected
    fi
    
    return 1  # Not AI environment
}

# Check if user is authorized developer
check_developer_authorization() {
    local git_name git_email
    
    git_name="$(git config user.name 2>/dev/null || echo "")"
    git_email="$(git config user.email 2>/dev/null || echo "")"
    
    # Known authorized developers (add more as needed)
    local authorized_developers=(
        "Richeve S. Bebedor:richeve.bebedor@gmail.com"
        # Add more authorized developers here in "Name:email" format
    )
    
    local current_dev="$git_name:$git_email"
    
    for auth_dev in "${authorized_developers[@]}"; do
        if [[ "$current_dev" == "$auth_dev" ]]; then
            return 0  # Authorized
        fi
    done
    
    return 1  # Not authorized
}

# Enable VERSION file protection
enable_protection() {
    local force="${1:-false}"
    
    log_info "Enabling VERSION file protection..."
    
    if [[ ! -f "$VERSION_FILE" ]]; then
        log_error "VERSION file not found: $VERSION_FILE"
        return 1
    fi
    
    local current_version checksum
    current_version="$(get_current_version)"
    checksum="$(generate_checksum)"
    
    # Store protection metadata
    store_protection_metadata "$current_version" "$checksum"
    
    # Make VERSION file immutable (Linux)
    if command -v chattr >/dev/null 2>&1; then
        if chattr +i "$VERSION_FILE" 2>/dev/null; then
            log_success "VERSION file made immutable via chattr"
        else
            log_warn "Could not set immutable flag (may require sudo)"
        fi
    fi
    
    # Set restrictive permissions
    chmod 444 "$VERSION_FILE" 2>/dev/null || true
    
    # Create pre-commit hook
    create_precommit_hook
    
    log_success "VERSION file protection enabled for version: $current_version"
    log_info "Checksum: $checksum"
    
    return 0
}

# Disable VERSION file protection
disable_protection() {
    local force="${1:-false}"
    
    if [[ "$force" != "true" ]]; then
        log_error "Protection disable requires --force flag"
        log_warn "Use: $SCRIPT_NAME disable --force"
        return 1
    fi
    
    log_warn "Disabling VERSION file protection..."
    
    # Remove immutable flag (Linux)
    if command -v chattr >/dev/null 2>&1; then
        chattr -i "$VERSION_FILE" 2>/dev/null || true
    fi
    
    # Restore write permissions
    chmod 644 "$VERSION_FILE" 2>/dev/null || true
    
    # Remove metadata
    rm -f "$PROJECT_ROOT/.version-guard" 2>/dev/null || true
    
    # Remove pre-commit hook
    remove_precommit_hook
    
    log_warn "VERSION file protection disabled"
    
    return 0
}

# Create pre-commit hook
create_precommit_hook() {
    local hook_dir="$PROJECT_ROOT/.git/hooks"
    local hook_file="$hook_dir/pre-commit.version-guard"
    
    mkdir -p "$hook_dir"
    
    cat > "$hook_file" << 'EOF'
#!/usr/bin/env bash
# VERSION file protection pre-commit hook

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
VERSION_GUARD="$PROJECT_ROOT/scripts/version-guard.sh"

if [[ -f "$VERSION_GUARD" ]]; then
    # Check if VERSION file is being modified
    if git diff --cached --name-only | grep -q "^VERSION$"; then
        echo "🚨 VERSION file modification detected!"
        
        # Run version guard validation
        if ! "$VERSION_GUARD" validate-commit; then
            echo "❌ VERSION file modification blocked by version-guard"
            echo "💡 Only authorized developers can modify VERSION file"
            echo "💡 Use './scripts/version.sh' for legitimate version updates"
            exit 1
        fi
    fi
fi

exit 0
EOF
    
    chmod +x "$hook_file"
    
    # Install or update main pre-commit hook
    local main_hook="$hook_dir/pre-commit"
    if [[ ! -f "$main_hook" ]]; then
        cat > "$main_hook" << 'EOF'
#!/usr/bin/env bash
# Main pre-commit hook dispatcher

set -euo pipefail

HOOK_DIR="$(dirname "$0")"

# Run all pre-commit.* hooks
for hook in "$HOOK_DIR"/pre-commit.*; do
    if [[ -x "$hook" && "$hook" != "$0" ]]; then
        echo "Running $(basename "$hook")..."
        if ! "$hook"; then
            exit 1
        fi
    fi
done

exit 0
EOF
        chmod +x "$main_hook"
    fi
}

# Remove pre-commit hook
remove_precommit_hook() {
    local hook_file="$PROJECT_ROOT/.git/hooks/pre-commit.version-guard"
    rm -f "$hook_file" 2>/dev/null || true
}

# Validate VERSION file integrity
validate_version_file() {
    log_info "Validating VERSION file integrity..."
    
    if [[ ! -f "$VERSION_FILE" ]]; then
        log_error "VERSION file not found"
        return 1
    fi
    
    local metadata_file="$PROJECT_ROOT/.version-guard"
    if [[ ! -f "$metadata_file" ]]; then
        log_warn "No protection metadata found - file may not be protected"
        return 0
    fi
    
    local stored_checksum current_checksum
    stored_checksum="$(grep "^# Checksum:" "$metadata_file" | cut -d' ' -f3)"
    current_checksum="$(generate_checksum)"
    
    if [[ "$stored_checksum" == "$current_checksum" ]]; then
        log_success "VERSION file integrity verified"
        return 0
    else
        log_error "VERSION file integrity check FAILED"
        log_error "Expected: $stored_checksum"
        log_error "Current:  $current_checksum"
        return 1
    fi
}

# Validate commit-time changes
validate_commit() {
    log_info "Validating VERSION file changes for commit..."
    
    # Check if running in AI environment
    if detect_ai_environment; then
        log_error "AI environment detected - VERSION modifications not allowed"
        log_error "AI systems cannot modify version numbers without explicit developer authorization"
        return 1
    fi
    
    # Check developer authorization
    if ! check_developer_authorization; then
        local git_name git_email
        git_name="$(git config user.name 2>/dev/null || echo "UNKNOWN")"
        git_email="$(git config user.email 2>/dev/null || echo "UNKNOWN")"
        
        log_error "Unauthorized user attempting VERSION modification"
        log_error "User: $git_name <$git_email>"
        log_error "Only authorized developers can modify VERSION file"
        return 1
    fi
    
    log_success "VERSION file modification authorized"
    
    # Update protection metadata with new version
    if [[ -f "$VERSION_FILE" ]]; then
        local new_version new_checksum
        new_version="$(get_current_version)"
        new_checksum="$(generate_checksum)"
        store_protection_metadata "$new_version" "$new_checksum"
    fi
    
    return 0
}

# Check protection status
check_protection_status() {
    log_info "Checking VERSION file protection status..."
    
    if [[ ! -f "$VERSION_FILE" ]]; then
        log_error "VERSION file not found"
        return 1
    fi
    
    local current_version
    current_version="$(get_current_version)"
    echo "Current version: $current_version"
    
    # Check metadata file
    local metadata_file="$PROJECT_ROOT/.version-guard"
    if [[ -f "$metadata_file" ]]; then
        log_success "Protection metadata found"
        echo "Protection details:"
        grep "^# " "$metadata_file" | sed 's/^# /  /'
    else
        log_warn "No protection metadata found"
    fi
    
    # Check file attributes
    if command -v lsattr >/dev/null 2>&1; then
        local attrs
        attrs="$(lsattr "$VERSION_FILE" 2>/dev/null | cut -d' ' -f1)"
        if [[ "$attrs" == *i* ]]; then
            log_success "VERSION file is immutable (chattr +i)"
        else
            log_warn "VERSION file is not immutable"
        fi
    fi
    
    # Check permissions
    local perms
    perms="$(stat -c %a "$VERSION_FILE" 2>/dev/null || stat -f %A "$VERSION_FILE" 2>/dev/null || echo "unknown")"
    if [[ "$perms" == "444" ]]; then
        log_success "VERSION file has read-only permissions"
    else
        log_warn "VERSION file permissions: $perms (not read-only)"
    fi
    
    # Check pre-commit hook
    if [[ -f "$PROJECT_ROOT/.git/hooks/pre-commit.version-guard" ]]; then
        log_success "Pre-commit hook installed"
    else
        log_warn "Pre-commit hook not found"
    fi
}

# Reset protection system
reset_protection() {
    log_warn "Resetting VERSION file protection system..."
    
    # This requires manual intervention for security
    log_error "Reset requires manual steps:"
    echo "1. Remove immutable flag: sudo chattr -i $VERSION_FILE"
    echo "2. Remove metadata: rm -f $PROJECT_ROOT/.version-guard"
    echo "3. Remove hooks: rm -f $PROJECT_ROOT/.git/hooks/pre-commit.version-guard"
    echo "4. Restore permissions: chmod 644 $VERSION_FILE"
    
    return 1
}

# Main function
main() {
    local command="${1:-status}"
    local verbose=false
    local force=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            enable|disable|check|validate|reset|status|validate-commit)
                command="$1"
                shift
                ;;
            *)
                if [[ "$1" =~ ^- ]]; then
                    log_error "Unknown option: $1"
                    usage
                    exit 1
                else
                    command="$1"
                    shift
                fi
                ;;
        esac
    done
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Execute command
    case "$command" in
        enable)
            enable_protection "$force"
            ;;
        disable)
            disable_protection "$force"
            ;;
        check|status)
            check_protection_status
            ;;
        validate)
            validate_version_file
            ;;
        validate-commit)
            validate_commit
            ;;
        reset)
            reset_protection
            ;;
        *)
            log_error "Unknown command: $command"
            usage
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

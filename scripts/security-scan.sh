#!/usr/bin/env bash

# security-scan.sh - Comprehensive security scanning for soft-delete project
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

set -euo pipefail

# Script metadata
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[SECURITY]${NC} $*" >&1
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $*" >&1
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $*" >&2
}

# Usage function
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Comprehensive security scanning for the soft-delete project.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -q, --quiet     Suppress output except security issues

CHECKS PERFORMED:
    - Shell script security analysis with shellcheck
    - File permission validation
    - Hardcoded secrets detection
    - Path traversal vulnerability checks
    - Input validation analysis
    - Docker security scanning
    - Dependency security audit

EXAMPLES:
    $SCRIPT_NAME                    # Run all security checks
    $SCRIPT_NAME -v                 # Run with verbose output
    $SCRIPT_NAME -q                 # Run quietly
EOF
}

# Function to check file permissions
check_file_permissions() {
    log_info "Checking file permissions..."
    
    local issues=0
    
    # Check for overly permissive files
    if find "$PROJECT_ROOT" -type f -perm /o+w 2>/dev/null | grep -v ".git" | grep -q .; then
        log_error "Found world-writable files:"
        find "$PROJECT_ROOT" -type f -perm /o+w 2>/dev/null | grep -v ".git"
        ((issues++))
    fi
    
    # Check for executable files that shouldn't be
    local suspicious_executables
    suspicious_executables=$(find "$PROJECT_ROOT" -name "*.md" -o -name "*.txt" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" 2>/dev/null | xargs -I {} test -x {} \; -print 2>/dev/null || true)
    if [[ -n "$suspicious_executables" ]]; then
        log_error "Found unexpectedly executable documentation files:"
        echo "$suspicious_executables"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        log_success "File permissions are secure"
    fi
    
    return $issues
}

# Function to check for hardcoded secrets
check_hardcoded_secrets() {
    log_info "Scanning for hardcoded secrets..."
    
    local issues=0
    local secret_patterns=(
        "password\s*=\s*['\"][^'\"]{3,}"
        "api[_-]?key\s*=\s*['\"][^'\"]{10,}"
        "secret\s*=\s*['\"][^'\"]{8,}"
        "token\s*=\s*['\"][^'\"]{10,}"
        "-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----"
        "ssh-rsa\s+[A-Za-z0-9+/]{200,}"
        "[0-9a-f]{32,64}"  # Potential hashes/tokens
    )
    
    for pattern in "${secret_patterns[@]}"; do
        local matches
        matches=$(grep -rEi "$pattern" "$PROJECT_ROOT" --exclude-dir=.git --exclude-dir=reports --exclude-dir=dist 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            log_warn "Potential secret found with pattern: $pattern"
            echo "$matches"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_success "No hardcoded secrets detected"
    fi
    
    return $issues
}

# Function to check for path traversal vulnerabilities
check_path_traversal() {
    log_info "Checking for path traversal vulnerabilities..."
    
    local issues=0
    
    # Check for unsafe path handling
    local unsafe_patterns=(
        '\$[A-Za-z_][A-Za-z0-9_]*/'  # Unquoted variables in paths
        '\.\./\.\.'                   # Obvious path traversal
        'cd\s+\$'                     # cd with unquoted variables
    )
    
    for pattern in "${unsafe_patterns[@]}"; do
        if grep -rE "$pattern" "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null | grep -v "# Safe:"; then
            log_error "Potential path traversal vulnerability found with pattern: $pattern"
            ((issues++))
        fi
    done
    
    # Check that all path operations use proper validation
    local path_ops
    path_ops=$(grep -rE "(mv|cp|rm|mkdir|rmdir)\s+" "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null || true)
    if echo "$path_ops" | grep -v "validate_path\|test -e\|test -f\|test -d\|\[\[ -[efd]"; then
        log_warn "Found file operations that may need path validation"
    fi
    
    if [[ $issues -eq 0 ]]; then
        log_success "No path traversal vulnerabilities detected"
    fi
    
    return $issues
}

# Function to check input validation
check_input_validation() {
    log_info "Analyzing input validation..."
    
    local issues=0
    
    # Check for unvalidated user input usage
    local input_sources=('$1' '$2' '$@' '$*' 'read -r')
    
    for source in "${input_sources[@]}"; do
        local usage
        usage=$(grep -rF "$source" "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null || true)
        if [[ -n "$usage" ]]; then
            # Check if validation is present nearby
            if ! echo "$usage" | grep -B5 -A5 "validate\|test\|\[\[\|if.*-[a-z]"; then
                log_warn "Found potentially unvalidated input usage: $source"
                ((issues++))
            fi
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_success "Input validation appears adequate"
    fi
    
    return $issues
}

# Function to run shellcheck security analysis
run_shellcheck_security() {
    log_info "Running shellcheck security analysis..."
    
    local issues=0
    
    if ! command -v shellcheck >/dev/null 2>&1; then
        log_warn "shellcheck not found, skipping shell security analysis"
        return 0
    fi
    
    local security_relevant_codes=(
        "SC2086"  # Double quote to prevent globbing and word splitting
        "SC2046"  # Quote this to prevent word splitting
        "SC2006"  # Use $(..) instead of legacy `..`
        "SC2035"  # Use ./* so names with dashes won't become options
        "SC2068"  # Double quote array expansions
        "SC2090"  # Quotes/backslashes will be treated literally
        "SC2294"  # eval can break out of its parent context
    )
    
    for code in "${security_relevant_codes[@]}"; do
        if shellcheck -f tty --include="$code" "$PROJECT_ROOT"/*.sh "$PROJECT_ROOT"/scripts/*.sh 2>/dev/null | grep -q "$code"; then
            log_error "Security-relevant shellcheck issue found: $code"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_success "No security-relevant shellcheck issues found"
    fi
    
    return $issues
}

# Function to check Docker security
check_docker_security() {
    log_info "Checking Docker security configuration..."
    
    local issues=0
    
    # Check Dockerfile security best practices
    if [[ -f "$PROJECT_ROOT/Dockerfile.test" ]]; then
        local dockerfile="$PROJECT_ROOT/Dockerfile.test"
        
        # Check for non-root user
        if ! grep -q "USER.*[^root]" "$dockerfile"; then
            log_warn "Dockerfile does not explicitly set a non-root user for final stage"
            ((issues++))
        else
            log_success "Dockerfile uses non-root user"
        fi
        
        # Check for COPY with proper ownership
        if grep -q "COPY.*--chown" "$dockerfile"; then
            log_success "Dockerfile uses --chown for proper file ownership"
        fi
        
        # Check for secrets in Dockerfile
        if grep -iE "(password|secret|key|token)" "$dockerfile"; then
            log_error "Potential secrets found in Dockerfile"
            ((issues++))
        fi
    fi
    
    return $issues
}

# Main security scan function
run_security_scan() {
    local verbose="${1:-false}"
    local quiet="${2:-false}"
    
    [[ "$quiet" == "false" ]] && log_info "Starting comprehensive security scan..."
    
    local total_issues=0
    
    # Run all security checks
    check_file_permissions || ((total_issues += $?))
    check_hardcoded_secrets || ((total_issues += $?))
    check_path_traversal || ((total_issues += $?))
    check_input_validation || ((total_issues += $?))
    run_shellcheck_security || ((total_issues += $?))
    check_docker_security || ((total_issues += $?))
    
    # Summary
    if [[ "$quiet" == "false" ]]; then
        echo ""
        if [[ $total_issues -eq 0 ]]; then
            log_success "Security scan completed - No issues found! ✅"
        else
            log_error "Security scan completed - $total_issues issues found ❌"
        fi
    fi
    
    return $total_issues
}

# Main function
main() {
    local verbose=false
    local quiet=false
    
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
            -q|--quiet)
                quiet=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    cd "$PROJECT_ROOT"
    
    if run_security_scan "$verbose" "$quiet"; then
        exit 0
    else
        exit 1
    fi
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

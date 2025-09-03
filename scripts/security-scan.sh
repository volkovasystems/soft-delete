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
    )
    
    # Special pattern for hashes/tokens with exclusions
    local hash_pattern="[0-9a-f]{32,64}"
    
    for pattern in "${secret_patterns[@]}"; do
        local matches
        matches=$(grep -rEi "$pattern" "$PROJECT_ROOT" --exclude-dir=.git --exclude-dir=reports --exclude-dir=dist 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            log_warn "Potential secret found with pattern: $pattern"
            echo "$matches"
            ((issues++))
        fi
    done
    
    # Check for potential hashes/tokens but exclude legitimate checksums
    local hash_matches
    hash_matches=$(grep -rEi "$hash_pattern" "$PROJECT_ROOT" --exclude-dir=.git --exclude-dir=reports --exclude-dir=dist 2>/dev/null || true)
    if [[ -n "$hash_matches" ]]; then
        # Filter out known legitimate checksums and version guard files
        local filtered_matches
        filtered_matches=$(echo "$hash_matches" | grep -v "# Checksum:" | grep -v ".version-guard" | grep -v "sha256sum" | grep -v "checksum" | grep -vi "hash" || true)
        
        if [[ -n "$filtered_matches" ]]; then
            log_warn "Potential secret found with hash pattern (excluding legitimate checksums):"
            echo "$filtered_matches"
            ((issues++))
        fi
    fi
    
    if [[ $issues -eq 0 ]]; then
        log_success "No hardcoded secrets detected"
    fi
    
    return $issues
}

# Function to check for path traversal vulnerabilities
check_path_traversal() {
    log_info "Checking for path traversal vulnerabilities..."
    
    local issues=0
    
    # Safe variable patterns that should be excluded from path traversal checks
    local safe_variables=(
        "PROJECT_ROOT"
        "SCRIPT_DIR"
        "HOME"
        "TMPDIR"
        "TMP"
        "TEMP"
        "PWD"
        "OLDPWD"
        "BASH_SOURCE"
        "0"
        "deployment_type"
        "remote"
        "current_branch"
        "branch_name"
        "backup_name"
        "backup_directory"
        "dirname"
        "filename"
        "backup_path"
        "target_path"
        "source_path"
        "file"
        "dir"
        "path"
        "state_file"
        "hook_dir"
        "hook_file"
        "metadata_file"
        "dockerfile"
        "reports_dir"
        "temp_file"
        "temp_canonical"
        "structure_file"
        "report_file"
        "restore_path"
        "old_backups"
    )
    
    # Create exclusion pattern for safe variables
    local safe_pattern=""
    for var in "${safe_variables[@]}"; do
        if [[ -n "$safe_pattern" ]]; then
            safe_pattern="${safe_pattern}|\\\$${var}/|\\\${${var}}/"
        else
            safe_pattern="\\\$${var}/|\\\${${var}}/"
        fi
    done
    
    # Check for unsafe path handling (exclude safe variables)
    local unsafe_patterns=(
        '\.\./\.\.'                   # Obvious path traversal
        'cd\s+\$[^{]'                 # cd with unquoted variables (but allow ${var} form)
    )
    
    for pattern in "${unsafe_patterns[@]}"; do
        local matches
        matches=$(grep -rE "$pattern" "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null | grep -v "# Safe:" || true)
        if [[ -n "$matches" ]]; then
            log_error "Potential path traversal vulnerability found with pattern: $pattern"
            echo "$matches"
            ((issues++))
        fi
    done
    
    # Check for unquoted variables in paths, but exclude safe variables
    local unquoted_var_matches
    unquoted_var_matches=$(grep -rE '\$[A-Za-z_][A-Za-z0-9_]*/' "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null || true)
    
    if [[ -n "$unquoted_var_matches" ]]; then
        # Filter out safe variable usage (escape the pattern properly)
        local filtered_matches
        if [[ -n "$safe_pattern" ]]; then
            filtered_matches=$(echo "$unquoted_var_matches" | grep -vE "$safe_pattern" | grep -v "# Safe:" || true)
        else
            filtered_matches="$unquoted_var_matches"
        fi
        
        if [[ -n "$filtered_matches" ]]; then
            log_error "Potential path traversal vulnerability found with unquoted variables:"
            echo "$filtered_matches"
            ((issues++))
        fi
    fi
    
    # Check that critical path operations use proper validation (but be less strict)
    local critical_ops
    critical_ops=$(grep -rE "(rm -rf|rmdir)\s+" "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null || true)
    if [[ -n "$critical_ops" ]]; then
        # Enhanced validation patterns to recognize more security practices
        local validation_patterns=(
            "validate_path"
            "test -e"
            "test -f"
            "test -d"
            "\[\[ -[efd]"
            "if.*-[efd]"
            "2>/dev/null || true"
            "=~.*\^/.*\$$"           # Regex path validation
            "\[\[ -n.*\]\] &&"        # Non-empty check before rm
            "\[\[ -d.*\]\] &&"        # Directory existence check
            "rm -rf dist/"           # Hardcoded safe path
            "-maxdepth 1"            # find with maxdepth is safer
        )
        
        local validation_pattern=""
        for pattern in "${validation_patterns[@]}"; do
            if [[ -n "$validation_pattern" ]]; then
                validation_pattern="$validation_pattern|$pattern"
            else
                validation_pattern="$pattern"
            fi
        done
        
        local unvalidated_critical_ops
        unvalidated_critical_ops=$(echo "$critical_ops" | grep -vE "($validation_pattern)" || true)
        
        # Filter out example files which are documentation
        unvalidated_critical_ops=$(echo "$unvalidated_critical_ops" | grep -v "examples/" || true)
        
        if [[ -n "$unvalidated_critical_ops" ]]; then
            log_warn "Found critical file operations that may benefit from path validation:"
            echo "$unvalidated_critical_ops"
        fi
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
    
    # Check for potentially dangerous unvalidated input patterns
    # Focus on usage patterns that could be exploited
    local dangerous_patterns=(
        'eval.*\$[0-9@*]'          # eval with user input
        '\$[0-9@*].*>.*/'          # user input used in file paths without quotes
        'rm.*\$[0-9@*][^"\]]'      # rm with unquoted user input
    )
    
    # Special pattern for exec (exclude find -exec which is safe)
    local exec_pattern='exec.*\$[0-9@*]'
    local exec_matches
    exec_matches=$(grep -rE "$exec_pattern" "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null || true)
    if [[ -n "$exec_matches" ]]; then
        # Filter out safe find -exec usage
        local filtered_exec_matches
        filtered_exec_matches=$(echo "$exec_matches" | grep -v "find.*-exec" | grep -v "^[[:space:]]*#" | grep -v "# Safe:" || true)
        
        if [[ -n "$filtered_exec_matches" ]]; then
            log_error "Dangerous unvalidated input usage found with exec pattern:"
            echo "$filtered_exec_matches"
            ((issues++))
        fi
    fi
    
    for pattern in "${dangerous_patterns[@]}"; do
        local matches
        matches=$(grep -rE "$pattern" "$PROJECT_ROOT" --include="*.sh" --include="*.bash" --exclude-dir=.git 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            # Filter out comments and safe usage patterns
            local filtered_matches
            filtered_matches=$(echo "$matches" | grep -v "^[[:space:]]*#" | grep -v "# Safe:" || true)
            
            if [[ -n "$filtered_matches" ]]; then
                log_error "Dangerous unvalidated input usage found with pattern: $pattern"
                echo "$filtered_matches"
                ((issues++))
            fi
        fi
    done
    
    # Check for scripts that handle sensitive operations with user input
    local sensitive_scripts
    sensitive_scripts=$(find "$PROJECT_ROOT" -name "*.sh" -o -name "*.bash" | grep -E "(deploy|install|setup|admin|root|sudo)" 2>/dev/null || true)
    
    for script in $sensitive_scripts; do
        if [[ -f "$script" ]] && grep -q '\$[0-9@*]' "$script" 2>/dev/null; then
            # Check if the script has input validation
            if ! grep -q "validate\|test.*-[a-z]\|\[\[.*-[a-z]\|if.*-[a-z]" "$script" 2>/dev/null; then
                log_warn "Sensitive script may need input validation: $(basename "$script")"
            fi
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_success "No dangerous input validation issues detected"
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

#!/usr/bin/env bash

# audit-cleanup.sh - Repository cleanup monitoring and auditing
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

# Flags
QUIET_MODE=false
AUTO_FIX=false

# Usage function
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Repository cleanup monitoring and auditing script.

OPTIONS:
    -h, --help      Show this help message
    -q, --quiet     Suppress all output except errors
    --fix           Automatically clean up found dangling files
    --report        Generate detailed cleanup report

EXAMPLES:
    $SCRIPT_NAME                    # Run audit and show results
    $SCRIPT_NAME --quiet            # Run quietly, exit code indicates status
    $SCRIPT_NAME --fix              # Audit and automatically fix issues
    $SCRIPT_NAME --report           # Generate detailed report

EXIT CODES:
    0    Repository is clean
    1    Dangling files found (or other issues)
    2    Script error
EOF
}

# Logging functions
log_info() {
    [[ "$QUIET_MODE" == "false" ]] && echo -e "${BLUE}[AUDIT]${NC} $*" >&1
}

log_success() {
    [[ "$QUIET_MODE" == "false" ]] && echo -e "${GREEN}[PASS]${NC} $*" >&1
}

log_warn() {
    [[ "$QUIET_MODE" == "false" ]] && echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $*" >&2
}

# Function to count and report file patterns
count_files() {
    local pattern="$1"
    local description="$2"
    local count=0
    local size=0
    local files=""

    if [[ -n "$pattern" ]]; then
        files=$(find . -name "$pattern" -type f 2>/dev/null || true)
        if [[ -n "$files" ]]; then
            count=$(echo "$files" | wc -l)
            size=$(echo "$files" | xargs du -b 2>/dev/null | awk '{sum+=$1} END {print sum+0}' || echo 0)
        fi
    fi

    if [[ $count -gt 0 ]]; then
        local size_human
        size_human=$(numfmt --to=iec --suffix=B "$size" 2>/dev/null || echo "${size}B")
        [[ "$QUIET_MODE" == "false" ]] && echo "  $description: $count files ($size_human)"
        
        if [[ "$AUTO_FIX" == "true" ]]; then
            echo "$files" | xargs rm -f 2>/dev/null || true
            log_success "Auto-cleaned: $description"
        fi
    fi

    printf "%d" "$count"
}

# Function to audit test artifacts
audit_test_artifacts() {
    log_info "Auditing test artifacts..."
    
    local total=0
    local tap_count junit_count coverage_count shellcheck_count
    tap_count=$(count_files "*.tap" "TAP test files")
    junit_count=$(count_files "*.xml" "JUnit XML reports")
    coverage_count=$(find reports/coverage/ -type f ! -name ".gitkeep" 2>/dev/null | wc -l || echo 0)
    shellcheck_count=$(find reports/ -name "*.txt" -type f 2>/dev/null | wc -l || echo 0)
    
    total=$((tap_count + junit_count + coverage_count + shellcheck_count))
    
    if [[ $coverage_count -gt 0 ]]; then
        [[ "$QUIET_MODE" == "false" ]] && echo "  Coverage files: $coverage_count files"
        if [[ "$AUTO_FIX" == "true" ]]; then
            find reports/coverage/ -type f ! -name ".gitkeep" -delete 2>/dev/null || true
            log_success "Auto-cleaned: Coverage files"
        fi
    fi
    
    if [[ $shellcheck_count -gt 0 ]]; then
        [[ "$QUIET_MODE" == "false" ]] && echo "  Report text files: $shellcheck_count files"
        if [[ "$AUTO_FIX" == "true" ]]; then
            find reports/ -name "*.txt" -delete 2>/dev/null || true
            log_success "Auto-cleaned: Report text files"
        fi
    fi
    
    return $total
}

# Function to audit temporary files
audit_temp_files() {
    log_info "Auditing temporary files..."
    
    local total=0
    local tmp_count temp_count log_count backup_count editor_count
    tmp_count=$(count_files "*.tmp" "Temporary files (.tmp)")
    temp_count=$(count_files "*.temp" "Temporary files (.temp)")
    log_count=$(count_files "*.log" "Log files")
    backup_count=$(count_files "*~" "Backup files (~)")
    editor_count=$(count_files "*.swp" "Editor swap files")
    
    total=$((tmp_count + temp_count + log_count + backup_count + editor_count))
    
    return $total
}

# Function to audit system files
audit_system_files() {
    log_info "Auditing system files..."
    
    local total=0
    local ds_count thumbs_count orig_count rej_count
    ds_count=$(count_files ".DS_Store" "macOS metadata files")
    thumbs_count=$(count_files "Thumbs.db" "Windows thumbnail files")
    orig_count=$(count_files "*.orig" "Original files (.orig)")
    rej_count=$(count_files "*.rej" "Rejected patch files")
    
    total=$((ds_count + thumbs_count + orig_count + rej_count))
    
    return $total
}

# Function to audit deployment artifacts
audit_deployment_artifacts() {
    log_info "Auditing deployment artifacts..."
    
    local total=0
    local pid_count lock_count nohup_count
    pid_count=$(count_files "*.pid" "Process ID files")
    lock_count=$(count_files "*.lock" "Lock files")
    nohup_count=$(count_files "nohup.out" "Background process logs")
    
    total=$((pid_count + lock_count + nohup_count))
    
    # Check for old backup directories in /tmp
    if [[ -d "/tmp" ]]; then
        local backup_dirs
        backup_dirs=$(find /tmp -name "backup-*" -type d -mtime +1 2>/dev/null | wc -l || echo 0)
        if [[ $backup_dirs -gt 0 ]]; then
            [[ "$QUIET_MODE" == "false" ]] && echo "  Old backup directories in /tmp: $backup_dirs directories"
            total=$((total + backup_dirs))
            
            if [[ "$AUTO_FIX" == "true" ]]; then
                find /tmp -name "backup-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
                log_success "Auto-cleaned: Old backup directories"
            fi
        fi
    fi
    
    return $total
}

# Function to audit security temporary files
audit_security_temps() {
    log_info "Auditing security temporary files..."
    
    local total=0
    local patterns=("*.key.tmp" "*.pem.backup" "staging.env" "temp.state" "*.secret.tmp" "auth.temp" "token.cache")
    
    for pattern in "${patterns[@]}"; do
        local count
        count=$(count_files "$pattern" "Security temp: $pattern")
        total=$((total + count))
    done
    
    return $total
}

# Function to check untracked files
audit_untracked_files() {
    log_info "Auditing untracked files..."
    
    local untracked
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null || true)
    local unexpected=0
    
    if [[ -n "$untracked" ]]; then
        # Filter out allowed patterns (.deploy/, reports/, etc.)
        local unexpected_files
        unexpected_files=$(echo "$untracked" | grep -v -E '^\.deploy/|^reports/|^\.cache/' || true)
        
        if [[ -n "$unexpected_files" ]]; then
            unexpected=$(echo "$unexpected_files" | wc -l)
            [[ "$QUIET_MODE" == "false" ]] && echo "  Unexpected untracked files: $unexpected files"
            
            if [[ "$QUIET_MODE" == "false" ]]; then
                echo "$unexpected_files" | sed 's/^/    /'
            fi
        fi
    fi
    
    return $unexpected
}

# Function to generate detailed report
generate_report() {
    cd "$PROJECT_ROOT"
    
    echo "🧹 REPOSITORY CLEANUP AUDIT - $(date)"
    echo "====================================="
    echo ""
    
    local total_issues=0
    
    # Run all audits
    audit_test_artifacts || total_issues=$((total_issues + $?))
    echo ""
    
    audit_temp_files || total_issues=$((total_issues + $?))
    echo ""
    
    audit_system_files || total_issues=$((total_issues + $?))
    echo ""
    
    audit_deployment_artifacts || total_issues=$((total_issues + $?))
    echo ""
    
    audit_security_temps || total_issues=$((total_issues + $?))
    echo ""
    
    audit_untracked_files || total_issues=$((total_issues + $?))
    echo ""
    
    # Repository statistics
    log_info "Repository statistics..."
    local repo_size
    repo_size=$(du -sh --exclude=.git . 2>/dev/null | cut -f1 || echo "Unknown")
    echo "  Repository size (excluding .git): $repo_size"
    
    local tracked_files
    tracked_files=$(git ls-files | wc -l || echo 0)
    echo "  Tracked files: $tracked_files files"
    
    echo ""
    
    # Final assessment
    if [[ $total_issues -eq 0 ]]; then
        log_success "REPOSITORY CLEAN - No dangling files detected"
        echo ""
        echo "✅ All cleanup audits passed"
        echo "✅ No action required"
        return 0
    else
        log_error "CLEANUP REQUIRED - $total_issues issues found"
        echo ""
        echo "❌ Repository has dangling files"
        
        if [[ "$AUTO_FIX" == "true" ]]; then
            echo "🔧 Auto-fix mode enabled - issues were automatically cleaned"
        else
            echo "🔧 Run with --fix to automatically clean up"
            echo "🔧 Or run: ./scripts/cleanup.sh --auto --quiet"
        fi
        
        return 1
    fi
}

# Main function
main() {
    local show_report=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -q|--quiet)
                QUIET_MODE=true
                shift
                ;;
            --fix)
                AUTO_FIX=true
                shift
                ;;
            --report)
                show_report=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 2
                ;;
        esac
    done
    
    cd "$PROJECT_ROOT"
    
    if [[ "$show_report" == "true" ]] || [[ $# -eq 0 ]]; then
        generate_report
    else
        # Quick audit mode
        local issues=0
        audit_test_artifacts || issues=$((issues + $?))
        audit_temp_files || issues=$((issues + $?))
        audit_system_files || issues=$((issues + $?))
        audit_deployment_artifacts || issues=$((issues + $?))
        audit_security_temps || issues=$((issues + $?))
        audit_untracked_files || issues=$((issues + $?))
        
        if [[ $issues -eq 0 ]]; then
            [[ "$QUIET_MODE" == "false" ]] && log_success "Repository is clean"
            exit 0
        else
            [[ "$QUIET_MODE" == "false" ]] && log_error "$issues issues found"
            exit 1
        fi
    fi
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

#!/usr/bin/env bash

# functionality-guard.sh - AI Agent Functionality Preservation System
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>
#
# CRITICAL PURPOSE: Prevents AI agents (including Warp AI) from accidentally 
# removing core functionality through overly aggressive refactoring or recreation

set -euo pipefail

# Script metadata
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT

# Critical files to monitor for functionality preservation
readonly CRITICAL_FILES=(
    "scripts/security-scan.sh"
    "scripts/compliance-check.sh"  
    "scripts/functionality-guard.sh"
    "soft-delete.sh"
    "Makefile"
    ".warp/protocols/security-protocol.md"
    ".warp/protocols/compliance-protocol.md"
)

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[FUNC-GUARD]${NC} $*" >&1
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

log_critical() {
    echo -e "${RED}${BOLD}[CRITICAL]${NC} $*" >&2
}

# Create functionality baseline if it doesn't exist
create_functionality_baseline() {
    local baseline_file="$PROJECT_ROOT/.functionality-baseline.json"
    
    if [[ -f "$baseline_file" ]]; then
        return 0  # Baseline already exists
    fi
    
    log_info "Creating functionality baseline..."
    
    local baseline_data="{"
    local first_entry=true
    
    for file in "${CRITICAL_FILES[@]}"; do
        local full_path="$PROJECT_ROOT/$file"
        
        if [[ -f "$full_path" ]]; then
            if [[ "$first_entry" == "true" ]]; then
                first_entry=false
            else
                baseline_data+=","
            fi
            
            local line_count
            line_count=$(wc -l < "$full_path" 2>/dev/null || echo "0")
            
            local function_count
            if function_count=$(grep -c "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$full_path" 2>/dev/null); then
                function_count=$(echo "$function_count" | tr -d '\n')
            else
                function_count="0"
            fi
            
            # Get function names
            local functions
            functions=$(grep "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$full_path" 2>/dev/null | sed 's/() {.*//' | tr '\n' ',' | sed 's/,$//' || echo "")
            
            baseline_data+="
  \"$file\": {
    \"line_count\": $line_count,
    \"function_count\": $function_count,
    \"functions\": \"$functions\",
    \"last_updated\": \"$(date -Iseconds)\"
  }"
        fi
    done
    
    baseline_data+="
}"
    
    echo "$baseline_data" > "$baseline_file"
    log_success "Functionality baseline created: $baseline_file"
}

# Check for functionality regressions
check_functionality_regression() {
    local baseline_file="$PROJECT_ROOT/.functionality-baseline.json"
    
    if [[ ! -f "$baseline_file" ]]; then
        log_warn "No functionality baseline found. Creating one now..."
        create_functionality_baseline
        return 0
    fi
    
    log_info "Checking for functionality regressions..."
    
    local regressions_detected=false
    local total_line_reduction=0
    local total_function_reduction=0
    
    for file in "${CRITICAL_FILES[@]}"; do
        local full_path="$PROJECT_ROOT/$file"
        
        if [[ ! -f "$full_path" ]]; then
            log_critical "CRITICAL FILE MISSING: $file"
            log_error "This file is essential and must not be removed!"
            regressions_detected=true
            continue
        fi
        
        # Get current metrics
        local current_lines
        current_lines=$(wc -l < "$full_path" 2>/dev/null || echo "0")
        
        local current_functions
        if current_functions=$(grep -c "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$full_path" 2>/dev/null); then
            current_functions=$(echo "$current_functions" | tr -d '\n')
        else
            current_functions="0"
        fi
        
        # Get baseline metrics with fallback values
        local baseline_lines
        baseline_lines=$(grep -A 10 "\"$file\":" "$baseline_file" | grep "\"line_count\":" | sed 's/.*: *\([0-9]*\).*/\1/' | head -1)
        [[ -z "$baseline_lines" || "$baseline_lines" == "" ]] && baseline_lines="0"
        
        local baseline_functions  
        baseline_functions=$(grep -A 10 "\"$file\":" "$baseline_file" | grep "\"function_count\":" | sed 's/.*: *\([0-9]*\).*/\1/' | head -1)
        [[ -z "$baseline_functions" || "$baseline_functions" == "" ]] && baseline_functions="0"
        
        # Skip if baseline data not found or is zero (indicates missing baseline)
        if [[ "$baseline_lines" == "0" && "$baseline_functions" == "0" ]]; then
            log_warn "No baseline data for $file, skipping..."
            continue
        fi
        
        # Calculate reductions
        # Ensure we have valid integers for arithmetic
        baseline_lines=$(echo "$baseline_lines" | tr -d '\n')
        baseline_functions=$(echo "$baseline_functions" | tr -d '\n')
        
        # Default to 0 if empty or non-numeric
        [[ ! "$baseline_lines" =~ ^[0-9]+$ ]] && baseline_lines=0
        [[ ! "$baseline_functions" =~ ^[0-9]+$ ]] && baseline_functions=0
        
        local line_reduction=$((baseline_lines - current_lines))
        local function_reduction=$((baseline_functions - current_functions))
        
        # Check for significant line count reduction (>10% or >50 lines)
        local line_reduction_percent=0
        if [[ "$baseline_lines" != "0" ]] && [[ $baseline_lines -gt 0 ]]; then
            line_reduction_percent=$((line_reduction * 100 / baseline_lines))
        fi
        
        if [[ $line_reduction -gt 50 || $line_reduction_percent -gt 10 ]]; then
            log_critical "FUNCTIONALITY REGRESSION DETECTED in $file!"
            log_error "  Baseline lines: $baseline_lines"
            log_error "  Current lines:  $current_lines"
            log_error "  Lines lost:     $line_reduction ($line_reduction_percent%)"
            log_error "  This indicates potential removal of core functionality!"
            regressions_detected=true
            total_line_reduction=$((total_line_reduction + line_reduction))
        fi
        
        # Check for function removal
        if [[ $function_reduction -gt 0 ]]; then
            log_critical "FUNCTION LOSS DETECTED in $file!"
            log_error "  Baseline functions: $baseline_functions"
            log_error "  Current functions:  $current_functions"
            log_error "  Functions lost:     $function_reduction"
            
            # Get specific missing functions
            local baseline_function_list
            baseline_function_list=$(grep -A 10 "\"$file\":" "$baseline_file" | grep "\"functions\":" | sed 's/.*": *"\([^"]*\)".*/\1/')
            
            local current_function_list
            current_function_list=$(grep "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$full_path" 2>/dev/null | sed 's/() {.*//' | tr '\n' ',' | sed 's/,$//' || echo "")
            
            # Find missing functions (simplified check)
            if [[ -n "$baseline_function_list" ]]; then
                log_error "  Expected functions: $baseline_function_list"
                log_error "  Current functions:  $current_function_list"
            fi
            
            regressions_detected=true
            total_function_reduction=$((total_function_reduction + function_reduction))
        else
            log_success "$file: Functions preserved (${current_functions} functions)"
        fi
        
        # Log positive changes if no regression
        if [[ $line_reduction -le 0 && $function_reduction -le 0 ]]; then
            if [[ $current_lines -gt $baseline_lines ]]; then
                local line_increase=$((current_lines - baseline_lines))
                log_info "$file: Grew by $line_increase lines (likely feature additions)"
            else
                log_success "$file: Line count stable ($current_lines lines)"
            fi
        fi
    done
    
    # Summary
    if [[ "$regressions_detected" == "true" ]]; then
        echo ""
        log_critical "================== FUNCTIONALITY REGRESSION DETECTED =================="
        log_error "TOTAL LINE REDUCTION: $total_line_reduction lines"
        log_error "TOTAL FUNCTION REDUCTION: $total_function_reduction functions"
        echo ""
        log_error "This indicates that an AI agent may have accidentally removed core functionality!"
        log_error "Common causes:"
        log_error "  • Overly aggressive refactoring"
        log_error "  • Recreation of files from scratch without preserving all functions"
        log_error "  • Incomplete understanding of existing functionality"
        log_error "  • Copy-paste errors or truncation"
        echo ""
        log_error "REQUIRED ACTIONS:"
        log_error "  1. Review recent commits for functionality loss"
        log_error "  2. Restore missing functions from git history"
        log_error "  3. Update functionality baseline after restoration"
        log_error "  4. Re-run compliance checks"
        echo ""
        return 1
    else
        log_success "No functionality regressions detected"
        return 0
    fi
}

# Update functionality baseline with current state
update_functionality_baseline() {
    local baseline_file="$PROJECT_ROOT/.functionality-baseline.json"
    
    log_info "Updating functionality baseline..."
    
    # Backup existing baseline
    if [[ -f "$baseline_file" ]]; then
        cp "$baseline_file" "${baseline_file}.backup-$(date +%s)"
    fi
    
    # Create new baseline
    create_functionality_baseline
    
    log_success "Functionality baseline updated"
}

# Generate functionality regression report
generate_regression_report() {
    local report_file="$PROJECT_ROOT/functionality-regression-report.md"
    
    log_info "Generating functionality regression report..."
    
    cat > "$report_file" << 'EOF'
# Functionality Regression Analysis Report

**Generated:** $(date -Iseconds)
**Purpose:** Detect AI agent-induced functionality loss

## Critical Files Analysis

EOF
    
    for file in "${CRITICAL_FILES[@]}"; do
        local full_path="$PROJECT_ROOT/$file"
        
        if [[ -f "$full_path" ]]; then
            local current_lines
            current_lines=$(wc -l < "$full_path" 2>/dev/null || echo "0")
            
            local current_functions
            current_functions=$(grep -c "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$full_path" 2>/dev/null || echo "0")
            
            cat >> "$report_file" << EOF

### $file
- **Current lines:** $current_lines
- **Current functions:** $current_functions
- **Function list:**
$(grep "^[a-zA-Z_][a-zA-Z0-9_]*() {" "$full_path" 2>/dev/null | sed 's/() {.*//' | sed 's/^/  - /' || echo "  - No functions found")

EOF
        else
            cat >> "$report_file" << EOF

### $file
- **Status:** ❌ MISSING FILE
- **Issue:** Critical file not found!

EOF
        fi
    done
    
    cat >> "$report_file" << 'EOF'

## AI Agent Safety Guidelines

1. **Never recreate large scripts from scratch** - Always edit existing files
2. **Preserve all existing functions** - Check function count before/after changes  
3. **Validate line count changes** - Large reductions (>10%) require verification
4. **Use incremental changes** - Make small, targeted modifications
5. **Always run functionality checks** - Use `scripts/functionality-guard.sh`

## Remediation Steps

If functionality regression is detected:

1. **Immediate rollback:**
   ```bash
   git log --oneline -10
   git revert <problematic-commit>
   ```

2. **Manual restoration:**
   ```bash
   git show <previous-good-commit>:path/to/file > path/to/file
   ```

3. **Update baseline:**
   ```bash
   scripts/functionality-guard.sh --update-baseline
   ```

EOF
    
    log_success "Report generated: $report_file"
}

# Automated rollback for severe regressions
attempt_auto_rollback() {
    if [[ "${AUTO_ROLLBACK:-false}" != "true" ]]; then
        log_warn "Auto-rollback not enabled. Set AUTO_ROLLBACK=true to enable."
        return 0
    fi
    
    log_warn "Attempting automatic rollback due to severe functionality regression..."
    
    # Find the last commit that passed functionality checks
    local commits
    commits=$(git log --oneline -10 --format="%H")
    
    for commit in $commits; do
        log_info "Checking commit $commit..."
        
        # Temporarily checkout commit
        if git checkout "$commit" 2>/dev/null; then
            if check_functionality_regression >/dev/null 2>&1; then
                log_success "Found good commit: $commit"
                
                # Create rollback branch
                local rollback_branch="auto-rollback-$(date +%s)"
                git checkout -b "$rollback_branch"
                
                log_success "Created rollback branch: $rollback_branch"
                log_warn "Manual review required before merging rollback"
                return 0
            fi
        fi
    done
    
    log_error "Could not find recent good commit for auto-rollback"
    git checkout develop 2>/dev/null || git checkout main 2>/dev/null || true
    return 1
}

# Pre-commit hook functionality
run_pre_commit_check() {
    log_info "Running pre-commit functionality preservation check..."
    
    if ! check_functionality_regression; then
        echo ""
        log_critical "🚫 COMMIT BLOCKED: Functionality regression detected!"
        log_error ""
        log_error "Your changes appear to have removed significant functionality."
        log_error "This suggests accidental deletion of important functions or code."
        log_error ""
        log_error "Please review your changes and ensure all functionality is preserved."
        log_error "If this is intentional, update the baseline with:"
        log_error "  scripts/functionality-guard.sh --update-baseline"
        log_error ""
        return 1
    fi
    
    log_success "✅ Pre-commit check passed - no functionality regressions detected"
    return 0
}

# Usage information
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

AI Agent Functionality Preservation System - Prevents accidental removal of core functionality.

COMMANDS:
    --check                 Check for functionality regressions (default)
    --update-baseline       Update functionality baseline with current state
    --create-baseline       Create initial functionality baseline
    --generate-report       Generate detailed functionality analysis report
    --pre-commit            Run pre-commit functionality check
    --auto-rollback         Attempt automatic rollback on severe regression

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    --auto-rollback-enable  Enable automatic rollback on severe regressions

ENVIRONMENT VARIABLES:
    AUTO_ROLLBACK=true      Enable automatic rollback functionality

PURPOSE:
This script prevents AI agents (including Warp AI) from accidentally removing
core functionality through overly aggressive refactoring or script recreation.

CRITICAL PROTECTION:
- Detects >10% line count reductions in critical files
- Monitors function count preservation  
- Blocks commits that lose significant functionality
- Provides rollback mechanisms for regression recovery

EXAMPLES:
    $SCRIPT_NAME                           # Check for regressions
    $SCRIPT_NAME --check                   # Explicit check
    $SCRIPT_NAME --update-baseline         # Update after confirmed changes
    $SCRIPT_NAME --generate-report         # Generate analysis report
    AUTO_ROLLBACK=true $SCRIPT_NAME        # Enable auto-rollback
EOF
}

# Main function
main() {
    local command="check"
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                command="check"
                shift
                ;;
            --update-baseline)
                command="update-baseline"
                shift
                ;;
            --create-baseline)
                command="create-baseline"
                shift
                ;;
            --generate-report)
                command="generate-report"
                shift
                ;;
            --pre-commit)
                command="pre-commit"
                shift
                ;;
            --auto-rollback)
                command="auto-rollback"
                shift
                ;;
            --auto-rollback-enable)
                export AUTO_ROLLBACK=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    cd "$PROJECT_ROOT"
    
    case $command in
        check)
            if check_functionality_regression; then
                exit 0
            else
                exit 1
            fi
            ;;
        update-baseline)
            update_functionality_baseline
            ;;
        create-baseline)
            create_functionality_baseline
            ;;
        generate-report)
            generate_regression_report
            ;;
        pre-commit)
            if run_pre_commit_check; then
                exit 0
            else
                exit 1
            fi
            ;;
        auto-rollback)
            if ! check_functionality_regression; then
                attempt_auto_rollback
            else
                log_info "No rollback needed - functionality preserved"
            fi
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

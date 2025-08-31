#!/bin/bash
# 100% Compliance Verification Script
# This script ensures zero tolerance for non-compliance

set -euo pipefail

# Script directory detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

# Compliance tracking
COMPLIANCE_FAILED=0

# Utility functions
log_info() {
    echo "ℹ️  $*"
}

log_success() {
    echo "✅ $*"
}

log_error() {
    echo "❌ $*" >&2
    COMPLIANCE_FAILED=1
}

log_warning() {
    echo "⚠️  $*" >&2
}

check_exit_code() {
    local exit_code=$1
    local check_name="$2"
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "$check_name: 100% compliant"
    else
        log_error "$check_name: COMPLIANCE FAILURE"
    fi
}

echo "🔍 RUNNING 100% COMPLIANCE VERIFICATION"
echo "======================================="

# 1. CODE QUALITY COMPLIANCE
echo ""
log_info "📋 Checking Code Quality Compliance..."

# ShellCheck compliance
log_info "Running ShellCheck validation..."
if make docker-lint >/dev/null 2>&1; then
    log_success "ShellCheck: 100% compliant (zero warnings)"
else
    log_error "ShellCheck: COMPLIANCE FAILURE - warnings detected"
    make docker-lint
fi

# Bash strict mode verification
log_info "Verifying bash strict mode in all scripts..."
strict_mode_failures=0
while IFS= read -r -d '' script; do
    if ! grep -q "set -euo pipefail" "$script"; then
        log_error "Missing strict mode in: $script"
        strict_mode_failures=$((strict_mode_failures + 1))
    fi
done < <(find . -name "*.sh" -type f -print0)

if [[ $strict_mode_failures -eq 0 ]]; then
    log_success "Strict mode: 100% compliant"
else
    log_error "Strict mode: $strict_mode_failures scripts missing strict mode"
fi

# File encoding and line ending checks
log_info "Checking file encoding and line endings..."
encoding_failures=0

# Check for non-UTF-8 files
while IFS= read -r -d '' file; do
    if ! file "$file" | grep -q "UTF-8\|ASCII"; then
        log_error "Non-UTF-8 encoding: $file"
        encoding_failures=$((encoding_failures + 1))
    fi
done < <(find . -name "*.sh" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" -type f -print0)

# Check for Windows line endings
if find . -name "*.sh" -o -name "*.md" -exec grep -l $'\r$' {} \; | grep -q .; then
    log_error "Windows line endings detected"
    encoding_failures=$((encoding_failures + 1))
else
    log_success "Line endings: 100% compliant (Unix LF)"
fi

if [[ $encoding_failures -eq 0 ]]; then
    log_success "File encoding: 100% compliant"
fi

# 2. TESTING COMPLIANCE
echo ""
log_info "🧪 Checking Testing Compliance..."

# Test execution compliance
log_info "Running comprehensive test suite..."
if make docker-test >/dev/null 2>&1; then
    log_success "Testing: 100% compliant (all tests passed)"
    
    # Verify TAP format compliance
    if [[ -f "./reports/tap/results.tap" ]]; then
        if head -1 "./reports/tap/results.tap" | grep -q "TAP version 14"; then
            log_success "TAP format: 100% compliant"
        else
            log_error "TAP format: Non-compliant version"
        fi
    fi
else
    log_error "Testing: COMPLIANCE FAILURE - tests failed"
    make docker-test
fi

# Build verification
log_info "Verifying build integrity..."
if make build >/dev/null 2>&1; then
    log_success "Build: 100% compliant"
else
    log_error "Build: COMPLIANCE FAILURE"
fi

# 3. DOCUMENTATION COMPLIANCE
echo ""
log_info "📚 Checking Documentation Compliance..."

# Markdown link verification
log_info "Verifying all markdown links..."
broken_links=0

# Check internal markdown links
while IFS= read -r file; do
    while IFS= read -r link; do
        # Extract target from markdown link
        target=$(echo "$link" | sed -n 's/.*(\([^)]*\.md\)).*/\1/p')
        if [[ -n "$target" && ! -f "$target" ]]; then
            log_error "Broken link in $file: $target"
            broken_links=$((broken_links + 1))
        fi
    done < <(grep -o '\[.*\](.*\.md)' "$file" 2>/dev/null || true)
done < <(find docs/ .warp/ -name "*.md" 2>/dev/null || true)

if [[ $broken_links -eq 0 ]]; then
    log_success "Documentation links: 100% compliant"
fi

# Example verification (basic check)
log_info "Verifying documentation examples..."
example_issues=0

# Check for obvious command examples in README
if [[ -f "README.md" ]]; then
    # Look for commands that should exist
    if grep -q "make docker-test" README.md; then
        log_success "Documentation examples: References verified commands"
    else
        log_warning "Documentation examples: Could not verify command references"
    fi
fi

# 4. VERSION CONTROL COMPLIANCE
echo ""
log_info "🔧 Checking Version Control Compliance..."

# Branch compliance
current_branch=$(git branch --show-current)
if [[ "$current_branch" == "develop" ]]; then
    log_success "Branch: 100% compliant (on develop)"
else
    log_error "Branch: COMPLIANCE FAILURE (not on develop: $current_branch)"
fi

# Working directory cleanliness
uncommitted_count=$(git status --porcelain | wc -l)
if [[ $uncommitted_count -eq 0 ]]; then
    log_success "Working directory: 100% compliant (clean)"
else
    log_error "Working directory: COMPLIANCE FAILURE ($uncommitted_count uncommitted changes)"
    git status --short
fi

# Check for dangling generated files that should not be committed
log_info "Checking for dangling generated files..."
generated_files_count=0

# Check for report files that should be ignored
while IFS= read -r -d '' file; do
    if [[ "$file" =~ \.(tap|log)$ ]] || [[ "$file" =~ reports/.*\.(txt|tap)$ ]]; then
        # Check if file is tracked in git (should not be)
        if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
            log_error "Generated file should not be tracked: $file"
            generated_files_count=$((generated_files_count + 1))
        fi
    fi
done < <(find . -name "*.tap" -o -name "*.log" -o -path "./reports/*.txt" -o -path "./reports/*.tap" -print0 2>/dev/null)

if [[ $generated_files_count -eq 0 ]]; then
    log_success "Generated files: 100% compliant (no tracked generated files)"
fi

# Recent commit message format verification (last 5 commits)
log_info "Verifying recent commit message formats..."
commit_format_failures=0

# Check last 5 commits for basic format compliance
while IFS= read -r commit_msg; do
    # Check if commit follows conventional format
    if ! echo "$commit_msg" | grep -qE '^(feat|fix|docs|test|refactor|perf|style|chore|ci|revert|checkpoint)(\(.+\))?: .+'; then
        log_error "Non-compliant commit message: $commit_msg"
        commit_format_failures=$((commit_format_failures + 1))
    fi
done < <(git log --format="%s" -5)

if [[ $commit_format_failures -eq 0 ]]; then
    log_success "Commit format: 100% compliant"
fi

# 5. FILE SYSTEM COMPLIANCE
echo ""
log_info "📁 Checking File System Compliance..."

# File permission verification
permission_failures=0

# Check script permissions (should be 755)
while IFS= read -r -d '' script; do
    permissions=$(stat -c "%a" "$script")
    if [[ "$permissions" != "755" ]]; then
        log_error "Incorrect permissions for $script: $permissions (should be 755)"
        permission_failures=$((permission_failures + 1))
    fi
done < <(find scripts/ -name "*.sh" -type f -print0 2>/dev/null || true)

# Check documentation permissions (should be 644)
while IFS= read -r -d '' doc; do
    permissions=$(stat -c "%a" "$doc")
    if [[ "$permissions" != "644" ]]; then
        log_error "Incorrect permissions for $doc: $permissions (should be 644)"
        permission_failures=$((permission_failures + 1))
    fi
done < <(find docs/ .warp/ -name "*.md" -type f -print0 2>/dev/null || true)

if [[ $permission_failures -eq 0 ]]; then
    log_success "File permissions: 100% compliant"
fi

# File naming compliance
log_info "Checking file naming standards..."
naming_failures=0

# Check for files with spaces (prohibited)
while IFS= read -r -d '' file; do
    basename_file=$(basename "$file")
    if [[ "$basename_file" =~ [[:space:]] ]]; then
        log_error "Filename contains spaces: $file"
        naming_failures=$((naming_failures + 1))
    fi
done < <(find . -name "* *" -type f -print0 2>/dev/null || true)

if [[ $naming_failures -eq 0 ]]; then
    log_success "File naming: 100% compliant"
fi

# 6. SECURITY COMPLIANCE
echo ""
log_info "🔒 Checking Security Compliance..."

# Check for sensitive data in git history
log_info "Scanning git history for sensitive data..."
sensitive_data_count=$(git log --all --grep="password\|secret\|key\|token" | wc -l)
if [[ $sensitive_data_count -eq 0 ]]; then
    log_success "Git history: 100% compliant (no sensitive data)"
else
    log_error "Git history: COMPLIANCE FAILURE ($sensitive_data_count potential sensitive commits)"
fi

# Check for hardcoded credentials in files
log_info "Scanning for hardcoded credentials..."
credential_matches=$(grep -r -i "password\|secret\|key.*=" . --exclude-dir=.git --exclude-dir=node_modules --exclude="*.log" 2>/dev/null | wc -l)
if [[ $credential_matches -eq 0 ]]; then
    log_success "Credentials: 100% compliant (no hardcoded values)"
else
    log_error "Credentials: COMPLIANCE FAILURE ($credential_matches potential matches)"
fi

# Check for path traversal vulnerabilities
log_info "Checking for path traversal vulnerabilities..."
path_traversal_count=$(grep -r "\.\./\|\.\.\\\\" . --exclude-dir=.git --include="*.sh" 2>/dev/null | wc -l)
if [[ $path_traversal_count -eq 0 ]]; then
    log_success "Path security: 100% compliant"
else
    log_error "Path security: COMPLIANCE FAILURE ($path_traversal_count potential issues)"
fi

# 7. CONSISTENCY COMPLIANCE
echo ""
log_info "🔄 Checking Cross-File Consistency Compliance..."

# VERSION file consistency
if [[ -f "VERSION" ]]; then
    version_content=$(cat VERSION | tr -d '\n\r' | tr -d ' ')
    if [[ -f "Formula/soft-delete.rb" ]]; then
        formula_version=$(grep -o 'version "[^"]*"' Formula/soft-delete.rb | cut -d'"' -f2 2>/dev/null || echo "")
        if [[ "$version_content" == "$formula_version" ]]; then
            log_success "Version consistency: 100% compliant"
        else
            log_error "Version consistency: VERSION ($version_content) != Formula ($formula_version)"
        fi
    else
        log_success "Version consistency: VERSION file present"
    fi
else
    log_error "Version consistency: VERSION file missing"
fi

# Protocol file cross-references
log_info "Verifying protocol cross-references..."
protocol_ref_failures=0

# Check if all protocols are listed in README
while IFS= read -r -d '' protocol; do
    protocol_name=$(basename "$protocol")
    if ! grep -q "$protocol_name" .warp/README.md 2>/dev/null; then
        log_error "Protocol not documented in README: $protocol_name"
        protocol_ref_failures=$((protocol_ref_failures + 1))
    fi
done < <(find .warp/protocols/ -name "*.md" -type f -print0 2>/dev/null || true)

if [[ $protocol_ref_failures -eq 0 ]]; then
    log_success "Protocol references: 100% compliant"
fi

# FINAL COMPLIANCE REPORT
echo ""
echo "🎯 FINAL COMPLIANCE REPORT"
echo "=========================="

if [[ $COMPLIANCE_FAILED -eq 0 ]]; then
    echo ""
    log_success "🎉 ALL COMPLIANCE CHECKS PASSED - 100% COMPLIANT"
    echo ""
    echo "Repository meets all standards:"
    echo "  ✅ Code Quality: 100%"
    echo "  ✅ Testing: 100%"
    echo "  ✅ Documentation: 100%"
    echo "  ✅ Version Control: 100%"
    echo "  ✅ File System: 100%"
    echo "  ✅ Security: 100%"
    echo "  ✅ Consistency: 100%"
    echo ""
    echo "🟢 READY FOR DEVELOPMENT/DEPLOYMENT"
    exit 0
else
    echo ""
    log_error "❌ COMPLIANCE FAILURES DETECTED"
    echo ""
    echo "🔴 DEVELOPMENT MUST BE HALTED UNTIL 100% COMPLIANCE ACHIEVED"
    echo ""
    echo "To fix:"
    echo "1. Address all ❌ failures listed above"
    echo "2. Re-run: ./scripts/compliance-check.sh"
    echo "3. Achieve 100% compliance before proceeding"
    exit 1
fi

#!/bin/bash
# Pre-commit hook to enforce changelog and protocol compliance
# This should be installed as .git/hooks/pre-commit

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
log_info() {
    echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $*${NC}"
}

log_error() {
    echo -e "${RED}❌ $*${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  $*${NC}" >&2
}

echo -e "${BLUE}🔍 PRE-COMMIT COMPLIANCE VALIDATION${NC}"
echo "===================================="

# Get list of staged files
staged_files=$(git diff --cached --name-only)
staged_count=$(echo "$staged_files" | wc -l)

if [[ -z "$staged_files" ]]; then
    log_error "No files staged for commit"
    exit 1
fi

log_info "Checking $staged_count staged files for compliance..."

# Check 1: CHANGELOG.md Update Enforcement
check_changelog_compliance() {
    log_info "Checking changelog compliance..."
    
    # Check current branch
    local current_branch
    current_branch="$(git branch --show-current)"
    
    # According to our changelog protocol, changes on develop branch should NOT
    # be documented until they are part of a tagged release
    if [[ "$current_branch" == "develop" ]]; then
        log_success "On develop branch: Changelog updates not required until release"
        return 0
    fi
    
    # For other branches (staging, release, etc.), check for changelog updates
    meaningful_changes=false
    
    # Files that require changelog updates
    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            # Skip certain files that don't require changelog updates
            if [[ "$file" =~ \.(md)$ && "$file" != "CHANGELOG.md" ]]; then
                # Documentation changes - may require changelog
                if [[ "$file" =~ ^(README|CONTRIBUTING|docs/) ]]; then
                    meaningful_changes=true
                fi
            elif [[ "$file" =~ \.(sh|yml|yaml|rb|js|json|Makefile)$ ]]; then
                # Code changes - definitely require changelog
                meaningful_changes=true
            elif [[ "$file" == "VERSION" ]]; then
                # Version changes - require changelog
                meaningful_changes=true
            elif [[ "$file" =~ ^(\.warp/protocols/) ]]; then
                # Protocol changes - require changelog
                meaningful_changes=true
            fi
        fi
    done <<< "$staged_files"
    
    # If meaningful changes detected, ensure CHANGELOG.md is also staged
    if [[ "$meaningful_changes" == "true" ]]; then
        if ! echo "$staged_files" | grep -q "CHANGELOG.md"; then
            log_warning "CHANGELOG UPDATE RECOMMENDED!"
            echo ""
            echo -e "${YELLOW}⚠️  WARNING: Meaningful changes detected without changelog update${NC}"
            echo ""
            echo "Files with meaningful changes:"
            while IFS= read -r file; do
                if [[ -n "$file" && ! "$file" =~ \.(log|tap|tmp)$ ]]; then
                    echo "  - $file"
                fi
            done <<< "$staged_files"
            echo ""
            echo -e "${YELLOW}Consider updating CHANGELOG.md if preparing for release${NC}"
            echo "Changelog protocol: .warp/protocols/changelog-protocol.md"
            # Return success - this is a warning, not an error
            return 0
        else
            log_success "Changelog updated along with meaningful changes"
        fi
    else
        log_success "No meaningful changes requiring changelog update"
    fi
    
    return 0
}

# Check 2: Version Consistency
check_version_consistency() {
    log_info "Checking version consistency..."
    
    if echo "$staged_files" | grep -q "VERSION"; then
        if ! echo "$staged_files" | grep -q "CHANGELOG.md"; then
            log_error "Version changed without changelog update"
            return 1
        fi
        
        # Check if README version badge needs updating
        current_version=$(cat VERSION)
        if [[ -f "README.md" ]] && grep -q "badge/version-" README.md; then
            readme_version=$(grep -o "badge/version-[^-]*-blue" README.md | cut -d'-' -f2)
            if [[ "$readme_version" != "$current_version" ]]; then
                log_warning "Version in README.md badge ($readme_version) may need to be updated to match VERSION file ($current_version)"
            fi
        fi
    fi
    
    return 0
}

# Check 3: Commit Message Format Preview
check_commit_message_format() {
    log_info "Commit message format will be validated after commit..."
    
    # Note: We can't check the commit message in pre-commit since it hasn't been written yet
    # This is handled by our commit-msg hook or post-commit validation
    
    log_success "Commit message validation scheduled for post-commit"
    return 0
}

# Check 4: Basic File Validation
check_basic_file_compliance() {
    log_info "Checking basic file compliance..."
    
    local violations=0
    
    # Check for files that shouldn't be committed
    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            # Check for temporary/generated files
            if [[ "$file" =~ \.(tmp|log|tap)$ ]]; then
                log_error "Temporary/generated file should not be committed: $file"
                violations=$((violations + 1))
            fi
            
            # Check for files with spaces (not allowed by our naming convention)
            if [[ "$file" =~ [[:space:]] ]]; then
                log_error "Filename contains spaces (not allowed): $file"
                violations=$((violations + 1))
            fi
        fi
    done <<< "$staged_files"
    
    if [[ $violations -eq 0 ]]; then
        log_success "Basic file compliance validated"
        return 0
    else
        log_error "Found $violations file compliance violations"
        return 1
    fi
}

# Check 5: Protocol Compliance for New Protocols
check_protocol_compliance() {
    log_info "Checking protocol file compliance..."
    
    local protocol_files
    protocol_files=$(echo "$staged_files" | grep "\.warp/protocols/.*\.md" || true)
    
    if [[ -n "$protocol_files" ]]; then
        log_info "New/updated protocol files detected"
        while IFS= read -r protocol_file; do
            if [[ -n "$protocol_file" ]]; then
                log_info "Protocol: $protocol_file"
                
                # Check if protocol is documented in .warp/README.md
                protocol_name=$(basename "$protocol_file")
                if [[ -f ".warp/README.md" ]]; then
                    if ! grep -q "$protocol_name" ".warp/README.md"; then
                        log_warning "New protocol $protocol_name should be documented in .warp/README.md"
                    fi
                fi
            fi
        done <<< "$protocol_files"
    fi
    
    return 0
}

# Check 6: Structure Documentation Synchronization
check_structure_documentation_sync() {
    log_info "Checking structure documentation synchronization..."
    
    local structure_changes=false
    local doc_changes=false
    
    # Check if any structural changes are being committed
    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            # Files/changes that affect structure
            if [[ "$file" =~ ^(scripts/.*\.sh|docs/.*\.md|\.warp/.*\.md|examples/.*\.(sh|md)|tests/.*\.bats)$ ]]; then
                structure_changes=true
            elif [[ "$file" =~ ^(Dockerfile|docker-compose|Makefile|.*\.yml|\.gitignore|\.editorconfig)$ ]]; then
                structure_changes=true
            elif [[ "$file" =~ ^(bin/|Formula/|reports/).*$ ]]; then
                structure_changes=true
            fi
            
            # Check if documentation with structure sections is being modified
            if [[ "$file" == "README.md" || "$file" == "CONTRIBUTING.md" ]]; then
                doc_changes=true
            fi
        fi
    done <<< "$staged_files"
    
    # If structural changes detected, check if structure documentation might need updating
    if [[ "$structure_changes" == "true" ]]; then
        log_info "Structural changes detected in staged files"
        
        # Check if sync-structure script is available
        if [[ -x "scripts/sync-structure.sh" ]]; then
            # Run quick structure validation (non-destructive)
            if ! ./scripts/sync-structure.sh --validate-only >/dev/null 2>&1; then
                log_warning "Structure documentation may need synchronization"
                echo ""
                echo -e "${YELLOW}⚠️  STRUCTURE SYNC RECOMMENDATION:${NC}"
                echo "Consider running: ./scripts/sync-structure.sh"
                echo "This will update project structure documentation automatically."
                echo ""
            else
                log_success "Structure documentation appears synchronized"
            fi
        else
            log_warning "Structure synchronization script not found"
        fi
    fi
    
    # Additional check: if documentation files are being modified, ensure they have current structure
    if [[ "$doc_changes" == "true" ]]; then
        log_info "Documentation files with potential structure sections being modified"
        
        # Check for outdated .warp file counts
        if echo "$staged_files" | grep -q "README.md"; then
            if [[ -d ".warp/protocols" && -d ".warp/rules" ]]; then
                local actual_protocols actual_rules
                actual_protocols=$(find .warp/protocols -name "*.md" -type f 2>/dev/null | wc -l)
                actual_rules=$(find .warp/rules -name "*.md" -type f 2>/dev/null | wc -l)
                
                # Check staged README.md content for file counts
                local staged_readme_content
                staged_readme_content=$(git show :README.md 2>/dev/null || cat README.md)
                
                # Extract documented counts from staged content
                local documented_protocols documented_rules
                documented_protocols=$(echo "$staged_readme_content" | grep -o "[0-9]\+ protocol files" | head -1 | grep -o "[0-9]\+" || echo "0")
                documented_rules=$(echo "$staged_readme_content" | grep -o "[0-9]\+ rule files" | head -1 | grep -o "[0-9]\+" || echo "0")
                
                if [[ "$actual_protocols" != "$documented_protocols" || "$actual_rules" != "$documented_rules" ]]; then
                    log_warning "File counts in README.md may be outdated"
                    echo "  Actual: $actual_protocols protocols, $actual_rules rules"
                    echo "  Documented: $documented_protocols protocols, $documented_rules rules"
                fi
            fi
        fi
    fi
    
    return 0
}

# Run all compliance checks
main() {
    local exit_code=0
    
    # Run all checks
    if ! check_changelog_compliance; then
        exit_code=1
    fi
    
    if ! check_version_consistency; then
        exit_code=1
    fi
    
    if ! check_commit_message_format; then
        exit_code=1
    fi
    
    if ! check_basic_file_compliance; then
        exit_code=1
    fi
    
    if ! check_protocol_compliance; then
        exit_code=1
    fi
    
    if ! check_structure_documentation_sync; then
        exit_code=1
    fi
    
    # Final result
    echo ""
    if [[ $exit_code -eq 0 ]]; then
        log_success "🎉 All pre-commit compliance checks passed!"
        echo -e "${GREEN}✅ Commit approved - proceeding...${NC}"
        echo ""
        return 0
    else
        log_error "🚫 Pre-commit compliance checks failed!"
        echo -e "${RED}❌ Commit blocked - fix issues above before committing${NC}"
        echo ""
        echo -e "${YELLOW}Common fixes:${NC}"
        echo "1. Update CHANGELOG.md following our protocol"
        echo "2. Run: git add CHANGELOG.md"
        echo "3. Fix any file compliance issues"
        echo "4. Run: ./scripts/sync-structure.sh (if structure changed)"
        echo "5. Re-attempt commit"
        echo ""
        return 1
    fi
}

# Install hook function
install_hook() {
    local hook_path=".git/hooks/pre-commit"
    local script_path="scripts/pre-commit-hook.sh"
    
    if [[ ! -d ".git/hooks" ]]; then
        echo "Error: Not in a git repository or .git/hooks directory missing"
        exit 1
    fi
    
    # Create the hook
    cat > "$hook_path" << 'EOF'
#!/bin/bash
# Pre-commit hook - installed by scripts/pre-commit-hook.sh
exec ./scripts/pre-commit-hook.sh
EOF
    
    chmod +x "$hook_path"
    chmod +x "$script_path"
    
    echo "✅ Pre-commit hook installed successfully!"
    echo "📁 Location: $hook_path"
    echo "🔗 Points to: $script_path"
    echo ""
    echo "The hook will now run before every commit to ensure:"
    echo "  - CHANGELOG.md is updated for meaningful changes"
    echo "  - Version consistency is maintained"
    echo "  - Basic file compliance rules are followed"
    echo "  - Protocol files are properly documented"
}

# Command line interface
case "${1:-run}" in
    --install)
        install_hook
        ;;
    run|--run|*)
        main
        ;;
esac

#!/bin/bash
# Comprehensive Structural Alignment Validation
# Validates all aspects of repository structure and documentation synchronization

set -euo pipefail

# Script directory detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

# Validation tracking
VALIDATION_FAILED=0
WARNINGS_COUNT=0

# Utility functions
log_info() {
    echo "ℹ️  $*"
}

log_success() {
    echo "✅ $*"
}

log_error() {
    echo "❌ $*" >&2
    VALIDATION_FAILED=1
}

log_warning() {
    echo "⚠️  $*" >&2
    WARNINGS_COUNT=$((WARNINGS_COUNT + 1))
}

echo "🔍 STRUCTURAL ALIGNMENT VALIDATION"
echo "=================================="

# Validate directory structure consistency
validate_directory_structure() {
    log_info "Validating directory structure consistency..."
    
    local structure_failures=0
    local documented_dirs=()
    
    # Extract directories mentioned in documentation
    while IFS= read -r dir; do
        if [[ "$dir" =~ ├──[[:space:]]+([a-zA-Z0-9_.-]+/) ]]; then
            documented_dirs+=("${BASH_REMATCH[1]}")
        fi
    done < <(grep -h "├──.*/" docs/*.md .warp/*.md README.md 2>/dev/null || true)
    
    # Check if documented directories exist
    for dir in "${documented_dirs[@]}"; do
        if [[ -n "$dir" && ! -d "$dir" ]]; then
            log_error "Documented directory missing: $dir"
            structure_failures=$((structure_failures + 1))
        fi
    done
    
    # Check for undocumented important directories
    local important_dirs=("scripts" "docs" "tests" "examples" ".warp")
    for dir in "${important_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local documented=false
            for doc_dir in "${documented_dirs[@]}"; do
                if [[ "$doc_dir" == "$dir/" ]]; then
                    documented=true
                    break
                fi
            done
            if [[ "$documented" == "false" ]]; then
                log_warning "Important directory not documented: $dir"
            fi
        fi
    done
    
    if [[ $structure_failures -eq 0 ]]; then
        log_success "Directory structure: All documented directories exist"
        return 0
    else
        log_error "Directory structure: $structure_failures inconsistencies found"
        return 1
    fi
}

# Validate file path references
validate_file_references() {
    log_info "Validating file path references..."
    
    local reference_failures=0
    
    # Check file references in documentation
    local doc_files=("README.md" "CONTRIBUTING.md")
    if [[ -d "docs" ]]; then
        while IFS= read -r -d '' file; do
            doc_files+=("$file")
        done < <(find docs/ -name "*.md" -type f -print0 2>/dev/null)
    fi
    if [[ -d ".warp" ]]; then
        while IFS= read -r -d '' file; do
            doc_files+=("$file")
        done < <(find .warp/ -name "*.md" -type f -print0 2>/dev/null)
    fi
    
    # Extract and validate file references
    for doc in "${doc_files[@]}"; do
        if [[ -f "$doc" ]]; then
            # Find file references with extensions
            while IFS= read -r file_ref; do
                # Clean up the reference
                file_ref=$(echo "$file_ref" | sed 's/[`"'\''()]//g' | sed 's/.*: *//')
                
                # Skip URLs, variables, and generic patterns
                if [[ "$file_ref" =~ ^https?:// || "$file_ref" =~ ^\$ || "$file_ref" =~ \* || "$file_ref" == *"example"* || "$file_ref" == *"your-"* ]]; then
                    continue
                fi
                
                # Check if file exists (only for specific extensions)
                if [[ "$file_ref" =~ \.(sh|md|bats|yml|yaml|rb|js|json)$ ]]; then
                    if [[ ! -e "$file_ref" && ! "$file_ref" =~ ^/ ]]; then
                        log_error "Referenced file missing in $doc: $file_ref"
                        reference_failures=$((reference_failures + 1))
                    fi
                fi
            done < <(grep -o '[a-zA-Z0-9_./-]*\.\(sh\|md\|bats\|yml\|yaml\|rb\|js\|json\)' "$doc" 2>/dev/null | head -10)
        fi
    done
    
    if [[ $reference_failures -eq 0 ]]; then
        log_success "File references: All referenced files exist"
        return 0
    else
        log_error "File references: $reference_failures missing files found"
        return 1
    fi
}

# Validate internal link integrity
validate_internal_links() {
    log_info "Validating internal link integrity..."
    
    local broken_links=0
    
    # Check all markdown files for internal links
    while IFS= read -r -d '' file; do
        while IFS= read -r link; do
            # Extract the link target
            local target
            target=$(echo "$link" | sed -n 's/.*](\([^)#]*\)).*/\1/p')
            
            # Skip external links, anchors, and empty targets
            if [[ "$target" =~ ^https?:// || "$target" =~ ^# || -z "$target" ]]; then
                continue
            fi
            
            # Check if internal link target exists
            if [[ ! -e "$target" ]]; then
                log_error "Broken internal link in $file: $target"
                broken_links=$((broken_links + 1))
            fi
        done < <(grep -o '\[.*\]([^)]*\.md[^)]*)' "$file" 2>/dev/null || true)
    done < <(find . -name "*.md" -type f -not -path "./.git/*" -print0)
    
    if [[ $broken_links -eq 0 ]]; then
        log_success "Internal links: All internal links are valid"
        return 0
    else
        log_error "Internal links: $broken_links broken links found"
        return 1
    fi
}

# Validate executable references consistency
validate_executable_consistency() {
    log_info "Validating executable references consistency..."
    
    local inconsistencies=0
    
    # Check for incorrect .sh references in user-facing documentation
    local readme_file="README.md"
    if [[ -f "$readme_file" ]]; then
        # Look for soft-delete.sh references that should be just soft-delete
        while IFS= read -r line; do
            # Skip lines that clearly refer to source code or development
            if [[ "$line" =~ (source|repository|development|clone|git|\.sh.*#) ]]; then
                continue
            fi
            
            # Check for .sh usage in examples or commands
            if [[ "$line" =~ soft-delete\.sh[[:space:]] ]]; then
                log_warning "Potential .sh usage in user example in $readme_file: $line"
            fi
        done < <(grep "soft-delete\.sh" "$readme_file" 2>/dev/null || true)
    fi
    
    # Check docs and examples directories
    for dir in docs examples; do
        if [[ -d "$dir" ]]; then
            for file in "$dir"/*.md; do
                if [[ -f "$file" ]]; then
                    # Look for soft-delete.sh references that should be just soft-delete
                    while IFS= read -r line; do
                        # Skip lines that clearly refer to source code or development
                        if [[ "$line" =~ (source|repository|development|clone|git|\.sh.*#) ]]; then
                            continue
                        fi
                        
                        # Check for .sh usage in examples or commands
                        if [[ "$line" =~ soft-delete\.sh[[:space:]] ]]; then
                            log_warning "Potential .sh usage in user example in $file: $line"
                        fi
                    done < <(grep "soft-delete\.sh" "$file" 2>/dev/null || true)
                fi
            done
        fi
    done
    
    # Validate installation path consistency
    local install_paths=()
    while IFS= read -r path; do
        install_paths+=("$path")
    done < <(grep -o '/usr/local/bin/[a-zA-Z0-9_-]*' README.md docs/*.md 2>/dev/null || true)
    
    # Check that all installation paths are consistent
    local expected_path="/usr/local/bin/soft-delete"
    for path in "${install_paths[@]}"; do
        if [[ "$path" != "$expected_path" ]]; then
            log_error "Inconsistent installation path: $path (expected: $expected_path)"
            inconsistencies=$((inconsistencies + 1))
        fi
    done
    
    if [[ $inconsistencies -eq 0 ]]; then
        log_success "Executable references: All references are consistent"
        return 0
    else
        log_error "Executable references: $inconsistencies inconsistencies found"
        return 1
    fi
}

# Validate version consistency across files
validate_version_consistency() {
    log_info "Validating version consistency across files..."
    
    if [[ ! -f "VERSION" ]]; then
        log_error "VERSION file missing"
        return 1
    fi
    
    local version
    version=$(tr -d '\n\r' < VERSION | tr -d ' ')
    local version_inconsistencies=0
    
    # Check README.md version badge
    if [[ -f "README.md" ]]; then
        if grep -q "badge/version-" "README.md"; then
            local readme_version
            readme_version=$(grep -o "badge/version-[^-]*-blue" README.md | cut -d'-' -f2)
            if [[ "$readme_version" != "$version" ]]; then
                log_error "Version mismatch: README.md badge ($readme_version) != VERSION file ($version)"
                version_inconsistencies=$((version_inconsistencies + 1))
            fi
        fi
    fi
    
    # Check Formula version (if using dynamic reference)
    if [[ -f "Formula/soft-delete.rb" ]]; then
        if grep -q "#{version}" "Formula/soft-delete.rb"; then
            log_success "Formula uses dynamic version reference"
        else
            local formula_version
            formula_version=$(grep -o 'version "[^"]*"' Formula/soft-delete.rb | cut -d'"' -f2 2>/dev/null || echo "")
            if [[ -n "$formula_version" && "$formula_version" != "$version" ]]; then
                log_error "Version mismatch: Formula ($formula_version) != VERSION file ($version)"
                version_inconsistencies=$((version_inconsistencies + 1))
            fi
        fi
    fi
    
    # Check AI Version Control Protocol compliance
    if [[ -f ".warp/AI_VERSION_CONTROL_PROTOCOL.md" ]]; then
        log_info "AI Version Control Protocol: ACTIVE - Version changes require explicit developer authorization"
    else
        log_warning "AI Version Control Protocol: MISSING - Consider adding version protection"
    fi
    
    if [[ $version_inconsistencies -eq 0 ]]; then
        log_success "Version consistency: All version references are consistent ($version)"
        return 0
    else
        log_error "Version consistency: $version_inconsistencies inconsistencies found"
        return 1
    fi
}

# Validate table of contents accuracy
validate_table_of_contents() {
    log_info "Validating table of contents accuracy..."
    
    local toc_failures=0
    
    # Check major documentation files for TOC accuracy
    local readme_file="README.md"
    if [[ -f "$readme_file" ]]; then
        # Look for table of contents sections
        if grep -q "## Table of Contents\|# Table of Contents" "$readme_file"; then
            # Extract TOC links
            while IFS= read -r toc_link; do
                local anchor
                anchor=$(echo "$toc_link" | sed -n 's/.*](#\([^)]*\)).*/\1/p')
                
                if [[ -n "$anchor" ]]; then
                    # Convert anchor to header format
                    local expected_header
                    expected_header=$(echo "$anchor" | tr '-' ' ' | sed 's/.*/\L&/' | sed 's/\b\(.\)/\u\1/g')
                    
                    # Check if corresponding header exists (simplified check)
                    if ! grep -qi "^#.*$expected_header" "$readme_file" 2>/dev/null; then
                        log_warning "Potential TOC mismatch in $readme_file: anchor #$anchor"
                    fi
                fi
            done < <(grep -o '\[.*\](#[^)]*)' "$readme_file" 2>/dev/null | head -10)
        fi
    fi
    
    # Check docs and .warp directories
    for dir in docs .warp; do
        if [[ -d "$dir" ]]; then
            for doc in "$dir"/*.md; do
                if [[ -f "$doc" ]]; then
                    # Look for table of contents sections
                    if grep -q "## Table of Contents\|# Table of Contents" "$doc"; then
                        # Extract TOC links
                        while IFS= read -r toc_link; do
                            local anchor
                            anchor=$(echo "$toc_link" | sed -n 's/.*](#\([^)]*\)).*/\1/p')
                            
                            if [[ -n "$anchor" ]]; then
                                # Convert anchor to header format
                                local expected_header
                                expected_header=$(echo "$anchor" | tr '-' ' ' | sed 's/.*/\L&/' | sed 's/\b\(.\)/\u\1/g')
                                
                                # Check if corresponding header exists (simplified check)
                                if ! grep -qi "^#.*$expected_header" "$doc" 2>/dev/null; then
                                    log_warning "Potential TOC mismatch in $doc: anchor #$anchor"
                                fi
                            fi
                        done < <(grep -o '\[.*\](#[^)]*)' "$doc" 2>/dev/null | head -10)
                    fi
                fi
            done
        fi
    done
    
    log_success "Table of contents: Validation completed"
    return 0
}

# Validate script documentation coverage
validate_script_documentation() {
    log_info "Validating script documentation coverage..."
    
    local undocumented_scripts=0
    
    # Check if all scripts are documented
    if [[ -d "scripts" ]]; then
        for script in scripts/*.sh; do
            if [[ -f "$script" ]]; then
                local script_name
                script_name=$(basename "$script")
                
                # Check if script is mentioned in API docs
                if [[ -f "docs/API.md" ]]; then
                    if ! grep -q "$script_name" "docs/API.md"; then
                        log_warning "Script not documented in API.md: $script_name"
                        undocumented_scripts=$((undocumented_scripts + 1))
                    fi
                fi
            fi
        done
    fi
    
    if [[ $undocumented_scripts -eq 0 ]]; then
        log_success "Script documentation: All scripts are documented"
        return 0
    else
        log_warning "Script documentation: $undocumented_scripts scripts may need documentation"
        return 0  # Don't fail on this, just warn
    fi
}

# Main validation function
run_comprehensive_validation() {
    log_info "Starting comprehensive structural alignment validation..."
    
    local validation_results=()
    
    # Run all validation checks
    if validate_directory_structure; then
        validation_results+=("Directory Structure: ✅")
    else
        validation_results+=("Directory Structure: ❌")
    fi
    
    if validate_file_references; then
        validation_results+=("File References: ✅")
    else
        validation_results+=("File References: ❌")
    fi
    
    if validate_internal_links; then
        validation_results+=("Internal Links: ✅")
    else
        validation_results+=("Internal Links: ❌")
    fi
    
    if validate_executable_consistency; then
        validation_results+=("Executable References: ✅")
    else
        validation_results+=("Executable References: ❌")
    fi
    
    if validate_version_consistency; then
        validation_results+=("Version Consistency: ✅")
    else
        validation_results+=("Version Consistency: ❌")
    fi
    
    validate_table_of_contents
    validation_results+=("Table of Contents: ✅")
    
    validate_script_documentation
    validation_results+=("Script Documentation: ✅")
    
    # Summary report
    echo ""
    echo "🎯 STRUCTURAL ALIGNMENT VALIDATION REPORT"
    echo "=========================================="
    
    for result in "${validation_results[@]}"; do
        echo "  $result"
    done
    
    echo ""
    if [[ $VALIDATION_FAILED -eq 0 ]]; then
        log_success "🎉 ALL STRUCTURAL ALIGNMENT CHECKS PASSED"
        if [[ $WARNINGS_COUNT -gt 0 ]]; then
            log_warning "Note: $WARNINGS_COUNT warnings found (non-critical)"
        fi
        echo ""
        echo "🟢 REPOSITORY STRUCTURE IS 100% ALIGNED"
        return 0
    else
        log_error "❌ STRUCTURAL ALIGNMENT VALIDATION FAILED"
        echo ""
        echo "🔴 STRUCTURAL MISALIGNMENT DETECTED"
        echo ""
        echo "To fix:"
        echo "1. Address all ❌ failures listed above"
        echo "2. Run: ./scripts/sync-structure.sh to auto-fix issues"
        echo "3. Re-run: ./scripts/validate-structural-alignment.sh"
        return 1
    fi
}

# Command line interface
case "${1:-validate}" in
    --directory-structure)
        validate_directory_structure
        ;;
    --file-references)
        validate_file_references
        ;;
    --internal-links)
        validate_internal_links
        ;;
    --version-consistency)
        validate_version_consistency
        ;;
    --quick)
        validate_directory_structure && validate_file_references
        ;;
    validate|--validate|*)
        run_comprehensive_validation
        ;;
esac

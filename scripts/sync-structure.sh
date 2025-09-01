#!/bin/bash
# Structural Synchronization Tool
# Automatically updates documentation to match current repository structure

set -euo pipefail

# Script directory detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

# Utility functions
log_info() {
    echo "ℹ️  $*"
}

log_success() {
    echo "✅ $*"
}

log_error() {
    echo "❌ $*" >&2
}

log_warning() {
    echo "⚠️  $*" >&2
}

# Only show header when running as main script (not when generating tree)
if [[ "${1:-sync}" != "--generate-tree" ]]; then
    echo "🔄 REPOSITORY STRUCTURE SYNCHRONIZATION"
    echo "========================================"
fi

# Generate current directory tree with comprehensive structure
generate_directory_tree() {
    # Generate ONLY the tree structure without any headers or extra output
    echo '```'
    echo "soft-delete/"
    
    # Core files at root level
    [[ -f ".editorconfig" ]] && echo "├── .editorconfig            # Code formatting standards"
    [[ -f ".gitattributes" ]] && echo "├── .gitattributes           # Git file handling configuration"
    [[ -f ".gitignore" ]] && echo "├── .gitignore               # Git ignore patterns"
    [[ -f ".markdownlint.yaml" ]] && echo "├── .markdownlint.yaml       # Markdown linting configuration"
    [[ -f ".shellcheckrc" ]] && echo "├── .shellcheckrc            # Shell script linting configuration"
    
    # Main directories with structure
    if [[ -d ".github" ]]; then
        echo "├── .github/"
        [[ -d ".github/workflows" ]] && echo "│   └── workflows/"
        [[ -f ".github/workflows/release.yml" ]] && echo "│       └── release.yml      # GitHub Actions CI/CD pipeline"
    fi
    
    if [[ -d ".warp" ]]; then
        echo "├── .warp/                   # Warp.dev AI configuration"
        [[ -f ".warp/README.md" ]] && echo "│   ├── README.md            # Warp configuration documentation"
        [[ -f ".warp/project-context.md" ]] && echo "│   ├── project-context.md   # Main project context"
        if [[ -d ".warp/protocols" ]]; then
            echo "│   ├── protocols/           # Development protocols"
            local protocol_count
            protocol_count=$(find .warp/protocols -name "*.md" -type f | wc -l)
            echo "│   │   └── ${protocol_count} protocol files  # Standard workflows and procedures"
        fi
        if [[ -d ".warp/rules" ]]; then
            echo "│   ├── rules/               # AI agent rules and guidelines"
            local rule_count
            rule_count=$(find .warp/rules -name "*.md" -type f | wc -l)
            echo "│   │   └── ${rule_count} rule files        # Behavioral guidelines"
        fi
        [[ -d ".warp/templates" ]] && echo "│   └── templates/           # Rule templates"
    fi
    
    if [[ -d "bin" ]]; then
        echo "├── bin/"
        [[ -f "bin/soft-delete" ]] && echo "│   └── soft-delete          # Built executable"
    fi
    [[ -d "dist" ]] && echo "├── dist/                    # Distribution files"
    
    if [[ -d "docs" ]]; then
        echo "├── docs/                    # Documentation"
        [[ -f "docs/API.md" ]] && echo "│   ├── API.md               # Comprehensive API documentation"
        [[ -f "docs/DEPLOYMENT.md" ]] && echo "│   ├── DEPLOYMENT.md        # Deployment automation guide"
        [[ -f "docs/SECURITY.md" ]] && echo "│   ├── SECURITY.md          # Security policy and reporting"
        [[ -f "docs/TESTING.md" ]] && echo "│   └── TESTING.md           # Testing guide and infrastructure"
    fi
    
    if [[ -d "examples" ]]; then
        echo "├── examples/                # Usage examples"
        [[ -f "examples/README.md" ]] && echo "│   ├── README.md            # Examples documentation"
        [[ -f "examples/basic_usage.sh" ]] && echo "│   ├── basic_usage.sh       # Basic usage examples"
        [[ -f "examples/advanced_usage.sh" ]] && echo "│   └── advanced_usage.sh    # Advanced integration examples"
    fi
    
    if [[ -d "Formula" ]]; then
        echo "├── Formula/"
        [[ -f "Formula/soft-delete.rb" ]] && echo "│   └── soft-delete.rb       # Homebrew formula"
    fi
    if [[ -d "reports" ]]; then
        echo "├── reports/                 # Test reports and artifacts"
        echo "│   └── .gitkeep             # Keep directory in git"
    fi
    
    if [[ -d "scripts" ]]; then
        echo "├── scripts/                 # Utility scripts"
        local script_count
        script_count=$(find scripts -name "*.sh" -type f | wc -l)
        local scripts_array
        mapfile -t scripts_array < <(find scripts -name "*.sh" -type f | sort | head -6)
        for script in "${scripts_array[@]}"; do
            local basename_script
            basename_script=$(basename "$script")
            case "$basename_script" in
                "benchmark.sh") echo "│   ├── benchmark.sh         # Performance testing" ;;
                "cleanup.sh") echo "│   ├── cleanup.sh           # Comprehensive cleanup utility" ;;
                "compliance-check.sh") echo "│   ├── compliance-check.sh  # 100% compliance verification" ;;
                "deploy.sh") echo "│   ├── deploy.sh            # Deployment automation system" ;;
                "run-tests.sh") echo "│   ├── run-tests.sh         # Docker-based test runner" ;;
                "security-scan.sh") echo "│   ├── security-scan.sh     # Security vulnerability scanner" ;;
                *) echo "│   ├── $basename_script" ;;
            esac
        done
        if [[ $script_count -gt 6 ]]; then
            local remaining=$((script_count - 6))
            echo "│   └── ... (${remaining} more scripts)"
        fi
    fi
    
    if [[ -d "tests" ]]; then
        echo "├── tests/                   # Test files"
        [[ -f "tests/edge-cases.bats" ]] && echo "│   ├── edge-cases.bats      # Edge case test suite"
        [[ -f "tests/soft-delete.bats" ]] && echo "│   ├── soft-delete.bats     # Main test suite"
        [[ -f "tests/test_helper.bash" ]] && echo "│   └── test_helper.bash     # Test utilities and helpers"
    fi
    
    # Root-level files
    echo "├── CHANGELOG.md             # Version history"
    echo "├── CONTRIBUTING.md          # Contribution guidelines"
    [[ -f "docker-compose.test.yml" ]] && echo "├── docker-compose.test.yml  # Docker testing environment"
    [[ -f "Dockerfile.runtime" ]] && echo "├── Dockerfile.runtime       # Runtime container"
    [[ -f "Dockerfile.test" ]] && echo "├── Dockerfile.test          # Testing container"
    [[ -f "install.sh" ]] && echo "├── install.sh               # Simple installation script"
    [[ -f "LICENSE" ]] && echo "├── LICENSE                  # MIT License"
    [[ -f "Makefile" ]] && echo "├── Makefile                 # Build automation and development tasks"
    echo "├── README.md                # This file"
    echo "├── soft-delete.sh           # Source script"
    [[ -f "VERSION" ]] && echo "└── VERSION                  # Version information"
    
    echo '```'
}

# Check for duplicate structure sections
check_for_duplicates() {
    local file="$1"
    local duplicates=0
    
    # Count occurrences of structure indicators
    local structure_count
    structure_count=$(grep -c "soft-delete/" "$file" 2>/dev/null || echo 0)
    
    # Check for multiple code blocks with soft-delete/
    if [[ $structure_count -gt 1 ]]; then
        log_error "DUPLICATE DETECTED: Found $structure_count structure sections in $file"
        duplicates=$structure_count
    fi
    
    # Check for sync header duplication
    local header_count
    header_count=$(grep -c "🔄 REPOSITORY STRUCTURE SYNCHRONIZATION" "$file" 2>/dev/null || echo 0)
    if [[ $header_count -gt 0 ]]; then
        log_error "SYNC HEADER CONTAMINATION: Found sync headers in $file (should not exist)"
        duplicates=$((duplicates + header_count))
    fi
    
    return $duplicates
}

# Clean existing duplicate structures
clean_duplicates() {
    local file="$1"
    local temp_file
    temp_file=$(mktemp)
    
    log_info "Cleaning any existing duplicates in $file..."
    
    # Remove sync headers that shouldn't be in the file
    sed '/🔄 REPOSITORY STRUCTURE SYNCHRONIZATION/d; /========================================/d' "$file" > "$temp_file"
    mv "$temp_file" "$file"
    
    # Remove duplicate structure sections (keep only the first one)
    local temp_file2
    temp_file2=$(mktemp)
    
    awk '
    BEGIN { structure_found = 0; in_structure = 0; skip_structure = 0 }
    
    # Detect start of structure section
    /^#+ (Project|Directory) Structure$/ {
        if (structure_found == 0) {
            structure_found = 1
            print $0
            next
        } else {
            # This is a duplicate - skip entire section
            skip_structure = 1
            next
        }
    }
    
    # Handle content within structure sections
    structure_found == 1 && !skip_structure {
        if (/^```/) {
            if (in_structure == 0) {
                in_structure = 1
                print $0
                next
            } else {
                in_structure = 0
                structure_found = 2  # Mark as completed
                print $0
                next
            }
        }
        if (in_structure == 1 || /^$/) {
            print $0
            next
        }
        if (/^#+ /) {
            structure_found = 2  # End of structure section
            print $0
            next
        }
        print $0
        next
    }
    
    # Skip duplicate structure content
    skip_structure == 1 {
        if (/^#+ / && !/^#+ (Project|Directory) Structure$/) {
            skip_structure = 0
            print $0
        }
        next
    }
    
    # Print all other lines
    { print }
    ' "$file" > "$temp_file2"
    
    mv "$temp_file2" "$file"
    log_success "Cleaned duplicates from $file"
}

# Update file listings in documentation
update_file_listings() {
    local file="$1"
    local temp_file
    temp_file=$(mktemp)
    
    log_info "Updating file listings in $file..."
    
    # First, check for and clean any duplicates
    if ! check_for_duplicates "$file"; then
        clean_duplicates "$file"
    fi
    
    # Look for sections that need updating
    if grep -q "# Project Structure\|# Directory Structure\|## Project Structure\|## Directory Structure" "$file"; then
        
        # Simple sed-based replacement approach
        local in_structure=false
        local structure_header_found=false
        
        while IFS= read -r line; do
            # Check for structure header
            if [[ "$line" =~ ^#+[[:space:]]+(Project|Directory)[[:space:]]+Structure[[:space:]]*$ ]]; then
                if [[ "$structure_header_found" == "false" ]]; then
                    echo "$line"
                    echo ""
                    "$0" --generate-tree
                    structure_header_found=true
                    in_structure=true
                    # Skip until we find the closing code block
                    while IFS= read -r inner_line; do
                        if [[ "$inner_line" =~ ^```[[:space:]]*$ ]]; then
                            break
                        fi
                    done
                fi
                # Skip duplicate headers
                continue
            elif [[ "$in_structure" == "true" && "$line" =~ ^```[[:space:]]*$ ]]; then
                in_structure=false
                continue
            elif [[ "$in_structure" == "true" ]]; then
                # Skip content inside structure block
                continue
            else
                echo "$line"
            fi
        done < "$file" > "$temp_file"
        
        if [[ -s "$temp_file" ]]; then
            mv "$temp_file" "$file"
            log_success "Updated structure in $file"
        else
            rm "$temp_file"
            log_error "Failed to update $file"
        fi
    else
        rm -f "$temp_file"
    fi
}

# Update script references in documentation
update_script_references() {
    local file="$1"
    local temp_file
    temp_file=$(mktemp)
    
    log_info "Validating script references in $file..."
    
    # Find all script references and check if they exist
    local script_refs
    script_refs=$(grep -o 'scripts/[a-zA-Z0-9_-]*\.sh' "$file" 2>/dev/null || true)
    
    local updates_needed=false
    if [[ -n "$script_refs" ]]; then
        while IFS= read -r script_ref; do
            if [[ ! -f "$script_ref" ]]; then
                log_warning "Referenced script missing: $script_ref"
                updates_needed=true
            fi
        done <<< "$script_refs"
    fi
    
    if [[ "$updates_needed" == "true" ]]; then
        log_warning "Script references in $file need manual review"
    fi
    
    rm -f "$temp_file"
}

# Preserve existing API documentation (do not regenerate)
preserve_api_docs() {
    log_info "Preserving existing API documentation..."
    
    if [[ -f "docs/API.md" ]]; then
        log_success "API documentation exists and is preserved"
        log_info "Note: API.md contains comprehensive technical documentation"
        log_info "      and should be manually maintained by developers"
    else
        log_warning "API documentation file (docs/API.md) not found"
        log_info "Consider creating comprehensive API documentation"
    fi
}

# Update version references across all files
sync_version_references() {
    if [[ ! -f "VERSION" ]]; then
        log_warning "VERSION file not found, skipping version sync"
        return 0
    fi
    
    local version
    version=$(tr -d '\n\r' < VERSION | tr -d ' ')
    
    log_info "Synchronizing version $version across all files..."
    
    # Update README.md badge
    if [[ -f "README.md" ]]; then
        if grep -q "badge/version-" "README.md"; then
            sed -i "s|badge/version-[^-]*-blue|badge/version-$version-blue|g" "README.md"
            log_success "Updated version badge in README.md"
        fi
    fi
    
    # Update other version references as needed
    local doc_files=()
    if [[ -d "docs" ]]; then
        while IFS= read -r -d '' file; do
            doc_files+=("$file")
        done < <(find docs/ -name "*.md" -type f -print0)
    fi
    if [[ -d ".warp" ]]; then
        while IFS= read -r -d '' file; do
            doc_files+=("$file")
        done < <(find .warp/ -name "*.md" -type f -print0)
    fi
    if [[ -f "CONTRIBUTING.md" ]]; then
        doc_files+=("CONTRIBUTING.md")
    fi
    
    for file in "${doc_files[@]}"; do
        if [[ -f "$file" && -w "$file" ]]; then
            # Look for version patterns and update them (conservatively)
            if grep -q "v[0-9]*\.[0-9]*\.[0-9]*" "$file"; then
                log_info "Version references found in $file (manual review recommended)"
            fi
        fi
    done
}

# Validate cross-references
validate_cross_references() {
    log_info "Validating cross-references between documents..."
    
    local broken_refs=0
    
    # Check internal markdown links
    local check_files=()
    if [[ -d "docs" ]]; then
        while IFS= read -r -d '' file; do
            check_files+=("$file")
        done < <(find docs/ -name "*.md" -type f -print0 2>/dev/null)
    fi
    if [[ -d ".warp" ]]; then
        while IFS= read -r -d '' file; do
            check_files+=("$file")
        done < <(find .warp/ -name "*.md" -type f -print0 2>/dev/null)
    fi
    if [[ -f "README.md" ]]; then
        check_files+=("README.md")
    fi
    if [[ -f "CONTRIBUTING.md" ]]; then
        check_files+=("CONTRIBUTING.md")
    fi
    
    for file in "${check_files[@]}"; do
        if [[ -f "$file" ]]; then
            # Create a temporary file without code blocks to avoid false positives
            local temp_file
            temp_file=$(mktemp)
            
            # Remove code blocks using awk to prevent regex patterns being treated as links
            awk '
                /^```/ { in_code = !in_code; next }
                !in_code { print }
            ' "$file" > "$temp_file"
            
            while IFS= read -r link; do
                local target
                target=$(echo "$link" | sed -n 's/.*](\([^)#]*\)).*/\1/p')
                
                # Skip external links
                if [[ "$target" =~ ^https?:// || "$target" =~ ^# || -z "$target" ]]; then
                    continue
                fi
                
                # Check if target exists
                if [[ ! -e "$target" ]]; then
                    log_error "Broken reference in $file: $target"
                    ((broken_refs++))
                fi
            done < <(grep -o '\[.*\]([^)]*\.md[^)]*)' "$temp_file" 2>/dev/null || true)
            
            rm -f "$temp_file"
        fi
    done
    
    if [[ $broken_refs -eq 0 ]]; then
        log_success "All cross-references are valid"
    else
        log_error "Found $broken_refs broken cross-references"
        return 1
    fi
}

# Validate executable consistency (from validate-structural-alignment.sh)
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

# Validate script documentation coverage (from validate-structural-alignment.sh)
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

# Comprehensive validation function
run_comprehensive_validation() {
    log_info "Running comprehensive structural validation..."
    
    local validation_failed=0
    
    # Run all validation checks
    if ! validate_cross_references; then
        validation_failed=1
    fi
    
    if ! validate_executable_consistency; then
        validation_failed=1
    fi
    
    if ! validate_script_documentation; then
        validation_failed=1
    fi
    
    if [[ $validation_failed -eq 0 ]]; then
        log_success "🎉 All comprehensive validation checks passed!"
        return 0
    else
        log_error "❌ Some validation checks failed"
        return 1
    fi
}

# Final verification after synchronization
final_verification() {
    log_info "Running final verification for duplicate prevention..."
    
    local verification_failed=0
    local docs_to_check=(
        "README.md"
        ".warp/project-context.md"
    )
    
    for doc in "${docs_to_check[@]}"; do
        if [[ -f "$doc" ]]; then
            log_info "Checking $doc for duplicates..."
            
            # Check for duplicates
            if ! check_for_duplicates "$doc"; then
                log_error "VERIFICATION FAILED: Duplicates detected in $doc after synchronization"
                verification_failed=1
            else
                log_success "$doc is clean - no duplicates detected"
            fi
            
            # Verify structure sections are properly formatted
            local structure_blocks
            structure_blocks=$(grep -c "^```$" "$doc" 2>/dev/null || echo 0)
            if [[ $structure_blocks -gt 0 && $((structure_blocks % 2)) -ne 0 ]]; then
                log_error "VERIFICATION FAILED: Unmatched code blocks in $doc"
                verification_failed=1
            fi
        fi
    done
    
    if [[ $verification_failed -eq 0 ]]; then
        log_success "🎉 Final verification passed - no duplicates detected!"
        return 0
    else
        log_error "❌ Final verification failed - duplicates or formatting issues detected"
        return 1
    fi
}

# Main synchronization function
sync_all_documentation() {
    log_info "Starting comprehensive documentation synchronization..."
    
    # Update project structure in key documents (but NOT API.md)
    local docs_to_update=(
        "README.md"
        ".warp/project-context.md"
    )
    
    for doc in "${docs_to_update[@]}"; do
        if [[ -f "$doc" ]]; then
            update_file_listings "$doc"
            update_script_references "$doc"
        fi
    done
    
    # Preserve existing API documentation (do not regenerate)
    preserve_api_docs
    
    # Sync version references
    sync_version_references
    
    # Validate all cross-references
    validate_cross_references
    
    # Final verification to ensure no duplicates were created
    final_verification
    
    log_success "Documentation synchronization complete!"
}

# Command line interface
case "${1:-sync}" in
    --generate-tree)
        generate_directory_tree
        ;;
    --clean-duplicates)
        log_info "Cleaning duplicates from documentation files..."
        for doc in "README.md" ".warp/project-context.md"; do
            if [[ -f "$doc" ]]; then
                if ! check_for_duplicates "$doc"; then
                    clean_duplicates "$doc"
                else
                    log_success "$doc is already clean"
                fi
            fi
        done
        log_success "Duplicate cleaning completed"
        ;;
    --check-duplicates)
        log_info "Checking for duplicates in documentation files..."
        found_duplicates=0
        for doc in "README.md" ".warp/project-context.md"; do
            if [[ -f "$doc" ]]; then
                if ! check_for_duplicates "$doc"; then
                    found_duplicates=1
                fi
            fi
        done
        if [[ $found_duplicates -eq 0 ]]; then
            log_success "No duplicates found in any documentation files"
        else
            log_error "Duplicates found - run with --clean-duplicates to fix"
            exit 1
        fi
        ;;
    --validate-only)
        validate_cross_references
        ;;
    --validate-comprehensive)
        run_comprehensive_validation
        ;;
    --validate-executables)
        validate_executable_consistency
        ;;
    --validate-script-docs)
        validate_script_documentation
        ;;
    --preserve-api)
        preserve_api_docs
        ;;
    --version-sync)
        sync_version_references
        ;;
    --verify)
        final_verification
        ;;
    sync|--sync|*)
        sync_all_documentation
        ;;
esac

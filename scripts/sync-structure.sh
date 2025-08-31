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

echo "🔄 REPOSITORY STRUCTURE SYNCHRONIZATION"
echo "========================================"

# Generate current directory tree
generate_directory_tree() {
    local exclude_dirs=".git|node_modules|__pycache__|\.pytest_cache"
    
    echo "# Project Structure"
    echo ""
    echo '```'
    echo "soft-delete/"
    
    # Generate directory structure
    find . -type d ! -path "./.git/*" ! -path "./node_modules/*" ! -name "__pycache__" | \
    sort | sed 's|[^/]*/|├── |g; s|├── \./|├── |' | head -20
    
    echo ""
    echo "# Key Files"
    
    # List important files with descriptions
    if [[ -f "soft-delete.sh" ]]; then
        echo "├── soft-delete.sh        # Main executable script"
    fi
    if [[ -f "README.md" ]]; then
        echo "├── README.md            # Primary documentation"
    fi
    if [[ -f "CHANGELOG.md" ]]; then
        echo "├── CHANGELOG.md         # Version history"
    fi
    if [[ -f "CONTRIBUTING.md" ]]; then
        echo "├── CONTRIBUTING.md      # Contribution guidelines"
    fi
    if [[ -f "Makefile" ]]; then
        echo "├── Makefile            # Build system"
    fi
    if [[ -f "VERSION" ]]; then
        echo "├── VERSION             # Version file"
    fi
    if [[ -f "install.sh" ]]; then
        echo "├── install.sh          # Installation script"
    fi
    if [[ -d "Formula" ]]; then
        echo "├── Formula/            # Homebrew formula"
    fi
    
    echo '```'
}

# Update file listings in documentation
update_file_listings() {
    local file="$1"
    local temp_file
    temp_file=$(mktemp)
    
    log_info "Updating file listings in $file..."
    
    # Look for sections that need updating
    if grep -q "# Project Structure\|# Directory Structure\|## Project Structure\|## Directory Structure" "$file"; then
        
        # Replace the structure section
        awk '
        /^#+ (Project|Directory) Structure$/ {
            print $0
            print ""
            while ((getline) > 0 && !/^#+ / && !/^```$/) {
                # Skip old content until next section or end of code block
                if (/^```$/) break
            }
            # Insert new structure
            system("cd '"$REPO_ROOT"' && '"$0"' --generate-tree")
            if (/^```$/) next
            if (/^#+ /) print $0
        }
        !/^#+ (Project|Directory) Structure$/ { print }
        ' "$file" > "$temp_file"
        
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

# Generate API documentation based on actual scripts
generate_api_docs() {
    local api_doc="docs/API.md"
    local temp_file
    temp_file=$(mktemp)
    
    log_info "Updating API documentation with current scripts..."
    
    {
        echo "# Soft-Delete API Reference"
        echo ""
        echo "This document provides comprehensive API documentation for the soft-delete utility and its associated scripts."
        echo ""
        echo "## Table of Contents"
        echo ""
        echo "- [Core Utility](#core-utility)"
        echo "- [Build System](#build-system)"
        echo "- [Testing Infrastructure](#testing-infrastructure)"
        echo "- [Utility Scripts](#utility-scripts)"
        echo "- [Configuration Files](#configuration-files)"
        echo ""
        
        echo "## Core Utility"
        echo ""
        if [[ -f "soft-delete.sh" ]]; then
            echo "### soft-delete.sh"
            echo ""
            echo "**Location**: \`soft-delete.sh\`"
            echo "**Purpose**: Main executable that safely moves files and directories to timestamped backup locations"
            echo "**Language**: Bash 4.0+"
            echo ""
            
            # Extract help text if available
            if grep -q "Usage:" "soft-delete.sh"; then
                echo "**Usage**:"
                echo '```bash'
                grep -A 10 "Usage:" "soft-delete.sh" | head -5 | sed 's/^echo "//' | sed 's/"$//'
                echo '```'
                echo ""
            fi
        fi
        
        echo "## Utility Scripts"
        echo ""
        
        # Document all scripts in scripts/ directory
        if [[ -d "scripts" ]]; then
            for script in scripts/*.sh; do
                if [[ -f "$script" ]]; then
                    local script_name
                    script_name=$(basename "$script")
                    echo "### $script_name"
                    echo ""
                    echo "**Location**: \`$script\`"
                    
                    # Extract purpose from comments
                    local purpose
                    purpose=$(head -10 "$script" | grep "^#.*[Pp]urpose\|^#.*[Dd]escription" | head -1 | sed 's/^#[[:space:]]*//' || echo "Utility script")
                    echo "**Purpose**: $purpose"
                    echo ""
                fi
            done
        fi
        
        echo "## Configuration Files"
        echo ""
        
        # Document configuration files
        if [[ -f "Makefile" ]]; then
            echo "### Makefile"
            echo ""
            echo "**Location**: \`Makefile\`"
            echo "**Purpose**: Build system and task automation"
            echo ""
        fi
        
        if [[ -f "VERSION" ]]; then
            echo "### VERSION"
            echo ""
            echo "**Location**: \`VERSION\`"
            echo "**Purpose**: Version information file"
            echo ""
        fi
        
        if [[ -d "Formula" ]]; then
            echo "### Formula/"
            echo ""
            echo "**Location**: \`Formula/\`"
            echo "**Purpose**: Homebrew formula for package distribution"
            echo ""
        fi
        
    } > "$temp_file"
    
    if [[ -s "$temp_file" ]]; then
        mkdir -p "$(dirname "$api_doc")"
        mv "$temp_file" "$api_doc"
        log_success "Generated API documentation: $api_doc"
    else
        rm -f "$temp_file"
        log_error "Failed to generate API documentation"
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
            done < <(grep -o '\[.*\]([^)]*\.md[^)]*)' "$file" 2>/dev/null || true)
        fi
    done
    
    if [[ $broken_refs -eq 0 ]]; then
        log_success "All cross-references are valid"
    else
        log_error "Found $broken_refs broken cross-references"
        return 1
    fi
}

# Main synchronization function
sync_all_documentation() {
    log_info "Starting comprehensive documentation synchronization..."
    
    # Update project structure in key documents
    local docs_to_update=(
        "README.md"
        "docs/API.md"
        ".warp/project-context.md"
    )
    
    for doc in "${docs_to_update[@]}"; do
        if [[ -f "$doc" ]]; then
            update_file_listings "$doc"
            update_script_references "$doc"
        fi
    done
    
    # Generate/update API documentation
    generate_api_docs
    
    # Sync version references
    sync_version_references
    
    # Validate all cross-references
    validate_cross_references
    
    log_success "Documentation synchronization complete!"
}

# Command line interface
case "${1:-sync}" in
    --generate-tree)
        generate_directory_tree
        ;;
    --validate-only)
        validate_cross_references
        ;;
    --api-docs)
        generate_api_docs
        ;;
    --version-sync)
        sync_version_references
        ;;
    sync|--sync|*)
        sync_all_documentation
        ;;
esac

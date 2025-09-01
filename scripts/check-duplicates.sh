#!/usr/bin/env bash
# check-duplicates.sh - Simple duplicate detection for README.md structure
# Prevents the recurring issue of duplicated project structure sections

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "ℹ️  $*"
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

# Check for duplicates in README.md
check_readme_duplicates() {
    local file="README.md"
    
    if [[ ! -f "$file" ]]; then
        log_error "README.md not found"
        return 1
    fi
    
    log_info "Checking $file for duplicate structure sections..."
    
    # Count structure tree occurrences (should be exactly 1)
    local structure_count
    structure_count=$(grep -c "soft-delete/$" "$file" 2>/dev/null || echo 0)
    
    # Count legitimate GitHub URLs (expected)
    local github_count  
    github_count=$(grep -c "github.com/.*soft-delete" "$file" 2>/dev/null || echo 0)
    
    # Count total soft-delete/ occurrences
    local total_count
    total_count=$(grep -c "soft-delete/" "$file" 2>/dev/null || echo 0)
    
    # Calculate expected vs actual
    local expected_total=$((structure_count + github_count))
    
    log_info "Structure analysis:"
    echo "  • Project structure trees: $structure_count"
    echo "  • GitHub URL references: $github_count" 
    echo "  • Total 'soft-delete/' occurrences: $total_count"
    echo "  • Expected total: $expected_total"
    
    # Check for issues
    if [[ $structure_count -eq 0 ]]; then
        log_error "No project structure found - this is unusual"
        return 1
    elif [[ $structure_count -gt 1 ]]; then
        log_error "DUPLICATE DETECTED: Found $structure_count project structure trees (should be 1)"
        echo "Lines with structure trees:"
        grep -n "soft-delete/$" "$file"
        return 1
    elif [[ $total_count -gt $expected_total ]]; then
        log_warning "More 'soft-delete/' references than expected - check manually:"
        grep -n "soft-delete/" "$file"
        return 1
    else
        log_success "No duplicates detected - README.md structure is clean"
        return 0
    fi
}

# Clean duplicates from README.md  
clean_readme_duplicates() {
    local file="README.md"
    
    if [[ ! -f "$file" ]]; then
        log_error "README.md not found"
        return 1
    fi
    
    log_info "Creating backup..."
    cp "$file" "${file}.backup.$(date +%Y%m%d-%H%M%S)"
    
    log_info "Cleaning duplicates from $file..."
    
    # Find the line numbers for Project Structure sections
    local structure_lines
    mapfile -t structure_lines < <(grep -n "### Project Structure" "$file" | cut -d: -f1)
    
    if [[ ${#structure_lines[@]} -le 1 ]]; then
        log_info "Only one or zero Project Structure sections found - nothing to clean"
        return 0
    fi
    
    log_warning "Found ${#structure_lines[@]} Project Structure sections at lines: ${structure_lines[*]}"
    
    # Keep only the first section, remove the rest
    local temp_file
    temp_file=$(mktemp)
    
    local current_line=1
    local in_duplicate=false
    local structure_index=0
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]]+Project[[:space:]]+Structure[[:space:]]*$ ]]; then
            structure_index=$((structure_index + 1))
            if [[ $structure_index -eq 1 ]]; then
                # Keep the first occurrence
                echo "$line" >> "$temp_file"
                in_duplicate=false
            else
                # Start skipping duplicate sections
                in_duplicate=true
            fi
        elif [[ $in_duplicate == true && "$line" =~ ^##[[:space:]] ]]; then
            # End of duplicate section, start keeping content again
            in_duplicate=false
            echo "$line" >> "$temp_file"
        elif [[ $in_duplicate == false ]]; then
            # Keep non-duplicate content
            echo "$line" >> "$temp_file"
        fi
        # Skip lines that are part of duplicate sections
    done < "$file"
    
    mv "$temp_file" "$file"
    log_success "Cleaned duplicates from $file"
}

# Main function
main() {
    case "${1:-check}" in
        check)
            check_readme_duplicates
            ;;
        clean)
            clean_readme_duplicates
            ;;
        *)
            echo "Usage: $0 [check|clean]"
            echo "  check  - Check for duplicate structure sections (default)"
            echo "  clean  - Remove duplicate structure sections"
            exit 1
            ;;
    esac
}

main "$@"

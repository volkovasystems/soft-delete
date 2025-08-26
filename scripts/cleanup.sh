#!/usr/bin/env bash

# cleanup.sh - Comprehensive cleanup script for soft-delete project
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
    echo -e "${BLUE}[INFO]${NC} $*" >&1
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*" >&1
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Usage function
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [CLEANUP_TYPE]

Comprehensive cleanup script for build and deployment artifacts.

CLEANUP_TYPE:
    build           Clean build artifacts only
    temp            Clean temporary files only
    docker          Clean Docker environment only
    reports         Clean test reports only
    dist            Clean distribution packages only
    all             Clean everything (default)
    deployment      Clean deployment-specific artifacts

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
    -n, --dry-run   Show what would be cleaned without doing it
    -f, --force     Force cleanup without confirmation prompts
    -q, --quiet     Suppress output except errors

EXAMPLES:
    $SCRIPT_NAME                    # Clean everything
    $SCRIPT_NAME build              # Clean only build artifacts
    $SCRIPT_NAME -n all             # Dry run - show what would be cleaned
    $SCRIPT_NAME -f docker          # Force Docker cleanup
    $SCRIPT_NAME deployment         # Clean deployment artifacts
EOF
}

# Function to get file count and size for a pattern
get_cleanup_stats() {
    local pattern="$1"
    local description="$2"
    local count=0
    local size=0
    
    if [[ -n "$pattern" ]]; then
        # Count files
        count=$(find . -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' \n' || echo 0)
        
        # Calculate total size if files exist
        if [[ $count -gt 0 ]]; then
            size=$(find . -name "$pattern" -type f -exec du -b {} + 2>/dev/null | awk '{sum+=$1} END {print sum+0}')
        fi
    fi
    
    if [[ $count -gt 0 ]]; then
        local size_human
        size_human=$(numfmt --to=iec --suffix=B "$size" 2>/dev/null || echo "${size}B")
        echo "  $description: $count files ($size_human)"
    fi
}

# Function to show cleanup preview
show_cleanup_preview() {
    local cleanup_type="$1"
    
    log_info "Cleanup Preview for: $cleanup_type"
    echo "=========================="
    
    case "$cleanup_type" in
        build|all)
            get_cleanup_stats "bin/soft-delete" "Build executables"
            if [[ -d "dist" ]]; then
                local dist_count
                dist_count=$(find dist/ -type f 2>/dev/null | wc -l || echo 0)
                if [[ "$dist_count" -gt 0 ]]; then
                    local dist_size
                    dist_size=$(du -sh dist/ 2>/dev/null | cut -f1 || echo "0B")
                    echo "  Distribution packages: $dist_count files ($dist_size)"
                fi
            fi
            ;;
    esac
    
    case "$cleanup_type" in
        temp|all)
            get_cleanup_stats "*.tmp" "Temporary files (.tmp)"
            get_cleanup_stats "*.log" "Log files"
            get_cleanup_stats "*~" "Backup files (~)"
            get_cleanup_stats ".DS_Store" "macOS metadata files"
            get_cleanup_stats "Thumbs.db" "Windows thumbnail files"
            get_cleanup_stats "*.swp" "Vim swap files"
            get_cleanup_stats "*.swo" "Vim swap files (.swo)"
            get_cleanup_stats "*.orig" "Original files (.orig)"
            get_cleanup_stats "*.rej" "Rejected patch files"
            ;;
    esac
    
    case "$cleanup_type" in
        docker|all)
            if command -v docker >/dev/null 2>&1; then
                local docker_images
                docker_images=$(docker images -q "soft-delete*" 2>/dev/null | wc -l || echo 0)
                if [[ $docker_images -gt 0 ]]; then
                    echo "  Docker images: $docker_images images"
                fi
                
                local docker_containers
                docker_containers=$(docker ps -a --filter "name=soft-delete" --format "table {{.Names}}" 2>/dev/null | tail -n +2 | wc -l || echo 0)
                if [[ $docker_containers -gt 0 ]]; then
                    echo "  Docker containers: $docker_containers containers"
                fi
            fi
            ;;
    esac
    
    case "$cleanup_type" in
        reports|all)
            if [[ -d "reports" ]]; then
                local reports_count
                reports_count=$(find reports/ -type f ! -name ".gitkeep" 2>/dev/null | wc -l || echo 0)
                if [[ $reports_count -gt 0 ]]; then
                    local reports_size
                    reports_size=$(du -sh reports/ 2>/dev/null | cut -f1 || echo "0B")
                    echo "  Test reports: $reports_count files ($reports_size)"
                fi
            fi
            ;;
    esac
    
    case "$cleanup_type" in
        deployment|all)
            get_cleanup_stats "*.pid" "Process ID files"
            get_cleanup_stats "*.lock" "Lock files"
            get_cleanup_stats "nohup.out" "Background process logs"
            if [[ -d "/tmp" ]]; then
                local backup_count
                backup_count=$(find /tmp -name "backup-*" -type d 2>/dev/null | wc -l || echo 0)
                if [[ $backup_count -gt 0 ]]; then
                    echo "  Soft-delete backups in /tmp: $backup_count directories"
                fi
            fi
            ;;
    esac
    
    echo ""
}

# Function to perform build cleanup
clean_build() {
    local dry_run="${1:-false}"
    local verbose="${2:-false}"
    
    log_info "Cleaning build artifacts..."
    
    if [[ "$dry_run" == "true" ]]; then
        echo "[DRY RUN] Would remove: bin/soft-delete"
        echo "[DRY RUN] Would remove: dist/ directory"
    else
        [[ "$verbose" == "true" ]] && log_info "Removing build executable..."
        rm -f bin/soft-delete
        
        [[ "$verbose" == "true" ]] && log_info "Removing distribution directory..."
        rm -rf dist/
        
        log_success "Build artifacts cleaned"
    fi
}

# Function to perform temporary file cleanup
clean_temp() {
    local dry_run="${1:-false}"
    local verbose="${2:-false}"
    
    log_info "Cleaning temporary files..."
    
    local temp_patterns=(
        "*.tmp"
        "*.log"
        "*~"
        ".DS_Store"
        "Thumbs.db"
        "*.swp"
        "*.swo"
        "*.orig"
        "*.rej"
    )
    
    for pattern in "${temp_patterns[@]}"; do
        if [[ "$dry_run" == "true" ]]; then
            local count
            count=$(find . -name "$pattern" -type f 2>/dev/null | wc -l || echo 0)
            if [[ $count -gt 0 ]]; then
                echo "[DRY RUN] Would remove $count files matching: $pattern"
            fi
        else
            [[ "$verbose" == "true" ]] && log_info "Removing files matching: $pattern"
            find . -name "$pattern" -type f -delete 2>/dev/null || true
        fi
    done
    
    [[ "$dry_run" == "false" ]] && log_success "Temporary files cleaned"
}

# Function to perform Docker cleanup
clean_docker() {
    local dry_run="${1:-false}"
    local verbose="${2:-false}"
    
    if ! command -v docker >/dev/null 2>&1; then
        log_warn "Docker not found, skipping Docker cleanup"
        return 0
    fi
    
    log_info "Cleaning Docker environment..."
    
    if [[ "$dry_run" == "true" ]]; then
        echo "[DRY RUN] Would run: docker-compose -f docker-compose.test.yml down --volumes --remove-orphans"
        local image_count
        image_count=$(docker images -q "soft-delete*" 2>/dev/null | wc -l || echo 0)
        if [[ $image_count -gt 0 ]]; then
            echo "[DRY RUN] Would remove $image_count Docker images"
        fi
    else
        cd "$PROJECT_ROOT"
        
        [[ "$verbose" == "true" ]] && log_info "Stopping and removing containers..."
        docker-compose -f docker-compose.test.yml down --volumes --remove-orphans 2>/dev/null || true
        
        [[ "$verbose" == "true" ]] && log_info "Removing Docker images..."
        if docker images -q "soft-delete*" 2>/dev/null | head -1 | grep -q .; then
            docker rmi "$(docker images -q "soft-delete*")" 2>/dev/null || true
        fi
        
        log_success "Docker environment cleaned"
    fi
}

# Function to perform reports cleanup
clean_reports() {
    local dry_run="${1:-false}"
    local verbose="${2:-false}"
    
    log_info "Cleaning test reports..."
    
    if [[ "$dry_run" == "true" ]]; then
        if [[ -d "reports" ]]; then
            local count
            count=$(find reports/ -type f ! -name ".gitkeep" 2>/dev/null | wc -l || echo 0)
            if [[ $count -gt 0 ]]; then
                echo "[DRY RUN] Would remove $count report files"
            fi
        fi
    else
        [[ "$verbose" == "true" ]] && log_info "Removing report files..."
        if [[ -d "reports" ]]; then
            find reports/ -type f ! -name ".gitkeep" -delete 2>/dev/null || true
        fi
        
        log_success "Test reports cleaned"
    fi
}

# Function to perform deployment cleanup
clean_deployment() {
    local dry_run="${1:-false}"
    local verbose="${2:-false}"
    
    log_info "Cleaning deployment artifacts..."
    
    local deployment_patterns=(
        "*.pid"
        "*.lock"
        "nohup.out"
    )
    
    for pattern in "${deployment_patterns[@]}"; do
        if [[ "$dry_run" == "true" ]]; then
            local count
            count=$(find . -name "$pattern" -type f 2>/dev/null | wc -l || echo 0)
            if [[ $count -gt 0 ]]; then
                echo "[DRY RUN] Would remove $count files matching: $pattern"
            fi
        else
            [[ "$verbose" == "true" ]] && log_info "Removing files matching: $pattern"
            find . -name "$pattern" -type f -delete 2>/dev/null || true
        fi
    done
    
    # Clean soft-delete backups in /tmp (with caution)
    if [[ -d "/tmp" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            local backup_count
            backup_count=$(find /tmp -name "backup-*" -type d -mtime +1 2>/dev/null | wc -l || echo 0)
            if [[ $backup_count -gt 0 ]]; then
                echo "[DRY RUN] Would remove $backup_count old backup directories in /tmp"
            fi
        else
            [[ "$verbose" == "true" ]] && log_info "Removing old backup directories in /tmp (older than 1 day)..."
            find /tmp -name "backup-*" -type d -mtime +1 -exec rm -rf {} + 2>/dev/null || true
        fi
    fi
    
    [[ "$dry_run" == "false" ]] && log_success "Deployment artifacts cleaned"
}

# Main cleanup function
perform_cleanup() {
    local cleanup_type="$1"
    local dry_run="${2:-false}"
    local verbose="${3:-false}"
    local quiet="${4:-false}"
    
    cd "$PROJECT_ROOT"
    
    if [[ "$quiet" == "false" ]]; then
        show_cleanup_preview "$cleanup_type"
    fi
    
    case "$cleanup_type" in
        build)
            clean_build "$dry_run" "$verbose"
            ;;
        temp)
            clean_temp "$dry_run" "$verbose"
            ;;
        docker)
            clean_docker "$dry_run" "$verbose"
            ;;
        reports)
            clean_reports "$dry_run" "$verbose"
            ;;
        dist)
            clean_build "$dry_run" "$verbose"  # dist is part of build cleanup
            ;;
        deployment)
            clean_deployment "$dry_run" "$verbose"
            ;;
        all)
            clean_build "$dry_run" "$verbose"
            clean_temp "$dry_run" "$verbose"
            clean_docker "$dry_run" "$verbose"
            clean_reports "$dry_run" "$verbose"
            clean_deployment "$dry_run" "$verbose"
            ;;
        *)
            log_error "Unknown cleanup type: $cleanup_type"
            usage
            exit 1
            ;;
    esac
}

# Main function
main() {
    local cleanup_type="all"
    local dry_run=false
    local verbose=false
    local quiet=false
    local force=false
    
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
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            build|temp|docker|reports|dist|deployment|all)
                cleanup_type="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Confirmation prompt (unless force or dry-run)
    if [[ "$force" == "false" && "$dry_run" == "false" && "$quiet" == "false" ]]; then
        echo -n "Are you sure you want to perform '$cleanup_type' cleanup? (y/N) "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Cleanup cancelled"
            exit 0
        fi
    fi
    
    if [[ "$quiet" == "false" ]]; then
        log_info "Starting cleanup process..."
        log_info "Cleanup type: $cleanup_type"
        [[ "$dry_run" == "true" ]] && log_info "Mode: DRY RUN"
        [[ "$verbose" == "true" ]] && log_info "Verbose mode enabled"
    fi
    
    perform_cleanup "$cleanup_type" "$dry_run" "$verbose" "$quiet"
    
    if [[ "$quiet" == "false" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            log_info "Dry run completed. Use without -n/--dry-run to perform actual cleanup."
        else
            log_success "Cleanup completed successfully!"
        fi
    fi
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

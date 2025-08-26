#!/usr/bin/env bash

# run-tests.sh - Docker-based test runner for soft-delete
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

set -euo pipefail

# Script metadata
SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT

# Configuration
readonly DOCKER_COMPOSE_FILE="docker-compose.test.yml"
readonly REPORTS_DIR="reports"

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
Usage: $SCRIPT_NAME [OPTIONS] [TEST_TYPE]

Run BATS tests in Docker with TAP-compliant output.

TEST_TYPE:
    test            Standard test run (default)
    test-verbose    Verbose test output with detailed logs
    test-single     Run single test file
    lint            Run shellcheck linting
    all             Run all test types

OPTIONS:
    -h, --help      Show this help message
    -c, --clean     Clean Docker environment before running
    -r, --reports   Show test reports after completion
    -k, --keep      Keep containers running after tests
    -v, --verbose   Enable verbose output

EXAMPLES:
    $SCRIPT_NAME                    # Run standard tests
    $SCRIPT_NAME test-verbose       # Run with verbose output
    $SCRIPT_NAME -c test            # Clean environment first
    $SCRIPT_NAME -r all             # Run all tests and show reports
    $SCRIPT_NAME lint               # Run only linting
EOF
}

# Function to check dependencies
check_dependencies() {
    local missing=()
    
    if ! command -v docker >/dev/null 2>&1; then
        missing+=("docker")
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        missing+=("docker-compose")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing[*]}"
        log_error "Please install Docker and Docker Compose to continue."
        exit 1
    fi
}

# Function to setup directories
setup_directories() {
    log_info "Setting up test directories..."
    mkdir -p "$PROJECT_ROOT/$REPORTS_DIR"
    mkdir -p "$PROJECT_ROOT/$REPORTS_DIR/tap"
    mkdir -p "$PROJECT_ROOT/$REPORTS_DIR/junit"
    mkdir -p "$PROJECT_ROOT/$REPORTS_DIR/artifacts"
}

# Function to clean Docker environment
clean_docker_environment() {
    log_info "Cleaning Docker test environment..."
    cd "$PROJECT_ROOT"
    docker-compose -f "$DOCKER_COMPOSE_FILE" down --volumes --remove-orphans 2>/dev/null || true
    
    # Remove test images
    if docker images | grep -q "soft-delete"; then
        docker rmi "$(docker images -q "*soft-delete*")" 2>/dev/null || true
    fi
    
    log_success "Docker environment cleaned"
}

# Function to run specific test type
run_test_type() {
    local test_type="$1"
    local keep_containers="${2:-false}"
    
    log_info "Running test type: $test_type"
    cd "$PROJECT_ROOT"
    
    # Build and run tests
    if [[ "$keep_containers" == "true" ]]; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" up --build "$test_type"
    else
        docker-compose -f "$DOCKER_COMPOSE_FILE" up --build --remove-orphans "$test_type"
        docker-compose -f "$DOCKER_COMPOSE_FILE" down
    fi
}

# Function to show test reports
show_test_reports() {
    local reports_dir="$PROJECT_ROOT/$REPORTS_DIR"
    
    log_info "Test Reports Summary:"
    echo "===================="
    
    if [[ -d "$reports_dir" && "$(ls -A "$reports_dir" 2>/dev/null)" ]]; then
        find "$reports_dir" -type f -name "*.tap" -o -name "*.xml" -o -name "*.txt" | while read -r file; do
            echo "📄 $(basename "$file")"
            echo "   Path: $file"
            echo "   Size: $(du -h "$file" | cut -f1)"
            echo "   Modified: $(stat -c %y "$file" 2>/dev/null || stat -f %Sm "$file" 2>/dev/null)"
            echo ""
        done
        
        # Show TAP summary if available
        if find "$reports_dir" -name "*.tap" | head -1 | xargs test -f; then
            log_info "TAP Test Results:"
            find "$reports_dir" -name "*.tap" | head -1 | xargs tail -5
        fi
    else
        log_warn "No test reports found in $reports_dir"
        log_info "Run tests first with: $SCRIPT_NAME test"
    fi
}

# Function to validate TAP output
validate_tap_output() {
    local reports_dir="$PROJECT_ROOT/$REPORTS_DIR"
    
    log_info "Validating TAP output..."
    
    if find "$reports_dir" -name "*.tap" | head -1 | xargs test -f; then
        local tap_file
        tap_file=$(find "$reports_dir" -name "*.tap" | head -1)
        
        # Basic TAP validation
        if grep -q "^TAP version" "$tap_file" && grep -q "^[0-9]*\.\.[0-9]*" "$tap_file"; then
            log_success "TAP output is valid"
            return 0
        else
            log_warn "TAP output may not be properly formatted"
            return 1
        fi
    else
        log_warn "No TAP files found for validation"
        return 1
    fi
}

# Main function
main() {
    local test_type="test"
    local clean_first=false
    local show_reports=false
    local keep_containers=false
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--clean)
                clean_first=true
                shift
                ;;
            -r|--reports)
                show_reports=true
                shift
                ;;
            -k|--keep)
                keep_containers=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            test|test-verbose|test-single|lint|all)
                test_type="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
    
    # Enable verbose mode if requested
    if [[ "$verbose" == "true" ]]; then
        set -x
    fi
    
    log_info "Starting Docker-based test execution..."
    log_info "Test type: $test_type"
    
    # Check dependencies
    check_dependencies
    
    # Setup directories
    setup_directories
    
    # Clean if requested
    if [[ "$clean_first" == "true" ]]; then
        clean_docker_environment
    fi
    
    # Run tests based on type
    case "$test_type" in
        all)
            log_info "Running all test types..."
            run_test_type "test" "$keep_containers"
            run_test_type "test-verbose" "$keep_containers"
            run_test_type "lint" "$keep_containers"
            ;;
        *)
            run_test_type "$test_type" "$keep_containers"
            ;;
    esac
    
    # Validate TAP output
    validate_tap_output
    
    # Show reports if requested
    if [[ "$show_reports" == "true" ]]; then
        show_test_reports
    fi
    
    log_success "Test execution completed!"
    log_info "Reports available in: $PROJECT_ROOT/$REPORTS_DIR"
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

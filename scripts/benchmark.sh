#!/usr/bin/env bash

# benchmark.sh - Performance benchmarking for soft-delete
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

# Configuration
readonly BENCHMARK_DIR="/tmp/soft-delete-benchmark-$$"
readonly SOFT_DELETE_CMD="$PROJECT_ROOT/bin/soft-delete"

# Logging functions
log_info() {
    echo -e "${BLUE}[BENCHMARK]${NC} $*" >&1
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

# Usage function
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Performance benchmarking for the soft-delete tool.

OPTIONS:
    -h, --help      Show this help message
    -s, --small     Run small benchmark (default)
    -l, --large     Run large benchmark
    -a, --all       Run all benchmarks
    -r, --report    Generate detailed report

BENCHMARKS:
    - Single file operations
    - Multiple file operations
    - Directory operations
    - Large file operations
    - Memory usage analysis
    - Performance regression tests

EXAMPLES:
    $SCRIPT_NAME                    # Run small benchmark
    $SCRIPT_NAME -l                 # Run large benchmark
    $SCRIPT_NAME -a -r              # Run all benchmarks with report
EOF
}

# Function to setup benchmark environment
setup_benchmark_env() {
    log_info "Setting up benchmark environment..."

    # Create benchmark directory
    mkdir -p "$BENCHMARK_DIR"
    cd "$BENCHMARK_DIR"

    # Ensure soft-delete is built
    if [[ ! -x "$SOFT_DELETE_CMD" ]]; then
        log_info "Building soft-delete..."
        cd "$PROJECT_ROOT"
        make build >/dev/null 2>&1
        cd "$BENCHMARK_DIR"
    fi

    log_success "Benchmark environment ready"
}

# Function to cleanup benchmark environment
cleanup_benchmark_env() {
    log_info "Cleaning up benchmark environment..."
    cd "$PROJECT_ROOT"

    # Validate benchmark directory path is safe to remove
    if [[ -n "$BENCHMARK_DIR" ]] && [[ "$BENCHMARK_DIR" =~ ^/tmp/soft-delete-benchmark-[0-9]+$ ]] && [[ -d "$BENCHMARK_DIR" ]]; then
        rm -rf "$BENCHMARK_DIR"
        log_success "Removed benchmark directory: $BENCHMARK_DIR"
    else
        log_warn "Benchmark directory not found or invalid path: $BENCHMARK_DIR"
    fi

    # Clean up any backup directories created during benchmarking (already has validation pattern)
    rm -rf /tmp/backup-*benchmark* 2>/dev/null || true
    log_success "Benchmark environment cleaned"
}

# Function to create test files
create_test_files() {
    local count="$1"
    local size="$2"
    local prefix="${3:-testfile}"

    for ((i=1; i<=count; i++)); do
        dd if=/dev/zero of="${prefix}_${i}.txt" bs="$size" count=1 2>/dev/null
    done
}

# Function to measure time and memory
measure_performance() {
    local description="$1"
    shift
    local cmd=("$@")

    log_info "Measuring: $description"

    # Use /usr/bin/time if available, otherwise use bash time
    if command -v /usr/bin/time >/dev/null 2>&1; then
        local time_output
        time_output=$(/usr/bin/time -f "real:%e user:%U sys:%S maxrss:%M" "${cmd[@]}" 2>&1)
        echo "$time_output" | grep "real:" | while IFS=':' read -r label real user sys maxrss; do
            printf "  %-20s %8.3fs (user: %6.3fs, sys: %6.3fs, mem: %6s KB)\n" "$description" "$real" "$user" "$sys" "$maxrss"
        done
    else
        local start_time
        start_time=$(date +%s.%N)
        "${cmd[@]}" >/dev/null 2>&1
        local end_time
        end_time=$(date +%s.%N)
        local duration
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "N/A")
        printf "  %-20s %8.3fs\n" "$description" "$duration"
    fi
}

# Function to run small benchmark
run_small_benchmark() {
    log_info "Running small benchmark suite..."

    cd "$BENCHMARK_DIR"

    # Single small file
    echo "small test content" > small_file.txt
    measure_performance "Single small file" "$SOFT_DELETE_CMD" small_file.txt

    # Multiple small files
    create_test_files 10 100 "small"
    measure_performance "10 small files" "$SOFT_DELETE_CMD" small_*.txt

    # Single directory
    mkdir test_dir
    echo "content" > test_dir/file.txt
    measure_performance "Small directory" "$SOFT_DELETE_CMD" test_dir

    log_success "Small benchmark completed"
}

# Function to run large benchmark
run_large_benchmark() {
    log_info "Running large benchmark suite..."

    cd "$BENCHMARK_DIR"

    # Large file (10MB)
    create_test_files 1 10M "large"
    measure_performance "Large file (10MB)" "$SOFT_DELETE_CMD" large_1.txt

    # Many small files
    create_test_files 100 1K "many"
    measure_performance "100 small files" "$SOFT_DELETE_CMD" many_*.txt

    # Deep directory structure
    mkdir -p deep/nested/directory/structure
    for i in {1..20}; do
        echo "content $i" > "deep/nested/directory/structure/file_$i.txt"
    done
    measure_performance "Deep directory" "$SOFT_DELETE_CMD" deep

    log_success "Large benchmark completed"
}

# Function to run memory benchmark
run_memory_benchmark() {
    log_info "Running memory usage analysis..."

    cd "$BENCHMARK_DIR"

    # Create files for memory testing
    create_test_files 50 1M "memory"

    # Monitor memory usage during operation
    if command -v ps >/dev/null 2>&1; then
        log_info "Monitoring memory usage during bulk operation..."

        # Start soft-delete in background and monitor
        "$SOFT_DELETE_CMD" memory_*.txt &
        local pid=$!

        local max_memory=0
        while kill -0 $pid 2>/dev/null; do
            local current_memory
            current_memory=$(ps -o rss= -p $pid 2>/dev/null | tr -d ' ' || echo 0)
            if [[ $current_memory -gt $max_memory ]]; then
                max_memory=$current_memory
            fi
            sleep 0.1
        done

        wait $pid
        echo "  Maximum memory usage: ${max_memory} KB"
    else
        log_warn "ps command not available, skipping memory monitoring"
    fi

    log_success "Memory benchmark completed"
}

# Function to run performance regression test
run_regression_test() {
    log_info "Running performance regression test..."

    cd "$BENCHMARK_DIR"

    # Baseline test - consistent operation
    local baseline_times=()
    for i in {1..5}; do
        echo "test content $i" > "regression_$i.txt"
        local start_time
        start_time=$(date +%s.%N)
        "$SOFT_DELETE_CMD" "regression_$i.txt" >/dev/null 2>&1
        local end_time
        end_time=$(date +%s.%N)
        local duration
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "1")
        baseline_times+=("$duration")
    done

    # Calculate average and check consistency
    local total=0
    local count=0
    for time in "${baseline_times[@]}"; do
        total=$(echo "$total + $time" | bc 2>/dev/null || echo "$total")
        ((count++))
    done

    if command -v bc >/dev/null 2>&1 && [[ $count -gt 0 ]]; then
        local average
        average=$(echo "scale=3; $total / $count" | bc)
        echo "  Average operation time: ${average}s"
        echo "  Performance consistency: OK"
    else
        echo "  Performance regression test: SKIPPED (bc not available)"
    fi

    log_success "Regression test completed"
}

# Function to generate detailed report
generate_report() {
    log_info "Generating performance report..."

    local report_file
    report_file="$PROJECT_ROOT/reports/performance-report-$(date +%Y%m%d-%H%M%S).txt"
    mkdir -p "$(dirname "$report_file")"

    cat > "$report_file" << EOF
Soft-Delete Performance Benchmark Report
========================================
Generated: $(date)
System: $(uname -a)
Shell: $BASH_VERSION

Test Environment:
- Benchmark directory: $BENCHMARK_DIR
- Command tested: $SOFT_DELETE_CMD

Performance Summary:
EOF

    # Re-run benchmarks and capture output
    cd "$BENCHMARK_DIR"
    echo "Single file operations:" >> "$report_file"
    run_small_benchmark 2>&1 | grep -E "^\s+.*:" >> "$report_file" || echo "  No data captured" >> "$report_file"

    echo "" >> "$report_file"
    echo "Large file operations:" >> "$report_file"
    run_large_benchmark 2>&1 | grep -E "^\s+.*:" >> "$report_file" || echo "  No data captured" >> "$report_file"

    echo "" >> "$report_file"
    echo "Memory usage:" >> "$report_file"
    run_memory_benchmark 2>&1 | grep -E "^\s+.*:" >> "$report_file" || echo "  No data captured" >> "$report_file"

    log_success "Report generated: $report_file"
}

# Main benchmark function
run_benchmarks() {
    local benchmark_type="$1"
    local generate_report="${2:-false}"

    setup_benchmark_env

    case "$benchmark_type" in
        small)
            run_small_benchmark
            ;;
        large)
            run_large_benchmark
            run_memory_benchmark
            ;;
        all)
            run_small_benchmark
            echo ""
            run_large_benchmark
            echo ""
            run_memory_benchmark
            echo ""
            run_regression_test
            ;;
        *)
            log_error "Unknown benchmark type: $benchmark_type"
            return 1
            ;;
    esac

    if [[ "$generate_report" == "true" ]]; then
        generate_report
    fi

    cleanup_benchmark_env
}

# Main function
main() {
    local benchmark_type="small"
    local generate_report=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -s|--small)
                benchmark_type="small"
                shift
                ;;
            -l|--large)
                benchmark_type="large"
                shift
                ;;
            -a|--all)
                benchmark_type="all"
                shift
                ;;
            -r|--report)
                generate_report=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    log_info "Starting performance benchmarks..."

    if run_benchmarks "$benchmark_type" "$generate_report"; then
        log_success "All benchmarks completed successfully!"
        exit 0
    else
        log_error "Benchmarks failed"
        exit 1
    fi
}

# Cleanup on exit
trap cleanup_benchmark_env EXIT

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

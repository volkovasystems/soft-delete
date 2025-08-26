# Test helper functions for soft-delete tests
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

# Load BATS libraries if available
if [[ -n "${BATS_LIB_PATH:-}" ]]; then
    for lib_path in $(echo "$BATS_LIB_PATH" | tr ':' ' '); do
        if [[ -d "$lib_path/load.bash" ]]; then
            # shellcheck disable=SC1090
            source "$lib_path/load.bash"
        fi
    done
fi

# TAP-compliant logging functions
tap_pass() {
    echo "# PASS: $*"
}

tap_fail() {
    echo "# FAIL: $*"
}

tap_skip() {
    echo "# SKIP: $*"
}

tap_todo() {
    echo "# TODO: $*"
}

tap_diagnostic() {
    echo "# $*"
}

# Helper function to create test files with specific content
create_test_file() {
    local filename="$1"
    local content="${2:-test content}"
    echo "$content" > "$filename"
}

# Helper function to create test directories with files
create_test_directory() {
    local dirname="$1"
    local filename="${2:-test_file.txt}"
    local content="${3:-test content}"
    
    mkdir -p "$dirname"
    echo "$content" > "$dirname/$filename"
}

# Helper function to extract backup path from soft-delete output
extract_backup_path() {
    local output="$1"
    echo "$output" | grep -o "/tmp/backup-[^']*"
}

# Helper function to verify backup exists and has correct content
verify_backup() {
    local backup_path="$1"
    local expected_content="$2"
    
    [ -e "$backup_path" ] || return 1
    
    if [ -f "$backup_path" ]; then
        [ "$(cat "$backup_path")" = "$expected_content" ]
    elif [ -d "$backup_path" ]; then
        [ -d "$backup_path" ]
    else
        return 1
    fi
}

# Helper function to clean up backup directories (for test isolation)
cleanup_backups() {
    rm -rf /tmp/backup-* 2>/dev/null || true
}

# Helper function to count backup directories
count_backups() {
    ls -d /tmp/backup-* 2>/dev/null | wc -l || echo 0
}

# Helper function to create files with specific permissions
create_executable_file() {
    local filename="$1"
    local content="${2:-#!/bin/bash\necho 'test script'}"
    
    echo -e "$content" > "$filename"
    chmod +x "$filename"
}

# Helper function to create symlinks
create_symlink() {
    local target="$1"
    local linkname="$2"
    
    ln -s "$target" "$linkname"
}

# Helper function to setup complex directory structure
setup_complex_structure() {
    mkdir -p deep/nested/structure
    create_test_file "deep/file1.txt" "content1"
    create_test_file "deep/nested/file2.txt" "content2"
    create_test_file "deep/nested/structure/file3.txt" "content3"
    create_executable_file "deep/script.sh" "#!/bin/bash\necho 'deep script'"
}

# Debug helper - print test environment info
print_test_env() {
    echo "Test environment:"
    echo "  PWD: $(pwd)"
    echo "  TEST_DIR: ${TEST_DIR:-not set}"
    echo "  Available files: $(ls -la)"
    echo "  Backup count: $(count_backups)"
}

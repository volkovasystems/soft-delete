#!/usr/bin/env bats

# edge-cases.bats - Comprehensive edge case tests for soft-delete
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

# Load test helpers
# shellcheck disable=SC1091,SC2154
source "${BATS_TEST_DIRNAME}/test_helper.bash"

# Set up test environment
setup() {
    # Create a unique test directory for this test run
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR" || exit
    
    # Ensure we start with clean backup state
    cleanup_backups
    
    # Set executable path
    SOFT_DELETE="${BATS_TEST_DIRNAME}/../bin/soft-delete"
    
    # Ensure the executable exists and is executable
    [[ -x "$SOFT_DELETE" ]]
}

# Clean up after each test
teardown() {
    # shellcheck disable=SC2154
    cd "$BATS_TEST_DIRNAME" || exit
    rm -rf "$TEST_DIR"
    cleanup_backups
}

# Test special characters in filenames
@test "handle files with spaces in names" {
    local file_with_spaces="file with spaces.txt"
    create_test_file "$file_with_spaces" "content with spaces"
    
    run "$SOFT_DELETE" "$file_with_spaces"
    [ "$status" -eq 0 ]
    [[ $output =~ Soft\ deleted:\ \'$file_with_spaces\' ]]
    [ ! -e "$file_with_spaces" ]
    
    # Verify backup exists with correct content
    local backup_path
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "content with spaces"
}

@test "handle files with special characters" {
    local special_file="file-with-special-chars!@#$%.txt"
    create_test_file "$special_file" "special content"
    
    run "$SOFT_DELETE" "$special_file"
    [ "$status" -eq 0 ]
    [ ! -e "$special_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "special content"
}

@test "handle files with unicode characters" {
    local unicode_file="файл-тест-中文-🚀.txt"
    create_test_file "$unicode_file" "unicode content"
    
    run "$SOFT_DELETE" "$unicode_file"
    [ "$status" -eq 0 ]
    [ ! -e "$unicode_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "unicode content"
}

@test "handle files starting with dash" {
    local dash_file="-file-starting-with-dash.txt"
    create_test_file "$dash_file" "dash content"
    
    run "$SOFT_DELETE" -- "$dash_file"
    [ "$status" -eq 0 ]
    [ ! -e "$dash_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "dash content"
}

@test "handle hidden files (dotfiles)" {
    local hidden_file=".hidden-file"
    create_test_file "$hidden_file" "hidden content"
    
    run "$SOFT_DELETE" "$hidden_file"
    [ "$status" -eq 0 ]
    [ ! -e "$hidden_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "hidden content"
}

@test "handle very long filenames" {
    local long_filename
    long_filename="$(printf 'a%.0s' {1..200}).txt"
    create_test_file "$long_filename" "long filename content"
    
    run "$SOFT_DELETE" "$long_filename"
    [ "$status" -eq 0 ]
    [ ! -e "$long_filename" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "long filename content"
}

@test "handle empty files" {
    local empty_file="empty.txt"
    touch "$empty_file"
    
    run "$SOFT_DELETE" "$empty_file"
    [ "$status" -eq 0 ]
    [ ! -e "$empty_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -f "$backup_path" ]
    [ ! -s "$backup_path" ]  # File should be empty
}

@test "handle very large files" {
    local large_file="large.txt"
    # Create a 1MB file
    dd if=/dev/zero of="$large_file" bs=1024 count=1024 2>/dev/null
    
    run "$SOFT_DELETE" "$large_file"
    [ "$status" -eq 0 ]
    [ ! -e "$large_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -f "$backup_path" ]
    # Check file size is approximately 1MB (allowing for some variation)
    local size
    size=$(stat -c%s "$backup_path" 2>/dev/null || stat -f%z "$backup_path" 2>/dev/null)
    [ "$size" -gt 1000000 ]
}

@test "handle binary files" {
    local binary_file="binary.dat"
    # Create a binary file with null bytes
    printf '\x00\x01\x02\x03\xFF\xFE\xFD' > "$binary_file"
    
    run "$SOFT_DELETE" "$binary_file"
    [ "$status" -eq 0 ]
    [ ! -e "$binary_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -f "$backup_path" ]
    # Verify binary content is preserved
    local original_checksum backup_checksum
    original_checksum=$(printf '\x00\x01\x02\x03\xFF\xFE\xFD' | md5sum | cut -d' ' -f1)
    backup_checksum=$(md5sum "$backup_path" | cut -d' ' -f1)
    [ "$original_checksum" = "$backup_checksum" ]
}

@test "handle symbolic links" {
    local target_file="target.txt"
    local symlink_file="link.txt"
    
    create_test_file "$target_file" "target content"
    create_symlink "$target_file" "$symlink_file"
    
    run "$SOFT_DELETE" "$symlink_file"
    [ "$status" -eq 0 ]
    [ ! -e "$symlink_file" ]
    [ -e "$target_file" ]  # Target should still exist
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -L "$backup_path" ]  # Should be a symlink in backup
}

@test "handle broken symbolic links" {
    local symlink_file="broken-link.txt"
    
    # Create a symlink to non-existent file
    ln -s "non-existent-file.txt" "$symlink_file"
    
    run "$SOFT_DELETE" "$symlink_file"
    [ "$status" -eq 0 ]
    [ ! -L "$symlink_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -L "$backup_path" ]  # Should be a broken symlink in backup
}

@test "handle directories with special permissions" {
    local special_dir="special-perms-dir"
    
    mkdir "$special_dir"
    create_test_file "$special_dir/file.txt" "permission test"
    chmod 750 "$special_dir"
    
    run "$SOFT_DELETE" "$special_dir"
    [ "$status" -eq 0 ]
    [ ! -e "$special_dir" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -d "$backup_path" ]
    # Check permissions are preserved (750 = rwxr-x---)
    local perms
    perms=$(stat -c%a "$backup_path" 2>/dev/null || stat -f%Lp "$backup_path" 2>/dev/null)
    [ "$perms" = "750" ]
}

@test "handle files with no read permission" {
    skip "Cannot test files without read permission as user needs read access to move them"
}

@test "handle deep directory nesting" {
    local deep_dir="level1/level2/level3/level4/level5"
    
    mkdir -p "$deep_dir"
    create_test_file "$deep_dir/deep-file.txt" "deep content"
    
    run "$SOFT_DELETE" "level1"
    [ "$status" -eq 0 ]
    [ ! -e "level1" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -d "$backup_path" ]
    [ -f "$backup_path/level2/level3/level4/level5/deep-file.txt" ]
    verify_backup "$backup_path/level2/level3/level4/level5/deep-file.txt" "deep content"
}

@test "handle many files in directory" {
    local many_files_dir="many-files"
    
    mkdir "$many_files_dir"
    for i in {1..100}; do
        create_test_file "$many_files_dir/file$i.txt" "content $i"
    done
    
    run "$SOFT_DELETE" "$many_files_dir"
    [ "$status" -eq 0 ]
    [ ! -e "$many_files_dir" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -d "$backup_path" ]
    # Check a few random files
    verify_backup "$backup_path/file1.txt" "content 1"
    verify_backup "$backup_path/file50.txt" "content 50"
    verify_backup "$backup_path/file100.txt" "content 100"
}

@test "handle concurrent operations" {
    local file1="concurrent1.txt"
    local file2="concurrent2.txt"
    
    create_test_file "$file1" "concurrent content 1"
    create_test_file "$file2" "concurrent content 2"
    
    # Run two operations simultaneously
    "$SOFT_DELETE" "$file1" &
    local pid1=$!
    "$SOFT_DELETE" "$file2" &
    local pid2=$!
    
    wait $pid1
    local status1=$?
    wait $pid2
    local status2=$?
    
    # Both operations should succeed
    [ $status1 -eq 0 ]
    [ $status2 -eq 0 ]
    [ ! -e "$file1" ]
    [ ! -e "$file2" ]
    
    # Should have created 2 backup directories
    local backup_count
    backup_count=$(count_backups)
    [ "$backup_count" -eq 2 ]
}

@test "handle filesystem edge cases - path with trailing slash" {
    local dir_with_slash="testdir/"
    
    mkdir "testdir"
    create_test_file "testdir/file.txt" "trailing slash test"
    
    run "$SOFT_DELETE" "$dir_with_slash"
    [ "$status" -eq 0 ]
    [ ! -e "testdir" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -d "$backup_path" ]
    verify_backup "$backup_path/file.txt" "trailing slash test"
}

@test "handle relative paths with parent directory references" {
    local parent_dir="../parent-test"
    
    mkdir -p ../parent-test
    create_test_file "../parent-test/parent-file.txt" "parent test content"
    
    run "$SOFT_DELETE" "$parent_dir"
    [ "$status" -eq 0 ]
    [ ! -e "../parent-test" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -d "$backup_path" ]
    verify_backup "$backup_path/parent-file.txt" "parent test content"
}

@test "handle files in /tmp directory" {
    local tmp_file="/tmp/soft-delete-test-$$"
    
    create_test_file "$tmp_file" "tmp content"
    
    run "$SOFT_DELETE" "$tmp_file"
    [ "$status" -eq 0 ]
    [ ! -e "$tmp_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "tmp content"
}

@test "handle files with newlines in content" {
    local newline_file="newlines.txt"
    
    printf "line1\nline2\nline3\n" > "$newline_file"
    
    run "$SOFT_DELETE" "$newline_file"
    [ "$status" -eq 0 ]
    [ ! -e "$newline_file" ]
    
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -f "$backup_path" ]
    
    # Verify content with newlines is preserved
    local backup_content
    backup_content=$(cat "$backup_path")
    [[ "$backup_content" == $'line1\nline2\nline3' ]]
}

@test "handle rapid successive operations" {
    local files=()
    
    # Create multiple files quickly
    for i in {1..10}; do
        local file="rapid$i.txt"
        files+=("$file")
        create_test_file "$file" "rapid content $i"
    done
    
    # Delete them rapidly
    for file in "${files[@]}"; do
        run "$SOFT_DELETE" "$file"
        [ "$status" -eq 0 ]
        [ ! -e "$file" ]
    done
    
    # Should have created 10 backup directories
    local backup_count
    backup_count=$(count_backups)
    [ "$backup_count" -eq 10 ]
}

@test "verify unique backup directory names under high frequency" {
    local backup_dirs=()
    
    # Create and delete files in quick succession
    for i in {1..5}; do
        local file="unique$i.txt"
        create_test_file "$file" "unique content $i"
        
        run "$SOFT_DELETE" "$file"
        [ "$status" -eq 0 ]
        
        local backup_path
        backup_path=$(extract_backup_path "$output")
        backup_dirs+=("$(dirname "$backup_path")")
    done
    
    # Verify all backup directories are unique
    local unique_dirs
    unique_dirs=$(printf '%s\n' "${backup_dirs[@]}" | sort -u | wc -l)
    [ "$unique_dirs" -eq 5 ]
}

@test "handle error recovery - insufficient disk space simulation" {
    skip "Cannot easily simulate disk space issues in test environment"
}

@test "handle error recovery - permission denied during move" {
    skip "Complex permission scenarios require root access to test properly"
}

@test "verify no data corruption under stress" {
    local stress_dir="stress-test"
    
    mkdir "$stress_dir"
    
    # Create files with known checksums
    local expected_checksums=()
    for i in {1..20}; do
        local file="$stress_dir/stress$i.txt"
        local content
        content=$(openssl rand -base64 $((i * 100)) 2>/dev/null || head -c $((i * 100)) /dev/urandom | base64 2>/dev/null || echo "fallback content $i")
        echo "$content" > "$file"
        
        local checksum
        checksum=$(md5sum "$file" | cut -d' ' -f1)
        expected_checksums+=("$checksum")
    done
    
    run "$SOFT_DELETE" "$stress_dir"
    [ "$status" -eq 0 ]
    [ ! -e "$stress_dir" ]
    
    # Verify all files in backup have correct checksums
    local backup_path
    backup_path=$(extract_backup_path "$output")
    [ -d "$backup_path" ]
    
    for i in {1..20}; do
        local backup_file="$backup_path/stress$i.txt"
        [ -f "$backup_file" ]
        
        local backup_checksum
        backup_checksum=$(md5sum "$backup_file" | cut -d' ' -f1)
        [ "$backup_checksum" = "${expected_checksums[$((i-1))]}" ]
    done
}

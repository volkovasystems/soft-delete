#!/usr/bin/env bats

# Tests for soft-delete script
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

# Load test helpers
load test_helper

# Setup function run before each test
setup() {
    # Create temporary test directory
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR"

    # Copy the soft-delete script to test directory
    cp "$BATS_TEST_DIRNAME/../bin/soft-delete" ./soft-delete
    chmod +x ./soft-delete

    # Create test files
    echo "test content" > test_file.txt
    mkdir test_directory
    echo "dir content" > test_directory/file_in_dir.txt
}

# Teardown function run after each test
teardown() {
    # Clean up test directory
    cd /
    rm -rf "$TEST_DIR"
}

@test "script exists and is executable" {
    [ -x "./soft-delete" ]
}

@test "show help with --help" {
    run ./soft-delete --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft Delete Tool"* ]]
    [[ "$output" == *"DESCRIPTION:"* ]]
    [[ "$output" == *"SYNOPSIS:"* ]]
}

@test "show help with -h" {
    run ./soft-delete -h
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft Delete Tool"* ]]
}

@test "show version with --version" {
    run ./soft-delete --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"soft-delete 0.0.0"* ]]
    [[ "$output" == *"volkovasystems utility collection"* ]]
}

@test "show version with -v" {
    run ./soft-delete -v
    [ "$status" -eq 0 ]
    [[ "$output" == *"soft-delete 0.0.0"* ]]
}

@test "show usage when no arguments provided" {
    run ./soft-delete
    [ "$status" -eq 2 ]
    [[ "$output" == *"Error: No arguments provided"* ]]
    [[ "$output" == *"Usage:"* ]]
}

@test "error when file does not exist" {
    run ./soft-delete nonexistent_file.txt
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Path 'nonexistent_file.txt' does not exist"* ]]
}

@test "soft delete a file" {
    run ./soft-delete test_file.txt
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [[ "$output" == *"test_file.txt"* ]]
    [[ "$output" == *"/tmp/backup-"* ]]

    # Verify original file is gone
    [ ! -f "test_file.txt" ]

    # Use helper function to extract and verify backup
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "test content"
}

@test "soft delete a directory" {
    run ./soft-delete test_directory
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [[ "$output" == *"test_directory"* ]]
    [[ "$output" == *"/tmp/backup-"* ]]

    # Verify original directory is gone
    [ ! -d "test_directory" ]

    # Verify backup exists
    backup_path=$(echo "$output" | grep -o "/tmp/backup-[^']*")
    [ -d "$backup_path" ]
    [ -f "$backup_path/file_in_dir.txt" ]
    [ "$(cat "$backup_path/file_in_dir.txt")" = "dir content" ]
}

@test "soft delete with --path option" {
    run ./soft-delete --path test_file.txt
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [ ! -f "test_file.txt" ]
}

@test "soft delete with -p option" {
    run ./soft-delete -p test_file.txt
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [ ! -f "test_file.txt" ]
}

@test "verbose mode shows debug output" {
    run ./soft-delete --verbose test_file.txt
    [ "$status" -eq 0 ]
    [[ "$output" == *"[DEBUG]"* ]]
    [[ "$output" == *"Starting soft delete"* ]]
    [[ "$output" == *"Created backup directory"* ]]
    [[ "$output" == *"Operation completed successfully"* ]]
}

@test "error with invalid option" {
    run ./soft-delete --invalid-option
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Unknown option: --invalid-option"* ]]
}

@test "error with missing path argument" {
    run ./soft-delete --path
    [ "$status" -eq 2 ]
    [[ "$output" == *"Error: --path option requires an argument"* ]]
}

@test "error with too many arguments" {
    run ./soft-delete test_file.txt extra_arg
    [ "$status" -eq 1 ]
    [[ "$output" == *"Error: Too many arguments: extra_arg"* ]]
}

@test "backup directory has unique timestamp" {
    # Create two files and delete them quickly
    echo "content1" > file1.txt
    echo "content2" > file2.txt

    run ./soft-delete file1.txt
    [ "$status" -eq 0 ]
    backup1=$(echo "$output" | grep -o "/tmp/backup-[^']*")

    run ./soft-delete file2.txt
    [ "$status" -eq 0 ]
    backup2=$(echo "$output" | grep -o "/tmp/backup-[^']*")

    # Backup paths should be different
    [ "$backup1" != "$backup2" ]

    # Both backups should exist
    [ -f "$backup1" ]
    [ -f "$backup2" ]
}

@test "handles special characters in filename" {
    echo "special content" > "file with spaces & symbols!.txt"

    run ./soft-delete "file with spaces & symbols!.txt"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [ ! -f "file with spaces & symbols!.txt" ]

    # Verify backup exists and has correct content
    backup_path=$(echo "$output" | grep -o "/tmp/backup-[^']*")
    [ -f "$backup_path" ]
    [ "$(cat "$backup_path")" = "special content" ]
}

@test "preserves file permissions" {
    # Create executable file
    echo "#!/bin/bash" > test_script.sh
    chmod +x test_script.sh

    run ./soft-delete test_script.sh
    [ "$status" -eq 0 ]

    # Check that backup preserves executable permission
    backup_path=$(echo "$output" | grep -o "/tmp/backup-[^']*")
    [ -x "$backup_path" ]
}

@test "handles relative paths" {
    mkdir -p subdir
    echo "subdir content" > subdir/file.txt

    run ./soft-delete subdir/file.txt
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [ ! -f "subdir/file.txt" ]
}

@test "handles absolute paths" {
    abs_path="$TEST_DIR/test_file.txt"

    run ./soft-delete "$abs_path"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [ ! -f "$abs_path" ]
}

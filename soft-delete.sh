#!/usr/bin/env bash

# soft-delete.sh - Soft Delete Tool
# Version: 1.0.0
# Author: Richeve S. Bebedor <richeve.bebedor@gmail.com>
# Description: Safely moves files/directories to a temporary backup location
#              instead of permanently deleting them

# Enable strict mode for better error handling
set -euo pipefail

# Script metadata
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Find VERSION file (try multiple locations)
if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
    VERSION_FILE="$SCRIPT_DIR/VERSION"
elif [[ -f "$(dirname "$SCRIPT_DIR")/VERSION" ]]; then
    VERSION_FILE="$(dirname "$SCRIPT_DIR")/VERSION"
else
    VERSION_FILE=""
fi
readonly VERSION_FILE

# Read version from VERSION file
if [[ -f "$VERSION_FILE" ]]; then
    VERSION=$(tr -d '\n\r' < "$VERSION_FILE" | tr -d ' ')
else
    VERSION="0.0.0"  # Fallback version
fi
readonly VERSION

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME

# Global variables
declare -g VERBOSE=false
declare -g TARGET_PATH=""

# Cleanup function for trap
cleanup() {
    local exit_code=$?
    # Add any cleanup operations here if needed
    exit $exit_code
}

# Set up signal handlers
trap cleanup EXIT INT TERM

# Logging functions
log_info() {
    echo "$*" >&1
}

log_error() {
    echo "Error: $*" >&2
}

log_verbose() {
    [[ "$VERBOSE" == true ]] && echo "[DEBUG] $*" >&2
}

# Usage function (short version)
usage() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTIONS] [PATH]
       $SCRIPT_NAME PATH

Use '$SCRIPT_NAME --help' for detailed information.
EOF
}

# Function to display comprehensive help information
show_help() {
    cat << EOF
$SCRIPT_NAME - Soft Delete Tool v$VERSION

DESCRIPTION:
    A safe deletion utility that moves files and directories to a temporary backup
    location with a timestamp instead of permanently deleting them. This allows for
    easy recovery of accidentally deleted items.

SYNOPSIS:
    $SCRIPT_NAME [OPTIONS] [PATH]
    $SCRIPT_NAME PATH

OPTIONS:
    -p, --path PATH     Specify the path to the file or directory to soft delete
    -v, --version       Display version information and exit
    -h, --help          Display this help message and exit
        --verbose       Enable verbose output (for debugging)

ARGUMENTS:
    PATH                Path to the file or directory to soft delete
                        Can be used directly without the -p/--path option

EXAMPLES:
    $SCRIPT_NAME file.txt
    $SCRIPT_NAME /path/to/directory
    $SCRIPT_NAME --path ~/documents/old_file.doc
    $SCRIPT_NAME -p ./temp_folder

BEHAVIOR:
    • Creates a temporary backup directory with format: backup-XXXXX-YYYYMMDD-HHMMSS
    • Moves the specified file/directory to the backup location
    • Preserves file permissions and attributes during the move
    • Only processes existing files and directories
    • Backup location is printed to stdout for reference

BACKUP LOCATION:
    Backup directories are created in the system's temporary directory (/tmp)
    with a unique timestamp to prevent conflicts.

EXIT STATUS:
    0    Success - file/directory was moved successfully
    1    General error - invalid arguments or operation failed
    2    Usage error - missing or invalid arguments

SEE ALSO:
    mv(1), mktemp(1), rm(1)

AUTHOR:
    Richeve S. Bebedor <richeve.bebedor@gmail.com>

REPORTING BUGS:
    Report bugs to the volkovasystems maintainers.

EOF
}

# Function to display version information
show_version() {
    cat << EOF
$SCRIPT_NAME $VERSION
Part of the volkovasystems utility collection

This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.
EOF
}

# Function to validate path argument
validate_path() {
    local path="$1"

    if [[ -z "$path" ]]; then
        log_error "No path specified"
        usage
        return 1
    fi

    # Check if path exists (including broken symlinks)
    if [[ ! -e "$path" && ! -L "$path" ]]; then
        log_error "Path '$path' does not exist"
        return 1
    fi

    # For broken symlinks, we can't check readability
    if [[ -e "$path" && ! -r "$path" ]]; then
        log_error "Path '$path' is not readable"
        return 1
    fi

    return 0
}

# Function to perform soft delete
soft_delete() {
    local target_path="$1"
    local backup_directory
    local backup_name

    log_verbose "Starting soft delete for: $target_path"

    # Validate the target path
    if ! validate_path "$target_path"; then
        return 1
    fi

    # Create backup directory
    if ! backup_directory=$(mktemp -d -t "backup-XXXXX-$(date +%Y%m%d-%H%M%S)"); then
        log_error "Failed to create backup directory"
        return 1
    fi

    log_verbose "Created backup directory: $backup_directory"

    # Get the basename for the moved item
    backup_name="$(basename "$target_path")"

    # Perform the move operation (use -- to handle files starting with dash)
    if mv -- "$target_path" "$backup_directory/$backup_name"; then
        log_info "Soft deleted: '$target_path' -> '$backup_directory/$backup_name'"
        log_verbose "Operation completed successfully"
        return 0
    else
        log_error "Failed to move '$target_path' to backup location"
        # Clean up the empty backup directory
        rmdir "$backup_directory" 2>/dev/null || true
        return 1
    fi
}

# Parse command line arguments using getopts for short options
parse_arguments() {
    local OPTIND=1 OPTARG opt
    local args=()
    local end_of_options=false

    # First pass: handle long options and collect remaining arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --path)
                if [[ -n "${2:-}" ]]; then
                    TARGET_PATH="$2"
                    shift 2
                else
                    log_error "--path option requires an argument"
                    usage
                    exit 2
                fi
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --)
                # End of options marker
                shift
                end_of_options=true
                break
                ;;
            --*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            -*)
                # Collect short options for getopts processing
                args+=("$1")
                shift
                ;;
            *)
                # Not an option, collect for later processing
                args+=("$1")
                shift
                ;;
        esac
    done

    # Add remaining arguments after -- to args array
    while [[ $# -gt 0 ]]; do
        args+=("$1")
        shift
    done

    # Second pass: handle short options with getopts if we have any
    if [[ ${#args[@]} -gt 0 ]]; then
        set -- "${args[@]}"
        
        # Only process short options if we haven't hit end of options marker
        if [[ "$end_of_options" == false ]]; then
            while getopts "hvp:" opt; do
                case $opt in
                    h)
                        show_help
                        exit 0
                        ;;
                    v)
                        show_version
                        exit 0
                        ;;
                    p)
                        TARGET_PATH="$OPTARG"
                        ;;
                    \?)
                        log_error "Invalid option: -$OPTARG"
                        usage
                        exit 1
                        ;;
                    :)
                        log_error "Option -$OPTARG requires an argument"
                        usage
                        exit 2
                        ;;
                esac
            done
            
            # Shift processed options
            shift $((OPTIND - 1))
        fi
        
        # If no path was specified via -p/--path, use the first remaining argument
        if [[ -z "$TARGET_PATH" && -n "${1:-}" ]]; then
            TARGET_PATH="$1"
            shift
        fi
        
        # Check for extra arguments
        if [[ $# -gt 0 ]]; then
            log_error "Too many arguments: $*"
            usage
            exit 1
        fi
    fi

    # Ensure we have a target path
    if [[ -z "$TARGET_PATH" ]]; then
        log_error "No path specified"
        usage
        exit 2
    fi
}

# Main function
main() {
    # Check if no arguments provided
    if [[ $# -eq 0 ]]; then
        log_error "No arguments provided"
        usage
        exit 2
    fi

    # Parse command line arguments
    parse_arguments "$@"

    # Perform the soft delete operation
    if soft_delete "$TARGET_PATH"; then
        exit 0
    else
        exit 1
    fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

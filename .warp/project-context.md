# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

`soft-delete` is a bash utility that safely moves files/directories to timestamped backup locations in `/tmp` instead of permanently deleting them. The project emphasizes safety, comprehensive testing, and professional development practices.

### Core Architecture

- **Main Script**: `soft-delete.sh` - Single bash script with strict mode (`set -euo pipefail`)
- **Entry Point**: Files moved to `/tmp/backup-XXXXX-YYYYMMDD-HHMMSS/` format
- **Build System**: Makefile-based with copy-to-bin approach (`soft-delete.sh` → `bin/soft-delete`)
- **Testing**: Docker-based BATS testing with TAP-compliant output
- **Distribution**: Homebrew formula + GitHub releases

## Essential Commands

### Build and Development
```bash
# Build executable (copies source to bin/)
make build

# Install system-wide (requires sudo)
make install

# Install to custom location
make install PREFIX=~/local

# Check if installed correctly
make check
```

### Testing (Docker-based - Primary Method)
```bash
# Standard TAP-compliant tests (recommended)
make docker-test

# Verbose test output with debugging
make docker-test-verbose

# Run only shellcheck linting
make docker-lint

# View test reports
make test-reports

# Clean Docker environment
make docker-clean
```

### Manual Testing (Fallback)
```bash
# Install dependencies first
make install-deps

# Run tests locally (requires bats)
make test

# Run linting
make lint
```

### Development Workflow
```bash
# Full development cycle
make build && make docker-test

# Clean everything
make clean-all  # Includes build artifacts, Docker, reports

# Create distribution package
make package
```

## Code Architecture

### Core Components

1. **Argument Parsing** (`parse_arguments()`)
   - Handles both long (`--path`, `--verbose`) and short (`-p`, `-v`) options
   - Complex getopts implementation with two-pass parsing
   - Supports `--` end-of-options marker

2. **Path Validation** (`validate_path()`)
   - Checks file/directory existence (including broken symlinks)
   - Verifies read permissions before operation
   - Provides specific error messages

3. **Backup Creation** (`soft_delete()`)
   - Uses `mktemp -d` with timestamp pattern
   - Preserves original filename and permissions
   - Atomic move operation with error recovery

4. **Error Handling**
   - Strict mode enabled throughout
   - Cleanup trap for signal handling
   - Specific exit codes: 0 (success), 1 (general error), 2 (usage error)

### Key Patterns

- **Logging Functions**: `log_info()`, `log_error()`, `log_verbose()`
- **Global Variables**: Declared with `declare -g` (VERBOSE, TARGET_PATH)
- **Source Guard**: Only runs main if executed directly (`[[ "${BASH_SOURCE[0]}" == "${0}" ]]`)
- **VERSION Management**: Always read from `/VERSION` file - NEVER hardcode versions

## Testing Framework

### Docker Environment
- **Base**: Ubuntu 22.04 with bash, bats, shellcheck
- **Libraries**: bats-support, bats-assert, bats-file
- **Isolation**: Non-root testuser, separate workspace volumes
- **Output**: TAP version 14 compliant results

### Test Structure
```bash
# Test files location
tests/
├── soft-delete.bats     # Main test suite
├── edge-cases.bats      # Edge case testing
└── test_helper.bash     # Shared utilities

# Test helper functions
extract_backup_path()    # Parse backup path from output
verify_backup()          # Verify backup integrity
create_test_file()       # Create test fixtures
```

### Critical Test Areas
- Command-line argument parsing (both formats)
- File/directory operations with various names and permissions
- Backup directory creation and uniqueness
- Error conditions and exit codes
- Special characters and edge cases

## Development Guidelines

### Code Quality Standards
- **ShellCheck**: Custom configuration in `.shellcheckrc`
- **EditorConfig**: 4-space indentation, LF line endings
- **Strict Mode**: Always use `set -euo pipefail`
- **Quoting**: Quote all variables (`"$variable"`)
- **Functions**: Use `local` for function variables

### Common Tasks

#### Adding New Features
1. Modify `soft-delete.sh`
2. Add corresponding tests in `tests/soft-delete.bats`
3. Update help text in `show_help()`
4. Run full test suite: `make build && make docker-test`

#### Debugging Issues
```bash
# Enable verbose mode for debugging
./bin/soft-delete --verbose test-file.txt

# Check shellcheck output
make docker-lint

# View detailed test output
make docker-test-verbose
```

#### Release Process
- Automated via GitHub Actions on git tags (`v*`)
- Tests run in Docker with TAP output
- Security scanning via `scripts/security-scan.sh`
- Distribution archives created automatically

### File Structure Context

```
Key directories:
├── bin/                 # Built executable (git-tracked)
├── tests/              # BATS test suite
├── scripts/            # Utility scripts (benchmark, cleanup, etc.)
├── docs/               # API.md, TESTING.md
├── examples/           # Usage examples
└── Formula/            # Homebrew formula

Entry points:
- soft-delete.sh        # Source code
- bin/soft-delete       # Built executable
- Dockerfile.test       # Docker test environment
- docker-compose.test.yml # Test orchestration
```

## Important Notes

- **Test First**: Always use Docker testing (`make docker-test`) as primary method
- **Build Pattern**: Source is copied to `bin/`, not compiled
- **Safety**: Script uses atomic moves, no permanent deletion
- **Permissions**: Preserves original file permissions and attributes
- **TAP Output**: Test results are TAP version 14 compliant for CI/CD integration

## Troubleshooting

### Common Issues
- **Permission Errors**: Check if target path is readable
- **Docker Issues**: Run `make docker-clean` then retry
- **Build Problems**: Ensure `soft-delete.sh` exists and is executable
- **Test Failures**: Check `./reports/` directory for detailed TAP output

### Debug Commands
```bash
# Validate bash syntax
bash -n soft-delete.sh

# Check shellcheck results
./scripts/run-tests.sh lint

# View TAP test output
cat ./reports/tap/results.tap
```

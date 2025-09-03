# Soft-Delete API Reference

This document provides comprehensive API documentation for the soft-delete utility and its associated scripts.

## Table of Contents

- [Core Utility](#core-utility)
- [Build System](#build-system)
- [Testing Infrastructure](#testing-infrastructure)
- [Utility Scripts](#utility-scripts)
- [Configuration Files](#configuration-files)

## Core Utility

### soft-delete.sh

**Location**: `soft-delete.sh`
**Purpose**: Main executable that safely moves files and directories to timestamped backup locations
**Language**: Bash 4.0+

#### Functions

##### `main()`

**Description**: Entry point function that orchestrates the entire soft delete operation

**Parameters**:

- Command line arguments (`"$@"`)

**Returns**:

- `0` on success
- `1` on general error
- `2` on usage error

**Example**:

```bash
main "$@"
```

---

##### `parse_arguments()`

**Description**: Parses and validates command line arguments using getopts

**Parameters**:

- Command line arguments

**Global Variables Modified**:

- `TARGET_PATH`: Set to the file/directory path to delete
- `VERBOSE`: Set to true if verbose mode enabled

**Supported Options**:

- `-h, --help`: Display help and exit
- `-v, --version`: Display version and exit
- `-p, --path PATH`: Specify target path
- `--verbose`: Enable debug output

##### `validate_path()`

**Description**: Validates that the target path exists and is readable

**Parameters**:

- `$1`: Path to validate

**Returns**:

- `0` if path is valid
- `1` if path is invalid

**Error Conditions**:

- Path is empty
- Path doesn't exist
- Path is not readable

---

##### `soft_delete()`

**Description**: Core function that performs the safe deletion operation

**Parameters**:

- `$1`: Target path to soft delete

**Returns**:

- `0` on successful move
- `1` on failure

**Side Effects**:

- Creates backup directory in `/tmp`
- Moves target to backup location
- Outputs backup path to stdout

**Algorithm**:

1. Validate target path
2. Create unique timestamped backup directory using `mktemp`
3. Move target to backup directory using `mv`
4. Report success with backup location

---

##### `show_help()`

**Description**: Displays comprehensive help information

**Parameters**: None

**Output**: Formatted help text to stdout

##### `show_version()`

**Description**: Displays version and copyright information

**Parameters**: None

**Output**: Version string to stdout

#### Global Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `VERSION` | readonly string | Current version | "1.0.0" |
| `SCRIPT_NAME` | readonly string | Script basename | Derived from `$0` |
| `VERBOSE` | boolean | Debug output flag | false |
| `TARGET_PATH` | string | Path to process | "" |

---

#### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - file/directory moved successfully |
| 1 | General error - invalid arguments or operation failed |
| 2 | Usage error - missing or invalid arguments |

#### Backup Directory Format

```bash
/tmp/backup-XXXXX-YYYYMMDD-HHMMSS/
```

Where:

- `XXXXX`: Random 5-character string from mktemp
- `YYYYMMDD`: Date (e.g., 20250122)
- `HHMMSS`: Time (e.g., 143052)

---

## Build System

### Makefile

**Location**: `Makefile`

**Purpose**: Automates building, testing, packaging, and maintenance tasks

#### Primary Targets

##### `build`

**Description**: Copies the source script to create the soft-delete executable

**Dependencies**: `soft-delete.sh`

**Side Effects**: Creates `bin/` directory and copies source to `bin/soft-delete`

##### `test`

**Description**: Runs the test suite using BATS

**Dependencies**: `build`

**Requirements**: BATS testing framework

##### `docker-test`

**Description**: Runs tests in Docker environment with TAP output

**Dependencies**: `build`, Docker, docker-compose

**Output**: TAP-compliant test results in `reports/`

##### `install`

**Description**: Installs soft-delete system-wide

**Requirements**: sudo privileges

**Installation Path**: `/usr/local/bin/soft-delete`

##### `package`

**Description**: Creates distributable tarball

**Dependencies**: `build`

**Output**: `dist/soft-delete-{VERSION}.tar.gz`

#### Cleanup Targets

##### `clean`

**Description**: Removes build artifacts

**Removes**: `bin/soft-delete`, `dist/`

##### `clean-temp`

**Description**: Removes temporary files

**Patterns**: `*.tmp`, `*.log`, `*~`, `.DS_Store`, `Thumbs.db`, `*.swp`, `*.swo`, `*.orig`

##### `clean-docker`

**Description**: Cleans Docker test environment

**Actions**: Stops containers, removes images, cleans volumes

##### `clean-reports`

**Description**: Removes test reports

**Preserves**: `.gitkeep` files

##### `clean-all`

**Description**: Runs all cleanup targets

**Equivalent**: `clean clean-temp clean-docker clean-reports`

#### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SCRIPT_NAME` | Main script filename | `soft-delete.sh` |
| `VERSION` | Current version | Extracted from script |
| `INSTALL_DIR` | Installation directory | `/usr/local/bin` |
| `PACKAGE_NAME` | Package basename | `soft-delete-$(VERSION)` |

## Testing Infrastructure

### Test Helpers (test_helper.bash)

**Location**: `tests/test_helper.bash`

**Purpose**: Common functions for BATS test suite

#### Helper Functions

##### `create_test_file(filename, content)`

**Description**: Creates a test file with specified content

**Parameters**:

- `filename`: File to create
- `content`: Content to write (default: "test content")

---

##### `create_test_directory(dirname, filename, content)`

**Description**: Creates test directory with file

**Parameters**:

- `dirname`: Directory to create
- `filename`: Name of file to create
- `content`: Content to write

---

##### `extract_backup_path(output)`

**Description**: Extracts the backup path from command output

**Parameters**:

- `output`: Command output string

---

##### `verify_backup(backup_path, expected_content)`

**Description**: Verifies that the backup file has expected content

**Parameters**:

- `backup_path`: Path to backup file
- `expected_content`: Expected content

---

##### `cleanup_backups()`

**Description**: Removes all backups created during testing

**Parameters**: None

---

##### `count_backups()`

**Description**: Returns the number of backup directories/files found

**Parameters**: None

---

##### `tap_pass(message)`, `tap_fail(message)`, `tap_skip(message)`, `tap_todo(message)`

**Description**: TAP-compliant status functions

**Parameters**: `message`: Diagnostic text

---

## Utility Scripts

### Security Scanner (security-scan.sh)

**Location**: `scripts/security-scan.sh`
**Purpose**: Comprehensive security vulnerability scanning

#### Security Checks

1. **File Permissions**: World-writable files, suspicious executables
2. **Hardcoded Secrets**: API keys, passwords, tokens, private keys
3. **Path Traversal**: Unquoted variables, directory traversal patterns
4. **Input Validation**: Unvalidated user input usage
5. **ShellCheck Security**: Security-relevant static analysis
6. **Docker Security**: Dockerfile best practices

#### Usage

```bash
scripts/security-scan.sh [OPTIONS]

OPTIONS:
    -h, --help      Show help
    -v, --verbose   Verbose output
    -q, --quiet     Quiet mode
```

### Performance Benchmark (benchmark.sh)

**Location**: `scripts/benchmark.sh`
**Purpose**: Performance testing and regression detection

#### Benchmark Types

1. **Small Benchmark**: Single files, small directories
2. **Large Benchmark**: Large files (10MB+), many files (100+)
3. **Memory Analysis**: Memory usage monitoring during operations
4. **Regression Testing**: Performance consistency validation

#### Usage

```bash
scripts/benchmark.sh [OPTIONS]

OPTIONS:
    -s, --small     Small benchmark (default)
    -l, --large     Large benchmark
    -a, --all       All benchmarks
    -r, --report    Generate detailed report
```

### Cleanup System (cleanup.sh)

**Location**: `scripts/cleanup.sh`
**Purpose**: Comprehensive project cleanup with preview and safety

#### Cleanup Types

1. **Build**: Build artifacts, distribution packages
2. **Temp**: Temporary files, editor backups, OS metadata
3. **Docker**: Containers, images, volumes
4. **Reports**: Test reports and artifacts
5. **Deployment**: PID files, locks, old backups

#### Safety Features

- **Dry Run Mode**: Preview changes without executing
- **Confirmation Prompts**: Interactive safety prompts
- **Statistics**: File counts and size reporting
- **Selective Cleanup**: Target specific artifact types

### Test Runner (run-tests.sh)

**Location**: `scripts/run-tests.sh`
**Purpose**: Docker-based test execution with TAP output

#### Features

- **Docker Integration**: Isolated test environment
- **TAP Compliance**: Standardized test output format
- **Report Generation**: Persistent test artifacts
- **Flexible Execution**: Multiple test types and options

### Version Management (version.sh)

**Location**: `scripts/version.sh`
**Purpose**: Automated version management and tagging

#### Features

- **Semantic Versioning**: Support for major.minor.patch versioning
- **Automatic Tagging**: Git tag creation with proper formatting
- **Version Validation**: Ensures version format compliance
- **Integration Ready**: Works with CI/CD pipelines

### Version Protection (version-guard.sh)

**Location**: `scripts/version-guard.sh`
**Purpose**: VERSION file protection and unauthorized modification prevention

#### Protection Features

- **File Immutability**: Uses Linux `chattr +i` to make VERSION file immutable
- **Pre-commit Hooks**: Git hooks to block unauthorized VERSION modifications
- **Checksum Validation**: SHA256 integrity verification and tamper detection
- **AI Environment Detection**: Automatically detects AI/automated environments
- **Developer Authentication**: Validates authorized developer credentials
- **Access Logging**: Audit trails for VERSION file access attempts

#### Security Controls

1. **AI Prevention**: Blocks AI systems from modifying version numbers
2. **Authentication**: Only authorized developers can update VERSION file
3. **Integrity Monitoring**: Detects unauthorized tampering
4. **Rollback Protection**: Prevents accidental version rollbacks
5. **Audit Logging**: Complete access and modification history

#### Usage

```bash
scripts/version-guard.sh [COMMAND] [OPTIONS]

COMMANDS:
    enable          Enable VERSION file protection
    disable         Disable protection (requires --force)
    status          Show protection status and file info
    validate        Validate VERSION file integrity
    reset           Reset protection system

OPTIONS:
    -h, --help      Show help
    -v, --verbose   Verbose output
    -f, --force     Force operation (disable only)
```

#### Make Integration

```bash
make version-guard-enable     # Enable protection
make version-guard-status     # Check protection status
make version-guard-validate   # Validate integrity
make version-guard-disable    # Disable (requires confirmation)
```

### Changelog Generation (changelog.sh)

**Location**: `scripts/changelog.sh`
**Purpose**: Automated changelog generation from git history

#### Features

- **Git Integration**: Extracts commit messages and metadata
- **Markdown Format**: Generates properly formatted changelog
- **Version Grouping**: Organizes changes by version releases
- **Conventional Commits**: Supports conventional commit message parsing

### Project Structure Synchronization (sync-structure.sh)

**Location**: `scripts/sync-structure.sh`
**Purpose**: Maintains consistency between project structure and documentation

#### Features

- **Tree Generation**: Creates comprehensive directory tree views
- **Documentation Sync**: Updates structure sections across files
- **Duplicate Prevention**: Detects and prevents duplicate content
- **Cross-reference Validation**: Ensures internal links are valid

### Structure Validation (validate-structure.sh)

**Location**: `scripts/validate-structure.sh`
**Purpose**: Validates project structure compliance and consistency

#### Features

- **File Existence**: Verifies required files are present
- **Link Validation**: Checks internal and external references
- **Format Compliance**: Ensures documentation follows standards
- **Executable Consistency**: Validates naming conventions

### Compliance Verification (compliance-check.sh)

**Location**: `scripts/compliance-check.sh`
**Purpose**: 100% compliance verification across all project aspects

#### Features

- **Multi-level Checks**: File, documentation, and integration compliance
- **Comprehensive Reporting**: Detailed compliance status reports
- **Automated Fixes**: Suggests or applies compliance corrections
- **Quality Gates**: Pass/fail thresholds for CI/CD integration

### Development Checkpoint (checkpoint.sh)

**Location**: `scripts/checkpoint.sh`
**Purpose**: Development checkpoint and backup utility

#### Features

- **State Preservation**: Creates development snapshots
- **Backup Management**: Automated backup creation and rotation
- **Restore Capability**: Easy restoration from checkpoints
- **Progress Tracking**: Milestone and progress documentation

### Duplicate Detection (check-duplicates.sh)

**Location**: `scripts/check-duplicates.sh`
**Purpose**: Detects and reports duplicate content across project files

#### Features

- **Content Analysis**: Identifies duplicate text blocks
- **File Comparison**: Cross-file duplicate detection
- **Smart Filtering**: Excludes legitimate duplicates (licenses, etc.)
- **Cleanup Suggestions**: Provides remediation recommendations

### Deployment Automation (deploy.sh)

**Location**: `scripts/deploy.sh`
**Purpose**: Automated deployment orchestration and management

#### Features

- **Multi-stage Deployment**: Development, staging, production
- **Health Checks**: Pre and post-deployment validation
- **Rollback Support**: Automated rollback on failure
- **Environment Configuration**: Environment-specific deployments

### Quick Commit Workflow (quick-commit.sh)

**Location**: `scripts/quick-commit.sh`
**Purpose**: Streamlined commit workflow with automated checks

#### Features

- **Pre-commit Validation**: Runs linting and basic tests
- **Commit Message Templates**: Conventional commit formatting
- **Automatic Staging**: Smart file staging and commit creation
- **Integration Hooks**: Triggers additional workflow steps

### Git Hooks Management (setup-hooks.sh)

**Location**: `scripts/setup-hooks.sh`
**Purpose**: Git hooks installation and configuration

#### Features

- **Hook Installation**: Automated git hook setup
- **Configuration Management**: Hook behavior customization
- **Team Consistency**: Ensures consistent hooks across team
- **Validation Integration**: Links with project validation tools

### Pre-commit Hook (pre-commit-hook.sh)

**Location**: `scripts/pre-commit-hook.sh`
**Purpose**: Git pre-commit validation and enforcement

#### Features

- **Code Quality**: Linting and formatting validation
- **Test Execution**: Runs relevant test suites
- **Documentation Sync**: Updates documentation as needed
- **Commit Prevention**: Blocks commits that fail validation

## Configuration Files

### Editor Configuration (.editorconfig)

**Purpose**: Consistent code formatting across editors
**Coverage**: All file types with appropriate indentation and formatting rules

### Git Configuration

#### .gitattributes
**Purpose**: Git file handling and language detection
**Features**: Line ending normalization, binary file detection, linguist configuration

#### .gitignore
**Purpose**: Excludes generated files and build artifacts from version control

### ShellCheck Configuration (.shellcheckrc)

**Purpose**: Shell script linting configuration
**Features**: Custom rule sets, external source handling, severity levels

## Integration Points

### CI/CD Pipeline (.github/workflows/release.yml)

**Triggers**: Git tags matching `v*`
**Stages**:
1. **Test**: Docker-based testing with TAP output
2. **Security**: Linting and security scanning
3. **Build**: Package creation and artifact generation
4. **Release**: GitHub release with assets

### Docker Testing (docker-compose.test.yml, Dockerfile.test)

**Base Image**: Ubuntu 22.04
**Dependencies**: BATS, shellcheck, testing utilities
**Security**: Non-root test user, isolated environment
**Outputs**: TAP-compliant test reports, artifacts

## Best Practices

### Error Handling

1. **Strict Mode**: All scripts use `set -euo pipefail`
2. **Input Validation**: Comprehensive parameter checking
3. **Exit Codes**: Consistent and meaningful exit codes
4. **Error Messages**: Clear, actionable error reporting

### Security

1. **Path Validation**: All file operations validate paths
2. **No Hardcoded Secrets**: Secure credential handling
3. **Permission Checks**: Appropriate file permission validation
4. **Input Sanitization**: Safe handling of user input

### Performance

1. **Minimal Dependencies**: Core functionality uses only bash built-ins
2. **Efficient Operations**: Single `mv` operation for atomic moves
3. **Memory Conscious**: No unnecessary data buffering
4. **Fast Execution**: Optimized for speed and responsiveness

### Maintainability

1. **Comprehensive Documentation**: Function-level documentation
2. **Consistent Style**: Uniform coding conventions
3. **Modular Design**: Clear separation of concerns
4. **Extensive Testing**: Unit tests, integration tests, edge cases

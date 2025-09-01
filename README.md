# soft-delete

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/bash-%3E%3D4.0-green.svg)](https://www.gnu.org/software/bash/)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/volkovasystems/soft-delete)

A safe file deletion utility that moves files and directories to timestamped backup locations instead of permanently deleting them.

## Features

### Core Functionality
- 🗑️ **Safe Deletion**: Moves files to timestamped backup directories in `/tmp`
- 🔄 **Easy Recovery**: Files are preserved with original names and permissions
- ⚡ **Fast**: Lightweight bash script with minimal dependencies
- 🛡️ **Robust**: Comprehensive error handling and validation
- 📝 **Verbose Mode**: Debug output for troubleshooting
- 🎯 **Simple**: Clean command-line interface

### Installation & Distribution
- 📦 **Homebrew Support**: Easy installation via Homebrew package manager
- 🚀 **Multiple Install Methods**: Quick install, manual, from source
- 📋 **Cross-Platform**: Linux, macOS, BSD, Windows (WSL), Android (Termux)

### Development & Quality Assurance
- 🐳 **Docker Testing**: Isolated, reproducible test environment
- 🧪 **TAP Compliance**: Industry-standard test output format
- 🔍 **Security Scanning**: Comprehensive vulnerability detection
- 📊 **Performance Benchmarking**: Memory usage and speed analysis
- 🔧 **Automated CI/CD**: GitHub Actions pipeline with quality gates
- 📚 **Comprehensive Documentation**: API docs, testing guides, examples

### Deployment & Release Management
- 🚀 **Automated Deployments**: Branch-based deployment workflow (develop → staging → release)
- 🏷️ **Semantic Versioning**: Automated version tagging and management
- 🔄 **Rollback Capabilities**: Complete revert functionality for all deployment types
- 🌐 **Multi-Branch Support**: Develop, staging, test, release, master, and main branches
- 🔒 **Safety Checks**: Version validation and remote connectivity verification
- 📋 **Dry-Run Mode**: Preview deployments before execution

## Installation

### Quick Install

```bash
git clone https://github.com/volkovasystems/soft-delete.git
cd soft-delete
sudo make install
```

### Homebrew Install (macOS/Linux)

```bash
# Tap our repository
brew tap volkovasystems/soft-delete

# Install soft-delete
brew install soft-delete
```

### Manual Install

```bash
git clone https://github.com/volkovasystems/soft-delete.git
cd soft-delete

# Option 1: Use install script
sudo ./install.sh

# Option 2: Manual copy
sudo cp soft-delete.sh /usr/local/bin/soft-delete
sudo chmod +x /usr/local/bin/soft-delete
```

### From Source

```bash
wget https://raw.githubusercontent.com/volkovasystems/soft-delete/main/bin/soft-delete
sudo mv soft-delete /usr/local/bin/
sudo chmod +x /usr/local/bin/soft-delete
```

## Usage

### Basic Usage

```bash
# Delete a file
soft-delete file.txt

# Delete a directory
soft-delete /path/to/directory

# Using the --path option
soft-delete --path ~/documents/old_file.doc
soft-delete -p ./temp_folder
```

### Options

```bash
# Show help
soft-delete --help
soft-delete -h

# Show version
soft-delete --version
soft-delete -v

# Enable verbose output
soft-delete --verbose file.txt
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Display comprehensive help message and exit |
| `-v, --version` | Display version information and exit |
| `-p, --path PATH` | Specify the path to the file or directory to soft delete |
| `--verbose` | Enable verbose output for debugging |

## How It Works

`soft-delete` creates backup directories in `/tmp` with the format:
```
backup-XXXXX-YYYYMMDD-HHMMSS
```

Where:
- `XXXXX` is a unique random string
- `YYYYMMDD` is the date (e.g., 20250122)
- `HHMMSS` is the time (e.g., 143052)

### Example Backup Location
```
/tmp/backup-a7f3k-20250122-143052/file.txt
```

## Examples

### Basic File Operations

```bash
# Soft delete a document
soft-delete important-document.pdf
# Output: Soft deleted: 'important-document.pdf' -> '/tmp/backup-x9k2m-20250122-143052/important-document.pdf'

# Soft delete a directory
soft-delete old-project/
# Output: Soft deleted: 'old-project/' -> '/tmp/backup-p4n7q-20250122-143115/old-project'
```

### Using Different Options

```bash
# Using --path option
soft-delete --path ~/Downloads/temp.zip

# Using short option
soft-delete -p ./cache/

# With verbose output
soft-delete --verbose large-file.bin
# Output: [DEBUG] Starting soft delete for: large-file.bin
#         [DEBUG] Created backup directory: /tmp/backup-m5t8w-20250122-143200
#         Soft deleted: 'large-file.bin' -> '/tmp/backup-m5t8w-20250122-143200/large-file.bin'
#         [DEBUG] Operation completed successfully
```

### Recovery

To recover files, simply move them back from the backup location:

```bash
# Find your file
ls /tmp/backup-*/

# Restore it
mv /tmp/backup-x9k2m-20250122-143052/important-document.pdf ./
```

## Error Handling

The script provides clear error messages for common issues:

```bash
# File doesn't exist
soft-delete nonexistent.txt
# Error: Path 'nonexistent.txt' does not exist

# No arguments provided
soft-delete
# Error: No arguments provided
# Usage: soft-delete [OPTIONS] [PATH]

# Permission denied
soft-delete /root/protected-file
# Error: Path '/root/protected-file' is not readable
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success - file/directory was moved successfully |
| 1 | General error - invalid arguments or operation failed |
| 2 | Usage error - missing or invalid arguments |

## Testing

The project includes comprehensive testing infrastructure with multiple testing approaches:

### Quick Testing

```bash
# Run all tests (recommended)
make test

# Run Docker-based tests with TAP output
make docker-test

# Run tests with verbose output
make docker-test-verbose
```

### Docker Testing (Recommended)

The project uses Docker for isolated, reproducible testing:

```bash
# Standard TAP-compliant testing
make docker-test

# Verbose test output with detailed logs
make docker-test-verbose

# Run only main test suite
make docker-test-single

# View test reports
make test-reports

# Clean up Docker test environment
make docker-clean
```

### Manual Testing

```bash
# Install bats if not already installed
sudo apt-get install bats shellcheck  # Ubuntu/Debian
brew install bats-core shellcheck     # macOS

# Run tests manually
bats tests/

# Run specific test files
bats tests/soft-delete.bats
bats tests/edge-cases.bats
```

### Test Infrastructure

- **Docker Environment**: Isolated Ubuntu 22.04 testing environment
- **TAP Output**: Test results in Test Anything Protocol format
- **Coverage**: Core functionality, edge cases, error handling
- **Reports**: Persistent test artifacts in `reports/` directory
- **CI/CD Integration**: Automated testing on releases

## Development

### Project Structure

```
soft-delete/
├── bin/                     # Compiled executable binaries
│   └── soft-delete              # Compiled executable binary
├── CHANGELOG.md             # Version history and change tracking
├── CONTRIBUTING.md          # Contribution guidelines and development setup
├── dist/                    # Distribution and build artifacts
│   └── .gitkeep                 # Git directory preservation marker
├── docker-compose.test.yml  # Docker testing environment configuration
├── Dockerfile.runtime       # Runtime container image definition
├── Dockerfile.test          # Testing container image definition
├── docs/                    # Comprehensive project documentation
│   ├── API.md                   # Comprehensive API reference documentation
│   ├── DEPLOYMENT.md            # Deployment procedures and automation guide
│   ├── PROJECT-STRUCTURE.md                        # Markdown documentation file
│   ├── SECURITY.md              # Security policies and vulnerability reporting
│   └── TESTING.md               # Testing procedures and infrastructure guide
├── .editorconfig            # Code formatting and editor standards
├── examples/                # Usage examples and demonstrations
│   ├── advanced_usage.sh        # Advanced integration examples
│   ├── basic_usage.sh           # Basic usage examples and tutorials
│   └── README.md                # Project overview and main documentation
├── Formula/                  # Package manager formulas (Homebrew)
│   └── soft-delete.rb           # Homebrew formula for package distribution
├── .gitattributes           # Git file handling configuration
├── .githooks/
│   └── pre-commit                     # Executable file
├── .github/                 # GitHub configuration and workflows
│   └── workflows/               # GitHub Actions workflows
│       └── release.yml              # GitHub Actions CI/CD release pipeline
├── .gitignore               # Git ignore patterns and exclusions
├── install.sh               # Installation script for end users
├── LICENSE                  # MIT License terms and conditions
├── Makefile                 # Build automation and development tasks
├── .markdownlint.yaml       # Markdown linting rules and configuration
├── README.md                # Project overview and main documentation
├── reports/                 # Test reports and analysis artifacts
│   ├── artifacts/
│   │   └── .gitkeep                 # Git directory preservation marker
│   ├── coverage/
│   │   └── .gitkeep                 # Git directory preservation marker
│   ├── .gitkeep                 # Git directory preservation marker
│   ├── junit/
│   │   └── .gitkeep                 # Git directory preservation marker
│   └── tap/
│       └── .gitkeep                 # Git directory preservation marker
├── scripts/                 # Utility and automation scripts
│   ├── benchmark.sh             # Performance testing and benchmarking
│   ├── changelog.sh             # Automated changelog generation
│   ├── check-duplicates.sh      # Duplicate content detection and cleanup
│   ├── checkpoint.sh            # Development checkpoint and backup utility
│   ├── cleanup.sh               # Comprehensive system cleanup utility
│   ├── compliance-check.sh      # 100% compliance verification system
│   ├── deploy.sh                # Deployment automation and orchestration
│   ├── pre-commit-hook.sh                       # Shell script
│   ├── quick-commit.sh                       # Shell script
│   ├── run-tests.sh             # Docker-based comprehensive test runner
│   ├── security-scan.sh         # Security vulnerability scanning
│   ├── setup-hooks.sh                       # Shell script
│   ├── sync-structure.sh        # Project structure synchronization
│   ├── validate-structure.sh    # Project structure validation
│   └── version.sh                       # Shell script
├── .shellcheckrc            # Shell script linting configuration
├── soft-delete.sh           # Main application source script
├── tests/                   # Test suites and testing infrastructure
│   ├── edge-cases.bats          # Edge case and boundary testing suite
│   ├── soft-delete.bats         # Main application test suite
│   └── test_helper.bash         # Test utilities and helper functions
├── VERSION                  # Current version information
└── .warp/                   # Warp.dev AI configuration and context
    ├── project-context.md       # Main project context for AI assistance
    ├── protocols/               # Development protocols and procedures
    │   ├── ai-response-completeness-protocol.md                # Development protocol specification
    │   ├── ai-version-control-protocol.md                # Development protocol specification
    │   ├── auto-cleanup-protocol.md                # Development protocol specification
    │   ├── changelog-protocol.md                # Development protocol specification
    │   ├── compliance-protocol.md                # Development protocol specification
    │   ├── consistency-protocol.md                # Development protocol specification
    │   ├── continuous-commit-protocol.md                # Development protocol specification
    │   ├── git-management-protocol.md                # Development protocol specification
    │   ├── structural-alignment-protocol.md                # Development protocol specification
    │   ├── testing-protocol.md                # Development protocol specification
    │   ├── universal-compliance-checklist.md                # Development protocol specification
    │   └── version-protocol.md                # Development protocol specification
    ├── README.md                # Project overview and main documentation
    ├── rules/                   # AI agent behavioral rules
    │   ├── agent-instructions.md                    # AI agent behavioral rule definition
    │   ├── ai-agent-rules.md                    # AI agent behavioral rule definition
    │   ├── dynamic-rules.md                    # AI agent behavioral rule definition
    │   ├── rules-summary.md                    # AI agent behavioral rule definition
    │   └── validate-response-completeness.sh                       # Shell script
    └── templates/               # Template files for rules and protocols
        └── rule-template.md                        # Markdown documentation file
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Tools

The project includes comprehensive development utilities:

```bash
# Build and test
make build                  # Build the executable
make test                   # Run test suite
make docker-test           # Run Docker-based tests
make lint                   # Run shellcheck linting
make docker-lint           # Run linting in Docker

# Development utilities
make install-deps          # Install development dependencies
make check                  # Verify installation
make version               # Show current version

# Cleanup and maintenance
make clean                 # Remove build artifacts
make clean-all            # Comprehensive cleanup
make docker-clean         # Clean Docker environment

# Package and release
make package              # Create distribution archive
```

### Utility Scripts

The `scripts/` directory contains specialized utilities:

#### Security Scanner (`scripts/security-scan.sh`)

```bash
# Run comprehensive security scan
./scripts/security-scan.sh

# Options
./scripts/security-scan.sh --verbose   # Detailed output
./scripts/security-scan.sh --quiet     # Minimal output
```

**Checks performed:**
- File permissions vulnerabilities
- Hardcoded secrets detection
- Path traversal vulnerabilities
- Input validation issues
- ShellCheck security analysis

#### Performance Benchmark (`scripts/benchmark.sh`)

```bash
# Run performance tests
./scripts/benchmark.sh

# Benchmark options
./scripts/benchmark.sh --small         # Small files/directories
./scripts/benchmark.sh --large         # Large files (10MB+)
./scripts/benchmark.sh --all           # All benchmarks
./scripts/benchmark.sh --report        # Generate detailed report
```

#### Cleanup System (`scripts/cleanup.sh`)

```bash
# Comprehensive cleanup with safety features
./scripts/cleanup.sh all               # Clean everything
./scripts/cleanup.sh build             # Clean build artifacts
./scripts/cleanup.sh deployment        # Clean deployment files
./scripts/cleanup.sh --dry-run all     # Preview changes
```

**Safety features:**
- Dry run mode for preview
- Interactive confirmation prompts
- File statistics and reporting
- Selective cleanup options

#### Test Runner (`scripts/run-tests.sh`)

```bash
# Docker-based test execution
./scripts/run-tests.sh                 # Standard tests
./scripts/run-tests.sh --verbose       # Verbose output
./scripts/run-tests.sh --single        # Single test file
```

### Quick Start for Contributors

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes to `soft-delete.sh`
4. Build and test: `make build && make docker-test`
5. Run security scan: `./scripts/security-scan.sh`
6. Add tests for new functionality in `tests/`
7. Update documentation if needed
8. Commit changes: `git commit -am 'Add feature'`
9. Push to branch: `git push origin feature-name`
10. Create a Pull Request

## Deployment & Release Management

The project includes a comprehensive automated deployment system for managing releases across multiple branches.

### Branch Strategy

```
develop ──────────────► staging ──────────────► release
                            │                       │
                            ▼                       ▼
                         test                   master/main
```

### Quick Deployment

```bash
# Deploy to staging
make version-patch       # Update version first
make deploy-staging      # Deploy develop → staging

# Deploy to release
make deploy-release      # Deploy staging → release (creates tags)

# Deploy specific version (replace with desired version)
./scripts/deploy.sh deploy-version 1.0.1

# Check deployment status
make deploy-status
```

### Deployment Commands

| Command | Description | Make Target |
|---------|-------------|-------------|
| `deploy-staging` | Deploy develop to staging | `make deploy-staging` |
| `deploy-release` | Deploy staging to release | `make deploy-release` |
| `deploy-test` | Deploy develop to test | `make deploy-test` |
| `deploy-version VERSION` | Deploy specific version | N/A |
| `revert-staging` | Revert staging deployment | `make revert-staging` |
| `revert-release` | Revert release deployment | `make revert-release` |
| `status` | Show deployment status | `make deploy-status` |

### Version Management Integration

```bash
# Version management
make version-show        # Show current version
make version-patch      # Increment patch: current → current+0.0.1
make version-minor      # Increment minor: current → current+0.1.0
make version-major      # Increment major: current → current+1.0.0
```

### Deployment Features

- ✅ **Version Validation**: Ensures version is updated before deployment
- ✅ **Remote Verification**: Checks push access before deployment
- ✅ **Dry Run Mode**: Preview changes with `--dry-run`
- ✅ **Automatic Tagging**: Creates semantic version tags on release
- ✅ **Branch Synchronization**: Updates master/main with release
- ✅ **Rollback Support**: Complete revert capabilities
- ✅ **State Tracking**: Maintains deployment history

### Safety & Recovery

```bash
# Preview deployment
./scripts/deploy.sh deploy-staging --dry-run

# Emergency rollback
./scripts/deploy.sh revert-release

# Check what's deployed
./scripts/deploy.sh status
```

For detailed deployment documentation, see [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

### CI/CD and Releases

The project uses GitHub Actions for automated testing and releases:

#### Automated Release Process

- **Trigger**: Git tags matching `v*` (e.g., version from VERSION file)
- **Pipeline Stages**:
  1. **Testing**: Docker-based testing with TAP output
  2. **Security**: Linting and security scanning
  3. **Build**: Package creation and artifact generation
  4. **Release**: GitHub release with distribution archives

#### Release Workflow

```bash
# Create and push a release tag (version read from VERSION file)
git tag v$(cat VERSION)
git push origin v$(cat VERSION)

# GitHub Actions will automatically:
# 1. Run comprehensive tests
# 2. Perform security scans
# 3. Build distribution packages
# 4. Create GitHub release with assets
```

#### Quality Assurance

- **Automated Testing**: Full test suite runs on every release
- **Security Scanning**: Vulnerability detection and validation
- **Code Quality**: ShellCheck linting and best practices validation
- **Docker Testing**: Isolated, reproducible test environment
- **TAP Compliance**: Industry-standard test output format

## Requirements

- Bash 4.0 or later
- Standard Unix utilities (`mv`, `mktemp`, `date`, etc.)
- Write access to `/tmp` directory
- Optional: `bats` for running tests
- Optional: Docker for isolated testing

## Compatibility

- ✅ Linux (all major distributions)
- ✅ macOS
- ✅ BSD variants
- ✅ Windows (with WSL/Git Bash)
- ✅ Android (with Termux)

## FAQ

### Q: Where are my files stored after soft deletion?
A: Files are moved to timestamped directories in `/tmp` with format `backup-XXXXX-YYYYMMDD-HHMMSS`.

### Q: How do I recover deleted files?
A: Use standard `mv` command to move files back from the backup location shown in the output.

### Q: Do backup directories get cleaned up automatically?
A: No, backup directories remain in `/tmp` until manually removed or system reboot (depending on your system's `/tmp` cleanup policy).

### Q: Can I change the backup location?
A: Currently, backups are always created in `/tmp`. This may be configurable in future versions.

### Q: What happens if I try to delete a file I don't have permission to read?
A: The script will show an error message and exit without making any changes.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

**Richeve S. Bebedor** - [richeve.bebedor@gmail.com](mailto:richeve.bebedor@gmail.com)

Part of the volkovasystems utility collection

## Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/volkovasystems/soft-delete/issues)
- 💡 **Feature Requests**: [GitHub Issues](https://github.com/volkovasystems/soft-delete/issues)
- 📖 **Documentation**: [GitHub Wiki](https://github.com/volkovasystems/soft-delete/wiki)

---

**Made with ❤️ for safer file operations**

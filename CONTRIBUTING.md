# Contributing to soft-delete

Thank you for your interest in contributing to `soft-delete`! This document provides guidelines and information for contributors.

## Code of Conduct

Please be respectful and constructive in all interactions. We welcome contributions from everyone, regardless of experience level.

## Getting Started

### Prerequisites

**Required:**
- Bash 4.0 or later
- Git
- Make
- Docker and Docker Compose (for recommended testing)

**Optional:**
- `bats` for local testing (fallback method)
- `shellcheck` for code quality checks

### Development Setup

1. Fork the repository on GitHub
2. Clone your fork locally:

   ```bash
   git clone https://github.com/YOUR_USERNAME/soft-delete.git
   cd soft-delete
   ```

   Note: Replace `YOUR_USERNAME` with your actual GitHub username after forking from [volkovasystems/soft-delete](https://github.com/volkovasystems/soft-delete)

3. Install development dependencies:

   ```bash
   make install-deps
   ```

4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Making Changes

1. **Source Code**: The main script is in `soft-delete.sh`
2. **Build**: After making changes, run `make build` to copy to `bin/`
3. **Test**: Run `make test` to ensure your changes work
4. **Lint**: Run `make lint` to check code quality

### Project Structure

```
soft-delete/
├── .github/
│   └── workflows/          # GitHub Actions CI/CD
├── bin/                    # Built executable (git-tracked)
├── docs/                   # Documentation
│   ├── API.md              # API documentation
│   ├── DEPLOYMENT.md       # Deployment guide
│   ├── SECURITY.md         # Security policy and reporting
│   └── TESTING.md          # Testing guide
├── examples/               # Usage examples
│   ├── README.md           # Examples documentation
│   ├── basic_usage.sh      # Basic usage examples
│   └── advanced_usage.sh   # Advanced integration examples
├── Formula/                # Homebrew formula
│   └── soft-delete.rb     # Homebrew package definition
├── reports/                # Test reports (created during testing)
├── scripts/                # Utility scripts (13 shell scripts)
│   ├── benchmark.sh        # Performance testing
│   ├── checkpoint.sh       # Quick checkpoint commits
│   ├── cleanup.sh          # System cleanup utilities
│   ├── compliance-check.sh # 100% compliance verification
│   ├── deploy.sh           # Deployment automation
│   ├── pre-commit-hook.sh  # Git pre-commit validation
│   ├── quick-commit.sh     # Fast commit helper
│   ├── run-tests.sh        # Docker test runner
│   ├── security-scan.sh    # Security scanner
│   ├── sync-structure.sh   # Repository structure sync
│   ├── tap-formatter.sh    # TAP output formatter
│   ├── validate-structural-alignment.sh # Structure validation
│   └── version.sh          # Semantic version management
├── tests/                  # Test suite
│   ├── edge-cases.bats     # Edge case tests
│   ├── soft-delete.bats    # Main test suite
│   └── test_helper.bash    # Test utilities and helpers
├── .editorconfig           # Code formatting standards
├── .gitattributes          # Git file handling
├── .gitignore              # Git ignore patterns
├── .markdownlint.yaml      # Markdown linting rules
├── .shellcheckrc           # Shell linting configuration
├── CHANGELOG.md            # Version history
├── CONTRIBUTING.md         # This file
├── Dockerfile.test         # Docker test environment
├── docker-compose.test.yml # Test orchestration
├── install.sh              # Installation script
├── LICENSE                 # MIT License
├── Makefile                # Build automation
├── README.md               # Main documentation
├── .warp/                  # AI development protocols and rules
│   ├── project-context.md  # Project context (replaces WARP.md)
│   ├── protocols/          # Development protocols
│   ├── rules/              # AI agent rules and guidelines
│   └── templates/          # Rule templates
└── soft-delete.sh          # Source script
```

### Coding Standards

#### Bash Style Guide

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode with `set -euo pipefail`
- Use `readonly` for constants
- Quote variables: `"$variable"`
- Use `local` for function variables
- Use `[[ ]]` for conditionals instead of `[ ]`
- Use `$()` for command substitution instead of backticks

#### Code Organization

- Keep functions focused and single-purpose
- Add comments for complex logic
- Use meaningful variable and function names
- Follow the existing error handling patterns

#### Example Function Style

```bash
# Function to perform a specific task
# Arguments:
#   $1 - input parameter description
# Returns:
#   0 - success
#   1 - error
function_name() {
    local input_param="$1"
    local result

    # Validate input
    if [[ -z "$input_param" ]]; then
        log_error "Input parameter required"
        return 1
    fi

    # Main logic
    if result=$(some_command "$input_param"); then
        log_info "Success: $result"
        return 0
    else
        log_error "Failed to process: $input_param"
        return 1
    fi
}
```

## Testing

This project uses Docker-based testing as the primary method to ensure consistent, isolated test environments with TAP (Test Anything Protocol) compliance.

### Running Tests

**Docker Testing (Recommended):**
```bash
# Standard TAP-compliant tests
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

**Local Testing (Fallback):**
```bash
# Install dependencies first
make install-deps

# Run all tests locally
make test

# Run specific test file
bats tests/soft-delete.bats

# Run with verbose output
bats -v tests/soft-delete.bats
```

**Complete Development Cycle:**
```bash
# Build and test everything
make build && make docker-test
```

### Test Architecture

**Test Files:**
- `tests/soft-delete.bats` - Main functionality tests
- `tests/edge-cases.bats` - Edge cases and special scenarios
- `tests/test_helper.bash` - Shared test utilities

**Docker Environment:**
- Ubuntu 22.04 base with bash, bats, shellcheck
- TAP version 14 compliant output
- Non-root test user for security
- Isolated workspace volumes

### Writing Tests

**Guidelines:**
- Add tests for all new functionality
- Use descriptive test names that explain what is being tested
- Test both success and failure cases
- Include edge cases (special characters, permissions, etc.)
- Clean up test artifacts in `teardown()`
- Use helper functions from `test_helper.bash`

**Test Structure:**
```bash
#!/usr/bin/env bats

# Load test helpers
load test_helper

setup() {
    # Create isolated test environment
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR" || exit
    
    # Copy executable
    cp "$BATS_TEST_DIRNAME/../bin/soft-delete" ./soft-delete
    chmod +x ./soft-delete
}

teardown() {
    # Clean up
    cd /
    rm -rf "$TEST_DIR"
}

@test "descriptive test name" {
    # Setup test data
    create_test_file "test.txt" "content"

    # Execute command
    run ./soft-delete test.txt

    # Assert results
    [ "$status" -eq 0 ]
    [[ "$output" == *"Soft deleted:"* ]]
    [ ! -f "test.txt" ]
    
    # Verify backup using helper
    backup_path=$(extract_backup_path "$output")
    verify_backup "$backup_path" "content"
}
```

**Helper Functions Available:**
- `create_test_file()` - Create test files with content
- `create_symlink()` - Create symbolic links
- `extract_backup_path()` - Extract backup paths from output
- `verify_backup()` - Verify backup integrity
- `cleanup_backups()` - Clean test artifacts

## Submitting Changes

### Pull Request Process

1. **Test Your Changes**

   **Recommended (Docker-based):**
   ```bash
   make build
   make docker-test
   make docker-lint
   ```
   
   **Alternative (Local):**
   ```bash
   make build
   make test
   make lint
   ```

2. **Update Documentation**

   - Update `README.md` if adding features
   - Update `CHANGELOG.md` with your changes
   - Add examples if appropriate

3. **Commit Guidelines**

   - Use clear, descriptive commit messages
   - Start with a verb: "Add", "Fix", "Update", etc.
   - Keep first line under 72 characters
   - Add details in the body if needed

   ```
   Add support for custom backup locations

   - Add --backup-dir option to specify custom backup directory
   - Update help text and documentation
   - Add tests for new functionality
   ```

4. **Push and Create PR**

   ```bash
   git push origin feature/your-feature-name
   ```

   Then create a pull request on GitHub with:

   - Clear title and description
   - Reference any related issues
   - List changes made
   - Note any breaking changes

### PR Checklist

**Required:**
- [ ] Build succeeds (`make build`)
- [ ] Tests pass (preferably `make docker-test`)
- [ ] Code passes linting (`make docker-lint` or `make lint`)
- [ ] Documentation updated (README.md, help text, etc.)
- [ ] CHANGELOG.md updated with your changes
- [ ] Commit messages are clear and descriptive
- [ ] No unnecessary changes (formatting, whitespace, etc.)

**Recommended:**
- [ ] Security scan passes (`./scripts/security-scan.sh`)
- [ ] Edge cases tested (if applicable)
- [ ] Examples added or updated (if new feature)
- [ ] TAP test reports reviewed (`make test-reports`)
- [ ] Backward compatibility maintained

## Types of Contributions

### Bug Fixes

- Check existing issues first
- Include reproduction steps
- Add regression tests
- Update documentation if needed

### New Features

- Discuss large changes in an issue first
- Keep features focused and atomic
- Add comprehensive tests
- Update help text and documentation
- Consider backward compatibility

### Documentation

- Fix typos and grammar
- Improve clarity and examples
- Add missing information
- Update outdated content

### Examples

- Add practical usage examples
- Include different use cases
- Test examples to ensure they work
- Keep examples simple and clear

## Release Process

Releases are handled by maintainers:

1. Update version in `soft-delete.sh`
2. Update `CHANGELOG.md`
3. Tag release: `git tag v1.0.0`
4. Push: `git push origin v1.0.0`
5. Create GitHub release

## Getting Help

- **Questions**: Open a GitHub discussion or issue
- **Bugs**: Create a detailed bug report with reproduction steps
- **Features**: Open an issue to discuss before implementing

## Recognition

Contributors are recognized in:

- `CHANGELOG.md` for their contributions
- GitHub contributors section
- Release notes for significant contributions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to `soft-delete`! Every contribution, no matter how small, is appreciated. 🎉

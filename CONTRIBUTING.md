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
├── .editorconfig            # Code formatting standards
├── .gitattributes           # Git file handling configuration
├── .gitignore               # Git ignore patterns
├── .markdownlint.yaml       # Markdown linting configuration
├── .shellcheckrc            # Shell script linting configuration
├── .github/
│   └── workflows/
│       └── release.yml      # GitHub Actions CI/CD pipeline
├── .warp/                   # Warp.dev AI configuration
│   ├── README.md            # Warp configuration documentation
│   ├── project-context.md   # Main project context
│   ├── protocols/           # Development protocols
│   │   └── 10 protocol files  # Standard workflows and procedures
│   ├── rules/               # AI agent rules and guidelines
│   │   └── 4 rule files        # Behavioral guidelines
│   └── templates/           # Rule templates
├── bin/
│   └── soft-delete          # Built executable
├── dist/                    # Distribution files
├── docs/                    # Documentation
│   ├── API.md               # Comprehensive API documentation
│   ├── DEPLOYMENT.md        # Deployment automation guide
│   ├── SECURITY.md          # Security policy and reporting
│   └── TESTING.md           # Testing guide and infrastructure
├── examples/                # Usage examples
│   ├── README.md            # Examples documentation
│   ├── basic_usage.sh       # Basic usage examples
│   └── advanced_usage.sh    # Advanced integration examples
├── Formula/
│   └── soft-delete.rb       # Homebrew formula
├── reports/                 # Test reports and artifacts
│   └── .gitkeep             # Keep directory in git
├── scripts/                 # Utility scripts
│   ├── benchmark.sh         # Performance testing
│   ├── checkpoint.sh
│   ├── cleanup.sh           # Comprehensive cleanup utility
│   ├── compliance-check.sh  # 100% compliance verification
│   ├── deploy.sh            # Deployment automation system
│   ├── pre-commit-hook.sh
│   └── ... (7 more scripts)
├── tests/                   # Test files
│   ├── edge-cases.bats      # Edge case test suite
│   ├── soft-delete.bats     # Main test suite
│   └── test_helper.bash     # Test utilities and helpers
├── CHANGELOG.md             # Version history
├── CONTRIBUTING.md          # Contribution guidelines
├── docker-compose.test.yml  # Docker testing environment
├── Dockerfile.runtime       # Runtime container
├── Dockerfile.test          # Testing container
├── install.sh               # Simple installation script
├── LICENSE                  # MIT License
├── Makefile                 # Build automation and development tasks
├── README.md                # This file
├── soft-delete.sh           # Source script
└── VERSION                  # Version information
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
   - **REQUIRED:** Update `CHANGELOG.md` with your changes (see [Changelog Management](#changelog-management) below)
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

## Changelog Management

**⚠️ IMPORTANT:** Every commit that changes functionality, fixes bugs, or adds features **MUST** be documented in the changelog before committing. This is enforced by our pre-commit hooks.

### Why Changelog Matters

The changelog serves as:
- **Release Documentation**: Clear record of all changes for each version
- **User Communication**: Helps users understand what's new, changed, or fixed
- **Developer Reference**: Historical context for development decisions
- **Automated Releases**: Powers automatic release note generation

### Quick Start

#### 1. Set Up Changelog Automation

```bash
# Install git hooks (run once)
make setup-hooks

# This enables automatic changelog reminders on commits
```

#### 2. Add Changelog Entries

```bash
# Add a new feature (uses current version from VERSION file)
make changelog-add ENTRY="Add support for custom backup locations" CATEGORY="Added"

# Add a bug fix
make changelog-add ENTRY="Fix permission handling for symbolic links" CATEGORY="Fixed"

# Add with auto-detection (from conventional commit format)
make changelog-add ENTRY="feat: add new configuration option"

# Add to specific version
make changelog-add ENTRY="Security improvement" CATEGORY="Security" VERSION="1.2.0"
```

#### 3. Validate Your Changes

```bash
# Check changelog format
make changelog-validate

# See recent commits for reference
make changelog-recent
```

### Detailed Guide

#### Changelog Script Usage

The `scripts/changelog.sh` script provides full changelog management:

```bash
# Add entries (manual categorization)
./scripts/changelog.sh add "Your change description" [category]

# Prepare for release (maintainers only)
./scripts/changelog.sh prepare-release "1.2.0"

# Validate format
./scripts/changelog.sh validate

# View recent commits for reference
./scripts/changelog.sh recent-commits [count]

# Show help
./scripts/changelog.sh help
```

#### Make Targets

```bash
# Quick changelog operations via make
make changelog-add ENTRY="description" [CATEGORY="Added"]
make changelog-prepare VERSION="x.y.z"  # Maintainers only
make changelog-validate
make changelog-recent [COUNT=10]
make changelog-help
```

### Categories

Use these standard categories based on [Keep a Changelog](https://keepachangelog.com/):

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Vulnerability fixes

### Examples

#### Manual Categorization

```bash
# New feature
make changelog-add ENTRY="Add --dry-run option for preview mode" CATEGORY="Added"

# Bug fix
make changelog-add ENTRY="Fix crash when processing empty files" CATEGORY="Fixed"

# Security improvement
make changelog-add ENTRY="Improve input validation to prevent injection" CATEGORY="Security"
```

#### Auto-Detection (Recommended)

The script automatically detects conventional commit formats:

```bash
# These are automatically categorized:
make changelog-add ENTRY="feat: add new configuration system"     # → Added
make changelog-add ENTRY="fix: resolve memory leak in cleanup"    # → Fixed
make changelog-add ENTRY="docs: update API documentation"         # → Changed
make changelog-add ENTRY="security: fix path traversal issue"     # → Security
```

### Git Hooks Integration

After running `make setup-hooks`, git will:

1. **Remind you about changelog updates** when committing significant changes
2. **Validate changelog format** if you're modifying CHANGELOG.md
3. **Allow you to continue or cancel** the commit to update changelog first

#### Hook Behavior

**Will remind you for:**
- Code changes (any non-documentation files)
- Feature commits (`feat:`, `fix:`, etc.)
- Functional modifications

**Will NOT remind you for:**
- Documentation-only changes (`docs:`)
- Style/formatting changes (`style:`)
- Test-only changes (`test:`)
- CI changes (`ci:`)
- When CHANGELOG.md is already included in the commit

#### Hook Interaction

```
📝 CHANGELOG REMINDER
============================================

  ℹ️  You're making changes that might need changelog documentation.

  Quick commands:
    ./scripts/changelog.sh add "Your change description"
    ./scripts/changelog.sh recent-commits 5 # See recent commits

  Continue with commit? (y/N)
```

### Best Practices

#### 1. Write Clear Descriptions

**Good:**
```bash
make changelog-add ENTRY="Add support for excluding files by pattern" CATEGORY="Added"
make changelog-add ENTRY="Fix incorrect exit code when backup fails" CATEGORY="Fixed"
```

**Avoid:**
```bash
make changelog-add ENTRY="Update stuff" CATEGORY="Changed"      # Too vague
make changelog-add ENTRY="Fix bug" CATEGORY="Fixed"             # Not descriptive
```

#### 2. Update Before Committing

```bash
# Recommended workflow:
# 1. Make your code changes
# 2. Test your changes
make build && make docker-test

# 3. Update changelog
make changelog-add ENTRY="Add --verbose flag for detailed output" CATEGORY="Added"

# 4. Commit everything together
git add .
git commit -m "feat: add verbose output option

Adds --verbose flag to show detailed operation information
Includes tests and documentation updates"
```

#### 3. Be Specific About Impact

```bash
# Include user impact
make changelog-add ENTRY="Fix backup failure on systems with limited /tmp space" CATEGORY="Fixed"

# Note breaking changes
make changelog-add ENTRY="Change default backup location from /tmp to ~/.soft-delete (BREAKING)" CATEGORY="Changed"
```

### Troubleshooting

#### Skip Hooks Temporarily

```bash
# Skip hooks for emergency commits (use sparingly)
git commit --no-verify -m "emergency fix"
```

#### Manual Hook Setup

```bash
# If make setup-hooks doesn't work
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

#### Validate Changelog Format

```bash
# Check for formatting issues
./scripts/changelog.sh validate

# Common issues:
# - Invalid version format (use semantic versioning: 1.2.3)
# - Missing dates (format: YYYY-MM-DD)
# - Malformed section headers
```

### Integration with Deployment

Changelog updates are integrated with our deployment system:

- **Staging deployments** require up-to-date changelog entries
- **Release deployments** automatically reference changelog sections
- **Version bumps** can prepare changelog for release

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for complete deployment workflows.

## Release Process

Releases are handled by maintainers:

1. **Update changelog for release**:
   ```bash
   make changelog-prepare VERSION="1.2.0"
   ```

2. **Update version number**:
   ```bash
   make version-minor  # or version-major/version-patch
   ```

3. **Create and push release**:
   ```bash
   git add VERSION CHANGELOG.md
   git commit -m "chore: prepare release 1.2.0"
   git tag v1.2.0
   git push origin v1.2.0
   ```

4. Create GitHub release (automated by CI)

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

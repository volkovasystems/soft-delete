# Contributing to soft-delete

Thank you for your interest in contributing to `soft-delete`! This document provides guidelines and information for contributors.

## Code of Conduct

Please be respectful and constructive in all interactions. We welcome contributions from everyone, regardless of experience level.

## Getting Started

### Prerequisites

- Bash 4.0 or later
- Git
- Make
- Optional: `bats` for running tests
- Optional: `shellcheck` for code quality

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
├── bin/                    # Built executable
├── examples/               # Usage examples and documentation
│   ├── README.md           # Examples documentation
│   ├── basic_usage.sh      # Basic usage examples
│   └── advanced_usage.sh   # Advanced integration examples
├── tests/                  # Test files
│   ├── soft-delete.bats    # Main test suite
│   └── test_helper.bash    # Test utilities
├── .editorconfig           # Code formatting standards
├── CHANGELOG.md            # Version history
├── CONTRIBUTING.md         # This file
├── install.sh              # Simple installation script
├── LICENSE                 # MIT License
├── Makefile                # Build configuration
├── README.md               # Main documentation
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

### Running Tests

```bash
# Run all tests
make test

# Run specific test file
bats tests/soft-delete.bats

# Run with verbose output
bats -t tests/soft-delete.bats
```

### Writing Tests

- Add tests for all new functionality
- Use descriptive test names
- Test both success and failure cases
- Clean up test artifacts in `teardown()`

#### Test Example

```bash
@test "descriptive test name" {
    # Setup
    create_test_file "test.txt" "content"

    # Execute
    run ./soft-delete test.txt

    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"expected output"* ]]
    [ ! -f "test.txt" ]
}
```

## Submitting Changes

### Pull Request Process

1. **Test Your Changes**

   ```bash
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

- [ ] Tests pass (`make test`)
- [ ] Code passes linting (`make lint`)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Commit messages are clear
- [ ] No unnecessary changes (formatting, etc.)

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
3. Tag release: `git tag v0.0.0`
4. Push: `git push origin v0.0.0`
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

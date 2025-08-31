# Testing Protocol for Warp.dev

This protocol defines the standard testing procedures for the `soft-delete` project when working with Warp.dev agents.

## Primary Testing Method

### Docker-based Testing (Preferred)
Always use Docker-based testing as the primary method:

```bash
# Standard TAP-compliant test run
make docker-test

# Verbose output for debugging
make docker-test-verbose

# Lint-only check
make docker-lint
```

**Why Docker?**
- Consistent environment across all development machines
- Isolated test execution
- TAP version 14 compliant output for CI/CD
- Includes all required dependencies (bats, shellcheck, etc.)

## Test Development Workflow

### 1. Before Making Changes
```bash
# Ensure clean baseline
make docker-test
```

### 2. During Development
```bash
# Quick build and test cycle
make build && make docker-test

# For verbose debugging
make build && make docker-test-verbose
```

### 3. Adding New Features
1. Write tests first in `tests/soft-delete.bats`
2. Implement feature in `soft-delete.sh`
3. Run full test suite: `make docker-test`
4. Update help text if needed
5. Ensure 100% test pass rate

### 4. Edge Cases
Add edge case tests to `tests/edge-cases.bats`:
- Special characters in filenames
- Permission scenarios
- Broken symlinks
- Large file handling

## Test Structure Requirements

### Test File Organization
```
tests/
├── soft-delete.bats      # Main functionality tests
├── edge-cases.bats       # Edge case and error condition tests
└── test_helper.bash      # Shared test utilities
```

### Test Naming Convention
```bash
@test "should [expected behavior] when [condition]" {
    # Test implementation
}
```

### Required Test Coverage Areas
- [ ] Command-line argument parsing (both long and short forms)
- [ ] File and directory operations
- [ ] Backup directory creation and uniqueness
- [ ] Error handling and exit codes
- [ ] Permission preservation
- [ ] Special characters and edge cases
- [ ] Verbose mode functionality

## Quality Gates

### Before Any Commit
All tests must pass:
```bash
make docker-test
# Expected: 100% pass rate with TAP output
```

### Before Release
Complete validation:
```bash
# Full test suite
make docker-test

# Security scan
./scripts/security-scan.sh

# Build verification
make build && make check
```

## Debugging Failed Tests

### Step-by-Step Debug Process
1. **Run verbose tests**:
   ```bash
   make docker-test-verbose
   ```

2. **Check TAP reports**:
   ```bash
   cat ./reports/tap/results.tap
   ```

3. **Lint check**:
   ```bash
   make docker-lint
   ```

4. **Manual verification**:
   ```bash
   # Test specific functionality manually
   ./bin/soft-delete --verbose test-file.txt
   ```

### Common Test Failures
- **Permission errors**: Check test file setup
- **Path issues**: Verify test helper functions
- **Docker environment**: Run `make docker-clean` and retry
- **Syntax errors**: Check `bash -n soft-delete.sh`

## Fallback Testing (Local)

Only use local testing when Docker is unavailable:

```bash
# Install dependencies first
make install-deps

# Run tests locally
make test

# Lint only
make lint
```

**Note**: Local testing may have environment-specific issues and is not recommended for production workflows.

## Test Reporting

### TAP Output Format
All tests produce TAP (Test Anything Protocol) version 14 output:
```
TAP version 14
1..45
ok 1 - should create backup when deleting file
ok 2 - should preserve file permissions in backup
# ... additional test results
```

### Test Reports Location
```
./reports/
├── tap/
│   └── results.tap       # TAP format results
└── coverage/             # Coverage reports (if available)
```

## Integration with CI/CD

### GitHub Actions Integration
Tests run automatically on:
- Pull requests
- Pushes to `main` and `develop` branches
- Git tags (`v*` pattern)

### Required Checks
- [ ] All tests pass (100% success rate)
- [ ] ShellCheck compliance (100% clean)
- [ ] Security scan passes
- [ ] Build verification succeeds

## Protocol Compliance

When working with Warp.dev agents:
1. **Always use Docker testing** unless explicitly requested otherwise
2. **Verify test success** before proceeding with changes
3. **Run full test suite** for any code modifications
4. **Check TAP output** for detailed test results
5. **Clean Docker environment** if tests behave unexpectedly

This protocol ensures reliable, consistent testing across all development activities.

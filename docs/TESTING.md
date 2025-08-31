# Docker-Based Testing with TAP Compliance

This document describes the Docker-based testing setup for the
soft-delete project, which provides isolated, reproducible testing with TAP
(Test Anything Protocol) compliant output.

## Overview

Our testing infrastructure uses:

- **Docker** for isolated test environments
- **BATS** (Bash Automated Testing System) for test execution
- **TAP** (Test Anything Protocol) for standardized test output
- **Docker Compose** for orchestrating test services

## Quick Start

### Running Tests

```bash
# Run all tests in Docker (recommended)
make docker-test

# Run tests with verbose output
make docker-test-verbose

# Run only linting
make docker-lint

# View test reports
make test-reports

# Clean up everything
make clean-all
```

---

### Using the Test Script

```bash
# Basic test run
./scripts/run-tests.sh

# Run with cleanup and show reports
./scripts/run-tests.sh -c -r test

# Run all test types
./scripts/run-tests.sh all

# Get help
./scripts/run-tests.sh --help
```

---

## Test Environment

### Test Files Structure

The project includes comprehensive test coverage:

```
tests/
├── soft-delete.bats     # Main functionality tests (core features)
├── edge-cases.bats      # Edge cases and special scenarios
└── test_helper.bash     # Shared test utilities and helper functions
```

**Test Coverage Areas:**
- Basic file and directory operations
- Command-line argument parsing (both long and short forms)
- Error handling and validation
- Special characters and Unicode in filenames
- File permissions and executable preservation
- Symbolic links (both working and broken)
- Large files and binary data
- Edge cases (files starting with dash, very long names, etc.)

### Docker Configuration

**Dockerfile.test** creates a testing environment with:

- Ubuntu 22.04 base image
- BATS testing framework
- Additional BATS libraries (bats-support, bats-assert, bats-file)
- shellcheck for code quality
- Non-root test user for security

**docker-compose.test.yml** defines services for:

- `test`: Standard TAP-compliant test execution
- `test-verbose`: Detailed test output
- `test-single`: Single test file execution
- `lint`: Code quality checks

### Volume Mounts

```yaml
volumes:
  - ./bin:/app/bin:ro              # Source code (read-only)
  - ./soft-delete.sh:/app/soft-delete.sh:ro  # Source file mount
  - ./tests:/app/tests:ro
  - ./reports:/app/reports:rw      # Test reports (read-write)
  - test-workspace:/tmp/test-workspace:rw  # Isolated workspace
```

## TAP Compliance

### TAP Format

Our tests produce TAP version 14 compliant output:

```tap
TAP version 14
ok 1 - script exists and is executable
ok 2 - show help with --help
ok 3 - show version with --version
not ok 4 - error when file does not exist
# Expected error message not found
ok 5 - soft delete a file
1..5
```

### TAP Features

- ✅ **Version declaration**: `TAP version 14`
- ✅ **Test plan**: `1..N` format
- ✅ **Test results**: `ok`/`not ok` with descriptions
- ✅ **Diagnostics**: Comments starting with `#`
- ✅ **Skip support**: `ok N - test # SKIP reason`
- ✅ **TODO support**: `not ok N - test # TODO reason`

## Test Reports

### Directory Structure

```
reports/
├── tap/           # TAP format test results
│   └── results.tap
├── junit/         # JUnit XML format (if enabled)
├── coverage/      # Code coverage reports
├── artifacts/     # Test artifacts and logs
└── shellcheck.txt # Linting results
```

### Accessing Reports

Reports are automatically generated in the `./reports` directory and can be:

- Viewed locally after test execution
- Uploaded as CI/CD artifacts
- Processed by test result parsers
- Integrated with test reporting tools

## Available Make Targets

### Docker Test Targets

```bash
make docker-test              # Standard TAP-compliant testing
make docker-test-verbose      # Verbose test output
make docker-test-single       # Single test file execution
make docker-lint              # Code quality checks in Docker
```

### Management Targets

```bash
make docker-clean             # Clean Docker environment
make test-reports             # Show available reports
make clean-reports            # Remove test reports
make clean-all                # Full cleanup (build + reports + docker)
```

## Test Helper Functions

The `tests/test_helper.bash` file provides:

### TAP-Compliant Diagnostic Functions

- `tap_pass()` - Add PASS diagnostic comment
- `tap_fail()` - Add FAIL diagnostic comment
- `tap_skip()` - Add SKIP diagnostic comment
- `tap_todo()` - Add TODO diagnostic comment
- `tap_diagnostic()` - Add general diagnostic comment

### File and Directory Creation

- `create_test_file(filename, content)` - Create test files with specific content
- `create_test_directory(dirname, filename, content)` - Create directories with test files
- `create_executable_file(filename, content)` - Create executable files with proper permissions
- `create_symlink(target, linkname)` - Create symbolic links
- `setup_complex_structure()` - Create nested directory structure for testing

### Backup Verification

- `extract_backup_path(output)` - Extract backup paths from soft-delete output
- `verify_backup(backup_path, expected_content)` - Verify backup exists and has correct content
- `cleanup_backups()` - Clean up backup directories for test isolation
- `count_backups()` - Count backup directories in /tmp

### Debug and Utility Functions

- `print_test_env()` - Print test environment information for debugging

---

## CI/CD Integration

### GitHub Actions

The workflow automatically:

1. Sets up Docker environment
2. Runs tests with TAP output
3. Uploads test reports as artifacts
4. Publishes test results with TAP parser
5. Fails on test failures

### Key Features

```yaml
- name: Run Docker tests with TAP output
  run: |
    echo "Starting Docker tests..."
    make docker-test

- name: Run Docker linting
  run: |
    echo "Starting Docker linting..."
    make docker-lint || echo "Linting completed with warnings (non-fatal)"

- name: Upload test reports
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: test-reports-${{ github.run_number }}
    path: |
      reports/
      !reports/.gitkeep
    retention-days: 30

- name: Publish TAP Results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always()
  with:
    files: |
      reports/**/*.tap
      reports/**/*.xml
    check_name: "Test Results (TAP)"
    comment_mode: create new
    fail_on: "test failures"
```

## Troubleshooting

### Common Issues

### Docker not found

```bash
# Install Docker
sudo apt-get install docker.io docker-compose
```

### Permission denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Re-login or restart shell
```

### Tests failing in Docker but passing locally

- Check file permissions
- Verify volume mounts
- Check environment variables

### TAP output not valid

```bash
# Validate TAP output manually
cat reports/tap/results.tap | tap-parser
```

### Debug Mode

```bash
# Run with verbose output
make docker-test-verbose

# Keep containers running for inspection
./scripts/run-tests.sh -k test

# Inspect running container
# (Next line wrapped for 80 chars)
docker exec -it soft-delete-test /bin/bash
```

### Log Access

```bash
# View container logs
docker-compose -f docker-compose.test.yml logs test

# Follow logs in real-time
docker-compose -f docker-compose.test.yml logs -f test
```

## Advanced Usage

### Custom Test Commands

```bash
# Run specific test pattern
docker-compose -f docker-compose.test.yml run test \
  bats --tap /app/tests/ -f "soft delete"

# Run with custom environment
TAP_VERSION=13 docker-compose -f docker-compose.test.yml up test
```

### Integration with External Tools

```bash
# Parse TAP output with prove
cat reports/tap/results.tap | prove -

# Generate HTML report
bats-html-formatter < reports/tap/results.tap > reports/test-report.html

# Convert to JUnit XML
tap-junit < reports/tap/results.tap > reports/junit/results.xml
```

## Best Practices

1. **Always run tests in Docker** for consistency
2. **Check TAP compliance** with validators
3. **Use meaningful test descriptions** for better reports
4. **Clean up after tests** to avoid interference
5. **Review test reports** before merging changes
6. **Keep test environment minimal** for faster execution

## References

- [TAP Specification](https://testanything.org/)
- [BATS Documentation](https://bats-core.readthedocs.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

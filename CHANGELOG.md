# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and follows the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

## [0.0.0] - 2025-08-30

### Added
- Initial core features for soft-delete
- Command-line interface and standard options
- Safe file deletion with timestamped backups
- File permission preservation system
- Backup directory with unique identifiers
- Homebrew formula and installation support
- Makefile targets for automation and version management
- GitHub Actions workflow with testing and release automation
- Docker-based testing environment with TAP compliance
- Docker Compose orchestration for test services
- TAP version 14 compliant test output
- Isolated test environment with volume mounting
- BATS libraries integration (bats-support, bats-assert, bats-file)
- Test report generation and artifact management
- Comprehensive cleanup script for build and deployment
- Selective cleanup by artifact type (build, temp, docker, reports, deployment)
- Dry-run mode with cleanup preview and statistics
- Force mode and confirmation prompts for safety
- Verbose and quiet modes for different use cases
- Multiple cleanup targets for Makefile
- Cleanup integration with build process
- Test helper functions with TAP-compliant logging
- Enhanced error handling and validation in tests
- Comprehensive security scanning and vulnerability detection
- Hardcoded secrets detection and path traversal protection
- Input validation analysis and Docker security scanning
- Performance benchmarking suite with memory usage analysis
- Performance regression testing and detailed reporting
- Concurrent operation and stress testing capabilities
- Comprehensive edge case testing for special characters and Unicode
- Binary file, symlink, and filesystem edge case coverage
- Concurrent operation testing and data integrity verification
- Comprehensive shellcheck configuration and git attributes
- Editor configuration for consistent code formatting
- Support for files starting with dash using -- argument handling
- Enhanced argument parsing with proper -- end-of-options support
- Broken symbolic link detection and handling capabilities
- Comprehensive test suite with error handling and validation
- Comprehensive API documentation with function-level references
- Comprehensive Docker testing documentation
- Cleanup system usage guide and examples
- Troubleshooting guide for Docker testing
- TAP compliance and testing best practices
- Performance benchmarking and security scanning documentation
- Basic usage examples and installation guide
- Contributing guidelines and code of conduct
- Homebrew installation instructions
- Makefile for project automation and packaging
- .gitignore for project organization
- Comprehensive linting configuration and project standards
- Configuration management with `.markdownlint.yaml` for consistent markdown standards and quality compliance
- TAP-compliant test results (`reports/tap/results.tap`) with 45 comprehensive test cases
- Comprehensive update to README.md with current project structure and capabilities
- Enhanced API.md with complete function documentation and examples
- Comprehensive utility scripts in `scripts/` directory:
  - `security-scan.sh`: Comprehensive security vulnerability scanner
  - `benchmark.sh`: Performance testing and memory analysis
  - `cleanup.sh`: Comprehensive cleanup utility with safety features
  - `run-tests.sh`: Docker-based test runner
  - `tap-formatter.sh`: TAP output formatter
- Enhanced GitHub Actions workflow with security improvements and better error handling
- `docs/` directory with API documentation and testing guides
- Comprehensive Docker testing infrastructure with TAP compliance
- Markdown linting, security scanning, and performance benchmarking
- WARP.md guidance file for AI-assisted development
- Production-ready deployment preparation and validation
- Centralized VERSION file as single source of truth for version numbers
- Version management script (`scripts/version.sh`) with semantic versioning support
- Makefile integration for version management (version-major, version-minor, version-patch targets)

### Changed
- Streamlined and organized all configuration files for better maintainability:
  - `.editorconfig`: Removed redundant comments, cleaner structure
  - `.gitattributes`: Reorganized and optimized file type declarations
  - `.shellcheckrc`: Formatted configuration with organized disable/enable rules
  - `.gitignore`: Simplified structure while maintaining functionality
- Complete overhaul of project documentation to reflect current capabilities
- README.md updated with comprehensive development tools, testing infrastructure, and CI/CD information
- Project structure reorganized to include comprehensive API reference and testing guides

### Fixed
- Resolved all shellcheck warnings, achieving 100% compliance across 12 shell files
- Addressed SC2155 warnings by separating variable declarations
- Fixed SC2164 warnings with enhanced error handling for cd commands
- Fixed SC2154 warnings for BATS built-in variables with proper disable directives
- Fixed SC2076 warnings by correcting regex pattern matching in tests
- Improved Docker build compatibility with Ubuntu 22.04 (awk → gawk)
- Improved command substitution quoting for security
- Enhanced file handling for special characters and edge cases
- Improved path validation for broken symlink handling (-e AND -L checks)
- Improved argument parsing for files starting with dash (proper -- handling)
- Improved test reliability and edge case coverage
- Updated GitHub Actions to latest versions for security:
  - `actions/checkout@v4` → `v5`
  - `actions/cache@v3` → `v4`
  - `actions/upload-artifact@v3` → `v4`
  - `softprops/action-gh-release@v1` → `v2`
- Added explicit permissions and timeout limits for workflow security
- Fixed broken links and inconsistent formatting in API.md
- Fixed `.gitignore` patterns to properly handle `.tap` files and other extensions
- Enhanced Docker operations in CI/CD with better error reporting and diagnostics
- Removed deprecated `version` attribute from docker-compose.test.yml
- Fixed incorrect terminology in API.md (compile → copy for build process)
- Enhanced CONTRIBUTING.md with Docker-first testing approach and updated project structure
- Improved TESTING.md with accurate test helper function documentation
- Updated all documentation for consistency and deployment readiness

### Security
- Implemented comprehensive vulnerability scanning
- Added protection against path traversal attacks
- Ensured secure handling of files starting with dashes
- Input validation for all user-provided data
- Non-root Docker execution environment
- Secrets detection and prevention systems
- Added security permissions restrictions following principle of least privilege
- Updated all actions to latest secure versions
- Added security scanning integration to development process
- Enhanced security-conscious development practices in documentation

### Performance
- Optimized file operations for single atomic moves
- Added memory-conscious processing for large files
- Implemented efficient backup directory creation
- Performance monitoring and regression detection
- Achieved 100% test pass rate (45/45 tests passing)
- Added timeout limits to prevent runaway jobs
- Improved error handling and logging for better debugging
- Enhanced TAP-compliant testing with detailed reporting

---

#### Technical Details
- Written in Bash with strict mode (`set -euo pipefail`)
- Uses `/tmp` for backup storage
- Implements proper signal handling and cleanup
- Follows bash best practices for error handling
- Part of the volkovasystems utility collection
- Docker testing environment with Ubuntu 22.04 and BATS framework
- TAP version 14 compliant test output format
- Non-root test user for security in Docker environment
- Volume mounting for code isolation and report persistence
- Multi-level cleanup system for build, temp, Docker, reports, and deployment artifacts
- Smart preview system with file count and size statistics
- Cross-platform cleanup compatibility (macOS, Linux, Windows)
- CI/CD integration with automated cleanup and test reporting
- 100% shellcheck compliance across all 12 shell script files
- 100% test success rate with 45 comprehensive test cases
- Complete edge case coverage including Unicode, binary files, symlinks, and special characters
- Production-ready quality meeting all modern open source standards

---

## Release Management

### Versioning
This project uses [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html):
- **MAJOR**: Incompatible API changes
- **MINOR**: Functionality added in a backwards-compatible manner
- **PATCH**: Backwards-compatible bug fixes

### Release Process
1. Update the version number using `./scripts/version.sh` or `make version-patch/minor/major`.
2. Update this CHANGELOG.md with release notes.
3. Create git tag, e.g. `git tag v0.0.0`.
4. Push tag: `git push origin v0.0.0`.
5. Create GitHub release with the release notes.

### Version Management
The project uses a centralized VERSION file as the single source of truth:
- **VERSION file**: Contains only the current version number (e.g., 0.0.0)
- **Version script**: `./scripts/version.sh` for managing version updates
- **Makefile integration**: Version targets for easy version management

### Section Definitions
- **Added**: For new features.
- **Changed**: For changes in existing functionality.
- **Deprecated**: For features soon-to-be removed.
- **Removed**: For now-removed features.
- **Fixed**: For any bug fixes.
- **Security**: For vulnerabilities or mitigations.

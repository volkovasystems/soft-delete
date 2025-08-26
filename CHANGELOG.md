# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.0] - 2025-08-22

### Added

- feat: Add initial soft-delete implementation core features
- feat: Add command-line interface and standard options
- feat: Add safe file deletion with timestamped backups
- feat: Add file permission preservation system
- feat: Add backup directory with unique identifiers
- feat: Add Homebrew formula and installation support
- feat: Add Makefile targets for automation and version management
- feat(ci): Add GitHub Actions workflow with testing and release automation
- feat(test): Add Docker-based testing environment with TAP compliance
- feat(test): Add Docker Compose orchestration for test services
- feat(test): Add TAP version 14 compliant test output
- feat(test): Add isolated test environment with volume mounting
- feat(test): Add BATS libraries integration (bats-support, bats-assert, bats-file)
- feat(test): Add test report generation and artifact management
- feat(build): Add comprehensive cleanup script for build and deployment
- feat(build): Add selective cleanup by artifact type (build, temp, docker, reports, deployment)
- feat(build): Add dry-run mode with cleanup preview and statistics
- feat(build): Add force mode and confirmation prompts for safety
- feat(build): Add verbose and quiet modes for different use cases
- feat(build): Add multiple cleanup targets to Makefile
- feat(build): Add cleanup integration with build process
- feat(dev): Add test helper functions with TAP-compliant logging
- feat(dev): Add enhanced error handling and validation in tests
- test: Add comprehensive test suite with error handling and validation
- docs: Add comprehensive Docker testing documentation
- docs: Add cleanup system usage guide and examples
- docs: Add troubleshooting guide for Docker testing
- docs: Add TAP compliance and testing best practices
- docs: Add basic usage examples and installation guide
- docs: Add contributing guidelines and code of conduct
- docs: Add Homebrew installation instructions
- build: Add Makefile for project automation and packaging
- chore: Add .gitignore for project organization

### Technical Details

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

---

## Version History Notes

### Version Numbering

This project follows semantic versioning (SemVer):

- **MAJOR**: Incompatible API changes
- **MINOR**: Added functionality in a backwards compatible manner
- **PATCH**: Backwards compatible bug fixes

### Release Process

1. Update version number in `soft-delete.sh`
2. Update this CHANGELOG.md with release notes
3. Create git tag: `git tag v0.0.0`
4. Push tag: `git push origin v0.0.0`
5. Create GitHub release with release notes

### Categories

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Vulnerability fixes

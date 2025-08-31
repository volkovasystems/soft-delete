# Makefile for soft-delete
# Copyright (c) 2025 Richeve S. Bebedor <richeve.bebedor@gmail.com>

# Variables
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man/man1
SCRIPT_NAME = soft-delete
SOURCE_SCRIPT = soft-delete.sh
INSTALL = install

# Default target
.PHONY: all
all: build

# Build target - copy source to bin directory
.PHONY: build
build:
	@echo "Building $(SCRIPT_NAME)..."
	@mkdir -p bin
	@cp $(SOURCE_SCRIPT) bin/$(SCRIPT_NAME)
	@chmod +x bin/$(SCRIPT_NAME)
	@echo "Build complete. Executable created at bin/$(SCRIPT_NAME)"

# Install target
.PHONY: install
install: build
	@echo "Installing $(SCRIPT_NAME) to $(BINDIR)..."
	@$(INSTALL) -d $(BINDIR)
	@$(INSTALL) -m 755 bin/$(SCRIPT_NAME) $(BINDIR)/$(SCRIPT_NAME)
	@echo "Installation complete. $(SCRIPT_NAME) installed to $(BINDIR)/$(SCRIPT_NAME)"
	@echo "You can now run '$(SCRIPT_NAME)' from anywhere."

# Uninstall target
.PHONY: uninstall
uninstall:
	@echo "Uninstalling $(SCRIPT_NAME) from $(BINDIR)..."
	@rm -f $(BINDIR)/$(SCRIPT_NAME)
	@echo "Uninstallation complete."

# Test target
.PHONY: test
test: build
	@echo "Running tests..."
	@if command -v bats >/dev/null 2>&1; then \
		bats tests/; \
	else \
		echo "bats not found. Install bats to run tests:"; \
		echo "  Ubuntu/Debian: sudo apt-get install bats"; \
		echo "  macOS: brew install bats-core"; \
		echo "  Or run tests manually from tests/ directory"; \
	fi

# Lint target - basic bash syntax checking
.PHONY: lint
lint:
	@echo "Checking bash syntax..."
	@bash -n $(SOURCE_SCRIPT)
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "Running shellcheck..."; \
		shellcheck $(SOURCE_SCRIPT); \
	else \
		echo "shellcheck not found. Install for better linting:"; \
		echo "  Ubuntu/Debian: sudo apt-get install shellcheck"; \
		echo "  macOS: brew install shellcheck"; \
	fi

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -f bin/$(SCRIPT_NAME)
	@rm -rf dist/
	@echo "Build artifacts cleaned."

# Clean temporary files
.PHONY: clean-temp
clean-temp:
	@echo "Cleaning temporary files..."
	@find . -name "*.tmp" -type f -delete 2>/dev/null || true
	@find . -name "*.log" -type f -delete 2>/dev/null || true
	@find . -name "*~" -type f -delete 2>/dev/null || true
	@find . -name ".DS_Store" -type f -delete 2>/dev/null || true
	@find . -name "Thumbs.db" -type f -delete 2>/dev/null || true
	@find . -name "*.swp" -type f -delete 2>/dev/null || true
	@find . -name "*.swo" -type f -delete 2>/dev/null || true
	@find . -name "*.orig" -type f -delete 2>/dev/null || true
	@find . -name "*.rej" -type f -delete 2>/dev/null || true
	@echo "Temporary files cleaned."

# Clean package files
.PHONY: clean-dist
clean-dist:
	@echo "Cleaning distribution packages..."
	@rm -rf dist/
	@echo "Distribution packages cleaned."

# Check target - verify installation
.PHONY: check
check:
	@echo "Checking if $(SCRIPT_NAME) is installed..."
	@if command -v $(SCRIPT_NAME) >/dev/null 2>&1; then \
		echo "✓ $(SCRIPT_NAME) is installed at: $$(which $(SCRIPT_NAME))"; \
		echo "✓ Version: $$($(SCRIPT_NAME) --version | head -1)"; \
	else \
		echo "✗ $(SCRIPT_NAME) is not installed or not in PATH"; \
		exit 1; \
	fi

# Install development dependencies
.PHONY: install-deps
install-deps:
	@echo "Installing development dependencies..."
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "Detected Ubuntu/Debian. Installing bats and shellcheck..."; \
		sudo apt-get update && sudo apt-get install -y bats shellcheck; \
	elif command -v brew >/dev/null 2>&1; then \
		echo "Detected macOS with Homebrew. Installing bats-core and shellcheck..."; \
		brew install bats-core shellcheck; \
	elif command -v yum >/dev/null 2>&1; then \
		echo "Detected RHEL/CentOS. Installing ShellCheck..."; \
		sudo yum install -y ShellCheck; \
		echo "Please install bats manually from https://github.com/bats-core/bats-core"; \
	else \
		echo "Unable to detect package manager. Please install manually:"; \
		echo "  bats: https://github.com/bats-core/bats-core"; \
		echo "  shellcheck: https://github.com/koalaman/shellcheck"; \
	fi

# Version management
VERSION := $(shell cat VERSION | tr -d '\n\r' | tr -d ' ')

# Package target - create distribution archive
.PHONY: package
package: clean build
	@echo "Creating package for version $(VERSION)..."
	@mkdir -p dist
	@tar -czf dist/$(SCRIPT_NAME)-$(VERSION).tar.gz \
		--exclude='.git*' --exclude='dist' --exclude='.DS_Store' \
		--transform 's,^,$(SCRIPT_NAME)/,' \
		*
	@echo "Package created: dist/$(SCRIPT_NAME)-$(VERSION).tar.gz"

# Version targets
.PHONY: version
version:
	@echo "$(VERSION)"

.PHONY: version-show
version-show:
	@./scripts/version.sh show

.PHONY: version-major
version-major:
	@./scripts/version.sh major

.PHONY: version-minor
version-minor:
	@./scripts/version.sh minor

.PHONY: version-patch
version-patch:
	@./scripts/version.sh patch

# Docker-based testing targets
.PHONY: docker-test
docker-test: build
	@echo "Running tests in Docker with TAP output..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml up --build test
	@echo "Tests completed. TAP reports available in ./reports/"

.PHONY: docker-test-verbose
docker-test-verbose: build
	@echo "Running verbose tests in Docker..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml up --build test-verbose
	@echo "Verbose tests completed. Reports available in ./reports/"

.PHONY: docker-test-single
docker-test-single: build
	@echo "Running single test file in Docker..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml up --build test-single
	@echo "Single test completed. Reports available in ./reports/"

.PHONY: docker-lint
docker-lint: build
	@echo "Running shellcheck in Docker..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml up --build lint
	@echo "Linting completed. Results available in ./reports/shellcheck.txt"

.PHONY: docker-clean
docker-clean:
	@echo "Cleaning Docker test environment..."
	@docker-compose -f docker-compose.test.yml down --volumes --remove-orphans
	@docker image rm $$(docker images -q soft-delete*) 2>/dev/null || true
	@echo "Docker cleanup complete."

.PHONY: test-reports
test-reports:
	@echo "Available test reports:"
	@ls -la reports/ 2>/dev/null || echo "No reports found. Run 'make docker-test' first."

.PHONY: clean-reports
clean-reports:
	@echo "Cleaning test reports..."
	@rm -rf reports/*
	@echo "Reports cleaned."

# Comprehensive cleanup using cleanup script
.PHONY: cleanup
cleanup:
	@./scripts/cleanup.sh all

.PHONY: cleanup-build
cleanup-build:
	@./scripts/cleanup.sh build

.PHONY: cleanup-deployment
cleanup-deployment:
	@./scripts/cleanup.sh deployment

.PHONY: cleanup-dry-run
cleanup-dry-run:
	@./scripts/cleanup.sh -n all

# Enhanced clean target
.PHONY: clean-all
clean-all: clean clean-temp clean-dist clean-reports docker-clean
	@echo "Full cleanup complete."

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all              - Build the project (default)"
	@echo "  build            - Copy source script to bin/ and make executable"
	@echo "  install          - Install $(SCRIPT_NAME) to $(PREFIX)/bin (requires sudo)"
	@echo "  uninstall        - Remove $(SCRIPT_NAME) from $(PREFIX)/bin (requires sudo)"
	@echo "  test             - Run test suite (requires bats)"
	@echo "  docker-test      - Run tests in Docker with TAP output"
	@echo "  docker-test-verbose - Run verbose tests in Docker"
	@echo "  docker-test-single - Run single test file in Docker"
	@echo "  docker-lint      - Run shellcheck in Docker"
	@echo "  lint             - Check bash syntax and run shellcheck"
	@echo "  clean            - Remove build artifacts"
	@echo "  clean-temp       - Remove temporary files (.tmp, .log, ~, etc.)"
	@echo "  clean-dist       - Remove distribution packages"
	@echo "  clean-reports    - Remove test reports"
	@echo "  clean-all        - Full cleanup (build + reports + docker + temp)"
	@echo "  cleanup          - Comprehensive cleanup using cleanup script"
	@echo "  cleanup-build    - Clean only build artifacts (comprehensive)"
	@echo "  cleanup-deployment - Clean deployment artifacts"
	@echo "  cleanup-dry-run  - Preview what cleanup would do"
	@echo "  docker-clean     - Clean Docker test environment"
	@echo "  test-reports     - Show available test reports"
	@echo "  check            - Verify installation"
	@echo "  install-deps     - Install development dependencies"
	@echo "  package          - Create distribution archive (version: $(VERSION))"
	@echo "  version          - Show current version (short)"
	@echo "  version-show     - Show detailed version information"
	@echo "  version-major    - Increment major version (x.0.0)"
	@echo "  version-minor    - Increment minor version (x.y.0)"
	@echo "  version-patch    - Increment patch version (x.y.z)"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Docker Test Targets:"
	@echo "  docker-test      - Standard TAP-compliant testing in Docker"
	@echo "  docker-test-verbose - Verbose test output with detailed logs"
	@echo "  docker-lint      - Code quality checks in isolated environment"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX           - Installation prefix (default: /usr/local)"
	@echo "  BINDIR           - Binary installation directory (default: \$PREFIX/bin)"
	@echo ""
	@echo "Examples:"
	@echo "  make                      # Build the project"
	@echo "  make docker-test          # Run tests in Docker (recommended)"
	@echo "  make docker-test-verbose  # Run tests with verbose output"
	@echo "  make test-reports         # View test results"
	@echo "  sudo make install         # Install system-wide"
	@echo "  make install PREFIX=~     # Install to home directory"

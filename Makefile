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

# Deployment targets
.PHONY: deploy-staging
deploy-staging:
	@./scripts/deploy.sh deploy-staging

.PHONY: deploy-staging-dry
deploy-staging-dry:
	@./scripts/deploy.sh deploy-staging --dry-run

.PHONY: deploy-release
deploy-release:
	@./scripts/deploy.sh deploy-release

.PHONY: deploy-release-dry
deploy-release-dry:
	@./scripts/deploy.sh deploy-release --dry-run

.PHONY: deploy-test
deploy-test:
	@./scripts/deploy.sh deploy-test

.PHONY: deploy-test-dry
deploy-test-dry:
	@./scripts/deploy.sh deploy-test --dry-run

.PHONY: deploy-status
deploy-status:
	@./scripts/deploy.sh status

.PHONY: deploy-cleanup
deploy-cleanup:
	@./scripts/deploy.sh cleanup

# Revert targets
.PHONY: revert-staging
revert-staging:
	@./scripts/deploy.sh revert-staging

.PHONY: revert-release
revert-release:
	@./scripts/deploy.sh revert-release

.PHONY: revert-test
revert-test:
	@./scripts/deploy.sh revert-test

# Docker-based testing targets
.PHONY: docker-test
docker-test: build
	@echo "Running tests in Docker with TAP output..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml down --remove-orphans 2>/dev/null || true
	@docker-compose -f docker-compose.test.yml up --build --force-recreate test
	@echo "Tests completed. TAP reports available in ./reports/"

.PHONY: docker-test-verbose
docker-test-verbose: build
	@echo "Running verbose tests in Docker..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml down --remove-orphans 2>/dev/null || true
	@docker-compose -f docker-compose.test.yml up --build --force-recreate test-verbose
	@echo "Verbose tests completed. Reports available in ./reports/"

.PHONY: docker-test-single
docker-test-single: build
	@echo "Running single test file in Docker..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml down --remove-orphans 2>/dev/null || true
	@docker-compose -f docker-compose.test.yml up --build --force-recreate test-single
	@echo "Single test completed. Reports available in ./reports/"

.PHONY: docker-lint
docker-lint: build
	@echo "Running shellcheck in Docker..."
	@mkdir -p reports
	@docker-compose -f docker-compose.test.yml down --remove-orphans 2>/dev/null || true
	@docker-compose -f docker-compose.test.yml up --build --force-recreate lint
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

# Analysis and Statistics targets
.PHONY: analyze
analyze:
	@echo "=== Script Analysis ==="
	@echo "Total shell scripts: $(shell find . -name '*.sh' | wc -l)"
	@echo "Lines of code: $(shell find . -name '*.sh' -exec cat {} \; | wc -l)"
	@echo "Functions: $(shell grep -r 'function\|.*()' --include='*.sh' . | wc -l)"
	@echo "Test coverage: $(shell grep -c '^@test' tests/*.bats 2>/dev/null || echo '0') test cases"
	@echo "Compliance status: $(shell bash scripts/compliance-check.sh >/dev/null 2>&1 && echo 'PASSING' || echo 'FAILING')"
	@echo "Repository size: $(shell du -sh . --exclude=.git | cut -f1)"

.PHONY: docs-stats
docs-stats:
	@echo "=== Documentation Statistics ==="
	@echo "Documentation files: $(shell find . -name '*.md' | wc -l)"
	@echo "Protocol files: $(shell find .warp/protocols -name '*.md' 2>/dev/null | wc -l)"
	@echo "Rule files: $(shell find .warp/rules -name '*.md' 2>/dev/null | wc -l)"
	@echo "Total documentation lines: $(shell find . -name '*.md' -exec cat {} \; | wc -l)"
	@echo "README size: $(shell wc -l README.md | cut -d' ' -f1) lines"
	@echo "API docs size: $(shell wc -l docs/API.md 2>/dev/null | cut -d' ' -f1 || echo '0') lines"
	@echo "Testing docs size: $(shell wc -l docs/TESTING.md 2>/dev/null | cut -d' ' -f1 || echo '0') lines"

.PHONY: benchmark-suite
benchmark-suite:
	@echo "Running comprehensive performance benchmarks..."
	@./scripts/benchmark.sh --comprehensive
	@echo "Performance baseline established"
	@echo "Results available in reports/ directory"

# Container targets
.PHONY: container-build
container-build: build
	@echo "Building soft-delete container image..."
	@docker build -f Dockerfile.runtime -t soft-delete:$(VERSION) .
	@docker tag soft-delete:$(VERSION) soft-delete:latest
	@echo "Container built: soft-delete:$(VERSION)"

.PHONY: container-test
container-test: container-build
	@echo "Testing container functionality..."
	@docker run --rm soft-delete:$(VERSION) --version
	@echo "Container test passed"

.PHONY: container-run
container-run: container-build
	@echo "Running soft-delete container (use Ctrl+C to exit)..."
	@docker run --rm -it -v $$(pwd):/workspace soft-delete:$(VERSION)

.PHONY: container-clean
container-clean:
	@echo "Cleaning container images..."
	@docker rmi soft-delete:$(VERSION) soft-delete:latest 2>/dev/null || echo "No images to remove"
	@echo "Container cleanup complete"

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

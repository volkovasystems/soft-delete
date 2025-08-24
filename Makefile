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

# Clean target
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -f bin/$(SCRIPT_NAME)
	@echo "Clean complete."

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
VERSION := $(shell grep 'VERSION=' $(SOURCE_SCRIPT) | cut -d'"' -f2)

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

# Version target
.PHONY: version
version:
	@echo "$(VERSION)"

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all          - Build the project (default)"
	@echo "  build        - Copy source script to bin/ and make executable"
	@echo "  install      - Install $(SCRIPT_NAME) to $(PREFIX)/bin (requires sudo)"
	@echo "  uninstall    - Remove $(SCRIPT_NAME) from $(PREFIX)/bin (requires sudo)"
	@echo "  test         - Run test suite (requires bats)"
	@echo "  lint         - Check bash syntax and run shellcheck"
	@echo "  clean        - Remove build artifacts"
	@echo "  check        - Verify installation"
	@echo "  install-deps - Install development dependencies"
	@echo "  package      - Create distribution archive (version: $(VERSION))"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX       - Installation prefix (default: /usr/local)"
	@echo "  BINDIR       - Binary installation directory (default: \$PREFIX/bin)"
	@echo ""
	@echo "Examples:"
	@echo "  make                    # Build the project"
	@echo "  sudo make install       # Install system-wide"
	@echo "  make install PREFIX=~   # Install to home directory"
	@echo "  make test               # Run tests"
	@echo "  make lint               # Check code quality"

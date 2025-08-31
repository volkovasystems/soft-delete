# VERSION File Protocol for Warp.dev

This protocol establishes the VERSION file as the single source of truth for all version-related contexts in the `soft-delete` project.

## Core Principle

**CRITICAL RULE**: The `/VERSION` file is the **ONLY** authoritative source for version information in the entire repository.

## VERSION File Standards

### File Location and Format
```
/VERSION                    # Root directory only
Content: X.Y.Z             # Single line, semantic version format
Example: 1.2.3             # No 'v' prefix, no whitespace, no comments
```

### File Management Rules
- **ONLY** update via `scripts/version.sh` or deployment scripts
- **NEVER** manually edit the VERSION file
- **NEVER** create additional version files in subdirectories
- **ALWAYS** validate format: `^\d+\.\d+\.\d+$`

## Required Implementation Patterns

### Shell Scripts (REQUIRED)
All shell scripts must read version from the VERSION file:

```bash
# REQUIRED pattern for all shell scripts
if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
    VERSION_FILE="$SCRIPT_DIR/VERSION"
elif [[ -f "$(dirname "$SCRIPT_DIR")/VERSION" ]]; then
    VERSION_FILE="$(dirname "$SCRIPT_DIR")/VERSION"
else
    VERSION_FILE=""
fi

if [[ -f "$VERSION_FILE" ]]; then
    VERSION=$(cat "$VERSION_FILE" | tr -d '\n\r' | tr -d ' ')
else
    VERSION="1.0.0"  # Fallback only if VERSION file missing
fi
readonly VERSION
```

### Makefile Integration (REQUIRED)
```makefile
# REQUIRED pattern for Makefiles
VERSION := $(shell cat VERSION 2>/dev/null || echo "1.0.0")

# Use $(VERSION) throughout Makefile
version-info:
	@echo "Current version: $(VERSION)"
```

### Ruby Formula (REQUIRED)
```ruby
# Homebrew formula pattern
class SoftDelete < Formula
  # Version managed in /VERSION file - updated by deployment scripts
  url "https://github.com/volkovasystems/soft-delete/archive/refs/tags/v#{version}.tar.gz"
  # Use #{version} instead of hardcoded versions
end
```

### Documentation (REQUIRED)
```markdown
# REQUIRED patterns for documentation

# ✅ CORRECT - Reference VERSION file
Current version is maintained in the `/VERSION` file.

# ✅ CORRECT - Dynamic reference
Version: See `/VERSION` file

# ❌ PROHIBITED - Hardcoded version
Current version: 1.2.3
Version 1.2.3 introduces...
```

## File-Specific Requirements

### Source Code Files

#### soft-delete.sh ✅ (Already Compliant)
- ✅ Reads from VERSION file with fallback
- ✅ Uses proper file location detection
- ✅ Handles missing VERSION file gracefully
- ✅ Uses readonly VERSION variable

#### Other Shell Scripts (MUST IMPLEMENT)
All shell scripts in `scripts/` directory must:
1. Read version from /VERSION file using the required pattern
2. Use readonly VERSION variable
3. Provide 1.0.0 fallback only if VERSION file missing
4. Never hardcode version numbers

### Build and Configuration Files

#### Makefile ✅ (Already Compliant)
- ✅ Reads VERSION from file: `VERSION := $(shell cat VERSION)`
- ✅ Uses $(VERSION) variable throughout
- ✅ Provides fallback: `2>/dev/null || echo "1.0.0"`

#### Formula/soft-delete.rb ✅ (Now Compliant)
- ✅ Uses dynamic version reference: `#{version}`
- ✅ Includes comment about VERSION file management
- ✅ No hardcoded version strings

#### GitHub Actions (SHOULD IMPLEMENT)
```yaml
# Read version from VERSION file
- name: Get version
  run: echo "VERSION=$(cat VERSION)" >> $GITHUB_ENV
  
# Use ${{ env.VERSION }} instead of hardcoded versions
```

### Documentation Files

#### README.md (MUST UPDATE)
- Replace hardcoded version references with VERSION file references
- Use dynamic examples: `$(cat VERSION)` instead of specific versions
- Add note about VERSION file being source of truth

#### CHANGELOG.md (EXCEPTION - Can Reference Specific Versions)
- Changelog entries may reference specific historical versions
- But avoid "current version" statements
- Prefer "See VERSION file" for current version references

#### API Documentation (MUST UPDATE)
- Remove hardcoded version numbers from examples
- Reference VERSION file location
- Use placeholder patterns: `X.Y.Z` instead of specific versions

## Prohibited Practices

### ❌ NEVER Do These Things

#### Hardcoded Version Numbers
```bash
# PROHIBITED
VERSION="1.2.3"
echo "Version 1.2.3"
git tag v1.2.3
```

#### Multiple Version Sources
```bash
# PROHIBITED
VERSION_MAJOR=1
VERSION_MINOR=2  
VERSION_PATCH=3
```

#### Manual VERSION File Edits
```bash
# PROHIBITED
echo "1.2.3" > VERSION
```

#### Version in Source Code Comments
```bash
# PROHIBITED
# Version: 1.2.3
# @version 1.2.3
```

## Compliance Verification

### Required Checks
Before any commit involving version references:

```bash
# 1. Verify VERSION file exists and is properly formatted
if [[ -f VERSION ]] && [[ $(cat VERSION) =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "✅ VERSION file format valid"
else
    echo "❌ VERSION file missing or invalid format"
    exit 1
fi

# 2. Search for hardcoded versions (should return empty)
git grep -n '[0-9]\+\.[0-9]\+\.[0-9]\+' -- '*.sh' '*.rb' '*.yml' '*.md' | \
    grep -v VERSION | grep -v CHANGELOG.md | grep -v docs/

# 3. Verify shell scripts read from VERSION file
git grep -l 'VERSION.*cat.*VERSION' -- '*.sh'
```

### Automated Compliance
```bash
# Add to pre-commit hooks or CI/CD
./scripts/check-version-compliance.sh
```

## Version Update Workflow

### Proper Version Update Process
```bash
# 1. Use version script (ONLY acceptable method)
./scripts/version.sh patch|minor|major

# 2. Verify all files reflect new version
make version-check  # If implemented

# 3. Commit version change
git add VERSION
git commit -m "chore: bump version to $(cat VERSION)"

# 4. Use deployment system for tagging
./scripts/deploy.sh deploy-release
```

### Emergency Version Fix
```bash
# If VERSION file becomes corrupted
./scripts/version.sh set 1.2.3  # Only if script supports it
# OR restore from git history
git checkout HEAD~1 -- VERSION
```

## Integration Points

### With Git Management Protocol
- All version-related commits must reference VERSION file
- Commit messages should read from VERSION file: `$(cat VERSION)`
- Tags should be created by deployment scripts, not manually

### With Deployment System
- Deployment scripts must validate VERSION file before deployment
- All deployment artifacts must read version from VERSION file
- Release creation must use VERSION file content

### With Testing Protocol
- Tests should verify version consistency across repository
- Test scripts should read from VERSION file when needed
- Version-related test assertions should be dynamic

## Error Handling

### Missing VERSION File
```bash
# Acceptable fallback pattern
VERSION=$(cat VERSION 2>/dev/null || echo "1.0.0")

# Log warning but continue
if [[ ! -f VERSION ]]; then
    log_verbose "WARNING: VERSION file missing, using fallback"
fi
```

### Invalid VERSION Format
```bash
# Validation pattern
if [[ ! $(cat VERSION 2>/dev/null) =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_error "Invalid VERSION file format"
    exit 1
fi
```

### Inconsistent Versions
```bash
# Check for hardcoded versions in repository
make check-version-consistency  # If implemented
```

## Compliance Status

### Current Repository Status
- ✅ **soft-delete.sh**: Fully compliant
- ✅ **Makefile**: Fully compliant  
- ✅ **Formula/soft-delete.rb**: Updated to be compliant
- ⚠️ **Documentation files**: Need review and updates
- ⚠️ **Other scripts**: Need verification and updates

### Next Steps
1. Audit all remaining files for hardcoded versions
2. Update documentation to reference VERSION file
3. Implement version compliance checking
4. Add automated verification to CI/CD

This protocol ensures complete consistency and eliminates version drift across the entire repository.

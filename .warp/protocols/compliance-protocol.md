# 100% Compliance Protocol for Warp.dev

**CRITICAL**: This protocol MUST be followed for every prompt and operation performed on this repository. NO EXCEPTIONS.

This protocol establishes mandatory 100% compliance standards for all repository changes, ensuring strict adherence to quality, consistency, and professional development practices.

## Core Principle

**ZERO TOLERANCE RULE**: Every change must achieve 100% compliance across all applicable standards before being accepted. No exceptions, no compromises, no "acceptable" partial compliance.

## 🔴 PRE-OPERATION UNIVERSAL CHECKLIST

### System Status Checks (MANDATORY)
- [ ] **Working Directory Clean**: `git status --porcelain` returns empty
- [ ] **Correct Branch**: Currently on `develop` branch
- [ ] **Version File Exists**: `VERSION` file is present and valid
- [ ] **No Uncommitted Changes**: All previous work properly committed

```bash
# Quick pre-operation validation
git status --porcelain | wc -l  # MUST be 0
git branch --show-current       # MUST be "develop"
cat VERSION                     # MUST return valid semver
```

### 🟡 OPERATION-SPECIFIC PROTOCOL REQUIREMENTS

#### A. Version Control Operations (AI Version Control Protocol)

**FORBIDDEN OPERATIONS** - AI SHALL NEVER:
- [ ] ❌ **NEVER modify VERSION file**
- [ ] ❌ **NEVER create new version sections in changelog**
- [ ] ❌ **NEVER update version badges in README**
- [ ] ❌ **NEVER create git tags**
- [ ] ❌ **NEVER increment semantic versions**

**REQUIRED CHECKS**:
- [ ] ✅ **Version references use VERSION file**: `VERSION=$(cat VERSION)`
- [ ] ✅ **No hardcoded versions in code changes**
- [ ] ✅ **Version consistency maintained across files**

#### B. Changelog Operations (Changelog Protocol)

**REQUIRED ACTIONS**:
- [ ] ✅ **Add entries to CURRENT version only** (from VERSION file)
- [ ] ✅ **NO [Unreleased] sections created or used**
- [ ] ✅ **Follow Keep a Changelog format**
- [ ] ✅ **Use proper categories**: Added, Changed, Fixed, Security
- [ ] ✅ **Group related items with subheadings (####)**

**FORBIDDEN ACTIONS**:
- [ ] ❌ **NEVER create [Unreleased] section**
- [ ] ❌ **NEVER create new version sections**
- [ ] ❌ **NEVER modify version dates**

```bash
# Changelog validation
./scripts/changelog.sh validate  # MUST pass
grep -q "\[Unreleased\]" CHANGELOG.md && exit 1  # MUST NOT exist
```

#### C. File System Operations (Structural Alignment Protocol)

**REQUIRED VALIDATIONS**:
- [ ] ✅ **All file paths in documentation exist**
- [ ] ✅ **Internal links are valid and functional**
- [ ] ✅ **Cross-references updated when files change**
- [ ] ✅ **Directory structure documentation matches reality**
- [ ] ✅ **Examples use correct file paths**

**CROSS-FILE UPDATES REQUIRED**:
- [ ] ✅ **README.md updated** if functionality changes
- [ ] ✅ **API docs updated** if interfaces change
- [ ] ✅ **project-context.md updated** if architecture changes
- [ ] ✅ **Help text updated** if commands change

#### D. Gitignore Management Protocol (CRITICAL)

**ABSOLUTE RULE**: Never modify the reverse-ignore logic in .gitignore

**REQUIRED ACTIONS**:
- [ ] ✅ **NEVER change the core gitignore logic**: The `*` and `!*/` patterns must remain unchanged
- [ ] ✅ **Add new file extensions**: For new file types, add `!*.extension` patterns only
- [ ] ✅ **Add new directories**: For new critical directories, add `!dirname/` and `!dirname/**` patterns
- [ ] ✅ **Check ignored files**: Run `git status --ignored` to identify missing critical files
- [ ] ✅ **Force add critical files**: Use `git add -f filename` for essential files that were ignored

**FORBIDDEN OPERATIONS**:
- [ ] ❌ **NEVER modify the base ignore pattern**: `*` must remain the first line
- [ ] ❌ **NEVER remove directory inclusion**: `!*/` pattern must never be changed
- [ ] ❌ **NEVER change file type patterns**: Only add new ones, never modify existing
- [ ] ❌ **NEVER ignore critical workflow files**: .githooks/, scripts/, tests/, docs/ must be included

**VALIDATION COMMANDS**:
```bash
# Check for ignored critical files
git status --ignored | grep -E "\.(sh|md|bats|yml|yaml)$" && echo "❌ Critical files ignored" || echo "✅ No critical files ignored"

# Verify essential directories are tracked
find .githooks/ .warp/ scripts/ tests/ -name "*" -type f | while read file; do
    git ls-files --error-unmatch "$file" >/dev/null 2>&1 || echo "❌ Missing: $file"
done
```

## Compliance Domains

### 1. Code Quality Compliance

#### Shell Script Standards (MANDATORY 100%)
**ShellCheck Compliance:**
```bash
# REQUIRED: Zero warnings allowed
make docker-lint
# Must return: "All scripts passed ShellCheck validation"
# Exit code must be 0

# Verify specific compliance
shellcheck --version
shellcheck -f gcc soft-delete.sh  # Must show no issues
```

**Bash Strict Mode (MANDATORY):**
```bash
# REQUIRED in all bash scripts
set -euo pipefail

# Verification check
grep -q "set -euo pipefail" soft-delete.sh || exit 1
```

**Variable Quoting (MANDATORY 100%):**
```bash
# PROHIBITED: Unquoted variables
echo $VARIABLE        # ❌ FAILS COMPLIANCE

# REQUIRED: All variables quoted
echo "$VARIABLE"      # ✅ COMPLIANT
```

**Function Standards (MANDATORY):**
```bash
# REQUIRED patterns
function_name() {
    local var="$1"          # All parameters must be local
    readonly local_var      # Constants must be readonly
    [[ -n "$var" ]] || return 1  # Parameter validation required
}
```

#### Code Structure Compliance (MANDATORY)
- **Indentation**: Exactly 4 spaces, no tabs
- **Line endings**: LF only (Unix style)
- **File encoding**: UTF-8 without BOM
- **Trailing whitespace**: Prohibited
- **Final newline**: Required

### 2. Testing Compliance (MANDATORY 100%)

#### Test Coverage (NO EXCEPTIONS)
```bash
# REQUIRED: All tests must pass
make docker-test
# Must show: "All tests passed (X/X)"
# Exit code must be 0

# PROHIBITED: Skipping tests
# PROHIBITED: Commenting out failing tests
# PROHIBITED: "TODO: fix later" in tests
```

**Test Requirements:**
- **100% pass rate**: No failing tests allowed
- **TAP compliance**: All output must be TAP version 14 compliant
- **Edge case coverage**: Every feature must have edge case tests
- **Error path testing**: All error conditions must be tested

#### Test Quality Standards
```bash
# REQUIRED test structure
@test "should [expected behavior] when [specific condition]" {
    # Setup
    local test_file="test_$(date +%s).txt"

    # Execute
    run ./bin/soft-delete "$test_file"

    # Verify (ALL assertions required)
    [ "$status" -eq 0 ]                    # Exit code
    [[ "$output" =~ "Moved to backup" ]]   # Output content
    [ ! -f "$test_file" ]                  # File state
    # Cleanup verification required
}
```

### 3. Documentation Compliance (MANDATORY 100%)

#### Format Standards (STRICT ADHERENCE)
**Markdown Compliance:**
- **Headers**: Proper hierarchy (no skipped levels)
- **Links**: All links must be functional and tested
- **Code blocks**: All must have proper language tags
- **Lists**: Consistent formatting throughout
- **Tables**: Properly formatted with aligned columns

**Content Standards:**
```bash
# REQUIRED: All examples must be tested and functional
# Example verification
grep -o '`[^`]*`' README.md | while read cmd; do
    cmd=$(echo "$cmd" | tr -d '`')
    # Verify command exists and works
done
```

#### Cross-Reference Compliance (MANDATORY)
```bash
# REQUIRED: All references must be valid
# Check internal links
grep -r '\[.*\](.*\.md)' docs/ .warp/ | while read ref; do
    # Verify referenced file exists
    file=$(echo "$ref" | sed 's/.*(\([^)]*\)).*/\1/')
    [[ -f "$file" ]] || { echo "❌ Broken reference: $ref"; exit 1; }
done
```

### 4. Version Control Compliance (MANDATORY 100%)

#### Commit Message Standards (STRICT FORMAT)
**Required Format:**
```
type(scope): description

- Detailed explanation point 1
- Detailed explanation point 2
- Impact and rationale
- Cross-file updates included
```

**Commit Types (ONLY THESE ALLOWED):**
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation updates
- `test:` - Testing changes
- `refactor:` - Code restructuring
- `perf:` - Performance improvements
- `style:` - Code formatting
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes
- `revert:` - Reverting changes
- `checkpoint:` - Development milestones

**Prohibited Commit Patterns:**
```bash
# ❌ COMPLIANCE FAILURES - NEVER ALLOWED
git commit -m "fix"                    # Too vague
git commit -m "WIP: working on stuff"  # WIP prohibited
git commit -m "temp commit"            # Temporary commits prohibited
git commit -m "stuff"                  # Non-descriptive
```

#### Branch Compliance (MANDATORY)
```bash
# REQUIRED: Work on develop branch only
git branch --show-current | grep -q "develop" || exit 1

# PROHIBITED: Direct commits to main
git log main..HEAD --oneline | wc -l  # Must be 0
```

### 5. File System Compliance (MANDATORY 100%)

#### File Naming Standards (STRICT)
**Allowed Patterns:**
- `lowercase-with-hyphens.extension`
- `snake_case_for_scripts.sh`
- `UPPERCASE_FOR_CONSTANTS`
- `CamelCase.md` (for special documentation)

**Prohibited Patterns:**
- `Mixed-Case_inconsistent.file`
- `spaces in filename.txt`
- `file..double.extension`
- `trailing-dot.`

#### File Permission Compliance
```bash
# REQUIRED permissions
# Scripts: 755 (executable)
find scripts/ -name "*.sh" -not -perm 755 | wc -l  # Must be 0

# Documentation: 644 (read/write)
find docs/ -name "*.md" -not -perm 644 | wc -l     # Must be 0

# Configuration: 644
find . -name "Makefile" -not -perm 644 | wc -l     # Must be 0
```

#### Generated File Management (MANDATORY)
**Prohibited: Tracking generated files**
```bash
# REQUIRED: Generated files must not be tracked in git
# Reports, logs, and temporary files must be gitignored

# Check for tracked generated files (ZERO TOLERANCE)
find . -name "*.tap" -o -name "*.log" | while read file; do
    git ls-files --error-unmatch "$file" && exit 1
done

# Reports directory files must not be tracked
find reports/ -name "*.txt" -o -name "*.tap" | while read file; do
    git ls-files --error-unmatch "$file" && exit 1
done
```

**Required .gitignore patterns:**
```gitignore
# Generated reports (exclude from version control)
reports/*.tap
reports/*.txt
reports/**/*.tap
reports/**/*.txt

# Temporary and log files
*.log
*.tmp
```

### 6. Security Compliance (MANDATORY 100%)

#### Sensitive Data Protection (ZERO TOLERANCE)
```bash
# REQUIRED: No sensitive data in repository
git log --all --grep="password\|secret\|key\|token" | wc -l  # Must be 0

# REQUIRED: No hardcoded credentials
grep -r -i "password\|secret\|key.*=" . --exclude-dir=.git | wc -l  # Must be 0

# REQUIRED: No TODO with security implications
grep -r "TODO.*security\|FIXME.*security" . | wc -l  # Must be 0
```

#### Path Safety Compliance
```bash
# REQUIRED: No path traversal vulnerabilities
grep -r "\.\./\|\.\.\\\\" . --exclude-dir=.git | wc -l  # Must be 0

# REQUIRED: Proper input validation
grep -r "cd.*\$" . --include="*.sh" | wc -l  # Review required
```

## Compliance Verification Workflow

### Pre-Change Compliance Check
```bash
#!/bin/bash
# scripts/compliance-check.sh

echo "🔍 Running 100% Compliance Verification..."

# 1. Code Quality Compliance
echo "📋 Checking code quality compliance..."
make docker-lint || { echo "❌ ShellCheck compliance failed"; exit 1; }
echo "✅ Code quality: 100% compliant"

# 2. Testing Compliance
echo "🧪 Checking testing compliance..."
make docker-test || { echo "❌ Test compliance failed"; exit 1; }
echo "✅ Testing: 100% compliant"

# 3. Documentation Compliance
echo "📚 Checking documentation compliance..."
# Check for broken links
find docs/ .warp/ -name "*.md" -exec grep -l '\[.*\]([^)]*\.md[^)]*)' {} \; | while read file; do
    grep -o '\[.*\]([^)]*\.md[^)]*)' "$file" | while read link; do
        target=$(echo "$link" | sed -n 's/.*](\([^)#]*\)).*/\1/p')
        [[ -f "$target" ]] || { echo "❌ Broken link in $file: $target"; exit 1; }
    done
done
echo "✅ Documentation: 100% compliant"

# 4. Version Control Compliance
echo "🔧 Checking version control compliance..."
git status --porcelain | wc -l | grep -q "^0$" || { echo "❌ Uncommitted changes"; exit 1; }
echo "✅ Version control: 100% compliant"

# 5. File System Compliance
echo "📁 Checking file system compliance..."
# Check file permissions
find scripts/ -name "*.sh" -not -perm 755 | wc -l | grep -q "^0$" || { echo "❌ Script permissions"; exit 1; }
echo "✅ File system: 100% compliant"

# 6. Security Compliance
echo "🔒 Checking security compliance..."
git log --all --oneline | grep -i "password\|secret\|key" | wc -l | grep -q "^0$" || { echo "❌ Security compliance"; exit 1; }
echo "✅ Security: 100% compliant"

echo "🎉 ALL COMPLIANCE CHECKS PASSED - 100% COMPLIANT"
```

### Mandatory Pre-Commit Workflow
```bash
# REQUIRED before every commit
1. Run compliance check:
   ./scripts/compliance-check.sh

2. Verify cross-file consistency:
   # Following consistency-protocol.md

3. Run full test suite:
   make docker-test

4. Verify build integrity:
   make build && make check

5. Check working directory:
   git status --porcelain | wc -l  # Must be 0 after staging
```

## Compliance Standards Matrix

### Code Quality Standards (100% Required)

| Standard | Requirement | Verification | Tolerance |
|----------|-------------|--------------|-----------|
| ShellCheck | Zero warnings | `make docker-lint` | 0% |
| Strict Mode | All scripts | `grep -r "set -euo pipefail"` | 0% |
| Quoting | All variables | Manual review + tests | 0% |
| Indentation | 4 spaces exact | EditorConfig + linting | 0% |
| Line Endings | LF only | `.gitattributes` enforcement | 0% |

### Testing Standards (100% Required)

| Standard | Requirement | Verification | Tolerance |
|----------|-------------|--------------|-----------|
| Pass Rate | 100% pass | `make docker-test` | 0% |
| TAP Format | Version 14 compliant | Output validation | 0% |
| Coverage | All features tested | Manual review | 0% |
| Edge Cases | All paths covered | Test analysis | 0% |

### Documentation Standards (100% Required)

| Standard | Requirement | Verification | Tolerance |
|----------|-------------|--------------|-----------|
| Links | All functional | Automated checking | 0% |
| Examples | All tested | Command verification | 0% |
| Format | Consistent markdown | Linting + review | 0% |
| Cross-refs | All valid | Reference validation | 0% |

## Compliance Enforcement

### Automated Gates
```bash
# Git hooks enforcement
# .git/hooks/pre-commit
#!/bin/bash
./scripts/compliance-check.sh || exit 1
echo "✅ Compliance verified - commit allowed"
```

### CI/CD Integration
```yaml
# GitHub Actions compliance gate
- name: 100% Compliance Check
  run: |
    ./scripts/compliance-check.sh
    if [ $? -ne 0 ]; then
      echo "❌ Compliance failure - build terminated"
      exit 1
    fi
```

### Manual Review Checklist
Before any change acceptance:

- [ ] **Code Quality**: 100% ShellCheck compliance verified
- [ ] **Testing**: 100% test pass rate confirmed
- [ ] **Documentation**: All examples tested and functional
- [ ] **Version Control**: Commit messages follow strict format
- [ ] **File System**: Proper permissions and naming verified
- [ ] **Security**: No sensitive data or vulnerabilities
- [ ] **Consistency**: All related files updated together
- [ ] **Standards**: All domain-specific standards met

## Compliance Reporting

### Daily Compliance Report
```bash
#!/bin/bash
# scripts/compliance-report.sh

echo "📊 DAILY COMPLIANCE REPORT - $(date)"
echo "=================================="

# Code Quality Score
echo "📋 Code Quality:"
make docker-lint > /dev/null 2>&1 && echo "  ✅ ShellCheck: 100%" || echo "  ❌ ShellCheck: FAILED"

# Testing Score
echo "🧪 Testing:"
make docker-test > /dev/null 2>&1 && echo "  ✅ Tests: 100%" || echo "  ❌ Tests: FAILED"

# Documentation Score
echo "📚 Documentation:"
./scripts/check-doc-compliance.sh > /dev/null 2>&1 && echo "  ✅ Docs: 100%" || echo "  ❌ Docs: FAILED"

# Overall Compliance
echo "🎯 OVERALL COMPLIANCE: Requires 100% in all domains"
```

## Non-Compliance Response Protocol

### When Compliance Fails

#### 1. Immediate Action (MANDATORY)
```bash
# Stop all work immediately
git stash  # Preserve changes
echo "❌ COMPLIANCE FAILURE - All development halted"

# Identify specific failure
./scripts/compliance-check.sh 2>&1 | grep "❌"

# Fix compliance issues FIRST before continuing
```

#### 2. Root Cause Analysis (REQUIRED)
- Identify why compliance check failed
- Document the specific standard violated
- Determine if process improvement needed
- Update protocols if gap identified

#### 3. Remediation (MANDATORY 100%)
```bash
# Fix all compliance issues
# Re-run compliance check
./scripts/compliance-check.sh

# Verify 100% compliance before proceeding
[ $? -eq 0 ] || { echo "Still not compliant"; exit 1; }

# Resume development only after 100% compliance achieved
```

## Integration with Existing Protocols

### With Continuous Commit Protocol
- **Every commit** must pass compliance check
- **No exceptions** for "quick fixes" or "temporary commits"
- **Compliance verification** required before git add

### With Consistency Protocol
- **Cross-file updates** must maintain compliance
- **Related files** must all meet compliance standards
- **Consistency checks** included in compliance verification

### With Testing Protocol
- **Test compliance** integrated into overall compliance
- **TAP format** compliance mandatory
- **Coverage standards** part of compliance matrix

## Agent Behavior Rules

### For Warp.dev Agents (MANDATORY)

1. **Run compliance check** before making any changes
2. **Achieve 100% compliance** before suggesting changes
3. **Never compromise standards** for convenience or speed
4. **Always use compliant patterns** in code suggestions
5. **Verify compliance** before completing any task
6. **Report non-compliance** immediately when detected

### Prohibited Agent Behaviors

❌ **Never suggest "quick fixes"** that skip compliance
❌ **Never accept partial compliance** as "good enough"
❌ **Never defer compliance** for "later improvement"
❌ **Never suggest lowering standards** for any reason

## Success Metrics

### Compliance KPIs (All Must Be 100%)

- **ShellCheck Compliance**: 100% clean (0 warnings)
- **Test Pass Rate**: 100% (all tests passing)
- **Documentation Accuracy**: 100% (all examples functional)
- **Commit Format**: 100% (all commits follow standards)
- **Security Score**: 100% (no vulnerabilities)
- **Consistency Score**: 100% (all cross-references valid)

### Monitoring Dashboard
```bash
# Weekly compliance review
echo "COMPLIANCE SCORECARD"
echo "==================="
echo "ShellCheck: $(make docker-lint > /dev/null 2>&1 && echo "100%" || echo "FAILED")"
echo "Tests: $(make docker-test > /dev/null 2>&1 && echo "100%" || echo "FAILED")"
echo "Security: $(./scripts/security-check.sh > /dev/null 2>&1 && echo "100%" || echo "FAILED")"
echo "Overall: PASS only if all domains are 100%"
```

## 🟢 QUALITY ASSURANCE CHECKS

### A. Code Quality (100% Compliance Protocol)

**MANDATORY VALIDATIONS**:
- [ ] ✅ **ShellCheck 100% clean**: `make docker-lint` passes
- [ ] ✅ **All tests pass**: `make docker-test` shows 100% success
- [ ] ✅ **No syntax errors**: All scripts execute without errors
- [ ] ✅ **Proper file permissions**: Scripts 755, docs 644

```bash
# Quality validation commands
make docker-lint    # MUST pass with zero warnings
make docker-test    # MUST show 100% pass rate
find scripts/ -name "*.sh" -not -perm 755 | wc -l  # MUST be 0
```

### B. Testing Requirements (Testing Protocol)

**REQUIRED ACTIONS**:
- [ ] ✅ **Run full test suite before changes**: `make docker-test`
- [ ] ✅ **All tests pass after changes**: 100% success rate
- [ ] ✅ **Add tests for new functionality**
- [ ] ✅ **Update existing tests if behavior changes**
- [ ] ✅ **Verify TAP format compliance**

### C. Documentation Consistency (Consistency Protocol)

**CROSS-REFERENCE VALIDATIONS**:
- [ ] ✅ **Related files identified and updated**
- [ ] ✅ **Examples remain consistent across docs**
- [ ] ✅ **Command formats standardized**
- [ ] ✅ **Installation instructions aligned**
- [ ] ✅ **Version references synchronized**

## 🔵 COMMIT AND COMPLETION PROTOCOLS

### A. Continuous Commit Requirements

**MANDATORY COMMIT WORKFLOW**:
- [ ] ✅ **Stage all changes**: `git add .`
- [ ] ✅ **Commit with conventional format**:
  ```bash
  git commit -m "type: description

  - Detailed explanation of changes
  - Each major change on separate line
  - Impact and rationale included"
  ```
- [ ] ✅ **Update changelog**: Add entry to current version section
- [ ] ✅ **Commit changelog separately**:
  ```bash
  git add CHANGELOG.md
  git commit -m "docs: update changelog for [work description]"
  ```

**COMMIT MESSAGE VALIDATION**:
- [ ] ✅ **Uses conventional commit type**: feat, fix, docs, test, chore, etc.
- [ ] ✅ **Has clear, descriptive subject line**
- [ ] ✅ **Includes detailed body with bullet points**
- [ ] ✅ **References any related issues or protocols**

### B. Response Completeness Protocol

**END-OF-RESPONSE REQUIREMENTS**:
- [ ] ✅ **All changes committed**: Working directory clean
- [ ] ✅ **Changelog updated**: Entry added to current version
- [ ] ✅ **No uncommitted files**: `git status --porcelain` empty
- [ ] ✅ **All protocols followed**: Compliance verified

```bash
# Final verification commands
git status --porcelain | wc -l     # MUST be 0
git log --oneline -2 | grep -E "(feat|fix|docs|test|chore):"  # MUST match
```

## 🟣 SECURITY AND COMPLIANCE VALIDATION

### Security Protocol Checks
- [ ] ✅ **No sensitive data in commits**
- [ ] ✅ **No hardcoded credentials**
- [ ] ✅ **No path traversal vulnerabilities**
- [ ] ✅ **Proper input validation**
- [ ] ✅ **File permissions secure**

### Git Management Protocol
- [ ] ✅ **Working on develop branch**
- [ ] ✅ **Never commit to main directly**
- [ ] ✅ **Atomic commits with single logical change**
- [ ] ✅ **Pre-commit quality gates passed**

## 📋 FINAL VALIDATION CHECKLIST

### Automated Validation Commands
Run these commands to verify full compliance:

```bash
# 1. COMPREHENSIVE COMPLIANCE CHECK (PRIMARY VALIDATION)
./scripts/compliance-check.sh || exit 1

# 2. SECURITY VULNERABILITY SCANNING
./scripts/security-scan.sh --quiet || exit 1

# 3. STRUCTURAL SYNCHRONIZATION (Updates and validates structure)
./scripts/sync-structure.sh >/dev/null 2>&1 || { echo "❌ Structural sync failed"; exit 1; }

# 4. CHANGELOG PROTOCOL COMPLIANCE
./scripts/changelog.sh validate || exit 1

# 5. VERSION CONSISTENCY VALIDATION
# Check VERSION file format and consistency
VERSION_CONTENT=$(cat VERSION | tr -d '\n\r' | tr -d ' ')
[[ "$VERSION_CONTENT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "❌ Invalid VERSION format: $VERSION_CONTENT"; exit 1; }
echo "✅ VERSION file format valid: $VERSION_CONTENT"

# 6. CROSS-FILE CONSISTENCY CHECKS
# Verify essential directories are properly tracked
for dir in .githooks .warp scripts tests; do
    if [[ -d "$dir" ]]; then
        find "$dir" -name "*" -type f | while read file; do
            if ! git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
                echo "❌ Missing tracked file: $file"
                exit 1
            fi
        done
    fi
done
echo "✅ All essential directories properly tracked"

# 7. GITIGNORE VALIDATION (Critical files check)
if git status --ignored | grep -E "\.(sh|md|bats|yml|yaml)$" >/dev/null; then
    echo "❌ Critical files are being ignored:"
    git status --ignored | grep -E "\.(sh|md|bats|yml|yaml)$"
    exit 1
fi
echo "✅ No critical files ignored"

# 8. WORKING DIRECTORY STATUS
if [[ -n "$(git status --porcelain)" ]]; then
    echo "❌ Uncommitted changes detected:"
    git status --short
    exit 1
fi
echo "✅ Working directory clean"

# 9. RECENT COMMITS FORMAT VALIDATION
if ! git log --format="%s" -3 | grep -qE "^(feat|fix|docs|test|chore|checkpoint):"; then
    echo "❌ Recent commits don't follow conventional format:"
    git log --format="%s" -3
    exit 1
fi
echo "✅ Recent commits follow conventional format"

# 10. FILE PERMISSIONS VALIDATION
if find scripts/ -name "*.sh" -not -perm 755 2>/dev/null | grep -q .; then
    echo "❌ Script permission errors found:"
    find scripts/ -name "*.sh" -not -perm 755 2>/dev/null
    exit 1
fi
if find docs/ .warp/ -name "*.md" -not -perm 644 2>/dev/null | grep -q .; then
    echo "❌ Documentation permission errors found:"
    find docs/ .warp/ -name "*.md" -not -perm 644 2>/dev/null
    exit 1
fi
echo "✅ All file permissions correct"

# 11. AUTO-CLEANUP COMPLIANCE VALIDATION (MANDATORY)
echo "🧹 Auto-cleanup compliance validation..."

# Check for dangling test files
if find reports/ -name "*.tap" -o -name "*.txt" -o -name "*.xml" 2>/dev/null | grep -q .; then
    echo "❌ Dangling test artifacts found - running cleanup"
    find reports/ -name "*.tap" -o -name "*.txt" -o -name "*.xml" -delete 2>/dev/null || true
fi

# Check for temporary files
if find . -name "*.tmp" -o -name "*.temp" -o -name "*~" 2>/dev/null | grep -q .; then
    echo "❌ Temporary files found - running cleanup"
    find . -name "*.tmp" -o -name "*.temp" -o -name "*~" -delete 2>/dev/null || true
fi

# Check for system files
if find . -name ".DS_Store" -o -name "Thumbs.db" 2>/dev/null | grep -q .; then
    echo "❌ System files found - running cleanup"
    find . -name ".DS_Store" -o -name "Thumbs.db" -delete 2>/dev/null || true
fi

# Verify no unexpected untracked files remain
UNTRACKED_FILES=$(git ls-files --others --exclude-standard)
if [[ -n "$UNTRACKED_FILES" ]]; then
    # Allow specific patterns (.deploy/, reports/) but warn about others
    UNEXPECTED_UNTRACKED=$(echo "$UNTRACKED_FILES" | grep -v -E '^\.deploy/|^reports/' | head -5)
    if [[ -n "$UNEXPECTED_UNTRACKED" ]]; then
        echo "⚠️  Unexpected untracked files detected:"
        echo "$UNEXPECTED_UNTRACKED"
        # Don't fail for this, just warn
    fi
fi

# Clean old backup directories from /tmp
find /tmp -name "backup-*" -type d -mtime +0 -exec rm -rf {} + 2>/dev/null || true

echo "✅ Auto-cleanup compliance validated"

echo ""
echo "🎉 ALL AUTOMATED VALIDATIONS PASSED - 100% COMPLIANT"
```

### Manual Verification Points
- [ ] ✅ **Task completely finished**: No "TODO" or "FIXME" comments added
- [ ] ✅ **All requested functionality implemented**: Nothing left incomplete
- [ ] ✅ **Error conditions handled**: Edge cases considered
- [ ] ✅ **Documentation accurate**: Examples work as written
- [ ] ✅ **Tests comprehensive**: New functionality covered

## 🚨 PROTOCOL VIOLATION HANDLING

### If Any Check Fails:
1. **STOP ALL OPERATIONS IMMEDIATELY**
2. **Identify specific violation**
3. **Fix compliance issue first**
4. **Re-run full checklist**
5. **Only proceed when 100% compliant**

### Common Violations and Fixes:
- **Uncommitted changes**: `git add . && git commit -m "fix: commit outstanding changes"`
- **Version file modified**: `git checkout HEAD -- VERSION`
- **[Unreleased] section created**: Remove section, add to current version
- **Tests failing**: Fix code until `make docker-test` passes 100%
- **ShellCheck warnings**: Fix all warnings until `make docker-lint` passes

## ✅ SUCCESS VERIFICATION

### Final Confirmation (MANDATORY)
Before completing any response, verify:

```bash
echo "🔍 UNIVERSAL COMPLIANCE VERIFICATION"
echo "=================================="

# Clean working directory
echo -n "Working directory clean: "
[[ -z "$(git status --porcelain)" ]] && echo "✅ PASS" || echo "❌ FAIL"

# Tests passing
echo -n "All tests pass: "
make docker-test > /dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"

# Lint compliance
echo -n "ShellCheck clean: "
make docker-lint > /dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"

# Changelog compliance
echo -n "Changelog compliant: "
./scripts/changelog.sh validate > /dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"

# Security compliance
echo -n "Security scan: "
./scripts/security-scan.sh --quiet > /dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"

# Version format validation
echo -n "VERSION file valid: "
VERSION_CONTENT=$(cat VERSION | tr -d '\n\r' | tr -d ' ')
[[ "$VERSION_CONTENT" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] && echo "✅ PASS" || echo "❌ FAIL"

# Critical files tracked
echo -n "Critical files tracked: "
git status --ignored | grep -E "\.(sh|md|bats|yml|yaml)$" >/dev/null && echo "❌ FAIL" || echo "✅ PASS"

echo ""
echo "🎯 OVERALL COMPLIANCE: ALL CHECKS MUST PASS"
```

## 📊 COMPLIANCE METRICS

### Target Standards (100% Required)
- **Code Quality**: 100% ShellCheck compliance
- **Test Success**: 100% pass rate
- **Documentation**: 100% link validity
- **Protocol Adherence**: 100% compliance
- **Security**: 0 vulnerabilities
- **Version Control**: 100% proper commit format

### Monitoring Frequency
- **Pre-operation**: Every single prompt
- **Post-operation**: Every response completion
- **Daily**: Automated compliance reports
- **Weekly**: Comprehensive protocol audit

---

**ENFORCEMENT LEVEL**: ABSOLUTE AND IMMEDIATE
**EFFECTIVE DATE**: 2025-09-01
**PROTOCOL VERSION**: 1.0.0
**SCOPE**: ALL AI OPERATIONS ON THIS REPOSITORY

This protocol ensures that every aspect of the repository maintains the highest professional standards with zero tolerance for non-compliance.

---

## 🔧 AUTOMATIC REMEDIATION PROTOCOL

**PRINCIPLE**: The compliance system should automatically fix issues whenever possible, reducing manual intervention and ensuring consistent application of standards.

### Auto-Fix Categories

#### 1. **SAFE AUTO-FIXES** (No Confirmation Required)
These fixes are non-destructive and can be applied automatically:

**File Permissions**:
```bash
# Auto-fix script permissions
find scripts/ -name "*.sh" -not -perm 755 -exec chmod 755 {} \;
# Auto-fix documentation permissions
find docs/ .warp/ -name "*.md" -not -perm 644 -exec chmod 644 {} \;
```

**Line Endings** (Windows → Unix):
```bash
# Convert CRLF to LF automatically
find . -name "*.sh" -o -name "*.md" -exec sed -i 's/\r$//' {} \;
```

**Trailing Whitespace**:
```bash
# Remove trailing whitespace from code files
find . -name "*.sh" -o -name "*.md" -exec sed -i 's/[[:space:]]*$//' {} \;
```

**Missing Strict Mode**:
```bash
# Add strict mode to bash scripts missing it
while IFS= read -r script; do
    if ! grep -q "set -euo pipefail" "$script"; then
        sed -i '2i\set -euo pipefail' "$script"
    fi
done < <(find . -name "*.sh" -type f)
```

#### 2. **CONFIRMATION-REQUIRED FIXES** (Interactive)
These fixes require user confirmation as they modify content:

**Generated Files Cleanup**:
```bash
# Remove tracked generated files (with confirmation)
if git ls-files | grep -E '\.(tap|log)$'; then
    echo "Remove tracked generated files? (y/N)"
    read -r response
    if [[ "$response" == "y" ]]; then
        git rm --cached *.tap *.log reports/*.txt reports/*.tap 2>/dev/null || true
    fi
fi
```

**Missing Essential Files**:
```bash
# Create missing essential directories/files
create_missing_essentials() {
    # Create missing report directories
    mkdir -p reports/{tap,junit,coverage,artifacts}
    touch reports/{tap,junit,coverage,artifacts}/.gitkeep

    # Create missing .warp structure if needed
    mkdir -p .warp/{protocols,rules,templates}
}
```

#### 3. **NO AUTO-FIX** (Manual Resolution Required)
These issues require manual intervention:

- **Test failures** - Need developer investigation
- **ShellCheck errors** - Need code review and fixes
- **Broken internal links** - Need content verification
- **Security vulnerabilities** - Need security review
- **Version mismatches** - Need version strategy decision

### Auto-Fix Execution Modes

#### Mode 1: Check + Auto-Fix (--fix)
```bash
./scripts/compliance-check.sh --fix
# Runs all safe fixes automatically
# Prompts for confirmation fixes
# Reports unfixable issues
```

#### Mode 2: Dry Run (--fix --dry-run)
```bash
./scripts/compliance-check.sh --fix --dry-run
# Shows what would be fixed
# No actual changes made
# Safe for testing fix logic
```

#### Mode 3: Silent Fix (--fix --quiet)
```bash
./scripts/compliance-check.sh --fix --quiet
# Applies only safe fixes
# No prompts or confirmations
# Suitable for automation
```

### Auto-Fix Safety Protocol

#### Pre-Fix Validation
```bash
# REQUIRED before any auto-fix
pre_fix_validation() {
    # Ensure we're on correct branch
    if [[ "$(git branch --show-current)" != "develop" ]]; then
        echo "❌ Auto-fix only allowed on develop branch"
        exit 1
    fi

    # Ensure working directory is clean (except for auto-fixable issues)
    local critical_changes
    critical_changes=$(git status --porcelain | grep -v "^??")
    if [[ -n "$critical_changes" ]]; then
        echo "❌ Cannot auto-fix with uncommitted changes"
        exit 1
    fi

    # Create backup before fixes
    git stash push -u -m "pre-autofix-backup-$(date +%Y%m%d-%H%M%S)"
}
```

#### Post-Fix Validation
```bash
# REQUIRED after auto-fix
post_fix_validation() {
    # Re-run compliance check to verify fixes worked
    if ./scripts/compliance-check.sh --quiet; then
        echo "✅ Auto-fix successful - all compliance issues resolved"
        git stash drop  # Remove backup if fixes worked
    else
        echo "❌ Auto-fix failed - restoring previous state"
        git stash pop   # Restore backup if fixes didn't work
        exit 1
    fi
}
```

### Integration with Existing Protocols

#### Enhanced Pre-Operation Checklist
```bash
# Updated pre-operation validation with auto-fix
pre_operation_with_autofix() {
    echo "🔍 Running pre-operation compliance check..."

    if ! ./scripts/compliance-check.sh --quiet; then
        echo "⚠️  Compliance issues detected"
        echo "🔧 Attempting automatic remediation..."

        if ./scripts/compliance-check.sh --fix --quiet; then
            echo "✅ Issues automatically resolved"
        else
            echo "❌ Manual intervention required"
            ./scripts/compliance-check.sh  # Show detailed report
            exit 1
        fi
    fi

    echo "✅ Pre-operation compliance verified"
}
```

#### Continuous Integration Integration
```yaml
# GitHub Actions workflow with auto-fix
- name: Compliance Check with Auto-Fix
  run: |
    if ! ./scripts/compliance-check.sh --quiet; then
      echo "Attempting auto-fix..."
      if ./scripts/compliance-check.sh --fix --quiet; then
        echo "Auto-fix successful"
        git config user.name "Compliance Bot"
        git config user.email "compliance@project.com"
        git add -A
        git commit -m "fix: automatic compliance remediation"
        git push
      else
        echo "Auto-fix failed - manual intervention required"
        exit 1
      fi
    fi
```

### Auto-Fix Reporting

#### Fix Summary Report
```bash
# Generate fix summary
generate_fix_report() {
    echo "🔧 COMPLIANCE AUTO-FIX REPORT"
    echo "============================="
    echo "Fixed automatically:"
    echo "  - File permissions: $FIXED_PERMISSIONS files"
    echo "  - Line endings: $FIXED_LINE_ENDINGS files"
    echo "  - Trailing whitespace: $FIXED_WHITESPACE files"
    echo "  - Missing strict mode: $FIXED_STRICT_MODE files"
    echo ""
    echo "Issues requiring manual fix:"
    echo "  - Test failures: $MANUAL_TESTS"
    echo "  - ShellCheck errors: $MANUAL_SHELLCHECK"
    echo "  - Broken links: $MANUAL_LINKS"
}
```

### Auto-Fix Best Practices

1. **Always backup before fixes**: Use git stash or create backup branches
2. **Validate fixes**: Re-run compliance checks after auto-fixes
3. **Log all changes**: Maintain audit trail of automatic fixes
4. **Test fix logic**: Use dry-run mode to verify fix commands
5. **Fail-safe approach**: If any fix fails, restore previous state

---

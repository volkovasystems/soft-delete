# 100% Compliance Protocol for Warp.dev

This protocol establishes mandatory 100% compliance standards for all repository changes, ensuring strict adherence to quality, consistency, and professional development practices.

## Core Principle

**ZERO TOLERANCE RULE**: Every change must achieve 100% compliance across all applicable standards before being accepted. No exceptions, no compromises, no "acceptable" partial compliance.

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
find docs/ .warp/ -name "*.md" -exec grep -l '\[.*\](.*\.md)' {} \; | while read file; do
    grep -o '\[.*\](.*\.md)' "$file" | while read link; do
        target=$(echo "$link" | sed 's/.*(\([^)]*\)).*/\1/')
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

This protocol ensures that every aspect of the repository maintains the highest professional standards with zero tolerance for non-compliance.

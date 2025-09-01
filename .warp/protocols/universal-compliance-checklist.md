# Universal Compliance Checklist for Warp.dev AI Operations

**CRITICAL**: This checklist MUST be completed for every prompt and operation performed on this repository. NO EXCEPTIONS.

---

## 🔴 PRE-OPERATION VALIDATION

### System Status Checks
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

---

## 🟡 OPERATION-SPECIFIC PROTOCOLS

### A. Version Control Operations (AI Version Control Protocol)

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

### B. Changelog Operations (Changelog Protocol)

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

### C. File System Operations (Structural Alignment Protocol)

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

---

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

---

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

---

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

### D. Gitignore Management Protocol (CRITICAL)

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

**PROTOCOL JUSTIFICATION**:
- Reverse-ignore pattern (`*` then `!pattern`) ensures explicit control over tracked files
- Prevents accidental inclusion of generated files, logs, or sensitive data
- Maintains clean repository while ensuring essential files are never accidentally ignored

---

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

---

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

---

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

---

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

This checklist ensures every interaction with the repository maintains professional standards and strict protocol compliance without exception.

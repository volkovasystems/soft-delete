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

---

## 📋 FINAL VALIDATION CHECKLIST

### Automated Validation Commands
Run these commands to verify full compliance:

```bash
# 1. Comprehensive compliance check
./scripts/compliance-check.sh || exit 1

# 2. Structural alignment validation
./scripts/check-cross-references.sh || exit 1

# 3. Changelog protocol compliance
./scripts/changelog.sh validate || exit 1

# 4. Version consistency check
./scripts/check-version-consistency.sh || exit 1

# 5. Working directory status
[[ -z "$(git status --porcelain)" ]] || exit 1

# 6. Recent commits follow format
git log --format="%s" -2 | grep -qE "^(feat|fix|docs|test|chore|checkpoint):" || exit 1
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

# Version consistency
echo -n "Version consistency: "
./scripts/check-version-consistency.sh > /dev/null 2>&1 && echo "✅ PASS" || echo "❌ FAIL"

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

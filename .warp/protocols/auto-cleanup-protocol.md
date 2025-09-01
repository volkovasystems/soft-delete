# Auto-Cleanup Protocol for Warp.dev AI Operations

**CRITICAL**: All generated files not intended for version control MUST be automatically cleaned up after every AI operation to prevent dangling files from affecting automations.

---

## Core Philosophy

**ZERO TOLERANCE FOR DANGLING FILES**

This project follows a strict auto-cleanup approach:
- AI operations generate temporary files during execution
- Only explicitly tracked files should remain after operations
- Generated artifacts must be cleaned up immediately
- No dangling files should interfere with subsequent automations

---

## Generated File Categories

### 1. **Build Artifacts** (AUTO-CLEANUP REQUIRED)
```
bin/soft-delete         # Built executable (conditionally kept)
dist/                   # Distribution files
*.o, *.so, *.dylib     # Compiled objects
*.tmp, *.temp          # Temporary files
node_modules/          # Package dependencies
```

### 2. **Test Artifacts** (AUTO-CLEANUP REQUIRED)
```
reports/*.tap          # TAP test output files  
reports/*.txt          # Test report files
reports/junit/         # JUnit XML reports
reports/coverage/      # Coverage reports
reports/artifacts/     # Test artifacts
*.log                  # Log files
test_*.tmp             # Temporary test files
/tmp/backup-*          # Test backup directories
```

### 3. **Documentation Artifacts** (AUTO-CLEANUP REQUIRED)
```
*.pdf                  # Generated PDFs
*.html                 # Generated HTML docs
docs/build/            # Built documentation
site/                  # Generated sites
*.tmp.md               # Temporary markdown files
```

### 4. **Development Artifacts** (AUTO-CLEANUP REQUIRED)
```
.cache/                # Cache directories
.pytest_cache/         # Python test cache
.coverage              # Coverage data files
*.pyc, __pycache__/    # Python compiled files
.DS_Store              # macOS system files
Thumbs.db              # Windows system files
```

### 5. **Deployment Artifacts** (CONDITIONAL CLEANUP)
```
.deploy/               # Deployment state (keep for staging info)
*.state                # State files (keep for deployment tracking)
staging.env            # Environment files (cleanup after use)
```

---

## Auto-Cleanup Rules

### Rule AC-001: Immediate Post-Operation Cleanup
**MANDATORY**: After every AI response that generates files, run cleanup validation

```bash
# REQUIRED after every AI operation
cleanup_generated_files() {
    # Remove test artifacts
    find reports/ -name "*.tap" -mtime +0 -delete 2>/dev/null || true
    find reports/ -name "*.txt" -mtime +0 -delete 2>/dev/null || true
    find reports/ -name "*.xml" -mtime +0 -delete 2>/dev/null || true
    
    # Remove temporary files
    find . -name "*.tmp" -type f -delete 2>/dev/null || true
    find . -name "*.temp" -type f -delete 2>/dev/null || true
    find . -name "*~" -type f -delete 2>/dev/null || true
    
    # Remove system files
    find . -name ".DS_Store" -delete 2>/dev/null || true
    find . -name "Thumbs.db" -delete 2>/dev/null || true
    
    # Remove old backup directories from /tmp
    find /tmp -name "backup-*" -type d -mtime +0 -exec rm -rf {} + 2>/dev/null || true
}
```

### Rule AC-002: Build Artifact Cleanup
**CONDITIONAL**: Clean build artifacts unless explicitly needed

```bash
cleanup_build_artifacts() {
    # Clean built executable if not needed for testing
    if [[ -f "bin/soft-delete" && "$KEEP_BINARY" != "true" ]]; then
        rm -f bin/soft-delete
    fi
    
    # Clean distribution files
    if [[ -d "dist/" ]]; then
        rm -rf dist/
    fi
    
    # Clean compiled objects
    find . -name "*.o" -o -name "*.so" -o -name "*.dylib" -delete 2>/dev/null || true
}
```

### Rule AC-003: Documentation Cleanup
**SELECTIVE**: Clean generated docs, preserve source

```bash
cleanup_doc_artifacts() {
    # Remove generated HTML/PDF docs
    find docs/ -name "*.html" -o -name "*.pdf" -delete 2>/dev/null || true
    
    # Remove doc build directories
    rm -rf docs/build/ site/ 2>/dev/null || true
    
    # Remove temporary markdown files
    find . -name "*.tmp.md" -delete 2>/dev/null || true
}
```

### Rule AC-004: Cache and Development Cleanup
**AGGRESSIVE**: Remove all cache and development artifacts

```bash
cleanup_dev_artifacts() {
    # Remove cache directories
    rm -rf .cache/ .pytest_cache/ __pycache__/ 2>/dev/null || true
    
    # Remove coverage files
    rm -f .coverage 2>/dev/null || true
    
    # Remove Python compiled files
    find . -name "*.pyc" -delete 2>/dev/null || true
}
```

---

## Automatic Cleanup Integration

### Integration Point 1: Universal Compliance Checklist
Add cleanup validation to the final validation checklist:

```bash
# 11. AUTO-CLEANUP VALIDATION (MANDATORY)
echo "🧹 Running auto-cleanup validation..."

# Check for dangling test files
if find reports/ -name "*.tap" -o -name "*.txt" | grep -q .; then
    echo "❌ Dangling test artifacts found - running cleanup"
    ./scripts/cleanup.sh --quiet --type reports || true
fi

# Check for temporary files
if find . -name "*.tmp" -o -name "*.temp" | grep -q .; then
    echo "❌ Temporary files found - running cleanup"
    find . -name "*.tmp" -o -name "*.temp" -delete 2>/dev/null || true
fi

# Check for system files
if find . -name ".DS_Store" -o -name "Thumbs.db" | grep -q .; then
    echo "❌ System files found - running cleanup" 
    find . -name ".DS_Store" -o -name "Thumbs.db" -delete 2>/dev/null || true
fi

# Verify no untracked files remain (except allowed patterns)
UNTRACKED_FILES=$(git ls-files --others --exclude-standard)
if [[ -n "$UNTRACKED_FILES" ]]; then
    echo "⚠️  Untracked files detected:"
    echo "$UNTRACKED_FILES"
    # Allow specific patterns (.deploy/, reports/, but warn about others)
    if echo "$UNTRACKED_FILES" | grep -v -E '^\.deploy/|^reports/|^\.cache/' | grep -q .; then
        echo "❌ Unexpected untracked files found"
        exit 1
    fi
fi

echo "✅ Auto-cleanup validation passed"
```

### Integration Point 2: Response Completeness Protocol
Extend the response completeness protocol:

```bash
# MANDATORY AUTO-CLEANUP WORKFLOW (before final commit)
- [ ] ✅ **Run auto-cleanup**: Remove all generated artifacts
- [ ] ✅ **Validate cleanup**: No dangling files remain
- [ ] ✅ **Check untracked files**: Only allowed patterns remain
- [ ] ✅ **Verify automation safety**: No files interfere with scripts
```

### Integration Point 3: Continuous Commit Protocol
Add cleanup step to commit workflow:

```bash
# Enhanced commit workflow with auto-cleanup
git_commit_with_cleanup() {
    # 1. Pre-commit cleanup
    ./scripts/cleanup.sh --quiet --type temporary || true
    
    # 2. Stage intentional changes only
    git add .
    
    # 3. Verify no unintended files are staged
    if git diff --cached --name-only | grep -E '\.(tmp|temp|log|tap)$'; then
        echo "❌ Temporary files staged - aborting commit"
        exit 1
    fi
    
    # 4. Commit with conventional format
    git commit -m "type: description"
    
    # 5. Post-commit cleanup
    cleanup_generated_files
}
```

---

## Cleanup Script Integration

### Enhanced cleanup.sh Integration
The existing `scripts/cleanup.sh` should be extended with auto-cleanup capabilities:

```bash
# Auto-cleanup mode (silent, comprehensive)
./scripts/cleanup.sh --auto --quiet

# Specific cleanup types
./scripts/cleanup.sh --type reports     # Clean test artifacts
./scripts/cleanup.sh --type temporary  # Clean temp files  
./scripts/cleanup.sh --type build      # Clean build artifacts
./scripts/cleanup.sh --type all        # Clean everything
```

### Pre-commit Hook Integration
Add cleanup validation to `.githooks/pre-commit`:

```bash
# Auto-cleanup validation in pre-commit hook
validate_auto_cleanup() {
    echo "🧹 Validating auto-cleanup compliance..."
    
    # Check for common dangling files
    local dangling_files=0
    
    # Test artifacts
    if find reports/ -name "*.tap" -o -name "*.txt" 2>/dev/null | grep -q .; then
        echo "❌ Test artifacts found in reports/"
        dangling_files=$((dangling_files + 1))
    fi
    
    # Temporary files
    if find . -name "*.tmp" -o -name "*.temp" 2>/dev/null | grep -q .; then
        echo "❌ Temporary files found"
        dangling_files=$((dangling_files + 1))
    fi
    
    # System files
    if find . -name ".DS_Store" -o -name "Thumbs.db" 2>/dev/null | grep -q .; then
        echo "❌ System files found"
        dangling_files=$((dangling_files + 1))
    fi
    
    if [[ $dangling_files -gt 0 ]]; then
        echo "❌ Auto-cleanup validation failed"
        echo "Run: ./scripts/cleanup.sh --auto --quiet"
        return 1
    fi
    
    echo "✅ Auto-cleanup validation passed"
    return 0
}
```

---

## Gitignore Integration

### Enhanced .gitignore Patterns
Ensure generated files are properly ignored:

```gitignore
# Auto-cleanup targets (generated files that should never be committed)

# Test artifacts
reports/*.tap
reports/*.txt
reports/*.xml
reports/**/*.tap
reports/**/*.txt
reports/**/*.xml

# Build artifacts  
bin/soft-delete
dist/
*.o
*.so
*.dylib

# Temporary files
*.tmp
*.temp
*~
*.swp
*.swo

# Documentation artifacts
docs/**/*.html
docs/**/*.pdf
docs/build/
site/

# Development artifacts
.cache/
.pytest_cache/
__pycache__/
*.pyc
.coverage
node_modules/

# System files
.DS_Store
Thumbs.db

# Deployment artifacts (conditional)
staging.env
temp.state
```

---

## Automation Safety Rules

### Rule AS-001: Script Execution Safety
**CRITICAL**: Ensure cleanup doesn't interfere with running scripts

```bash
# Safe cleanup implementation
safe_cleanup() {
    local cleanup_type="$1"
    
    # Check if any automation is running
    if pgrep -f "make docker-test|make docker-lint|scripts/" >/dev/null; then
        echo "⚠️  Automation running - deferring cleanup"
        return 0
    fi
    
    # Proceed with cleanup
    case "$cleanup_type" in
        "reports")
            find reports/ -name "*.tap" -o -name "*.txt" -delete 2>/dev/null || true
            ;;
        "temporary")
            find . -name "*.tmp" -o -name "*.temp" -delete 2>/dev/null || true
            ;;
        "all")
            cleanup_generated_files
            cleanup_build_artifacts
            cleanup_doc_artifacts  
            cleanup_dev_artifacts
            ;;
    esac
}
```

### Rule AS-002: Essential File Protection
**MANDATORY**: Never cleanup files essential for automation

```bash
# Protected files that MUST NOT be cleaned up
PROTECTED_FILES=(
    "VERSION"
    "CHANGELOG.md"
    ".gitignore"
    ".warp/"
    "scripts/"
    "tests/"
    "Makefile"
    "docker-compose*.yml"
    "Dockerfile*"
)

# Protected patterns
PROTECTED_PATTERNS=(
    "*.sh"           # Shell scripts
    "*.bats"         # Test files
    "*.md"           # Documentation
    "*.yml"          # Configuration
    "*.yaml"         # Configuration
    ".githooks/"     # Git hooks
)

validate_protection() {
    local file="$1"
    
    # Check against protected files
    for protected in "${PROTECTED_FILES[@]}"; do
        if [[ "$file" == "$protected"* ]]; then
            return 1  # Protected - do not clean
        fi
    done
    
    # Check against protected patterns
    for pattern in "${PROTECTED_PATTERNS[@]}"; do
        if [[ "$file" == $pattern ]]; then
            return 1  # Protected - do not clean
        fi
    done
    
    return 0  # Safe to clean
}
```

### Rule AS-003: State Preservation
**SELECTIVE**: Preserve deployment and automation state

```bash
# Preserve deployment state but clean temporary deployment files
cleanup_deployment_artifacts() {
    # Keep .deploy/ directory and *.state files (needed for deployment tracking)
    # But clean temporary deployment files
    find . -name "staging.env" -delete 2>/dev/null || true
    find . -name "temp.state" -delete 2>/dev/null || true
    find . -name "deploy-*.tmp" -delete 2>/dev/null || true
}
```

---

## Compliance Monitoring

### Daily Cleanup Audit
```bash
#!/bin/bash
# scripts/audit-cleanup.sh

echo "🧹 DAILY AUTO-CLEANUP AUDIT - $(date)"
echo "===================================="

# Check for dangling files
echo "📊 Dangling File Report:"
echo "------------------------"

# Test artifacts
TEST_ARTIFACTS=$(find reports/ -name "*.tap" -o -name "*.txt" 2>/dev/null | wc -l)
echo "Test artifacts: $TEST_ARTIFACTS files"

# Temporary files  
TEMP_FILES=$(find . -name "*.tmp" -o -name "*.temp" 2>/dev/null | wc -l)
echo "Temporary files: $TEMP_FILES files"

# System files
SYSTEM_FILES=$(find . -name ".DS_Store" -o -name "Thumbs.db" 2>/dev/null | wc -l) 
echo "System files: $SYSTEM_FILES files"

# Build artifacts
BUILD_ARTIFACTS=0
[[ -f "bin/soft-delete" ]] && BUILD_ARTIFACTS=$((BUILD_ARTIFACTS + 1))
[[ -d "dist/" ]] && BUILD_ARTIFACTS=$((BUILD_ARTIFACTS + 1))
echo "Build artifacts: $BUILD_ARTIFACTS items"

# Untracked files (excluding allowed patterns)
UNTRACKED=$(git ls-files --others --exclude-standard | grep -v -E '^\.deploy/|^reports/' | wc -l)
echo "Unexpected untracked: $UNTRACKED files"

# Overall status
TOTAL_DANGLING=$((TEST_ARTIFACTS + TEMP_FILES + SYSTEM_FILES + UNTRACKED))
if [[ $TOTAL_DANGLING -eq 0 ]]; then
    echo ""
    echo "✅ REPOSITORY CLEAN - No dangling files detected"
else
    echo ""
    echo "❌ CLEANUP REQUIRED - $TOTAL_DANGLING dangling files found"
    echo "Run: ./scripts/cleanup.sh --auto --quiet"
fi
```

### Automated Cleanup Schedule
```bash
# Cron job for automated cleanup (run every hour)
0 * * * * /path/to/soft-delete/scripts/cleanup.sh --auto --quiet >/dev/null 2>&1

# Daily comprehensive audit
0 9 * * * /path/to/soft-delete/scripts/audit-cleanup.sh
```

---

## Integration with Universal Compliance Checklist

### Additional Compliance Check
Add to `.warp/protocols/universal-compliance-checklist.md`:

```bash
# 12. AUTO-CLEANUP COMPLIANCE VALIDATION
echo "🧹 Auto-cleanup compliance validation..."

# Run cleanup audit
if ! ./scripts/audit-cleanup.sh --quiet 2>/dev/null; then
    echo "❌ Auto-cleanup audit failed"
    exit 1
fi

# Verify no dangling artifacts
DANGLING_COUNT=$(find . -name "*.tmp" -o -name "*.temp" -o -name ".DS_Store" | wc -l)
if [[ $DANGLING_COUNT -gt 0 ]]; then
    echo "❌ Dangling files detected: $DANGLING_COUNT"
    exit 1
fi

# Check untracked files
UNEXPECTED_UNTRACKED=$(git ls-files --others --exclude-standard | grep -v -E '^\.deploy/|^reports/' | wc -l)
if [[ $UNEXPECTED_UNTRACKED -gt 0 ]]; then
    echo "❌ Unexpected untracked files: $UNEXPECTED_UNTRACKED"
    exit 1
fi

echo "✅ Auto-cleanup compliance verified"
```

---

## Error Recovery Procedures

### When Cleanup Fails
```bash
# Emergency cleanup recovery
emergency_cleanup() {
    echo "🚨 EMERGENCY CLEANUP PROCEDURE"
    echo "==============================="
    
    # Force remove known dangling patterns
    rm -rf reports/*.tap reports/*.txt 2>/dev/null || true
    find . -name "*.tmp" -delete 2>/dev/null || true
    find . -name "*.temp" -delete 2>/dev/null || true
    find . -name ".DS_Store" -delete 2>/dev/null || true
    find . -name "Thumbs.db" -delete 2>/dev/null || true
    
    # Clean old backup directories
    find /tmp -name "backup-*" -type d -mtime +0 -exec rm -rf {} + 2>/dev/null || true
    
    # Reset git to clean state (only if safe)
    if [[ -z "$(git status --porcelain | grep -v '^?? ')" ]]; then
        git clean -fdx --exclude=.deploy/ --exclude=VERSION --exclude=.warp/
    fi
    
    echo "✅ Emergency cleanup completed"
}
```

### Automation Recovery
```bash
# Recover from automation interference
recover_automation() {
    echo "🔧 AUTOMATION RECOVERY PROCEDURE"
    echo "================================"
    
    # Wait for running processes to complete
    while pgrep -f "make docker|scripts/" >/dev/null; do
        echo "⏳ Waiting for automation to complete..."
        sleep 5
    done
    
    # Run safe cleanup
    safe_cleanup "all"
    
    # Verify automation files are intact
    for script in scripts/*.sh; do
        if [[ ! -x "$script" ]]; then
            echo "❌ Script permissions lost: $script"
            chmod +x "$script"
        fi
    done
    
    echo "✅ Automation recovery completed"
}
```

---

## Success Metrics

### Auto-Cleanup KPIs
- **Zero Dangling Files**: 0 temporary/generated files remain
- **Clean Repository**: Only tracked files present
- **Automation Safety**: No interference with running processes
- **Performance Impact**: < 1 second cleanup execution time
- **Storage Efficiency**: < 1MB of artifacts at any time

### Monitoring Dashboard
```bash
# Weekly cleanup metrics
echo "AUTO-CLEANUP METRICS"
echo "===================="
echo "Dangling files cleaned this week: $(get_cleanup_count)"
echo "Average cleanup time: $(get_avg_cleanup_time)"
echo "Automation interference events: $(get_interference_count)"
echo "Repository size (excluding .git): $(du -sh --exclude=.git . | cut -f1)"
```

---

**ENFORCEMENT LEVEL**: ABSOLUTE AND IMMEDIATE  
**EFFECTIVE DATE**: 2025-09-01  
**PROTOCOL VERSION**: 1.0.0  
**SCOPE**: ALL AI OPERATIONS GENERATING FILES

This protocol ensures zero tolerance for dangling files while maintaining automation safety and repository cleanliness.

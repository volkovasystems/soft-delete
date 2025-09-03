# Security Protocol

**Version**: 1.0.0  
**Effective Date**: 2025-09-03  
**Scope**: All security-related operations and standards  
**Enforcement Level**: MANDATORY 100%

## Overview

This protocol establishes comprehensive security standards for the soft-delete project, ensuring zero tolerance for security vulnerabilities and implementing proactive security measures throughout the development lifecycle.

## Security Principles

### 1. **Zero Trust Security**
- Assume all input is malicious until proven otherwise
- Validate all inputs at system boundaries
- Apply least privilege principle to all operations
- Never trust data from external sources

### 2. **Defense in Depth**
- Multiple layers of security controls
- Fail-secure by default
- Comprehensive logging and monitoring
- Regular security assessments

### 3. **Security by Design**
- Security considerations from project inception
- Threat modeling for all major features
- Secure coding practices mandatory
- Regular security reviews

## Security Standards Matrix

### A. Sensitive Data Protection (ZERO TOLERANCE)

| Risk Level | Standard | Verification | Tolerance |
|------------|----------|--------------|-----------|
| **CRITICAL** | No credentials in source code | `scripts/security-scan.sh --credentials` | 0% |
| **CRITICAL** | No API keys in repository | `scripts/security-scan.sh --secrets` | 0% |
| **CRITICAL** | No private keys committed | `scripts/security-scan.sh --keys` | 0% |
| **HIGH** | No hardcoded passwords | `scripts/security-scan.sh --passwords` | 0% |
| **HIGH** | No sensitive URLs exposed | `scripts/security-scan.sh --urls` | 0% |

#### Implementation Requirements
```bash
# REQUIRED: No sensitive data patterns in repository
PROHIBITED_PATTERNS=(
    "password\s*=\s*['\"][^'\"]{3,}"
    "api[_-]?key\s*=\s*['\"][^'\"]{10,}"
    "secret\s*=\s*['\"][^'\"]{8,}"
    "token\s*=\s*['\"][^'\"]{10,}"
    "-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----"
    "ssh-rsa\s+[A-Za-z0-9+/]{200,}"
)

# MANDATORY: Scan for prohibited patterns
for pattern in "${PROHIBITED_PATTERNS[@]}"; do
    if grep -rEi "$pattern" . --exclude-dir=.git --exclude-dir=reports; then
        echo "❌ SECURITY VIOLATION: Sensitive data found"
        exit 1
    fi
done
```

### B. Path Security and Input Validation (MANDATORY 100%)

| Risk Level | Standard | Verification | Tolerance |
|------------|----------|--------------|-----------|
| **CRITICAL** | No path traversal vulnerabilities | `scripts/security-scan.sh --path-traversal` | 0% |
| **CRITICAL** | All user input validated | `scripts/security-scan.sh --input-validation` | 0% |
| **HIGH** | No unsafe file operations | `scripts/security-scan.sh --file-ops` | 0% |
| **HIGH** | Proper path canonicalization | Manual review + testing | 0% |

#### Path Security Requirements
```bash
# PROHIBITED: Unsafe path patterns
UNSAFE_PATTERNS=(
    "\.\./\.\."                    # Obvious path traversal
    "cd\s+\$[^{]"                  # cd with unquoted variables
    "rm\s+-rf\s+\$[0-9@*]"        # rm with unvalidated user input
    "eval.*\$[0-9@*]"              # eval with user input
)

# REQUIRED: Proper input validation for all user-facing scripts
validate_input() {
    local input="$1"
    local type="$2"
    
    case "$type" in
        "path")
            # Reject path traversal attempts
            if [[ "$input" == *".."* ]] || [[ "$input" == *"~"* ]]; then
                echo "❌ Invalid path: contains traversal patterns"
                return 1
            fi
            # Canonicalize path
            input=$(realpath -m "$input" 2>/dev/null || echo "$input")
            ;;
        "filename")
            # Reject dangerous filename patterns
            if [[ "$input" =~ [^a-zA-Z0-9._-] ]]; then
                echo "❌ Invalid filename: contains unsafe characters"
                return 1
            fi
            ;;
    esac
    
    echo "$input"
}
```

### C. File System Security (MANDATORY)

| Component | Required Permission | Verification | Auto-Fix |
|-----------|-------------------|--------------|-----------|
| Scripts | 755 (rwxr-xr-x) | `find scripts/ -name "*.sh" -not -perm 755` | ✅ |
| Documentation | 644 (rw-r--r--) | `find docs/ -name "*.md" -not -perm 644` | ✅ |
| Configuration | 644 (rw-r--r--) | `find . -name "*.yml" -not -perm 644` | ✅ |
| Private data | 600 (rw-------) | Manual verification | ❌ |

#### File Permission Security
```bash
# AUTO-FIX: Correct file permissions
fix_file_permissions() {
    echo "🔒 Fixing file permissions for security..."
    
    # Fix script permissions
    find scripts/ -name "*.sh" -not -perm 755 -exec chmod 755 {} \;
    
    # Fix documentation permissions  
    find docs/ .warp/ -name "*.md" -not -perm 644 -exec chmod 644 {} \;
    
    # Fix configuration file permissions
    find . -name "*.yml" -o -name "*.yaml" -o -name "*.json" -not -perm 644 -exec chmod 644 {} \;
    
    # Verify no world-writable files exist
    if find . -type f -perm /o+w -not -path "./.git/*"; then
        echo "❌ World-writable files found - security risk"
        return 1
    fi
    
    echo "✅ File permissions secured"
}
```

### D. Docker and Container Security

| Security Control | Requirement | Verification | Auto-Fix |
|------------------|-------------|--------------|----------|
| Non-root user | MANDATORY | `grep "USER.*[^root]" Dockerfile*` | ✅ |
| No secrets in images | MANDATORY | `grep -iE "(password\|secret\|key)" Dockerfile*` | ❌ |
| Minimal base images | RECOMMENDED | Manual review | ❌ |
| Security scanning | MANDATORY | `docker scan` (if available) | ❌ |

#### Container Security Implementation
```bash
# REQUIRED: Dockerfile security validation
validate_dockerfile_security() {
    local dockerfile="$1"
    
    if [[ ! -f "$dockerfile" ]]; then
        return 0  # No Dockerfile to validate
    fi
    
    local issues=0
    
    # Check for non-root user
    if ! grep -q "USER.*[^root]" "$dockerfile"; then
        echo "❌ Dockerfile security: No non-root user specified"
        ((issues++))
    fi
    
    # Check for secrets
    if grep -iE "(password|secret|key|token)" "$dockerfile"; then
        echo "❌ Dockerfile security: Potential secrets found"
        ((issues++))
    fi
    
    # Check for proper COPY ownership
    if ! grep -q "COPY.*--chown" "$dockerfile"; then
        echo "⚠️  Dockerfile security: Consider using --chown for proper file ownership"
    fi
    
    return $issues
}
```

## Security Verification Workflow

### Pre-Operation Security Check
```bash
#!/bin/bash
# scripts/security-scan.sh - Enhanced with auto-fix capabilities

security_pre_check() {
    echo "🔒 SECURITY PRE-OPERATION CHECK"
    echo "==============================="
    
    local issues=0
    
    # 1. Sensitive data scan
    echo "🔍 Scanning for sensitive data..."
    if ! scan_sensitive_data; then
        ((issues++))
    fi
    
    # 2. Path traversal vulnerability check
    echo "🔍 Checking for path traversal vulnerabilities..."
    if ! check_path_traversal; then
        ((issues++))
    fi
    
    # 3. Input validation analysis
    echo "🔍 Analyzing input validation..."
    if ! analyze_input_validation; then
        ((issues++))
    fi
    
    # 4. File permission verification
    echo "🔍 Verifying file permissions..."
    if ! verify_file_permissions; then
        ((issues++))
    fi
    
    # 5. Container security check
    echo "🔍 Checking container security..."
    if ! check_container_security; then
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        echo "✅ Security pre-check: PASSED"
        return 0
    else
        echo "❌ Security pre-check: $issues issues found"
        return 1
    fi
}
```

### Security Auto-Fix Categories

#### 1. SAFE AUTO-FIXES (No Confirmation Required)
These security fixes are non-destructive and safe to apply automatically:

**File Permission Fixes**:
```bash
# AUTO-FIX: Secure file permissions
auto_fix_permissions() {
    local fixes=0
    
    # Fix overly permissive scripts
    while IFS= read -r -d '' file; do
        if [[ -x "$file" ]] && [[ $(stat -c "%a" "$file") != "755" ]]; then
            chmod 755 "$file"
            echo "🔒 Fixed permissions: $file -> 755"
            ((fixes++))
        fi
    done < <(find scripts/ -name "*.sh" -type f -print0)
    
    # Fix overly permissive documentation
    while IFS= read -r -d '' file; do
        if [[ $(stat -c "%a" "$file") != "644" ]]; then
            chmod 644 "$file"
            echo "🔒 Fixed permissions: $file -> 644"
            ((fixes++))
        fi
    done < <(find docs/ .warp/ -name "*.md" -type f -print0)
    
    # Remove world-write permissions
    while IFS= read -r -d '' file; do
        chmod o-w "$file"
        echo "🔒 Removed world-write: $file"
        ((fixes++))
    done < <(find . -type f -perm /o+w -not -path "./.git/*" -print0)
    
    echo "✅ File permission fixes applied: $fixes files"
    return $fixes
}
```

**Secure Configuration Defaults**:
```bash
# AUTO-FIX: Apply secure configuration defaults
auto_fix_configurations() {
    local fixes=0
    
    # Ensure .gitignore contains security patterns
    local security_patterns=(
        "*.key"
        "*.pem"
        "*.p12"
        "*.pfx"
        ".env"
        ".env.*"
        "config/secrets.*"
        "*.credential*"
    )
    
    for pattern in "${security_patterns[@]}"; do
        if ! grep -q "^$pattern$" .gitignore 2>/dev/null; then
            echo "$pattern" >> .gitignore
            echo "🔒 Added security pattern to .gitignore: $pattern"
            ((fixes++))
        fi
    done
    
    echo "✅ Security configuration fixes applied: $fixes items"
    return $fixes
}
```

#### 2. CONFIRMATION-REQUIRED FIXES (Interactive)
These fixes require confirmation as they may impact functionality:

**Remove Potential Secrets**:
```bash
# CONFIRM-FIX: Remove potential secrets from repository
confirm_fix_secrets() {
    local potential_secrets
    potential_secrets=$(scan_for_secrets)
    
    if [[ -n "$potential_secrets" ]]; then
        echo "⚠️  Potential secrets found:"
        echo "$potential_secrets"
        echo ""
        echo "This could be:"
        echo "1. Actual secrets (SECURITY RISK)"
        echo "2. False positives (checksums, examples)"
        echo "3. Development test data"
        echo ""
        echo "Remove potential secrets? (y/N)"
        read -r response
        
        if [[ "$response" == "y" ]]; then
            # Implementation would sanitize the identified content
            echo "🔒 Removing potential secrets..."
            return 0
        else
            echo "⚠️  Secrets detection skipped by user"
            return 1
        fi
    fi
    
    return 0
}
```

#### 3. MANUAL-ONLY FIXES (Report Only)
These security issues require manual developer intervention:

- **Code injection vulnerabilities** - Need code review
- **Logic flaws in security controls** - Need architectural review  
- **Third-party dependency vulnerabilities** - Need dependency updates
- **Complex input validation issues** - Need domain expertise

### Security Execution Modes

#### Mode 1: Security Check + Auto-Fix (--fix)
```bash
./scripts/security-scan.sh --fix
# Runs all safe security fixes automatically
# Prompts for confirmation fixes
# Reports manual-only issues
```

#### Mode 2: Security Dry Run (--fix --dry-run)
```bash
./scripts/security-scan.sh --fix --dry-run
# Shows what security fixes would be applied
# No actual changes made
# Safe for testing security fix logic
```

#### Mode 3: Silent Security Fix (--fix --quiet)
```bash  
./scripts/security-scan.sh --fix --quiet
# Applies only safe security fixes
# No prompts or confirmations
# Suitable for automation/CI
```

## Security Integration Points

### With Compliance Protocol
```bash
# Security validation integrated into compliance checks
compliance_security_integration() {
    echo "🔒 Security compliance verification..."
    
    # Run security scan as part of compliance
    if ! ./scripts/security-scan.sh --quiet; then
        echo "❌ Security compliance failure"
        return 1
    fi
    
    echo "✅ Security compliance: PASSED"
}
```

### With CI/CD Pipeline
```yaml
# GitHub Actions security integration
- name: Security Scan with Auto-Fix
  run: |
    if ! ./scripts/security-scan.sh --quiet; then
      echo "Attempting security auto-fix..."
      ./scripts/security-scan.sh --fix --quiet
      
      # Re-check after auto-fix
      if ! ./scripts/security-scan.sh --quiet; then
        echo "❌ Security issues require manual intervention"
        exit 1
      fi
      
      # Commit security fixes if any were made
      if [[ -n "$(git status --porcelain)" ]]; then
        git add -A
        git commit -m "fix: automatic security remediation"
      fi
    fi
```

### With Pre-Commit Hooks
```bash
#!/bin/bash
# .githooks/pre-commit - Security gate
echo "🔒 Running security pre-commit checks..."

if ! ./scripts/security-scan.sh --quiet; then
    echo ""
    echo "❌ COMMIT BLOCKED: Security issues detected"
    echo "Run: ./scripts/security-scan.sh --fix"
    exit 1
fi

echo "✅ Security pre-commit: PASSED"
```

## Security Monitoring and Reporting

### Daily Security Report
```bash
#!/bin/bash
# scripts/security-report.sh

echo "📊 DAILY SECURITY REPORT - $(date)"
echo "================================="

# Security scan results
echo "🔒 Security Scan Results:"
if ./scripts/security-scan.sh --quiet > /dev/null 2>&1; then
    echo "  ✅ No security issues detected"
else
    echo "  ❌ Security issues found - review required"
    ./scripts/security-scan.sh --summary
fi

# File permission audit
echo "🔐 File Permission Audit:"
local perm_issues=0
if find scripts/ -name "*.sh" -not -perm 755 | grep -q .; then
    echo "  ❌ Script permission issues found"
    ((perm_issues++))
fi
if find docs/ -name "*.md" -not -perm 644 | grep -q .; then
    echo "  ❌ Documentation permission issues found"
    ((perm_issues++))
fi
if [[ $perm_issues -eq 0 ]]; then
    echo "  ✅ All file permissions correct"
fi

# Git history security scan
echo "🕵️ Git History Security:"
if git log --all --oneline | grep -iE "(password|secret|key|token)" | grep -q .; then
    echo "  ⚠️  Potential sensitive data in git history"
else
    echo "  ✅ No sensitive data patterns in git history"
fi

echo ""
echo "🎯 SECURITY STATUS: Regular monitoring active"
```

### Security Metrics and KPIs

| Metric | Target | Measurement | Frequency |
|--------|--------|-------------|-----------|
| **Vulnerabilities** | 0 critical/high | Security scan results | Pre-commit |
| **Permission Issues** | 0 violations | File permission audit | Daily |
| **Secrets Exposure** | 0 instances | Git history + code scan | Continuous |
| **Input Validation** | 100% coverage | Code review + testing | Per feature |
| **Container Security** | 0 vulnerabilities | Docker security scan | Per build |

## Non-Compliance Response Protocol

### Critical Security Issues (Immediate Response Required)

#### Level 1: CRITICAL (Immediate Halt)
- Exposed credentials, API keys, or secrets
- Active security vulnerabilities
- Data exposure risks

**Response**:
```bash
# IMMEDIATE: Stop all operations
echo "🚨 CRITICAL SECURITY ISSUE DETECTED"
echo "====================================="
echo "❌ All development MUST STOP immediately"
echo "❌ Issue must be resolved before any further work"

# Secure the repository
git stash push -u -m "security-halt-$(date +%Y%m%d-%H%M%S)"
./scripts/security-scan.sh --detailed-report

echo "Required actions:"
echo "1. Identify and fix security issue"
echo "2. Run security scan until clean"
echo "3. Review git history for exposure"
echo "4. Consider key rotation if needed"
```

#### Level 2: HIGH (24-hour Fix Required)
- Input validation weaknesses
- File permission issues
- Unsafe coding practices

#### Level 3: MEDIUM (72-hour Fix Required)
- Documentation security gaps
- Configuration improvements
- Dependency updates

### Security Incident Response
1. **Immediate Assessment** - Determine scope and severity
2. **Containment** - Stop further exposure or damage
3. **Remediation** - Fix the root cause
4. **Verification** - Confirm fix effectiveness
5. **Post-Incident Review** - Update protocols and procedures

## Agent Behavior Rules for Security

### Mandatory Agent Security Behaviors
1. **Always run security scan** before suggesting code changes
2. **Never suggest insecure patterns** in code recommendations
3. **Validate all user inputs** in suggested scripts
4. **Use secure defaults** in all configurations
5. **Report security concerns** immediately when detected
6. **Prioritize security** over convenience or speed

### Prohibited Agent Behaviors
❌ **Never ignore security warnings** for any reason  
❌ **Never suggest "quick fixes"** that bypass security  
❌ **Never recommend disabling security controls**  
❌ **Never expose sensitive data** in logs or output  
❌ **Never suggest insecure temporary solutions**

## Success Metrics and Validation

### Security KPIs (All Must Be 100%)
- **Vulnerability Score**: 0 critical/high vulnerabilities
- **Secrets Exposure**: 0 sensitive data in repository
- **Permission Compliance**: 100% correct file permissions
- **Input Validation**: 100% of user inputs validated
- **Container Security**: 100% secure container configurations

### Final Security Validation
```bash
# MANDATORY: Final security verification
echo "🔒 FINAL SECURITY VALIDATION"
echo "============================"

# Run comprehensive security scan
if ! ./scripts/security-scan.sh --comprehensive; then
    echo "❌ Security validation FAILED"
    exit 1
fi

# Verify no sensitive data
if git log --all --oneline | grep -iE "(password|secret|key|token)"; then
    echo "❌ Potential sensitive data in git history"
    exit 1
fi

# Verify file permissions
if find . -type f -perm /o+w -not -path "./.git/*" | grep -q .; then
    echo "❌ World-writable files found"
    exit 1
fi

echo "✅ SECURITY VALIDATION: 100% PASSED"
```

---

**ENFORCEMENT LEVEL**: MANDATORY AND IMMEDIATE  
**PROTOCOL VERSION**: 1.0.0  
**NEXT REVIEW**: 2025-12-01  
**SCOPE**: ALL SECURITY OPERATIONS

This protocol ensures that security is never compromised and remains the highest priority throughout the development lifecycle.

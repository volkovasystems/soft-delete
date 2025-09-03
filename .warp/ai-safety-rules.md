# Warp Terminal AI Safety Rules

**Version**: 1.0.0
**Effective Date**: 2025-09-03
**Scope**: All AI agents interacting via Warp terminal
**Enforcement Level**: MANDATORY

## Overview

These rules prevent AI agents (including Warp AI, Claude, GPT, and others) from accidentally damaging project functionality through well-intentioned but destructive modifications.

## Critical Safety Rules for AI Agents

### 🚨 NEVER DO THESE THINGS

#### 🔴 CRITICAL SECURITY VIOLATIONS (ZERO TOLERANCE - IMMEDIATE HALT)

**NEVER BYPASS SECURITY CHECKS IN CODE - THIS IS A CRITICAL SECURITY VIOLATION:**

0. **NEVER use `git commit --no-verify` in actual commands** ❌ # Safe: legitimate security warning documentation
   - This bypasses ALL security checks and pre-commit hooks
   - Creates immediate security vulnerabilities
   - Violates zero-tolerance security policy
   - **ALWAYS fix security issues properly instead of bypassing**

0. **NEVER use `git push --no-verify` in actual commands** ❌ # Safe: legitimate security warning documentation
   - Bypasses push-time security validation
   - Allows vulnerable code to reach remote repositories
   - Undermines security framework integrity

0. **NEVER ignore or dismiss security warnings** ❌
   - "False positives" indicate tool improvement opportunities
   - Proper resolution means fixing detection patterns, not bypassing
   - Security warnings exist to protect against real threats

0. **NEVER disable security scans** ❌ # Safe: legitimate security warning documentation
   - No `--skip-security`, `--no-scan`, or similar bypass flags in actual code # Safe: legitimate security warning documentation
   - No commenting out security validation code
   - No modifying security tools to be less effective

**COMMUNICATION SECURITY POLICY:**
- ✅ **Commit messages may freely discuss security topics** including bypass techniques
- ✅ **Documentation may reference bypass commands** for educational purposes
- ✅ **Security discussions are encouraged** - knowledge sharing improves security
- ✅ **Technical terms like "bypass" have legitimate uses** in many contexts
- 🎯 **Security enforcement focuses on executable code**, not language policing
- 📝 **Real security comes from preventing dangerous commands**, not restricting vocabulary

**PROPER RESPONSE TO SECURITY ISSUES:**
- ✅ Analyze why the security tool flagged the issue
- ✅ Fix the detection pattern or exclusion rules
- ✅ Document why the fix is safe and specific
- ✅ Test that real threats are still detected
- ✅ Get security team review for any pattern changes
- ❌ NEVER bypass or disable security checks

#### Other Critical Functionality Protections:

1. **NEVER recreate large scripts from scratch**
   - Always edit existing files incrementally
   - Preserve existing functionality and logic
   - When you see a 500+ line script, edit it, don't replace it

2. **NEVER remove functions without verification**
   - Check function count before and after changes
   - Understand what each function does before removing it
   - When in doubt, keep existing functions

3. **NEVER ignore line count reductions >10%**
   - Significant line reduction usually means functionality loss
   - Be extremely cautious with changes that reduce file size dramatically
   - Validate that all features still work after reduction

4. **NEVER bypass safety checks**
   - Always run `scripts/functionality-guard.sh --check`
   - Always run `scripts/compliance-check.sh`
   - Respect pre-commit hook warnings

5. **NEVER exclude files from security scanning**
   - All files must remain scannable
   - No `--exclude` flags on security-critical files
   - Maintain comprehensive security coverage

### ✅ ALWAYS DO THESE THINGS

1. **ALWAYS make incremental edits**
   - Edit existing files rather than creating new ones
   - Make one logical change at a time
   - Preserve existing structure and patterns

2. **ALWAYS validate functionality preservation**
   ```bash
   # Before major changes
   scripts/functionality-guard.sh --check

   # After any modifications
   scripts/functionality-guard.sh --check

   # If intentional changes
   scripts/functionality-guard.sh --update-baseline
   ```

3. **ALWAYS run full validation**
   ```bash
   # Complete validation pipeline
   scripts/compliance-check.sh
   scripts/security-scan.sh --quiet
   make test
   ```

4. **ALWAYS understand before changing**
   - Read and understand existing code before modifying
   - Identify the purpose of functions before altering them
   - Preserve edge case handling and error management

5. **ALWAYS communicate changes clearly**
   - Explain what you're changing and why
   - Alert users to significant modifications
   - Document any functionality that might be affected

## Warp Terminal Specific Guidelines

### Terminal Session Context
- Remember that commands run in a persistent session
- Previous commands and their effects are part of the context
- File changes are immediate and persistent

### Multi-Step Operations
- Break complex operations into smaller steps
- Validate each step before proceeding to the next
- Allow user review at critical junctures

### Error Recovery
- Always provide rollback instructions
- Keep git history clean for easy recovery
- Have recovery plans for failed operations

## Automated Protection Systems

### Pre-Commit Protection
The `.githooks/pre-commit` script automatically:
- ✅ Checks for functionality regressions
- ✅ Validates security compliance
- ✅ Scans for potential secrets
- ❌ Blocks commits that lose functionality

### Functionality Guard
The `scripts/functionality-guard.sh` script:
- Tracks line counts and function counts
- Detects >10% reductions in critical files
- Maintains baseline of expected functionality
- Provides rollback mechanisms

### Compliance Integration
The `scripts/compliance-check.sh` includes:
- Functionality preservation validation
- AI agent protection checks
- Zero tolerance for functionality loss
- Comprehensive validation pipeline

## Warning Signs You Should Stop

🛑 **Stop immediately if you see:**
- Line count dropping by more than 50 lines
- Function count decreasing
- Complex logic being "simplified" significantly
- Removing error handling or edge cases
- User expressing concern about missing functionality

## Recovery Procedures

### If Functionality Loss Occurs:

1. **Immediate Assessment**:
   ```bash
   scripts/functionality-guard.sh --check
   scripts/functionality-guard.sh --generate-report
   ```

2. **Automatic Rollback** (if enabled):
   ```bash
   AUTO_ROLLBACK=true scripts/functionality-guard.sh --auto-rollback
   ```

3. **Manual Recovery**:
   ```bash
   git log --oneline -10
   git revert <problematic-commit>
   # OR
   git show <good-commit>:path/to/file > path/to/file
   ```

4. **Validation**:
   ```bash
   scripts/functionality-guard.sh --update-baseline
   scripts/compliance-check.sh
   ```

## User Override Mechanisms

### ⚠️ DEPRECATED: Emergency Override (PROHIBITED)
**SECURITY POLICY UPDATE**: Bypassing security checks is now strictly prohibited.
```bash
# THESE COMMANDS ARE PROHIBITED - DO NOT USE:
# git commit --no-verify  # PROHIBITED: Security violation # Safe: legitimate security warning documentation
# Instead: Fix the underlying issue properly

# PROPER APPROACH:
# 1. Identify why validation is failing
# 2. Fix the root cause
# 3. Commit normally after fixing
```

### Intentional Functionality Changes
For legitimate functionality removal:
```bash
# Make changes
scripts/functionality-guard.sh --update-baseline
git add .functionality-baseline.json
git commit -m "feat: intentional functionality changes with updated baseline"
```

## Best Practices for AI Agents

### 1. Start Conservative
- Begin with minimal changes
- Test frequently
- Expand scope gradually

### 2. Preserve First, Optimize Second
- Ensure functionality works before improving it
- Don't sacrifice features for cleanliness
- Maintain backward compatibility

### 3. Use the Tools
- Run validation scripts frequently
- Pay attention to their output
- Don't ignore warnings

### 4. Communicate Proactively
- Warn about potentially destructive changes
- Explain the impact of modifications
- Offer rollback options

### 5. Plan for Recovery
- Always know how to undo changes
- Keep recovery commands ready
- Document the change process

## Examples of Dangerous Scenarios

### ❌ BAD: Complete Recreation
```bash
# User: "Fix this security scan script"
# AI: Creates entirely new script with different structure
# Result: Lost auto-fix functions, lost sophisticated logic
```

### ✅ GOOD: Incremental Fix
```bash
# User: "Fix this security scan script"
# AI: Identifies specific issue, edits only relevant lines
# Result: Problem fixed, all existing functionality preserved
```

### ❌ BAD: Aggressive Simplification
```bash
# AI: "This script is complex, let me simplify it"
# Result: Edge cases lost, error handling removed, features missing
```

### ✅ GOOD: Careful Enhancement
```bash
# AI: "I'll improve this specific function while preserving all others"
# Result: Targeted improvement, full functionality maintained
```

## Integration with Project Workflow

This safety system integrates with:
- **Version Control**: Git hooks and commit validation
- **Security Framework**: Preserved scanning and compliance
- **Development Workflow**: Maintained tooling and scripts
- **Documentation**: Updated protocols and guidelines

## Enforcement and Monitoring

- **Automated enforcement** via pre-commit hooks and compliance checks
- **Continuous monitoring** through functionality preservation tracking
- **Manual oversight** through user review and approval processes
- **Emergency response** via rollback and recovery mechanisms

---

**Remember**: The goal is to assist users while preserving the valuable functionality they've built. When in doubt, make smaller changes and validate more frequently.

**For AI Agents**: This isn't about restricting your capabilities—it's about channeling them safely to avoid accidental damage to complex, working systems.

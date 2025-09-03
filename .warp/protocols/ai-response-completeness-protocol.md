# AI Response Completeness Protocol

## Critical Rule: Complete Task Execution

**ABSOLUTE REQUIREMENT**: Every AI response that makes changes MUST include committing those changes and updating the changelog.

---

## Core Protocol Rules

### 1. No Uncommitted Changes Rule

**CRITICAL**: At the end of every AI response that modifies files, the working directory MUST be clean (no uncommitted changes).

```bash
# This command MUST return empty at the end of every response
git status --porcelain
```

### 2. Required End-of-Response Workflow

Every AI response that makes file changes MUST follow this exact sequence:

```bash
# 1. Check what was changed
git status

# 2. Add all changes
git add .

# 3. Commit with proper conventional message
git commit -m "type: description of changes

- Bullet point list of key changes
- Each major change on separate line
- Clear, specific descriptions"

# 4. Update CHANGELOG.md with new [Unreleased] section
# (Add entry describing all changes made)

# 5. Add and commit changelog
git add CHANGELOG.md
git commit -m "docs: update changelog for [description of work]"

# 6. Verify clean working directory
git status --porcelain  # MUST be empty
```

### 3. Changelog Requirements

Every meaningful change MUST be documented in CHANGELOG.md under `[Unreleased]` section:

```markdown
## [Unreleased]

### [Added/Changed/Fixed/Security]
- **Brief Title**: Description of change
  - Specific details of what was modified
  - Impact or benefit of the change
  - Any breaking changes or important notes
```

### 4. Response Validation Checklist

At the end of EVERY response that modifies files, verify:

- [ ] All changes are committed
- [ ] Changelog is updated
- [ ] Working directory is clean (`git status --porcelain` returns empty)
- [ ] Commit messages follow conventional format
- [ ] No protocol violations remain

---

## Implementation Rules

### For AI Agents

#### Before Starting Work
```bash
# Always start from clean state on develop branch
git checkout develop
git status --porcelain  # Should be empty
```

#### During Work
- Make changes incrementally
- Keep track of all modifications
- Follow existing protocols (version, structural alignment, etc.)

#### After Completing Work (MANDATORY)
```bash
# 1. Review what was changed
git status
git diff

# 2. Commit all work
git add .
git commit -m "appropriate conventional message with details"

# 3. Update changelog
# Edit CHANGELOG.md to add [Unreleased] section with changes

# 4. Commit changelog
git add CHANGELOG.md
git commit -m "docs: update changelog for [work description]"

# 5. Final verification
git status --porcelain  # MUST be empty
```

### Enforcement Mechanisms

#### Pre-commit Hooks
The existing pre-commit system will:
- Block commits without changelog updates for meaningful changes
- Validate commit message format
- Check protocol compliance
- Ensure version consistency

#### Response Template
Every AI response making changes should end with:

```
## ✅ Task Completion Verification

Changes committed:
- [List of files modified]
- Changelog updated with entry describing work
- Working directory clean: `git status --porcelour` returns empty
- All protocols followed
```

## Protocol Violations

### Examples of Violations

#### ❌ Leaving Uncommitted Changes
```bash
# This is a CRITICAL protocol violation
git status
# On branch develop
# Changes not staged for commit:
#   modified: file1.md
#   modified: file2.sh
# (Files modified but not committed)
```

#### ❌ Missing Changelog Update
Making meaningful changes without updating CHANGELOG.md is a protocol violation.

#### ❌ Incomplete Response
Ending a response with "Please commit these changes" instead of actually committing them.

### Violation Consequences

When violations occur:
1. **Immediate correction required**
2. **Protocol review and reinforcement**
3. **Process improvement to prevent recurrence**

---

## Integration with Existing Protocols

### Continuous Commit Protocol
This protocol reinforces the continuous commit principle:
- Changes are committed immediately when made
- Working directory stays clean
- No accumulation of uncommitted work

### Changelog Protocol
This protocol ensures changelog compliance:
- All meaningful changes are documented
- Changelog updates are committed separately
- Version history is complete and accurate

### Version Protocol
This protocol supports version consistency:
- Changes that affect version references are properly committed
- Version file protocol is followed
- No version drift occurs

---

## Future Enforcement Improvements

### 1. Automated Validation
```bash
# Add to .warp/rules/ as validation script
#!/bin/bash
# validate-response-completeness.sh

if [[ -n "$(git status --porcelain)" ]]; then
    echo "❌ PROTOCOL VIOLATION: Uncommitted changes detected"
    echo "All AI responses must commit changes before completion"
    exit 1
fi

echo "✅ Response completeness validated: Working directory clean"
```

### 2. AI Agent Instructions Enhancement
Update agent instructions to include:
- Automatic end-of-response workflow
- Mandatory commit verification
- Changelog update requirements
- Clean working directory validation

### 3. Pre-Response Checks
Implement checks that verify:
- Starting from clean working directory
- Proper branch (develop)
- All protocols accessible and valid

### 4. Post-Response Verification
Automatic validation that:
- Working directory is clean
- Changelog has been updated if needed
- All commits follow conventional format
- No protocol violations remain

---

## Response Quality Standards

### Minimum Requirements
Every AI response that makes changes must:
1. **Complete the requested work fully**
2. **Commit all changes with proper messages**
3. **Update changelog appropriately**
4. **Verify clean working directory**
5. **Follow all applicable protocols**

### Quality Indicators
- ✅ All files modified are committed
- ✅ Changelog reflects work performed
- ✅ Commit messages are clear and conventional
- ✅ Working directory is clean
- ✅ No protocol violations
- ✅ Work is production-ready

---

## Protocol Maintenance

### Regular Reviews
- Monthly protocol compliance audits
- Review of AI response quality
- Process improvement identification
- Protocol updates as needed

### Continuous Improvement
- Learn from any violations that occur
- Enhance enforcement mechanisms
- Improve AI agent instructions
- Streamline compliance processes

This protocol ensures every AI interaction maintains repository quality and follows established development practices.

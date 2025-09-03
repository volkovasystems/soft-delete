# Cross-File Consistency Protocol for Warp.dev

This protocol establishes mandatory requirements for maintaining consistency across all repository files when making any changes.

## Core Principle

**CRITICAL RULE**: Every change to any file must trigger a consistency check and update of all related files to maintain alignment throughout the repository.

## Consistency Domains

### 1. Documentation Consistency

#### When Changing Source Code
**Files to Update:**
- `README.md` - Usage examples, feature descriptions
- `docs/API.md` - API documentation and examples
- `docs/TESTING.md` - Test procedures and commands
- `.warp/project-context.md` - Project architecture description
- Help text in `soft-delete.sh` (`show_help()` function)

**Example Scenario:**
```bash
# If adding new command-line option to soft-delete.sh
1. Update soft-delete.sh (add option parsing and help)
2. Update README.md (add option to usage examples)
3. Update docs/API.md (document new option)
4. Update .warp/project-context.md (mention new functionality)
5. Add tests in tests/soft-delete.bats
```

#### When Changing Documentation
**Files to Update:**
- Cross-reference all other documentation files
- Update version references if applicable
- Align examples and command formats
- Update `.warp/project-context.md` if architecture changes

### 2. Version Consistency

#### When Updating VERSION File
**Files to Update:**
- `Formula/soft-delete.rb` (Homebrew formula)
- Any documentation with version references
- `CHANGELOG.md` (if version bump)
- GitHub Actions workflows (if version-dependent)

#### Version Reference Pattern
```bash
# Always read from VERSION file - NEVER hardcode
VERSION=$(cat VERSION | tr -d '\n\r' | tr -d ' ')
```

### 3. Configuration Consistency

#### When Changing Build System (Makefile)
**Files to Update:**
- `.warp/project-context.md` - Essential commands section
- `docs/TESTING.md` - Build and test procedures
- `README.md` - Installation and usage instructions
- GitHub Actions workflows - Build steps

#### When Changing Test Configuration
**Files to Update:**
- `.warp/project-context.md` - Testing framework description
- `docs/TESTING.md` - Complete test procedures
- `README.md` - Testing instructions
- Docker configuration files

### 4. Protocol and Rule Consistency

#### When Adding New Protocols
**Files to Update:**
- `.warp/README.md` - File structure and precedence
- `.warp/rules/agent-instructions.md` - Reference new protocol
- `.warp/rules/dynamic-rules.md` - Extract actionable rules
- Cross-reference related protocols

#### When Adding New Rules
**Files to Update:**
- Source protocol files - Cross-reference new rule
- `.warp/rules/agent-instructions.md` - Update rule counts and categories
- `.warp/rules/rules-summary.md` - Update comprehensive summary
- Related protocol files - Add cross-references

### 5. Script and Automation Consistency

#### When Changing Helper Scripts
**Files to Update:**
- `.warp/project-context.md` - Update command examples
- `.warp/protocols/continuous-commit-protocol.md` - Script usage examples
- `.warp/rules/ai-agent-rules.md` - Update workflow instructions
- Documentation referencing the scripts

#### When Adding New Scripts
**Files to Update:**
- `README.md` - Add to available commands
- `.warp/project-context.md` - Include in essential commands
- Relevant protocol files - Update examples
- Help documentation

### 6. Test Consistency

#### When Adding New Features
**Files to Update:**
- `tests/soft-delete.bats` - Add comprehensive tests
- `tests/edge-cases.bats` - Add edge case coverage
- `docs/TESTING.md` - Update test descriptions
- `.warp/project-context.md` - Update test count and coverage

#### When Changing Test Framework
**Files to Update:**
- All documentation referencing tests
- `.warp/project-context.md` - Testing framework section
- Build system configuration
- CI/CD workflow files

## Mandatory Consistency Checks

### Before Every Commit

#### 1. Cross-Reference Validation
```bash
# Check for inconsistent examples
grep -r "soft-delete" README.md docs/ .warp/
# Verify all examples use same format

# Check version references
grep -r "[0-9]\+\.[0-9]\+\.[0-9]\+" README.md docs/ .warp/
# Should only find references to VERSION file, not hardcoded versions
```

#### 2. Command Consistency
```bash
# Verify all documentation uses same commands
grep -r "make docker-test" README.md docs/ .warp/
grep -r "make build" README.md docs/ .warp/
# Ensure consistent command usage across all files
```

#### 3. File Structure Alignment
```bash
# Check if new files are documented
ls .warp/protocols/ | while read file; do
    grep -q "$file" .warp/README.md || echo "Missing: $file"
done
```

## Consistency Workflows

### Workflow 1: Source Code Changes

```bash
# 1. Make source code changes
vim soft-delete.sh

# 2. Update related documentation immediately
vim README.md              # Usage examples
vim docs/API.md            # API documentation
vim .warp/project-context.md  # Architecture description

# 3. Update tests
vim tests/soft-delete.bats  # Feature tests
vim tests/edge-cases.bats   # Edge cases

# 4. Verify consistency
make docker-test           # All tests pass
make docker-lint          # ShellCheck compliance

# 5. Commit atomically
git add soft-delete.sh README.md docs/API.md .warp/project-context.md tests/
git commit -m "feat: implement feature X with comprehensive documentation updates"
```

### Workflow 2: Documentation Changes

```bash
# 1. Update primary documentation
vim README.md

# 2. Update cross-referenced files
vim docs/API.md                    # Align examples
vim .warp/project-context.md      # Update architecture notes
vim docs/TESTING.md               # Align procedures

# 3. Verify consistency
grep -r "example pattern" README.md docs/ .warp/
# Ensure all examples match

# 4. Commit consistently
git add README.md docs/ .warp/
git commit -m "docs: update README with aligned cross-references"
```

### Workflow 3: Protocol Changes

```bash
# 1. Update protocol file
vim .warp/protocols/new-protocol.md

# 2. Extract and document rules
vim .warp/rules/dynamic-rules.md   # Add extracted rules

# 3. Update meta-documentation
vim .warp/README.md               # Add to file structure
vim .warp/rules/agent-instructions.md   # Reference new protocol
vim .warp/rules/rules-summary.md        # Update rule counts

# 4. Cross-reference related protocols
vim .warp/protocols/related-protocol.md  # Add cross-reference

# 5. Commit with full context
git add .warp/
git commit -m "feat: add new protocol with full cross-file integration"
```

## File Relationship Matrix

### Primary Files and Their Dependencies

| Primary File | Must Update | Cross-Check | Verify |
|-------------|-------------|-------------|--------|
| `soft-delete.sh` | README.md, docs/API.md, project-context.md, tests/ | Help text alignment | Version consistency |
| `README.md` | docs/API.md, project-context.md | Command examples | Installation steps |
| `Makefile` | project-context.md, TESTING.md, README.md | Build commands | CI/CD alignment |
| `VERSION` | Formula/soft-delete.rb | All version references | Changelog consistency |
| Protocol files | dynamic-rules.md, agent-instructions.md | Cross-references | Rule extraction |
| Test files | TESTING.md, project-context.md | Test descriptions | Coverage alignment |

## Consistency Verification Tools

### Automated Checks

#### 1. Version Consistency Check
```bash
#!/bin/bash
# scripts/check-version-consistency.sh

VERSION_FILE_VERSION=$(cat VERSION)
FORMULA_VERSION=$(grep "version" Formula/soft-delete.rb | cut -d'"' -f2)

if [[ "$VERSION_FILE_VERSION" != "$FORMULA_VERSION" ]]; then
    echo "❌ Version inconsistency: VERSION=$VERSION_FILE_VERSION, Formula=$FORMULA_VERSION"
    exit 1
fi
echo "✅ Version consistency verified"
```

#### 2. Documentation Example Check
```bash
#!/bin/bash
# scripts/check-doc-examples.sh

# Extract examples from different files
README_EXAMPLES=$(grep -o "soft-delete [^\"]*" README.md)
API_EXAMPLES=$(grep -o "soft-delete [^\"]*" docs/API.md)

# Compare for consistency
if [[ "$README_EXAMPLES" != "$API_EXAMPLES" ]]; then
    echo "❌ Documentation examples inconsistent"
    exit 1
fi
echo "✅ Documentation examples consistent"
```

#### 3. Cross-Reference Validator
```bash
#!/bin/bash
# scripts/check-cross-references.sh

# Check if all protocol files are listed in README
for protocol in .warp/protocols/*.md; do
    filename=$(basename "$protocol")
    if ! grep -q "$filename" .warp/README.md; then
        echo "❌ Protocol $filename not documented in README"
        exit 1
    fi
done
echo "✅ All protocols properly cross-referenced"
```

## Error Recovery

### When Inconsistencies Are Found

#### 1. Immediate Fix Protocol
```bash
# If inconsistency detected during commit
git add --all                    # Stage all current changes
git stash                       # Stash changes temporarily
git checkout HEAD -- conflicting-file.md  # Reset inconsistent file
# Fix inconsistency manually
git stash pop                   # Restore changes
git add --all                   # Stage corrected changes
git commit -m "fix: resolve cross-file inconsistency"
```

#### 2. Batch Consistency Update
```bash
# When multiple files are inconsistent
git add --all
git commit -m "fix: batch update for cross-file consistency

- Align all examples with current functionality
- Update version references throughout repository
- Synchronize command formats across documentation
- Verify test descriptions match actual test coverage"
```

## Integration with Existing Protocols

### With Continuous Commit Protocol
- **Each consistency update** gets its own commit
- **Related changes grouped** in single atomic commits
- **Cross-file updates** committed together when logically related

### With Testing Protocol
- **Consistency checks** run before tests
- **Documentation alignment** verified with linting
- **Cross-reference validation** included in quality gates

### With Version Protocol
- **VERSION file changes** trigger consistency updates
- **All version references** automatically aligned
- **Formula and documentation** updated together

## Agent Behavior Rules

### For Warp.dev Agents

1. **Always identify related files** before making any change
2. **Update cross-references immediately** in the same commit
3. **Verify examples and commands** remain consistent
4. **Check version references** for hardcoding
5. **Run consistency validation** before committing
6. **Document consistency updates** in commit messages

### Forbidden Patterns

❌ **Never change single file** without checking related files
❌ **Never commit partial updates** that leave inconsistencies
❌ **Never assume no cross-references** exist
❌ **Never skip consistency verification**

## Compliance Verification

### Required Checks Before Any Commit

- [ ] **Related files identified** and reviewed
- [ ] **Cross-references updated** where applicable
- [ ] **Examples and commands** remain consistent
- [ ] **Version references** use VERSION file
- [ ] **Tests updated** to match functionality
- [ ] **Documentation aligned** with implementation
- [ ] **Consistency validation** passed

This protocol ensures that every change maintains repository-wide consistency and alignment, preventing fragmentation and outdated references across the codebase.

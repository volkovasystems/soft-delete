# Git Management Protocol for Warp.dev

This protocol defines standard Git practices for the `soft-delete` project when working with Warp.dev agents.

## Branch Management Strategy

### Branch Structure
The repository follows a multi-branch workflow with specific purposes:

```
main        # Stable production releases (protected)
develop     # Active development branch (primary working branch)
staging     # Pre-release testing and validation
release     # Release preparation and final testing
test        # Experimental features and testing
master      # Legacy branch (avoid using)
```

### Branch Usage Rules

#### Primary Development Branch: `develop`
- **Default working branch** for all development
- All feature development should start from `develop`
- Regular commits and incremental changes
- Must pass all tests before pushing

#### Branch Selection Guidelines
```bash
# For normal development work
git checkout develop

# For experimental features or testing
git checkout test

# For release preparation (use deployment scripts)
# Managed by deployment automation - avoid manual checkout
```

### Branch Protection Rules
- **NEVER commit directly to `main`** - it's for stable releases only
- **Always work on `develop`** for regular development
- Use deployment scripts for `staging` and `release` branch management

## Commit Message Standards

### Format (Conventional Commits)
Follow the established pattern observed in the repository:

```
<type>(optional scope): <description>

<optional body>

<optional footer>
```

### Commit Types (Based on Repository History)

#### Primary Types
- **`feat:`** - New features or functionality
- **`fix:`** - Bug fixes and corrections
- **`docs:`** - Documentation updates
- **`test:`** - Test additions or modifications
- **`ci:`** - CI/CD pipeline changes
- **`config:`** - Configuration file changes
- **`chore:`** - Maintenance tasks

#### Secondary Types
- **`refactor:`** - Code restructuring without feature changes
- **`perf:`** - Performance improvements
- **`style:`** - Code formatting changes
- **`build:`** - Build system changes

### Commit Message Examples (From Repository)

#### Feature Commits
```bash
git commit -m "feat: implement comprehensive deployment automation system"
git commit -m "feat: implement centralized version management system"
git commit -m "feat: Add Homebrew formula and installation support"
```

#### Fix Commits
```bash
git commit -m "fix: correct .gitattributes patterns for new files"
git commit -m "fix: Remove deprecated version attribute from docker-compose.test.yml"
git commit -m "fix: Resolve shellcheck warnings and improve code quality"
```

#### Documentation Commits
```bash
git commit -m "docs: update changelog following enhanced organization protocol"
git commit -m "docs: enhance Warp.dev changelog protocol with organization principles"
git commit -m "docs: Improve TESTING.md with accurate test helper documentation"
```

#### Configuration Commits
```bash
git commit -m "config(git): fix gitignore patterns to properly allow .tap files"
git commit -m "config(shellcheck): format configuration, remove verbose comments"
```

#### CI/CD Commits
```bash
git commit -m "ci(github): update GitHub Actions to latest secure versions"
```

## Atomic Commit Principles

### What Makes a Commit Atomic

#### ✅ Good Atomic Commits
- **Single logical change** - One fix, one feature, one update
- **Complete functionality** - All related files for one change
- **Testable independently** - Can be tested in isolation
- **Clear purpose** - Obvious what changed and why

#### Examples of Proper Atomic Commits
```bash
# Single feature implementation
feat: implement centralized version management system

# Single bug fix with all related changes
fix: resolve shellcheck warnings and improve code quality

# Single documentation update
docs: enhance CONTRIBUTING.md with Docker-first testing approach
```

#### ❌ Avoid Non-Atomic Commits
- **Multiple unrelated changes** in one commit
- **Partial implementations** that break functionality
- **Mixed concerns** (e.g., feature + unrelated bug fix)
- **Large commits** that touch many different areas

### Atomic Commit Workflow

#### Before Committing
```bash
# 1. Review changes
git diff

# 2. Stage related changes only
git add specific-files-for-one-logical-change

# 3. Verify what's staged
git diff --cached

# 4. Ensure tests pass
make docker-test

# 5. Commit with descriptive message
git commit -m "type: clear description of single change"
```

#### Staging Strategies
```bash
# Stage all changes for single feature
git add src/ tests/ docs/

# Stage specific files only
git add soft-delete.sh tests/soft-delete.bats

# Stage parts of files (interactive)
git add -p filename

# Review staged changes
git diff --staged
```

## Pre-Commit Quality Gates

### Mandatory Checks Before Any Commit
```bash
# 1. Build verification
make build

# 2. Full test suite
make docker-test

# 3. Linting compliance
make docker-lint

# 4. Verify clean working directory
git status
```

### Commit Readiness Checklist
- [ ] **Tests pass** - `make docker-test` shows 100% success
- [ ] **Build succeeds** - `make build` completes without errors
- [ ] **Linting clean** - `make docker-lint` shows no warnings
- [ ] **Single logical change** - Commit addresses one specific concern
- [ ] **Clear commit message** - Follows conventional format
- [ ] **No unrelated changes** - Only files relevant to the change
- [ ] **Documentation updated** - If functionality changed

## Workflow Integration

### Standard Development Workflow
```bash
# 1. Start from develop branch
git checkout develop
git pull origin develop

# 2. Make changes (ensure atomicity)
# ... make focused changes for single purpose

# 3. Pre-commit validation
make build && make docker-test

# 4. Stage and review changes
git add <relevant-files>
git diff --staged

# 5. Commit with proper message
git commit -m "type: description of atomic change"

# 6. Push to develop
git push origin develop
```

### Multi-Change Development
```bash
# For multiple logical changes, use multiple atomic commits:

# First atomic commit
git add file1.sh tests/test1.bats
git commit -m "feat: implement feature A with tests"

# Second atomic commit
git add docs/README.md
git commit -m "docs: update README for feature A"

# Third atomic commit
git add file2.sh
git commit -m "fix: resolve edge case in existing function"

# Push all commits
git push origin develop
```

## Warp.dev Agent Guidelines

### Agent Behavior Rules
1. **Always start from `develop` branch**
2. **Never commit to `main` directly**
3. **Run full test suite before committing**
4. **Use conventional commit messages**
5. **Keep commits atomic and focused**
6. **Update relevant documentation in same commit when needed**

### Commit Message Templates for Agents

#### New Feature
```
feat: implement [feature description]

- Add core functionality for [specific capability]
- Include comprehensive tests with [X] test cases
- Update help text and documentation
- Ensure backward compatibility
```

#### Bug Fix
```
fix: resolve [specific problem]

- Fix [specific issue] in [component]
- Add regression test to prevent recurrence
- Maintain existing functionality
- Update error handling
```

#### Documentation Update
```
docs: update [document/section] with [improvement]

- Improve clarity and accuracy
- Add missing examples or details
- Fix formatting and structure
- Ensure consistency with codebase
```

### Error Recovery Procedures

#### If Tests Fail After Commit
```bash
# 1. Investigate failure
make docker-test-verbose

# 2. If critical, revert commit
git revert HEAD

# 3. Fix issue in new commit
# ... make fixes
git commit -m "fix: resolve test failures from previous commit"
```

#### If Commit Message Is Wrong
```bash
# If last commit and not pushed
git commit --amend -m "corrected: proper commit message"

# If already pushed, add clarifying commit
git commit -m "docs: clarify previous commit intent"
```

## VERSION File Protocol

### Single Source of Truth
**CRITICAL RULE**: The `VERSION` file is the **single source of truth** for all version references in the repository.

#### VERSION File Requirements
- **Location**: Root directory `/VERSION` file
- **Format**: Single line with semantic version (e.g., `X.Y.Z`)
- **Usage**: All version references must read from this file
- **Updates**: Only via version management scripts or deployment system

#### Prohibited Practices
- **NEVER** hardcode version numbers in source code
- **NEVER** maintain version information in multiple locations
- **NEVER** manually edit VERSION file without using scripts
- **NEVER** reference versions from other sources

#### Required Reading Pattern
```bash
# In scripts - always read from VERSION file
VERSION=$(cat VERSION | tr -d '\n')

# In documentation - reference VERSION file location
# In build systems - source version from VERSION file
# In deployment - validate against VERSION file
```

### Version Reference Standards

#### Acceptable Version References
✅ **Read from VERSION file**:
```bash
# Shell scripts
VERSION=$(cat VERSION)
echo "Current version: $VERSION"

# Makefile
VERSION := $(shell cat VERSION)

# Documentation references
"See VERSION file for current version"
"Version is maintained in /VERSION"
```

#### Prohibited Version References
❌ **Hardcoded versions**:
```bash
# NEVER do this
VERSION="X.Y.Z"  # Hardcoded - NEVER do this
echo "Version X.Y.Z"  # Hardcoded in output - NEVER do this
# Current version: X.Y.Z  # Hardcoded in docs - NEVER do this
```

## Integration with Deployment System

### Version-Tagged Commits
When using the deployment system:
```bash
# Deployment system handles version tagging
./scripts/deploy.sh deploy-version NEW_VERSION

# This creates properly tagged commits automatically
# Manual version commits should follow this pattern:
git commit -m "chore: bump version to $(cat VERSION) for release"
```

### Version Management Workflow
```bash
# 1. Update version using scripts (updates VERSION file)
./scripts/version.sh patch|minor|major

# 2. Verify version consistency across repository
# All references should now reflect new version from VERSION file

# 3. Commit version change
git add VERSION
git commit -m "chore: bump version to $(cat VERSION) for release"

# 4. Use deployment system
./scripts/deploy.sh deploy-release
```

### Release Preparation
```bash
# Update changelog first
git add CHANGELOG.md
git commit -m "docs: update changelog for version $(cat VERSION) release"

# Then use deployment system
./scripts/deploy.sh deploy-release
```

## Gitignore Strategy (REVERSE IGNORE LOGIC)

### CRITICAL UNDERSTANDING: Reverse Gitignore Pattern
**This repository uses REVERSE IGNORE LOGIC** - fundamentally different from standard gitignore patterns.

#### How It Works
```bash
# Line 1: Ignore EVERYTHING by default
*

# Line 2: Allow directories (needed for directory traversal)
!*/

# Remaining lines: EXPLICITLY allow specific files/patterns
!LICENSE
!*.md
!*.sh
# etc...
```

#### What This Means for AI Agents

**✅ CORRECT Understanding**:
- **Everything is ignored by default** - no need to add ignore patterns
- **Only explicitly allowed files are tracked** (using `!filename` patterns)
- **Security files (*.key, *.pem, etc.) are ALREADY ignored** - never add them to gitignore
- **Temporary files are ALREADY ignored** - never add them to gitignore

**❌ INCORRECT Understanding**:
- "I need to add *.key to gitignore" ❌ (already ignored by `*`)
- "Let me add *.tmp to gitignore" ❌ (already ignored by `*`)
- "I should add security patterns" ❌ (everything is ignored unless explicitly allowed)

#### When to Modify .gitignore

**✅ ADD these patterns (to ALLOW files)**:
```bash
# Add new file types you want to track
!*.new-extension
!*/**.new-extension

# Allow specific files
!important-config.cfg
```

**✅ ADD these patterns (to EXCLUDE specific allowed types)**:
```bash
# Exclude specific files from an allowed pattern
reports/*.tap     # Exclude .tap files from reports/ even though *.tap is allowed
temp/*.log        # Exclude .log files from temp/ even though they might be allowed
```

**❌ NEVER ADD these patterns (redundant with `*`)**:
```bash
# DON'T ADD - already ignored by default
*.key             ❌ (redundant)
*.tmp             ❌ (redundant) 
*.log             ❌ (redundant)
.env              ❌ (redundant)
node_modules/     ❌ (redundant)
*.pyc             ❌ (redundant)
```

### Gitignore Modification Protocol

#### Before Modifying .gitignore
1. **Understand the current logic**: Everything ignored by default (`*`)
2. **Check if the file type is already allowed**: Look for existing `!*.extension` patterns
3. **Determine intent**: Do you want to ALLOW a new type or EXCLUDE from an allowed type?

#### Decision Tree
```bash
# Want to track a new file type?
# → Add: !*.new-type

# Want to exclude specific files from a tracked type?
# → Add: specific/path/*.type

# Want to ignore a file type?
# → DO NOTHING (already ignored by *)
```

#### Examples of Proper .gitignore Modifications

**✅ Adding support for new file types**:
```bash
# Allow Python files
!*.py
!*/**/*.py

# Allow configuration files
!*.cfg
!*.ini
```

**✅ Excluding specific files from allowed patterns**:
```bash
# Allow .log files generally, but exclude from reports/
reports/*.log
reports/**/*.log

# Allow .json files generally, but exclude secrets
secrets.json
config/secrets.json
```

**❌ Incorrect additions (redundant with `*`)**:
```bash
# These are WRONG - already ignored
*.tmp       ❌
*.backup    ❌
.env        ❌
.cache/     ❌
```

### Validation Commands

```bash
# Check what files are currently tracked
git ls-files

# Check what files are ignored
git status --ignored

# Test if a file would be ignored
git check-ignore filename.ext

# See gitignore rules in effect
git check-ignore -v filename.ext
```

### Agent Guidelines for .gitignore

#### Before Modifying
1. **Read current .gitignore** to understand allowed patterns
2. **Test understanding**: "Is this file already ignored by the `*` rule?"
3. **Identify goal**: Allow new type vs. exclude from allowed type

#### Modification Process
1. **Only add `!pattern` to allow new file types**
2. **Only add `specific/path` to exclude from allowed patterns**
3. **Never add plain ignore patterns** (they're redundant)
4. **Test changes** with `git status` and `git check-ignore`

#### Common Mistakes to Avoid
- Adding redundant ignore patterns for files already ignored by `*`
- Not understanding that security files are ALREADY protected
- Treating this like a standard gitignore (it's reverse logic)
- Adding development artifacts that are already ignored by default

## Quality Metrics

### Commit Quality Indicators
- **Focused scope** - Single logical change
- **Clear message** - Obvious intent and impact
- **Test coverage** - All tests pass
- **Documentation sync** - Docs match implementation
- **Consistent format** - Follows established patterns

### Repository Health
- Maintain **100% test pass rate** on develop branch
- Keep **commit history clean** with atomic changes
- Ensure **consistent message format** across all commits
- Preserve **logical progression** of development

This protocol ensures consistent, professional Git practices aligned with the repository's established patterns and Warp.dev's agentic development approach.

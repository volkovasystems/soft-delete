# Continuous Commit Protocol for Warp.dev

This protocol establishes a continuous commit workflow for Warp.dev agents that ensures all changes are immediately committed while providing safe revert capabilities without losing work.

## Core Principle

**CRITICAL RULE**: Every change made to the repository must be committed immediately, with the ability to revert commits while preserving the actual changes as uncommitted modifications.

## Continuous Commit Strategy

### Immediate Commit Policy
- **EVERY** file modification must be committed within the same operation
- **EVERY** change, no matter how small, gets its own atomic commit
- **NO** uncommitted changes should remain in the working directory
- **ALWAYS** commit before moving to the next task

### Commit Categorization

#### Incremental Development Commits
```bash
# Use proper conventional commit types for incremental work
git commit -m "feat: add basic structure for feature X"
git commit -m "feat: add validation logic to feature X"
git commit -m "test: add initial tests for feature X"
```

#### Checkpoint Commits
```bash
# Use checkpoint prefix for significant milestones
git commit -m "checkpoint: feature X core functionality complete"
git commit -m "checkpoint: all tests passing for feature X"
```

#### Standard Commits
```bash
# Standard conventional commits for all work
git commit -m "feat: implement feature X with comprehensive validation"
git commit -m "test: add complete test suite for feature X"
git commit -m "docs: update documentation for feature X"
git commit -m "fix: resolve edge case in feature X"
```

## Safe Revert Mechanism

### Revert Without Losing Work
The protocol provides a way to revert commits while preserving changes:

#### Method 1: Revert to Uncommitted State
```bash
# Revert last commit but keep changes in working directory
git reset --soft HEAD~1

# Revert multiple commits but keep all changes
git reset --soft HEAD~3

# This preserves all file changes as staged modifications
# allowing you to recommit differently or continue working
```

#### Method 2: Revert with Backup Branch
```bash
# Create backup branch before reverting
git branch backup-$(date +%Y%m%d-%H%M%S)

# Revert commits on current branch
git reset --hard HEAD~3

# If you need the changes back:
git checkout backup-YYYYMMDD-HHMMSS
git checkout develop
git merge --no-ff backup-YYYYMMDD-HHMMSS
```

#### Method 3: Selective Revert with Stash
```bash
# Revert commit but stash the changes
git show HEAD --name-only | xargs git add
git stash push -m "backup: changes from commit $(git rev-parse --short HEAD)"
git reset --hard HEAD~1

# Apply changes back when needed
git stash pop
```

## Workflow Implementation

### Standard Development Cycle
```bash
# 1. Make changes
echo "new feature code" >> file.sh

# 2. Immediate commit (required)
git add file.sh
git commit -m "feat: add new feature code to file.sh"

# 3. Continue with more changes
echo "more feature code" >> file.sh

# 4. Another immediate commit (required)
git add file.sh
git commit -m "feat: enhance feature code in file.sh"

# 5. Run tests
make docker-test

# 6. If tests fail, commit the test run results
git add reports/
git commit -m "test: failures detected in feature implementation"

# 7. Fix issues
# ... make fixes

# 8. Commit fixes immediately
git add .
git commit -m "fix: resolve test failures in feature code"

# 9. Final verification
make docker-test

# 10. Final commit when ready
git add reports/
git commit -m "checkpoint: feature complete with all tests passing"
```

### Consolidation Strategy

#### Squashing Incremental Commits
When work is complete, consolidate incremental commits:

```bash
# Interactive rebase to squash incremental commits
git rebase -i HEAD~5

# In the editor:
# pick abc123 feat: implement feature X - add basic structure
# squash def456 feat: implement feature X - add validation logic
# squash ghi789 test: implement feature X - add tests
# squash jkl012 fix: resolve test failures in feature code
# pick mno345 checkpoint: feature complete with all tests passing

# Result: Clean history with logical commits
```

#### Alternative: Squash Merge to Main
```bash
# Keep detailed history on develop, clean history on main
git checkout main
git merge --squash develop
git commit -m "feat: implement comprehensive feature X"
```

## Revert Scenarios and Solutions

### Scenario 1: Need to Undo Last Few Commits
```bash
# Problem: Last 3 commits need to be undone but work preserved
git reset --soft HEAD~3

# All changes now staged, ready to recommit differently
git status  # Shows all changes as staged
```

### Scenario 2: Need to Remove Specific Commits
```bash
# Problem: Commit in the middle of history needs removal
git rebase -i HEAD~10

# In editor, delete or change 'pick' to 'drop' for unwanted commits
# Git will replay commits without the dropped ones
```

### Scenario 3: Experimental Changes Need Rollback
```bash
# Problem: Experimental work needs complete rollback
git branch experiment-backup
git reset --hard origin/develop

# Later, if you want the experimental work:
git checkout experiment-backup
git checkout -b new-approach
# Continue with refined approach
```

### Scenario 4: File-Level Revert
```bash
# Problem: Only specific file changes need reverting
git show HEAD:path/to/file.sh > temp_file
git checkout HEAD~3 -- path/to/file.sh
git commit -m "revert: restore file.sh to previous state"

# Or using git restore (Git 2.23+)
git restore --source=HEAD~3 path/to/file.sh
git commit -m "revert: restore file.sh to previous state"
```

## Warp.dev Agent Guidelines

### Agent Behavior Rules
1. **Commit immediately** after every file change
2. **Use descriptive conventional commit messages** for all work
3. **Always run tests** after significant changes and commit results
4. **Create checkpoint commits** at logical milestones
5. **Use proper commit types** (feat, fix, docs, test, etc.) for all commits
6. **Never leave uncommitted changes** when completing a task

### Commit Message Templates

#### Incremental Development
```
[type]: [action] [component] - [brief description]

Examples:
feat: implement user authentication - add login form
fix: resolve bug in parser - handle edge case for empty input
docs: update documentation - add API examples
```

#### Checkpoints
```
checkpoint: [milestone description]

Examples:
checkpoint: core functionality complete with validation
checkpoint: all unit tests passing
checkpoint: integration tests added and passing
```

#### Test Results
```
test: [result] [additional context]

Examples:
test: all tests passing (45/45)
test: failures detected in validation module (3 failed)
test: lint compliance achieved (100% clean)
```

### Error Recovery with Continuous Commits

#### If Tests Break After Commit
```bash
# 1. Commit the test failure state
git add reports/
git commit -m "test: failures detected after recent changes"

# 2. Investigate and fix
# ... debugging and fixes

# 3. Commit each fix immediately
git add src/buggy-file.sh
git commit -m "WIP: fix validation bug in buggy-file.sh"

# 4. Retest and commit results
make docker-test
git add reports/
git commit -m "test: validation bug fixed, all tests passing"
```

#### If Wrong Approach Taken
```bash
# 1. Current state is already committed (good!)
git log --oneline -5

# 2. Create backup and try different approach
git branch backup-attempt-1
git reset --soft HEAD~3  # Revert to before wrong approach

# 3. All changes now staged, ready for different approach
git status  # Everything staged, can modify and recommit
```

## Integration with Existing Protocols

### With Git Management Protocol
- **Extends** the atomic commit principle to continuous commits
- **Maintains** conventional commit format for final commits
- **Preserves** commit quality through checkpoint system

### With Testing Protocol
- **Commit test results** immediately after running tests
- **Commit test fixes** as separate WIP commits
- **Use test status** in checkpoint commit messages

### With Version Protocol
- **VERSION file changes** must be committed immediately
- **Use version reference** in commit messages: `$(cat VERSION)`
- **Version bumps** get their own immediate commits

## Automation Helpers

### Pre-commit Hook Integration
```bash
# .git/hooks/pre-commit
#!/bin/bash
# Ensure no uncommitted changes linger
if [ -n "$(git diff --cached)" ]; then
    echo "✅ Changes staged for commit"
else
    echo "❌ No changes staged - use continuous commit protocol"
    exit 1
fi
```

### Commit Helper Script
```bash
# scripts/quick-commit.sh
#!/bin/bash
# Quick commit helper for continuous commits

ACTION="$1"
COMPONENT="$2"
DESCRIPTION="$3"

if [[ -z "$ACTION" ]] || [[ -z "$COMPONENT" ]]; then
    echo "Usage: $0 <action> <component> [description]"
    echo "Example: $0 implement authentication 'add login validation'"
    exit 1
fi

git add .
if [[ -n "$DESCRIPTION" ]]; then
    git commit -m "WIP: $ACTION $COMPONENT - $DESCRIPTION"
else
    git commit -m "WIP: $ACTION $COMPONENT"
fi
```

### Checkpoint Helper Script
```bash
# scripts/checkpoint.sh
#!/bin/bash
# Create checkpoint commit

MILESTONE="$1"
if [[ -z "$MILESTONE" ]]; then
    echo "Usage: $0 <milestone_description>"
    echo "Example: $0 'core functionality complete with tests'"
    exit 1
fi

git add .
git commit -m "checkpoint: $MILESTONE"
```

## Benefits of Continuous Commit Protocol

### Advantages
1. **Never lose work** - everything always committed
2. **Complete history** - detailed tracking of development process
3. **Easy rollback** - can revert any change while preserving work
4. **Safe experimentation** - always have commits to fall back to
5. **Collaborative safety** - other agents can see all progress
6. **Debugging aid** - can bisect issues with fine granularity

### Safety Features
- **No data loss** - changes always preserved in commits
- **Flexible reversion** - multiple strategies for undoing work
- **Branch backup** - automatic backup branch creation
- **Stash integration** - temporary storage for complex reverts
- **Selective revert** - can undo specific files or commits

## Compliance Verification

### Required Checks
```bash
# 1. Ensure working directory is clean
git status --porcelain | wc -l  # Should be 0

# 2. Verify recent commit activity
git log --oneline -10 | grep -E "(WIP|checkpoint|feat|fix|docs)"

# 3. Check for proper commit message format
git log --format="%s" -10 | grep -v -E "^(WIP|checkpoint|feat|fix|docs|test|chore):"
```

### Automated Monitoring
```bash
# Add to CI/CD or regular checks
if [[ -n "$(git status --porcelain)" ]]; then
    echo "❌ Uncommitted changes detected - violates continuous commit protocol"
    exit 1
else
    echo "✅ Working directory clean - continuous commit protocol followed"
fi
```

This protocol ensures that Warp.dev agents maintain a complete, safe development history while providing maximum flexibility for experimentation and error recovery without ever losing work.

<citations>
<document>
    <document_type>WEB_PAGE</document_type>
    <document_id>https://warp.dev</document_id>
</document>
</citations>

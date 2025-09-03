# AI Agent Behavior Rules for Warp.dev

These rules define how AI agents should behave when working with the `soft-delete` project.

## Core Principles

### 1. Safety First
- **NEVER** permanently delete any files
- Always use the project's safe deletion mechanism
- Verify commands before execution, especially destructive ones
- Ask for confirmation on risky operations

### 2. Test-Driven Development
- **ALWAYS** run tests before and after changes: `make docker-test`
- Write tests first for new features
- Ensure 100% test pass rate before proceeding
- Use Docker-based testing as the primary method

### 3. Code Quality Standards
- Follow existing code patterns and style
- Use `set -euo pipefail` for all bash scripts
- Quote all variables: `"$variable"`
- Run ShellCheck and achieve 100% compliance
- Use 4-space indentation consistently

## Workflow Rules

### Before Making Any Changes
```bash
# Required checks
1. make docker-test          # Verify baseline
2. Review existing code      # Understand patterns
3. Plan changes              # Consider impact
```

### During Development
```bash
# Continuous commit development cycle
1. make build               # Build changes
2. ./scripts/quick-commit.sh implement feature "description"  # Immediate commit
3. make docker-test         # Test changes
4. ./scripts/quick-commit.sh -t "test results - status"       # Commit test results
5. Fix any failures         # Address issues
6. ./scripts/quick-commit.sh fix issue "description"          # Commit fixes immediately
7. Repeat until 100% pass   # Ensure quality
8. ./scripts/checkpoint.sh -t "milestone description"        # Create checkpoint
```

### After Changes
```bash
# Verification steps
1. make docker-test         # Final test run
2. make docker-lint         # ShellCheck compliance
3. Manual smoke test        # Basic functionality
4. Update documentation     # Keep docs current
```

## Command Usage Rules

### Preferred Commands
- `make docker-test` - Primary testing method
- `make build` - Build the executable
- `make docker-lint` - Code quality checks
- `make clean-all` - Clean environment

### Avoid These Commands
- Direct `rm` commands - Use soft-delete instead
- `make test` - Prefer Docker testing
- Manual bash script execution without building first
- Skipping tests for "small" changes

## File Modification Rules

### Source Code Changes
1. **Only modify `soft-delete.sh`** for core functionality
2. **Update tests** in `tests/` directory when adding features
3. **Update help text** in `show_help()` function when needed
4. **Preserve existing patterns** and conventions

### Documentation Updates
1. **Update relevant documentation** when changing functionality
2. **Follow existing formatting** and structure
3. **Maintain accuracy** between code and docs
4. **Use clear, concise language**

## Error Handling Rules

### When Tests Fail
1. **Do not proceed** until tests pass
2. **Investigate root cause** - don't just fix symptoms
3. **Use verbose output** for debugging: `make docker-test-verbose`
4. **Check TAP reports** in `./reports/tap/results.tap`

### When Build Fails
1. **Check syntax** with `bash -n soft-delete.sh`
2. **Review ShellCheck** output: `make docker-lint`
3. **Verify file permissions** and paths
4. **Clean environment** if needed: `make clean-all`

## Git and Version Control Rules

### Commit Standards
1. **Use conventional commit messages**:
   ```
   type(scope): description

   - Detailed explanation of changes
   - Include breaking changes if any
   ```

2. **Common types**: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

3. **Commit only working code** - all tests must pass

### Branch Management
- Work on `develop` branch for features
- Use `main` for stable releases
- Create feature branches for large changes
- Ensure clean git history

### Continuous Commit Protocol (CRITICAL)
**MANDATORY**: Every change must be committed immediately following these rules:

1. **Immediate Commits**: Use `./scripts/quick-commit.sh` for every change
   ```bash
   # After any file modification
   ./scripts/quick-commit.sh implement parser "add validation logic"
   ./scripts/quick-commit.sh fix bug "handle edge case"
   ./scripts/quick-commit.sh update docs "clarify usage examples"
   ```

2. **Test Result Commits**: Always commit test results immediately
   ```bash
   make docker-test
   ./scripts/quick-commit.sh -t "all tests passing (45/45)"
   # OR if tests fail
   ./scripts/quick-commit.sh -t "3 tests failed in validation module"
   ```

3. **Milestone Checkpoints**: Use `./scripts/checkpoint.sh` for significant progress
   ```bash
   ./scripts/checkpoint.sh "core functionality complete with tests"
   ./scripts/checkpoint.sh -t "feature ready for review"
   ```

4. **NEVER** leave uncommitted changes in working directory
5. **Safe Revert**: Use `git reset --soft HEAD~N` to revert commits while preserving changes

## Communication Rules

### Progress Updates
- Explain what you're doing and why
- Report test results and outcomes
- Highlight any issues or concerns
- Summarize changes made

### Error Reporting
- Provide clear error descriptions
- Include relevant command output
- Suggest potential solutions
- Ask for guidance when uncertain

## Specific Project Rules

### Backup Behavior
- All "deletions" create timestamped backups in `/tmp`
- Preserve original file permissions
- Use atomic move operations
- Provide clear feedback on backup locations

### Testing Requirements
- Maintain 45+ test cases with 100% pass rate
- Include edge cases and error conditions
- Test both short and long command-line options
- Verify backup integrity and permissions

### Build System
- Use Makefile for all build operations
- Copy source to `bin/` directory (don't compile)
- Maintain executable permissions
- Support custom PREFIX for installation

## Emergency Procedures

### If Tests Break
1. **Stop all changes immediately**
2. **Run `make docker-clean`** to reset environment
3. **Restore to last working state** if needed
4. **Investigate cause systematically**
5. **Ask for help** if solution isn't obvious

### If Critical Bug Found
1. **Document the bug** clearly
2. **Create minimal reproduction** case
3. **Write test to reproduce** the issue
4. **Fix the bug** following standard workflow
5. **Verify fix** with comprehensive testing

## Compliance Verification

Before completing any task, verify:
- [ ] All tests pass (`make docker-test`)
- [ ] ShellCheck compliance (`make docker-lint`)
- [ ] Code follows project patterns
- [ ] Documentation is updated
- [ ] Commit message follows standards
- [ ] No files permanently deleted

These rules ensure consistent, safe, and high-quality development practices when working with AI agents in the `soft-delete` project.

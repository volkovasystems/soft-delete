# Dynamic Rules Collection

This file captures rules and best practices extracted from protocols and suggested by Warp.dev agents to prevent repetitive suggestions and build a comprehensive knowledge base.

## Purpose

This file contains:
1. **Protocol-derived rules**: Actionable rules extracted from .warp/protocols/ files
2. **Agent suggestions**: New rules suggested by Warp.dev during interactions
3. **Implementation tracking**: Status of rule adoption and integration

## Rule Categories

### Git and Version Control

#### Atomic Commits (from git-management-protocol.md)
- **Rule**: Every commit must represent a single logical change
- **Context**: Extracted from git-management-protocol.md atomic commit principles
- **Status**: ✅ IMPLEMENTED
- **Location**: Enforced in ai-agent-rules.md continuous commit protocol
- **Rationale**: Ensures clean git history, easier rollbacks, and better collaboration

#### Branch Management (from git-management-protocol.md)
- **Rule**: Always work on 'develop' branch for regular development, never commit directly to 'main'
- **Context**: Extracted from git-management-protocol.md branch usage rules
- **Status**: ✅ IMPLEMENTED
- **Location**: Referenced in ai-agent-rules.md
- **Rationale**: Protects stable main branch and ensures proper release workflow

#### Continuous Commit Strategy (from continuous-commit-protocol.md)
- **Rule**: EVERY change must be committed immediately with WIP/checkpoint prefixes
- **Context**: Extracted from continuous-commit-protocol.md core principle
- **Status**: ✅ IMPLEMENTED
- **Location**: Detailed in ai-agent-rules.md and continuous-commit-protocol.md
- **Rationale**: Never lose work, complete history, safe experimentation

#### Safe Revert Mechanism (from continuous-commit-protocol.md)
- **Rule**: Use `git reset --soft HEAD~N` to revert commits while preserving changes
- **Context**: Extracted from continuous-commit-protocol.md revert procedures
- **Status**: ✅ IMPLEMENTED
- **Location**: continuous-commit-protocol.md methods section
- **Rationale**: Allows undoing commits without losing actual file changes

#### VERSION File Authority (from version-protocol.md)
- **Rule**: /VERSION file is the ONLY source of truth for all version information
- **Context**: Extracted from version-protocol.md core principle
- **Status**: ✅ IMPLEMENTED
- **Location**: version-protocol.md and enforced throughout codebase
- **Rationale**: Eliminates version drift and ensures consistency across repository

### Testing and Quality Assurance

#### Docker-First Testing (from testing-protocol.md)
- **Rule**: Always use `make docker-test` as primary testing method, never skip Docker testing
- **Context**: Extracted from testing-protocol.md primary method
- **Status**: ✅ IMPLEMENTED
- **Location**: testing-protocol.md and ai-agent-rules.md
- **Rationale**: Consistent environment, isolated execution, TAP compliance, includes dependencies

#### 100% Test Pass Rate Requirement (from testing-protocol.md)
- **Rule**: All tests must pass before any commit, no exceptions
- **Context**: Extracted from testing-protocol.md quality gates
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md and testing-protocol.md
- **Rationale**: Maintains code quality and prevents regression

#### Test-Driven Development Workflow (from testing-protocol.md)
- **Rule**: Write tests first when adding features, then implement feature
- **Context**: Extracted from testing-protocol.md development workflow
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md and testing-protocol.md
- **Rationale**: Ensures comprehensive test coverage and better design

#### Comprehensive Test Coverage Areas (from testing-protocol.md)
- **Rule**: Must test CLI parsing, file operations, backup creation, error handling, permissions, edge cases
- **Context**: Extracted from testing-protocol.md required coverage areas
- **Status**: ✅ IMPLEMENTED
- **Location**: testing-protocol.md checklist
- **Rationale**: Ensures all critical functionality is validated

### Code Style and Standards

#### Shell Script Strict Mode (from project-context.md)
- **Rule**: Always use `set -euo pipefail` in all bash scripts
- **Context**: Extracted from project-context.md code quality standards
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md and enforced in codebase
- **Rationale**: Prevents silent failures and improves error handling

#### Variable Quoting (from project-context.md)
- **Rule**: Quote all variables using `"$variable"` syntax
- **Context**: Extracted from project-context.md development guidelines
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md
- **Rationale**: Prevents word splitting and glob expansion issues

#### ShellCheck 100% Compliance (from testing-protocol.md)
- **Rule**: Achieve and maintain 100% ShellCheck compliance, no warnings allowed
- **Context**: Extracted from project-context.md and testing-protocol.md
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md and enforced via `make docker-lint`
- **Rationale**: Ensures code quality and prevents common bash pitfalls

### Documentation and Communication

#### Keep a Changelog Format (from changelog-protocol.md)
- **Rule**: Follow Keep a Changelog format strictly with semantic versioning
- **Context**: Extracted from changelog-protocol.md format standards
- **Status**: ✅ IMPLEMENTED
- **Location**: changelog-protocol.md base format section
- **Rationale**: Provides consistent, professional changelog format

#### No Unreleased Section (from changelog-protocol.md)
- **Rule**: NEVER create "Unreleased" section, all entries must have specific version numbers
- **Context**: Extracted from changelog-protocol.md version management protocol
- **Status**: ✅ IMPLEMENTED
- **Location**: changelog-protocol.md critical rule
- **Rationale**: Ties all changes to specific tagged versions for clarity

#### Changelog Entry Organization (from changelog-protocol.md)
- **Rule**: Group related changes with subheadings (####) by functional area
- **Context**: Extracted from changelog-protocol.md organization principles
- **Status**: ✅ IMPLEMENTED
- **Location**: changelog-protocol.md grouping categories
- **Rationale**: Improves readability and logical organization

#### VERSION File References in Documentation (from version-protocol.md)
- **Rule**: Never hardcode version numbers in documentation, always reference /VERSION file
- **Context**: Extracted from version-protocol.md documentation requirements
- **Status**: ⏳ PENDING IMPLEMENTATION
- **Location**: version-protocol.md documentation section
- **Rationale**: Eliminates version drift between code and documentation

### Security and Safety

#### No Permanent Deletion (from ai-agent-rules.md)
- **Rule**: NEVER permanently delete files, always use project's safe deletion mechanism
- **Context**: Core safety principle for soft-delete project
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md safety first principle
- **Rationale**: Aligns with project purpose and prevents data loss

#### Atomic Move Operations (from project-context.md)
- **Rule**: Use atomic move operations for file handling, preserve permissions
- **Context**: Extracted from project-context.md core architecture
- **Status**: ✅ IMPLEMENTED
- **Location**: Enforced in soft-delete.sh implementation
- **Rationale**: Ensures data integrity and prevents corruption during operations

### Development Workflow

#### Build Before Test Cycle (from ai-agent-rules.md)
- **Rule**: Always run `make build && make docker-test` for development cycle
- **Context**: Extracted from ai-agent-rules.md workflow rules
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md during development section
- **Rationale**: Ensures executable is current before testing

#### Immediate Commit with Descriptive Messages (from continuous-commit-protocol.md)
- **Rule**: Use `./scripts/quick-commit.sh` for immediate commits with WIP/checkpoint patterns
- **Context**: Extracted from continuous-commit-protocol.md workflow implementation
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md and continuous-commit-protocol.md
- **Rationale**: Provides structured immediate commit workflow

#### Helper Script Usage (from continuous-commit-protocol.md)
- **Rule**: Use `./scripts/quick-commit.sh` and `./scripts/checkpoint.sh` for structured commits
- **Context**: Extracted from continuous-commit-protocol.md automation helpers
- **Status**: ✅ IMPLEMENTED
- **Location**: continuous-commit-protocol.md automation section
- **Rationale**: Standardizes commit message format and workflow

#### Clean Working Directory Policy (from continuous-commit-protocol.md)
- **Rule**: NEVER leave uncommitted changes in working directory when completing tasks
- **Context**: Extracted from continuous-commit-protocol.md agent behavior rules
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md and continuous-commit-protocol.md
- **Rationale**: Ensures all work is preserved and traceable

#### No WIP Commits for Agentic AI (from user requirement)
- **Rule**: NEVER use "WIP:" prefix in commit messages - all AI commits should be complete and deliberate
- **Context**: User requirement on 2025-08-31 - WIP commits inappropriate for agentic AI
- **Status**: ✅ IMPLEMENTED
- **Location**: Updated in all protocols and agent rules
- **Rationale**: Agentic AI should make complete, deliberate commits, not "work in progress" - every change is intentional
- **Note**: Historical WIP commits (5 remaining) preserved for git history integrity - all future commits follow proper conventional format

### Project Management

#### Deployment Script Usage (from git-management-protocol.md)
- **Rule**: Use deployment scripts for branch management, never manually checkout staging/release
- **Context**: Extracted from git-management-protocol.md branch protection rules
- **Status**: ✅ IMPLEMENTED
- **Location**: git-management-protocol.md integration section
- **Rationale**: Ensures proper release workflow and prevents manual errors

#### Version Update Workflow (from version-protocol.md)
- **Rule**: Only update VERSION file via `./scripts/version.sh`, never manual edits
- **Context**: Extracted from version-protocol.md file management rules
- **Status**: ✅ IMPLEMENTED
- **Location**: version-protocol.md update workflow section
- **Rationale**: Maintains version consistency and proper automation

#### Quality Gate Compliance (from testing-protocol.md)
- **Rule**: Complete all verification steps before task completion: tests, lint, documentation
- **Context**: Extracted from ai-agent-rules.md compliance verification
- **Status**: ✅ IMPLEMENTED
- **Location**: ai-agent-rules.md verification checklist
- **Rationale**: Ensures consistent quality standards across all work

## How to Use This File

1. **When Warp.dev suggests a new rule**: Add it to the appropriate category above
2. **Include context**: Note why the rule was suggested and in what situation
3. **Mark as implemented**: If you implement the suggestion, mark it as ✅ IMPLEMENTED
4. **Cross-reference**: Link to other protocol files if the rule relates to existing documentation

## Example Entry Format

```markdown
### [Category]
- **Rule**: Brief description of the suggested rule
- **Context**: When/why this was suggested
- **Status**: ✅ IMPLEMENTED / ⏳ PENDING / ❌ REJECTED
- **Location**: Link to where this rule is documented (if implemented)
```

## Auto-Loading Integration

Rules added to this file become part of Warp.dev's context for this repository. This prevents:
- Repetitive suggestions of the same rules
- Loss of valuable insights from agent interactions
- Need to remember which suggestions were already considered

## Maintenance

- Review this file regularly to move implemented rules to appropriate protocol files
- Archive rejected rules with reasoning to prevent future re-suggestions
- Keep the file organized by category for easy reference

---

**Note**: This file grows dynamically based on Warp.dev interactions. It serves as both a capture mechanism for new suggestions and a reference to prevent repetition.

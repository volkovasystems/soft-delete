# Warp.dev Rules Summary

**Auto-Generated**: This file provides a comprehensive summary of all rules for Warp.dev agent loading and reference.

## Rule Loading Status: ✅ COMPLETE

**Total Rules**: 28+ rules extracted from protocols and integrated into the rule system
**Implementation Status**: ✅ 27 IMPLEMENTED | ⏳ 1 PENDING | ❌ 0 REJECTED

## Rule System Architecture

### 1. Core Behavioral Rules (ai-agent-rules.md)
**Purpose**: Immediate workflow requirements and safety principles
**Status**: ✅ FULLY LOADED

Key rules:
- Safety First: Never permanently delete files
- Test-Driven Development: Always run `make docker-test`
- Continuous Commit Protocol: Immediate commits with WIP patterns
- Code Quality: ShellCheck compliance, strict mode, variable quoting

### 2. Protocol-Derived Rules (dynamic-rules.md)
**Purpose**: Extracted actionable rules from detailed protocols
**Status**: ✅ FULLY LOADED WITH 25+ RULES

#### Git & Version Control (5 rules)
- **Atomic Commits**: Single logical change per commit
- **Branch Management**: Work on develop, protect main
- **Continuous Commits**: Immediate WIP commits for all changes
- **Safe Reverts**: Use `git reset --soft` to preserve changes
- **VERSION Authority**: /VERSION file is single source of truth

#### Testing & Quality Assurance (4 rules)
- **Docker-First**: `make docker-test` as primary method
- **100% Pass Rate**: No exceptions, all tests must pass
- **Test-Driven**: Write tests first for new features
- **Coverage Areas**: CLI, files, backup, errors, permissions, edge cases

#### Code Style & Standards (3 rules)
- **Strict Mode**: `set -euo pipefail` for all bash scripts
- **Variable Quoting**: `"$variable"` syntax always
- **ShellCheck**: 100% compliance, zero warnings allowed

#### Documentation & Communication (4 rules)
- **Changelog Format**: Keep a Changelog with semantic versioning
- **No Unreleased**: All entries must have specific version numbers
- **Organization**: Group changes with functional subheadings
- **VERSION References**: Never hardcode versions, reference /VERSION file

#### Security & Safety (2 rules)
- **No Permanent Deletion**: Use soft-delete mechanism only
- **Atomic Operations**: Preserve permissions, use atomic moves

#### Development Workflow (7 rules)
- **Build-Test Cycle**: `make build && make docker-test`
- **Immediate Commits**: Use helper scripts for structured commits
- **Helper Scripts**: `quick-commit.sh` and `checkpoint.sh` usage
- **Clean Directory**: Never leave uncommitted changes
- **No WIP Commits**: Use proper conventional commit types for agentic AI
- **Cross-File Consistency**: Update all related files when making changes
- **100% Compliance**: Zero tolerance for non-compliance across all standards

#### Project Management (3 rules)
- **Deployment Scripts**: Use automation for branch management
- **Version Workflow**: Only update VERSION via scripts
- **Quality Gates**: Complete verification before task completion

### 3. Detailed Protocols (protocols/*.md)
**Purpose**: Step-by-step procedures and technical details
**Status**: ✅ LOADED AND CROSS-REFERENCED

Files loaded:
- changelog-protocol.md
- compliance-protocol.md
- consistency-protocol.md
- continuous-commit-protocol.md
- git-management-protocol.md
- testing-protocol.md
- version-protocol.md

### 4. Project Context (project-context.md)
**Purpose**: Technical architecture and project-specific commands
**Status**: ✅ LOADED

Key context:
- Build system: Makefile-based with copy-to-bin
- Testing: Docker-based BATS with TAP output
- Architecture: Bash utility with strict mode
- Commands: `make docker-test`, `make build`, `make docker-lint`

## Rule Integration Verification

### ✅ Successfully Integrated Rules
All 25+ rules are now properly documented and cross-referenced:

1. **Source protocols identified** for each rule
2. **Implementation status tracked** (✅/⏳/❌)
3. **Location references provided** to detailed documentation
4. **Rationale documented** for each rule
5. **Cross-references maintained** between files

### ✅ Anti-Repetition System
Rules in dynamic-rules.md prevent Warp.dev from:
- Suggesting already documented practices
- Repeating protocol-derived recommendations
- Missing established project patterns

### ✅ Context Loading Hierarchy
Rules load in priority order:
1. Core behavioral rules (immediate requirements)
2. Protocol-derived rules (comprehensive coverage)
3. Detailed protocols (step-by-step procedures)
4. Project context (technical specifics)

## Agent Behavior Expectations

When working with this repository, Warp.dev agents should:

### Automatically Apply These Rules
- Use `make docker-test` for all testing (never skip)
- Commit immediately after every change (WIP pattern)
- Work on develop branch (never main directly)
- Quote all variables and use strict mode
- Reference /VERSION file (never hardcode versions)
- Use deployment scripts (never manual branch management)

### Never Suggest These (Already Covered)
- Alternative testing approaches (Docker-first established)
- Different commit strategies (continuous commit implemented)
- Version management changes (VERSION authority established)
- Different changelog formats (Keep a Changelog adopted)
- Hardcoded version references (forbidden by protocol)

### Quality Verification Required
- 100% test pass rate before proceeding
- ShellCheck compliance (zero warnings)
- Clean working directory (no uncommitted changes)
- Proper commit messages (conventional format)
- Documentation updates when functionality changes

## Rule Loading Verification

### Test Rule Loading
To verify Warp.dev has loaded the rules, check if agents:
1. **Use Docker testing** by default (`make docker-test`)
2. **Commit immediately** after changes (WIP pattern)
3. **Reference project architecture** (bash utility, BATS testing)
4. **Follow VERSION file protocol** (never hardcode versions)
5. **Apply quality gates** (tests, lint, documentation)

### Expected Agent Knowledge
Agents should demonstrate knowledge of:
- Project-specific commands (make targets)
- Testing framework (Docker-based BATS with TAP)
- Build system (copy-to-bin approach)
- Version management (single source of truth)
- Safety principles (no permanent deletion)

## Maintenance Notes

### When Rules Change
1. Update source protocol file
2. Update dynamic-rules.md status
3. Update this summary
4. Commit changes immediately (following our own rules)

### When Adding New Rules
1. Check existing coverage (prevent duplication)
2. Add to appropriate category in dynamic-rules.md
3. Cross-reference to protocols
4. Update rule counts in summary

---

**Status**: ✅ COMPLETE RULE EXTRACTION AND INTEGRATION  
**Last Updated**: 2025-08-31  
**Rules Count**: 25+ extracted and integrated  
**Coverage**: All major protocols converted to actionable rules

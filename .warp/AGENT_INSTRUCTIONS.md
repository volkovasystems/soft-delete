# Agent Instructions for Rule Management

This file provides specific instructions for Warp.dev agents on how to handle rule suggestions and knowledge integration in this repository.

## Rule Suggestion Protocol

### When to Suggest Rules
- **New situations** not covered by existing protocols
- **Best practices** that would benefit the project
- **Industry standards** relevant to the project type
- **Security considerations** not already documented
- **Efficiency improvements** for workflows

### When NOT to Suggest Rules
- **Already documented** in existing `.warp/protocols/` or `.warp/rules/` files
- **Already implemented** in project structure (Makefile, scripts, etc.)
- **Already rejected** (check `.warp/rules/dynamic-rules.md`)

## How to Suggest Rules

### Step 1: Check Existing Documentation
Before suggesting a rule, verify it's not already covered:
```bash
# Check if rule exists in protocols
grep -r "rule concept" .warp/protocols/

# Check if rule exists in rules
grep -r "rule concept" .warp/rules/

# Check if rule is in dynamic rules (including rejected ones)
grep -r "rule concept" .warp/rules/dynamic-rules.md
```

### Step 2: Suggest and Document
If the rule is new:
1. **Make the suggestion** to the user
2. **If accepted**, add it to `.warp/rules/dynamic-rules.md` using the format:

```markdown
### [Category]
- **Rule**: [Brief description]
- **Context**: Suggested during [task/situation] on [date]
- **Status**: ⏳ PENDING IMPLEMENTATION
- **Rationale**: [Why this rule would be beneficial]
```

### Step 3: Integration
Once a rule is accepted and implemented:
1. **Update status** to ✅ IMPLEMENTED
2. **Add location** where rule is documented
3. **Cross-reference** in relevant protocol files
4. **Update this file** if the rule affects agent behavior

## Comprehensive Rule Loading System

### Auto-Loading Hierarchy
Warp.dev automatically loads rules from multiple interconnected files in this priority order:

1. **Core Behavioral Rules** (`.warp/rules/ai-agent-rules.md`)
   - Fundamental workflow and safety principles
   - Immediate action requirements (testing, commits, etc.)
   - Emergency procedures and error handling

2. **Protocol-Derived Rules** (`.warp/rules/dynamic-rules.md`)
   - **20+ extracted rules** from protocol files
   - Implementation status tracking (✅/⏳/❌)
   - Cross-references to source protocols
   - Prevents re-suggestion of established practices

3. **Detailed Protocols** (`.warp/protocols/*.md`)
   - Step-by-step workflow procedures
   - Technical implementation details
   - Quality standards and formatting rules

4. **Project Context** (`.warp/project-context.md`)
   - Technical architecture and commands
   - Build system and testing framework
   - Project-specific patterns

### Current Rule Coverage (25+ Rules Extracted)

#### Git & Version Control (5 rules)
- Atomic commits with single logical changes
- Branch management (develop/main protection)
- Continuous commit strategy (immediate commits)
- Safe revert mechanism (`git reset --soft`)
- VERSION file as single source of truth

#### Testing & Quality Assurance (4 rules)
- Docker-first testing (`make docker-test` primary)
- 100% test pass rate requirement (no exceptions)
- Test-driven development workflow
- Comprehensive coverage areas (CLI, files, backup, errors)

#### Code Style & Standards (3 rules)
- Shell script strict mode (`set -euo pipefail`)
- Variable quoting (`"$variable"` syntax)
- ShellCheck 100% compliance (no warnings)

#### Documentation & Communication (4 rules)
- Keep a Changelog format with semantic versioning
- No "Unreleased" section (version-specific entries only)
- Changelog organization with functional groupings
- VERSION file references (no hardcoded versions)

#### Security & Safety (2 rules)
- No permanent deletion (soft-delete mechanism only)
- Atomic move operations with permission preservation

#### Development Workflow (6 rules)
- Build-before-test cycle (`make build && make docker-test`)
- Immediate commits with helper scripts
- Structured commit patterns (conventional commits)
- Clean working directory policy
- No WIP commits for agentic AI
- Cross-file consistency requirement (all related files updated)

#### Project Management (3 rules)
- Deployment script usage (automated branch management)
- Version update workflow (script-only updates)
- Quality gate compliance verification

### Dynamic Rule Categories

### Current Categories in `.warp/rules/dynamic-rules.md`:
- Git and Version Control (5 extracted rules)
- Testing and Quality Assurance (4 extracted rules)
- Code Style and Standards (3 extracted rules)
- Documentation and Communication (4 extracted rules)
- Security and Safety (2 extracted rules)
- Development Workflow (4 extracted rules)
- Project Management (3 extracted rules)

### Adding New Categories
If a rule doesn't fit existing categories:
1. Create a new category in `dynamic-rules.md`
2. Update this file with the new category
3. Consider if a new protocol file is needed

### Rule Implementation Status
- ✅ **25 rules IMPLEMENTED**: Core behavioral and protocol-derived rules
- ⏳ **1 rule PENDING**: VERSION file documentation references
- ❌ **0 rules REJECTED**: All extracted rules align with project goals

## Rule Templates

Use `.warp/templates/rule-template.md` for detailed rule documentation when:
- Rule is complex and needs examples
- Rule affects multiple files or protocols
- Rule requires specific implementation steps

## Agent Learning Loop

### Information Flow:
1. **Observe** project patterns and user needs
2. **Check** existing documentation for coverage
3. **Suggest** rules that add value
4. **Document** accepted rules in appropriate files
5. **Reference** established rules in future interactions
6. **Avoid** repeating suggestions for documented rules

### Memory Integration:
- **Established rules** become part of agent context
- **Rejected rules** prevent future redundant suggestions
- **Implementation notes** guide future similar situations

## Quality Guidelines

### Good Rule Suggestions:
- **Specific** and actionable
- **Beneficial** to project goals
- **Consistent** with existing patterns
- **Well-reasoned** with clear rationale

### Poor Rule Suggestions:
- **Generic** advice not specific to project
- **Contradictory** to existing patterns
- **Overly complex** for the project scope
- **Already covered** in documentation

## Feedback Loop

### When Rules Are Rejected:
1. **Document rejection** in `dynamic-rules.md` with ❌ REJECTED status
2. **Include reasoning** for rejection
3. **Learn from feedback** to improve future suggestions
4. **Avoid suggesting** similar rules

### When Rules Are Modified:
1. **Update documentation** with changes
2. **Note modifications** in rule history
3. **Adjust future suggestions** based on preferences

## Integration with Continuous Commit Protocol

When documenting rules:
1. **Use quick-commit.sh** for rule additions:
   ```bash
   ./scripts/quick-commit.sh add rule "document new rule for [category]"
   ```

2. **Create checkpoints** for significant rule additions:
   ```bash
   ./scripts/checkpoint.sh "integrated new [category] rules from Warp.dev suggestions"
   ```

This creates a traceable history of rule evolution and agent learning.

---

**Purpose**: Enable intelligent rule suggestion while preventing repetition  
**Maintenance**: Update when new rule categories or processes are added  
**Version**: 1.0

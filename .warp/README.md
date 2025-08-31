# Warp.dev Configuration Directory

This directory contains all Warp.dev-specific configuration files and protocols for the `soft-delete` project.

## File Structure

```
.warp/
├── README.md                    # This file - explains the structure
├── project-context.md           # Main project context (replaces WARP.md)
├── protocols/
│   ├── ai-version-control-protocol.md # AI version control and modification rules
│   ├── changelog-protocol.md    # Changelog management protocol
│   ├── compliance-protocol.md   # 100% compliance standards and verification protocol
│   ├── consistency-protocol.md  # Cross-file consistency protocol  
│   ├── continuous-commit-protocol.md # Continuous commit workflow protocol
│   ├── git-management-protocol.md # Git workflow and branch management protocol
│   ├── structural-alignment-protocol.md # Repository structure documentation sync protocol
│   ├── testing-protocol.md      # Testing workflow protocol
│   └── version-protocol.md      # VERSION file management protocol
├── rules/
│   ├── agent-instructions.md    # Agent behavior and rule suggestion guidelines
│   ├── ai-agent-rules.md        # AI agent behavior rules
│   ├── dynamic-rules.md         # Protocol-derived and suggested rules
│   └── rules-summary.md         # Comprehensive summary of all rules
└── templates/
    └── rule-template.md          # Template for documenting complex rules
```

## Usage

Warp.dev will automatically read these files to understand:
- **Project Context**: Architecture, commands, and workflows
- **Development Protocols**: Standardized procedures for common tasks
- **Rules and Guidelines**: Constraints and best practices
- **Templates**: Consistent formatting for commits, PRs, etc.

## Benefits

1. **Centralized Configuration**: All Warp.dev settings in one place
2. **Version Controlled**: Protocols evolve with the project
3. **Team Consistency**: Shared understanding across developers
4. **Modular Organization**: Easy to maintain and update specific areas
5. **Clear Separation**: Distinct from project documentation

## File Precedence

Warp.dev reads files in this order:
1. `.warp/project-context.md` (main project overview)
2. `.warp/protocols/*.md` (specific workflow protocols)
3. `.warp/rules/*.md` (behavioral rules and constraints)
4. Root-level `WARP.md` (fallback for compatibility)

## Rule Loading System

Warp.dev automatically loads and recognizes established rules from this repository. When new rules are added to the `.warp/` directory structure, they become part of the project's development context.

### Auto-Loading Behavior
- **Protocols** in `.warp/protocols/` define standard workflows
- **Rules** in `.warp/rules/` establish behavioral guidelines
- **Templates** in `.warp/templates/` provide consistent formatting
- **New additions** are automatically incorporated into agent knowledge

This structure ensures comprehensive context while maintaining organization and maintainability.

# Warp.dev Configuration Directory

This directory contains all Warp.dev-specific configuration files and protocols for the `soft-delete` project.

## File Structure

```
.warp/
├── README.md                    # This file - explains the structure
├── project-context.md           # Main project context (replaces WARP.md)
├── protocols/
│   ├── changelog-protocol.md    # Changelog management protocol
│   ├── testing-protocol.md      # Testing workflow protocol
│   ├── deployment-protocol.md   # Deployment and release protocol
│   └── code-style-protocol.md   # Code quality and style guidelines
├── rules/
│   ├── development-rules.md     # Development workflow rules
│   ├── security-rules.md        # Security and safety rules
│   └── ai-agent-rules.md        # AI agent behavior rules
└── templates/
    ├── commit-message.md         # Commit message templates
    ├── changelog-entry.md        # Changelog entry templates
    └── pr-template.md            # Pull request templates
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

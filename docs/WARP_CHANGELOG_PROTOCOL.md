# Warp.dev Changelog Protocol

This document establishes the protocol for updating the CHANGELOG.md file when working in Warp.dev agentic development environments.

## Format Standards

### Base Format
Follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format strictly:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Version] - YYYY-MM-DD

### Added
- For new features

### Changed
- For changes in existing functionality

### Deprecated
- For features soon-to-be removed

### Removed
- For now-removed features

### Fixed
- For any bug fixes

### Security
- For vulnerabilities or mitigations
```

## Section Guidelines

### Added
- **New features** and functionality
- **New files** or scripts
- **New capabilities** or commands
- **New integrations** or tools
- **New documentation** sections

**Format**: Use present tense, be specific about what was added.

**Examples**:
```markdown
- Comprehensive deployment automation system with branch-based workflow
- Version management script (`scripts/version.sh`) with semantic versioning
- Make targets for developer-friendly deployment operations
- Extensive deployment documentation (`docs/DEPLOYMENT.md`)
```

### Changed
- **Modifications** to existing functionality
- **Improvements** to existing features
- **Updates** to dependencies or configurations
- **Refactoring** of code structure

**Format**: Use past tense, explain what changed and why.

**Examples**:
```markdown
- Updated GitHub Actions to latest versions for security improvements
- Reorganized project structure to include comprehensive API reference
- Enhanced error handling and validation throughout deployment process
```

### Fixed
- **Bug fixes** and corrections
- **Issue resolutions**
- **Compatibility fixes**
- **Security patches**

**Format**: Use past tense, describe what was fixed.

**Examples**:
```markdown
- Fixed shellcheck warnings achieving 100% compliance
- Resolved path validation issues for broken symlink handling
- Fixed `.gitignore` patterns to properly handle test artifacts
```

### Security
- **Vulnerability fixes**
- **Security improvements**
- **Permission changes**
- **Authentication updates**

**Format**: Focus on security impact and mitigation.

**Examples**:
```markdown
- Implemented comprehensive vulnerability scanning
- Added protection against path traversal attacks
- Enhanced security-conscious development practices
```

## Version Management Protocol

### Version Numbering
Follow [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html):
- **MAJOR**: Breaking changes, incompatible API changes
- **MINOR**: New features, backwards-compatible additions
- **PATCH**: Bug fixes, backwards-compatible fixes

### Release Date Format
Use ISO 8601 date format: `YYYY-MM-DD`

### Version Structure
Each release should be documented with a complete version entry:

```markdown
## [1.0.0] - 2025-08-31

### Added
- New features for this release

### Changed
- Improvements made in this release

### Fixed
- Bug fixes included in this release
```

## Warp.dev Integration

### Agent Instructions
When updating CHANGELOG.md in Warp.dev:

1. **Check existing format** before making changes
2. **Use uniform formatting** as defined in this protocol
3. **Maintain chronological order** (newest first)
4. **Be specific and descriptive** in entries
5. **Group related changes** under appropriate sections
6. **Use consistent language** and tense

### Commit Protocol
When committing changelog updates:

```bash
# Update version first (if needed)
./scripts/version.sh patch|minor|major

# Update CHANGELOG.md following this protocol

# Commit with structured message
git add CHANGELOG.md
git commit -m "docs: update changelog for version X.Y.Z

- Add comprehensive deployment system features
- Document security improvements and fixes  
- Update version management integration details
- Include developer experience enhancements"
```

### Quality Checks
Before committing changelog updates:

- [ ] **Format consistency** with Keep a Changelog standard
- [ ] **Version numbering** follows semantic versioning
- [ ] **Date format** is ISO 8601 (YYYY-MM-DD)
- [ ] **Section ordering** is correct (Added, Changed, Fixed, Security)
- [ ] **Entry formatting** is consistent and clear
- [ ] **Links work** and references are accurate
- [ ] **Grammar and spelling** are correct

## Examples of Good Entries

### Feature Addition
```markdown
### Added
- Comprehensive deployment automation system with four deployment types
  - Staging deployment with version validation
  - Release deployment with automatic tagging
  - Test deployment for QA environments
  - Version-specific deployment with rollback capabilities
```

### Bug Fix
```markdown
### Fixed
- Resolved shellcheck warnings SC2155 by separating variable declarations
- Fixed Docker compatibility issues with Ubuntu 22.04 (awk → gawk)
- Improved path validation for broken symlink handling (-e AND -L checks)
```

### Security Update
```markdown
### Security
- Updated GitHub Actions to latest secure versions:
  - `actions/checkout@v4` → `v5`
  - `actions/cache@v3` → `v4`
  - `softprops/action-gh-release@v1` → `v2`
- Added explicit permissions and timeout limits for workflow security
```

## Bad Examples (Avoid These)

### Too Vague
```markdown
### Added
- Some new features
- Better stuff
- More tools
```

### Wrong Tense/Format
```markdown
### Added
- Will add deployment system
- Adding new features
- TODO: Fix bugs
```

### Mixed Categories
```markdown
### Added
- New deployment system
- Fixed broken tests  <!-- This should be in Fixed -->
- Updated documentation  <!-- This should be in Changed -->
```

## Automation Integration

### With Version Script
```bash
# Update version and changelog together
make version-minor
# Then update CHANGELOG.md manually following protocol
git add CHANGELOG.md VERSION
git commit -m "chore: bump version to X.Y.Z with changelog updates"
```

### With Deployment System
```bash
# Before deployment, ensure changelog is current
./scripts/deploy.sh deploy-version X.Y.Z
# Deployment will check version consistency
```

## Maintenance

### Regular Reviews
- **Monthly**: Review changelog for consistency
- **Before releases**: Ensure all changes are documented
- **After major features**: Update current release entry

### Link Updates
Maintain working links to:
- **Keep a Changelog**: https://keepachangelog.com/en/1.0.0/
- **Semantic Versioning**: https://semver.org/spec/v2.0.0.html
- **Project repository**: Update when repository changes

This protocol ensures consistent, professional changelog maintenance in Warp.dev agentic development environments.

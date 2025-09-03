# Warp.dev Changelog Protocol (AI Version Control Aligned)

**CRITICAL**: This protocol is strictly aligned with the AI Version Control Protocol. AI systems are FORBIDDEN from creating version sections or modifying version-related content.

## Core Philosophy

**NO "UNRELEASED" SECTIONS ALLOWED**

This project follows a strict version-based changelog approach:
- The VERSION file contains the current working version
- If no git tag exists for that version = it represents unreleased work
- All changelog entries go into the current version section
- Only developers can create new version sections via git tags

## Format Standards

### Base Format
Follow [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format with VERSION-BASED sections only:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - YYYY-MM-DD

### Added
- New features added to this version

### Changed
- Changes made to existing functionality

### Fixed
- Bug fixes included in this version

### Security
- Security improvements for this version
```

## Organization Principles

### Grouping and Structure
- **Use subheadings (####)** to group related items within sections
- **Organize by functional area** (Core Features, Development Infrastructure, Documentation, etc.)
- **Keep entries concise** but descriptive enough to be meaningful
- **Avoid excessive detail** - focus on user/developer impact
- **Group related changes** logically rather than chronologically

### Common Grouping Categories
- **Core Features**: Main functionality and user-facing features
- **Development Infrastructure**: Testing, build systems, CI/CD
- **Documentation**: Guides, API docs, README updates
- **Utility Scripts**: Helper scripts and tools
- **Build & Automation**: Makefile, packaging, installation
- **Configuration**: Config files, linting, formatting

## Section Guidelines

### Added
- **New features** and functionality
- **New files** or scripts
- **New capabilities** or commands
- **New integrations** or tools
- **New documentation** sections

**Format**: Use present tense, be specific about what was added. Group related items using subheadings (####) for better organization.

**Examples**:
```markdown
#### Core Features
- Safe file deletion with timestamped backups in `/tmp`
- Command-line interface with comprehensive options
- File permission preservation and atomic move operations

#### Development Infrastructure
- Docker-based testing environment with TAP compliance
- Comprehensive test suite with 45 test cases achieving 100% pass rate
- ShellCheck configuration achieving 100% compliance

#### Deployment System
- Complete deployment script (`scripts/deploy.sh`) with branch-based workflow
- Four deployment types: staging, release, test, and version-specific
- Automated develop → staging → release workflow
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

### Unreleased Entries Policy
**CRITICAL RULE**: **NEVER** create an "Unreleased" section in the changelog.

**VERSION-BASED APPROACH**:
- All changelog entries MUST be associated with the current version in the VERSION file
- If no git tag exists for that version = the version represents "unreleased" work
- AI systems add entries to the CURRENT version section only
- Only developers can create NEW version sections (when they tag releases)
- Changes are documented immediately in the current working version

**Current Version Logic**:
- Read version from `/VERSION` file (e.g., "1.0.0")
- Check if git tag `v1.0.0` exists
- If NO tag exists = version 1.0.0 is the current "unreleased" working version
- All new entries go into the `## [1.0.0] - YYYY-MM-DD` section
- When developer creates git tag `v1.0.0` = that version becomes "released"

**Rationale**: This eliminates the need for "Unreleased" sections while maintaining clear version tracking. The VERSION file always represents the current working version, and git tags determine release status.

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

## AI System Restrictions

### FORBIDDEN Operations for AI Systems

**AI systems SHALL NEVER**:
- Create new version sections (e.g., `## [1.1.0]`)
- Modify version numbers in existing sections
- Create "Unreleased" sections
- Update the VERSION file
- Determine when to increment versions
- Create or suggest git tags
- Modify version-related dates

**AI systems MAY ONLY**:
- Add entries to the CURRENT version section (as specified in VERSION file)
- Format entries according to this protocol
- Categorize entries (Added, Changed, Fixed, Security)
- Auto-detect categories from conventional commit formats

### Enforcement Mechanism

The changelog management script (`scripts/changelog.sh`) contains:
- Version protection that blocks AI from creating new versions
- Automatic detection of current version from VERSION file
- Validation that prevents forbidden operations

**Violation Response**:
```
❌ PROTOCOL VIOLATION: AI systems cannot create new version sections
❌ Only developers can update version numbers per AI Version Control Protocol
❌ Current version in VERSION file: 1.0.0
ℹ️  AI must add entries to existing version: 1.0.0
```

## Warp.dev Integration

### Agent Instructions
When updating CHANGELOG.md in Warp.dev:

1. **Read VERSION file** to determine current version
2. **Check existing format** before making changes
3. **Add entries to current version ONLY** (never create new versions)
4. **Use uniform formatting** as defined in this protocol
5. **Maintain chronological order** (newest first)
6. **Be specific and descriptive** in entries
7. **Group related changes** under appropriate sections
8. **Use consistent language** and tense

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

## Protocol Integration and Compliance

### Integration with AI Version Control Protocol

This changelog protocol is **STRICTLY ALIGNED** with:
- `.warp/protocols/ai-version-control-protocol.md`
- `.warp/protocols/version-protocol.md`

**Key Integration Points**:
1. **VERSION File Authority**: Only the VERSION file determines the current working version
2. **AI Restrictions**: AI systems cannot create new version sections or modify version numbers
3. **Developer Control**: Only developers can increment versions using `./scripts/version.sh`
4. **Git Tag Logic**: Absence of git tag for current version = "unreleased" status
5. **Automated Enforcement**: Scripts contain protocol violations checks and blocks

### Compliance Validation

**Required Checks**:
- ✅ No [Unreleased] sections exist in changelog
- ✅ All entries are associated with specific version numbers
- ✅ Current version entries match VERSION file content
- ✅ AI systems cannot access version creation functions
- ✅ Changelog validation passes protocol requirements

**Validation Command**:
```bash
./scripts/changelog.sh validate
# Must return: ✅ No forbidden [Unreleased] sections found
```

### Protocol Enforcement

**Automatic Enforcement via**:
- `scripts/changelog.sh` - Version protection and validation
- `Makefile` - Restricted targets for AI systems
- `.githooks/pre-commit` - Format validation on commits
- Documentation - Clear AI system restrictions

**Manual Enforcement**:
- Code reviews must verify no [Unreleased] sections
- Deployment checks validate version consistency
- Regular protocol compliance audits

---

**EFFECTIVE DATE**: 2025-09-01
**PROTOCOL VERSION**: 2.0.0 (AI Version Control Aligned)
**ENFORCEMENT**: IMMEDIATE AND ABSOLUTE

This protocol ensures consistent, professional changelog maintenance in Warp.dev agentic development environments while maintaining strict adherence to AI Version Control restrictions.

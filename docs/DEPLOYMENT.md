# Deployment Guide

This document provides comprehensive guidance for using the automated deployment system in the soft-delete project.

## Table of Contents

- [Overview](#overview)
- [Branch Strategy](#branch-strategy)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Commands](#deployment-commands)
- [Revert Commands](#revert-commands)
- [Version Management](#version-management)
- [Workflows](#workflows)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Overview

The deployment automation system provides safe, reliable deployments across multiple branches with built-in version management, tagging, and revert capabilities. It follows a `develop -> staging -> release` workflow with automatic synchronization of `master` and `main` branches.

### Key Features

- ✅ **Automated branch deployments** with overwrite protection
- ✅ **Version validation** before deployments
- ✅ **Semantic version tagging** on releases
- ✅ **Master/main synchronization** with release branch
- ✅ **Comprehensive revert capabilities** for all deployment types
- ✅ **Dry-run support** for testing deployments
- ✅ **Remote connectivity verification** before operations
- ✅ **State tracking** for deployment history and rollbacks

## Branch Strategy

The project uses the following branch structure:

```
develop ──────────────► staging ──────────────► release
                            │                       │
                            ▼                       ▼
                         test                   master/main
```

### Branch Roles

| Branch    | Purpose                           | Developers Can Work |
|-----------|-----------------------------------|---------------------|
| `develop` | Main development branch           | ✅ Yes              |
| `staging` | Pre-production testing            | ✅ Yes              |
| `test`    | QA and testing branch             | ✅ Yes              |
| `release` | Production releases               | ✅ Yes              |
| `master`  | Synchronized with release         | ❌ Auto-managed     |
| `main`    | Synchronized with release         | ❌ Auto-managed     |

## Prerequisites

Before using the deployment system, ensure:

1. **Git repository** is properly configured with remote access
2. **Version file** (`VERSION`) exists in the project root
3. **Clean working directory** (no uncommitted changes)
4. **Remote push access** to all target branches
5. **Version script** (`scripts/version.sh`) is available

## Quick Start

### 1. Deploy to Staging

```bash
# Check current status
./scripts/deploy.sh status

# Update version first (required for staging deployment)
./scripts/version.sh patch  # or minor/major

# Deploy to staging
./scripts/deploy.sh deploy-staging

# Or using Make
make deploy-staging
```

### 2. Deploy to Release

```bash
# Deploy staging to release (creates tags, updates master/main)
./scripts/deploy.sh deploy-release

# Or using Make
make deploy-release
```

### 3. Deploy Specific Version

```bash
# Deploy version 1.2.3 through staging to release
./scripts/deploy.sh deploy-version 1.2.3
```

## Deployment Commands

### deploy-staging

Deploys `develop` branch to `staging` branch.

```bash
./scripts/deploy.sh deploy-staging [OPTIONS]
make deploy-staging
```

**Requirements:**
- Version must be updated from previous staging version
- Working directory must be clean
- Remote access must be available

**What it does:**
1. Validates version was updated
2. Force merges `develop` → `staging`
3. Pushes `staging` to remote
4. Saves deployment state for potential revert

### deploy-release

Deploys `staging` branch to `release` branch.

```bash
./scripts/deploy.sh deploy-release [OPTIONS]
make deploy-release
```

**Requirements:**
- Version must be updated from previous release version
- Working directory must be clean
- Remote access must be available

**What it does:**
1. Validates version was updated
2. Force merges `staging` → `release`
3. Creates and pushes version tag (e.g., `v1.2.3`)
4. Updates `master` and `main` branches with `release`
5. Pushes all branches to remote
6. Saves deployment state for potential revert

### deploy-test

Deploys `develop` branch to `test` branch.

```bash
./scripts/deploy.sh deploy-test [OPTIONS]
make deploy-test
```

**Requirements:**
- Working directory must be clean
- Remote access must be available

**What it does:**
1. Force merges `develop` → `test`
2. Pushes `test` to remote
3. Saves deployment state for potential revert

### deploy-version

Deploys a specific version through the full pipeline.

```bash
./scripts/deploy.sh deploy-version VERSION [OPTIONS]
```

**Example:**
```bash
./scripts/deploy.sh deploy-version 1.2.3
```

**Requirements:**
- Valid semantic version format (MAJOR.MINOR.PATCH)
- Working directory must be clean
- Remote access must be available

**What it does:**
1. Updates VERSION file to specified version
2. Commits version change to `develop`
3. Deploys `develop` → `staging`
4. Deploys `staging` → `release`
5. Creates version tag and updates `master`/`main`
6. Saves comprehensive deployment state

## Revert Commands

All deployment operations can be reverted using dedicated revert commands.

### revert-staging

Reverts the last staging deployment.

```bash
./scripts/deploy.sh revert-staging
make revert-staging
```

### revert-release

Reverts the last release deployment (including tags and master/main updates).

```bash
./scripts/deploy.sh revert-release
make revert-release
```

⚠️ **Warning:** This is a destructive operation that removes version tags.

### revert-test

Reverts the last test deployment.

```bash
./scripts/deploy.sh revert-test
make revert-test
```

### revert-version

Completely reverts a version deployment.

```bash
./scripts/deploy.sh revert-version
```

⚠️ **Warning:** This reverts the entire version deployment including:
- Version file changes
- All branch deployments
- Version tags
- Master/main updates

## Version Management

The deployment system integrates with the version management system:

```bash
# Check current version
./scripts/version.sh show
make version-show

# Update version before deployment
./scripts/version.sh patch    # 1.0.0 → 1.0.1
./scripts/version.sh minor    # 1.0.0 → 1.1.0  
./scripts/version.sh major    # 1.0.0 → 2.0.0

# Or using Make
make version-patch
make version-minor
make version-major
```

## Workflows

### Standard Development Workflow

```bash
# 1. Work on develop branch
git checkout develop
# ... make changes ...
git commit -m "feat: new feature"

# 2. Update version
make version-patch

# 3. Deploy to staging for testing
make deploy-staging

# 4. Test on staging environment
# ... testing ...

# 5. Deploy to production
make deploy-release
```

### Hotfix Workflow

```bash
# 1. Create hotfix version
./scripts/deploy.sh deploy-version 1.2.4

# This automatically:
# - Updates VERSION to 1.2.4
# - Deploys through staging to release
# - Tags v1.2.4
# - Updates master/main
```

### Emergency Rollback

```bash
# Check what's deployed
./scripts/deploy.sh status

# Revert last release
./scripts/deploy.sh revert-release

# Or revert specific deployment type
./scripts/deploy.sh revert-staging
./scripts/deploy.sh revert-test
```

## Command Options

All deployment commands support these options:

| Option          | Description                              | Example                           |
|----------------|------------------------------------------|-----------------------------------|
| `-n, --dry-run` | Show what would be done without changes | `deploy.sh deploy-staging -n`    |
| `-v, --verbose` | Enable verbose output                   | `deploy.sh deploy-release -v`    |
| `-f, --force`   | Skip safety checks (use carefully)     | `deploy.sh deploy-staging -f`    |
| `-h, --help`    | Show help message                       | `deploy.sh --help`               |

## Troubleshooting

### Common Issues

#### "Working directory is not clean"

```bash
# Check what's uncommitted
git status

# Either commit changes
git add .
git commit -m "description"

# Or stash them
git stash push -m "work in progress"
```

#### "Version not updated"

```bash
# Update version before deployment
./scripts/version.sh patch
# Then try deployment again
./scripts/deploy.sh deploy-staging
```

#### "Cannot push to remote"

```bash
# Check remote connectivity
git remote -v

# Test remote access
git fetch origin --dry-run

# Check credentials
git push origin develop --dry-run
```

#### "Branch does not exist"

The script will automatically create missing local branches from remote. If the branch doesn't exist remotely, you'll need to create it:

```bash
# Create missing branch
git checkout -b staging develop
git push -u origin staging
```

### Recovery Procedures

#### Lost deployment state

If deployment state files are lost, you can manually clean up:

```bash
# Clean all deployment state
./scripts/deploy.sh cleanup

# Or remove manually
rm -rf .deploy/
```

#### Broken deployment

```bash
# Check current status
./scripts/deploy.sh status

# Use appropriate revert command
./scripts/deploy.sh revert-staging   # or revert-release, etc.

# If revert fails, manual recovery:
git checkout staging
git reset --hard origin/staging  # Reset to remote state
```

## Best Practices

### Before Deployment

1. **Always test locally** before deploying
2. **Update version** appropriately (patch/minor/major)
3. **Use dry-run** to preview changes: `deploy.sh deploy-staging -n`
4. **Check deployment status**: `deploy.sh status`
5. **Ensure clean working directory**: `git status`

### During Deployment

1. **Monitor the output** for any errors
2. **Test the staging environment** before releasing
3. **Verify version tags** are created correctly
4. **Check all branches** are updated as expected

### After Deployment

1. **Verify deployment** in target environment
2. **Test critical functionality** 
3. **Monitor for issues** 
4. **Keep deployment state** until confident
5. **Clean up state** after successful verification: `deploy.sh cleanup`

### Emergency Procedures

1. **Have revert plan ready** before deploying
2. **Know your revert commands** for each deployment type
3. **Test revert procedures** in non-production environments
4. **Keep communication channels** open during deployments
5. **Document any issues** encountered for future reference

## Integration with CI/CD

The deployment scripts can be integrated with CI/CD systems:

```yaml
# Example GitHub Actions workflow
name: Deploy to Staging
on:
  push:
    branches: [develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to staging
        run: |
          ./scripts/version.sh patch
          ./scripts/deploy.sh deploy-staging
```

## Support

For deployment issues:

1. Check this documentation
2. Review deployment logs
3. Use `./scripts/deploy.sh status` to check current state
4. Try dry-run mode to test: `./scripts/deploy.sh deploy-staging -n`
5. Contact the development team

Remember: **Always prefer revert over manual fixes** to maintain consistency and traceability.

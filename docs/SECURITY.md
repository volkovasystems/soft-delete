# Security Policy

## Supported Versions

We provide security updates for the following versions of soft-delete:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Security Features

### Built-in Security Measures

- **No Permanent Deletion**: Files are moved to timestamped backup locations, preventing accidental data loss
- **Path Validation**: Comprehensive input validation prevents path traversal attacks
- **Permission Preservation**: Original file permissions are maintained during backup operations
- **Atomic Operations**: File moves are atomic to prevent partial operations during failures
- **Strict Bash Mode**: All scripts use `set -euo pipefail` for error handling
- **Input Sanitization**: All user inputs are validated and sanitized

### Security Scanning

This repository includes automated security scanning:

- **Vulnerability Detection**: Regular scans for known vulnerabilities
- **Credential Scanning**: Prevention of hardcoded secrets in source code
- **Path Traversal Protection**: Detection of directory traversal attempts
- **Shell Script Security**: ShellCheck integration for bash security best practices

## Reporting a Vulnerability

### How to Report

If you discover a security vulnerability in soft-delete, please report it responsibly:

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Email security reports to: [richeve.bebedor@gmail.com](mailto:richeve.bebedor@gmail.com)
3. Include "SECURITY" in the subject line
4. Provide detailed information about the vulnerability

### What to Include

Please include the following information in your security report:

- **Description**: Clear description of the vulnerability
- **Impact**: Potential impact and severity assessment
- **Reproduction**: Step-by-step instructions to reproduce the issue
- **Environment**: Operating system, shell version, and soft-delete version
- **Suggested Fix**: If you have ideas for fixing the vulnerability

### Response Timeline

We are committed to addressing security issues promptly:

- **Initial Response**: Within 48 hours of receiving your report
- **Assessment**: Initial assessment within 5 business days
- **Fix Development**: Security fixes prioritized over other development
- **Disclosure**: Coordinated disclosure once fix is available

### Example Report Template

```
Subject: SECURITY - [Brief Description]

**Vulnerability Description:**
[Detailed description of the security issue]

**Impact Assessment:**
[Potential impact: Low/Medium/High/Critical]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Environment:**
- OS: [e.g., Ubuntu 22.04]
- Shell: [e.g., bash 5.1.8]
- soft-delete version: [e.g., 1.0.0]

**Suggested Mitigation:**
[Any suggestions for fixing the issue]
```

## Security Best Practices

### For Users

1. **Regular Updates**: Keep soft-delete updated to the latest version
2. **Verify Installation**: Use official installation methods (Homebrew, GitHub releases)
3. **Check Permissions**: Ensure proper file permissions on the installed binary
4. **Backup Cleanup**: Regularly clean old backup directories in `/tmp`
5. **Input Validation**: Be cautious with special characters in filenames

### For Contributors

1. **Secure Development**: Follow secure coding practices for bash scripts
2. **Input Validation**: Always validate and sanitize user inputs
3. **Error Handling**: Use proper error handling (`set -euo pipefail`)
4. **Secret Management**: Never commit secrets or credentials
5. **Testing**: Include security test cases for new features
6. **Code Review**: All security-related changes require thorough review

## Security Testing

### Automated Security Checks

Run the security scanner to check for vulnerabilities:

```bash
# Run comprehensive security scan
./scripts/security-scan.sh

# Run specific security checks
./scripts/security-scan.sh --credentials
./scripts/security-scan.sh --path-traversal
./scripts/security-scan.sh --git-history
```

### Manual Security Testing

1. **Path Traversal Testing**:
   ```bash
   # Test with various path traversal attempts
   soft-delete "../../../etc/passwd"
   soft-delete "../../sensitive-file"
   ```

2. **Special Character Testing**:
   ```bash
   # Test with special characters
   soft-delete "file with spaces"
   soft-delete "file;rm -rf /"
   soft-delete $'file\nwith\nnewlines'
   ```

3. **Permission Testing**:
   ```bash
   # Test with various file permissions
   touch test-file
   chmod 000 test-file
   soft-delete test-file
   ```

### Security Checklist for Releases

Before each release, ensure:

- [ ] All security scans pass without critical issues
- [ ] No hardcoded credentials or secrets in code
- [ ] All user inputs are properly validated
- [ ] Path traversal protection is functional
- [ ] File permissions are correctly handled
- [ ] Error messages don't leak sensitive information
- [ ] Dependencies are up-to-date and secure
- [ ] Security documentation is current

## Known Security Considerations

### Temporary Directory Usage

- soft-delete uses `/tmp` for backup storage
- Files in `/tmp` may be world-readable depending on system configuration
- Users should be aware of this when deleting sensitive files
- Consider system-specific `/tmp` configurations (tmpfs, permissions)

### Symlink Handling

- soft-delete can handle symbolic links
- Broken symlinks are detected and handled safely
- No automatic following of symlinks outside intended paths

### Race Conditions

- Atomic move operations prevent most race conditions
- Unique timestamp + random string prevents backup directory collisions
- File existence checks are performed before operations

## Security Contact

For security-related questions or concerns:

- **Email**: [richeve.bebedor@gmail.com](mailto:richeve.bebedor@gmail.com)
- **Subject**: Include "SECURITY" in the subject line
- **Response Time**: Within 48 hours for security issues

## Acknowledgments

We appreciate security researchers who responsibly disclose vulnerabilities. Contributors who report valid security issues will be acknowledged in our security advisories (with their permission).

---

**Note**: This security policy is subject to updates. Please check the latest version in the repository for the most current information.

*Last updated: 2025-08-31*

# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| 1.0.x   | Yes       |

## Reporting a Vulnerability

**Do not report security vulnerabilities through public GitHub issues.**

Instead, please use [GitHub's private vulnerability reporting](https://github.com/kmmuntasir/ccs/security/advisories/new) to disclose security issues responsibly.

### What to include

- A description of the vulnerability
- Steps to reproduce
- The affected version (run `ccs --version`)
- Your OS and shell environment
- If applicable, a suggested fix

### Response timeline

- **Acknowledgment** within 48 hours
- **Initial assessment** within 5 business days
- **Fix or mitigation plan** communicated as soon as the issue is confirmed

### Scope

Security issues relevant to this project include:

- Accidental exposure of API keys or auth tokens in logs, output, or files
- Injection vulnerabilities in shell scripts (command injection via user input)
- Unsafe handling of temporary files
- Privilege escalation in install/uninstall scripts

General questions or non-sensitive bug reports should use the normal [issue tracker](https://github.com/kmmuntasir/ccs/issues).

# Open Source Readiness Plan

This plan covers everything needed to give CCS a polished, professional open source presence. Each item is ordered by priority within its category.

---

## 1. README Improvements

### 1.1 Add CI Status Badge
Add a GitHub Actions workflow status badge as the first badge in the existing badge row:
```markdown
[![Lint](https://github.com/kmmuntasir/ccs/actions/workflows/lint.yml/badge.svg)](https://github.com/kmmuntasir/ccs/actions/workflows/lint.yml)
```

### 1.2 Add "Why ccs?" Section
Insert between the tagline and the Demo section. This gives visitors an instant reason to care:
```markdown
## Why ccs?

If you use multiple Claude API providers (Anthropic, OpenRouter, Z.AI, etc.), switching between them means manually editing `~/.claude/settings.json` every time. CCS makes this a single command.
```

### 1.3 Improve Demo Section
- Replace the plain text block with a proper `console` code fence (syntax highlighting)
- Add an actual screenshot or animated GIF placeholder (`docs/demo.gif`)
- Add a "Demo" heading with an image embed above the text block

### 1.4 Add Troubleshooting Section
Add before the Contributing section:
```markdown
## Troubleshooting

<details>
<summary><strong>jq not found</strong></summary>

CCS requires `jq`. Re-run the installer or install manually:
  brew install jq   # macOS
  sudo apt install jq  # Linux
</details>

<details>
<summary><strong>ccs: command not found</strong></summary>

The shell function wasn't added or your shell wasn't restarted:
  source ~/.bashrc   # or ~/.zshrc
</details>

<details>
<summary><strong>Settings not taking effect</strong></summary>

Restart Claude Code after switching providers.
</details>
```

### 1.5 Add Acknowledgments Section
Before the License section:
```markdown
## Acknowledgments

Built with [jq](https://jqlang.github.io/jq/) and [ShellCheck](https://www.shellcheck.net/).
```

### 1.6 Link to Changelog
Add a one-liner in the Table of Contents or at the bottom:
```markdown
See [CHANGELOG.md](CHANGELOG.md) for release history.
```

---

## 2. New Files to Create

### 2.1 `.editorconfig`
Enforces consistent coding style across all editors and contributors:
```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.sh]
indent_style = space
indent_size = 4

[*.json]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false

[*.yml]
indent_style = space
indent_size = 2
```

### 2.2 `CODEOWNERS`
Defines code review ownership:
```
# Default owners for everything
* @kmmuntasir
```

### 2.3 `SUPPORT.md`
GitHub displays this when users file issues. Provides support channels:
```markdown
# Support

## Quick Help
- Check the [README](README.md) for usage instructions
- Check the [Troubleshooting](README.md#troubleshooting) section

## Questions
Open a [GitHub Discussion](https://github.com/kmmuntasir/ccs/discussions) or an [issue](https://github.com/kmmuntasir/ccs/issues/new).

## Security Issues
See [SECURITY.md](SECURITY.md). Do NOT report security vulnerabilities in public issues.
```

### 2.4 `Makefile`
Standardizes common development tasks. Signals project maturity:
```makefile
.PHONY: lint test install clean

lint:
	shellcheck *.sh
	bashate *.sh

test:
	@echo "No tests yet."

install:
	./install.sh

clean:
	rm -f *.tmp *.bak
```

### 2.5 `.github/ISSUE_TEMPLATE/question.yml`
Adds a structured "Question" issue type alongside bug reports and feature requests:
```yaml
name: Question
description: Ask a question about CCS usage or configuration
labels: ["question"]
body:
  - type: textarea
    id: question
    attributes:
      label: Your Question
      description: What would you like to know?
    validations:
      required: true
  - type: textarea
    id: context
    attributes:
      label: Context
      description: What have you already tried? What docs did you check?
    validations:
      required: false
```

### 2.6 `.github/workflows/release.yml`
Automates GitHub Releases when a version tag is pushed:
```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Get version
        id: version
        run: echo "VERSION=$(cat VERSION)" >> "$GITHUB_OUTPUT"

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: v${{ steps.version.outputs.VERSION }}
          name: v${{ steps.version.outputs.VERSION }}
          body_path: CHANGELOG.md
```

### 2.7 `.github/workflows/stale.yml`
Automatically marks inactive issues and PRs as stale. Shows the project is actively maintained:
```yaml
name: Stale

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday

permissions:
  issues: write
  pull-requests: write

jobs:
  stale:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/stale@v9
        with:
          days-before-stale: 60
          days-before-close: 7
          stale-issue-label: stale
          stale-pr-label: stale
          stale-issue-message: 'This issue has been inactive for 60 days and will be closed in 7 days if there is no further activity.'
          stale-pr-message: 'This PR has been inactive for 60 days and will be closed in 7 days if there is no further activity.'
          exempt-issue-labels: pinned
          exempt-pr-labels: pinned
```

---

## 3. Existing Files to Update

### 3.1 `.github/ISSUE_TEMPLATE/config.yml`
Add the Discussions and Security links alongside the existing Documentation link:
```yaml
blank_issues_enabled: false
contact_links:
  - name: Documentation
    url: https://github.com/kmmuntasir/ccs#readme
    about: Check the README for usage instructions and configuration details.
  - name: Question
    url: https://github.com/kmmuntasir/ccs/discussions
    about: Ask a question or start a discussion.
  - name: Security Vulnerability
    url: https://github.com/kmmuntasir/ccs/security/advisories/new
    about: Report security issues privately.
```
Note: Change `blank_issues_enabled` from `true` to `false` so users are guided to the right template.

### 3.2 `.github/workflows/lint.yml`
Minor improvements:
- Add `permissions: read-all` for least-privilege
- Pin ShellCheck action or version for reproducibility
- Add `shellcheck -s bash -S warning *.sh` with explicit shell and severity

### 3.3 `.github/FUNDING.yml`
Add more funding platforms if applicable:
```yaml
github: kmmuntasir
# Add if applicable:
# ko_fi: kmmuntasir
# buy_me_a_coffee: kmmuntasir
```

### 3.4 `install.sh`
- Line 89: `add_alias "$HOME/.fish"` looks wrong. Fish shell config is typically `~/.config/fish/config.fish`, which is handled on line 92. The `$HOME/.fish` path is non-standard. Should be removed or corrected.

### 3.5 `uninstall.sh`
- Line 41: Same issue — `remove_alias "$HOME/.fish"` references a non-standard path. Should be removed.

### 3.6 `.gitignore`
Add common entries:
```
# Distribution/install artifacts
dist/

# Test artifacts
test-results/
```

### 3.7 `CHANGELOG.md`
- Verify the date `2025-05-07` is intentional. If the project was created in 2026, correct it to `2026-05-07`.

---

## 4. GitHub Repository Settings (Manual Steps)

These are done through the GitHub UI, not files:

### 4.1 About Section
Set the repository description and website:
- **Description**: `One command to switch between Claude API providers in Claude Code CLI`
- **Website**: Leave blank or link to the README
- **Topics**: `claude`, `claude-code`, `anthropic`, `api-provider`, `cli`, `bash`, `shell-script`, `developer-tools`

### 4.2 Enable Features
In repository Settings:
- [x] Issues (already enabled — templates exist)
- [x] Discussions (enable if community grows)
- [ ] Projects (optional)
- [x] Wiki (disable — README and docs in repo are sufficient)

### 4.3 Branch Protection
- Require PR reviews for `main` branch
- Require status checks (Lint workflow) to pass
- Require linear history

### 4.4 Create Initial Release
After pushing, create a GitHub Release v1.0.0:
- Tag: `v1.0.0`
- Title: `v1.0.0 — Initial Release`
- Body: Copy from CHANGELOG.md

### 4.5 Social Proof
- Pin the repository to your GitHub profile
- Add the repo link in your GitHub bio
- Share in relevant communities (Reddit r/ClaudeAI, Hacker News, etc.)

---

## 5. Summary of All Changes

| # | Action | File | Priority |
|---|--------|------|----------|
| 1 | Add CI badge | `README.md` | High |
| 2 | Add "Why ccs?" section | `README.md` | High |
| 3 | Add demo screenshot/GIF placeholder | `README.md` | High |
| 4 | Add troubleshooting section | `README.md` | High |
| 5 | Add acknowledgments | `README.md` | Medium |
| 6 | Link to changelog | `README.md` | Medium |
| 7 | Create `.editorconfig` | `.editorconfig` | High |
| 8 | Create `CODEOWNERS` | `CODEOWNERS` | Medium |
| 9 | Create `SUPPORT.md` | `SUPPORT.md` | Medium |
| 10 | Create `Makefile` | `Makefile` | Medium |
| 11 | Create question template | `.github/ISSUE_TEMPLATE/question.yml` | Medium |
| 12 | Create release workflow | `.github/workflows/release.yml` | High |
| 13 | Create stale workflow | `.github/workflows/stale.yml` | Low |
| 14 | Update issue template config | `.github/ISSUE_TEMPLATE/config.yml` | High |
| 15 | Improve lint workflow | `.github/workflows/lint.yml` | Low |
| 16 | Fix `$HOME/.fish` path | `install.sh`, `uninstall.sh` | High |
| 17 | Update `.gitignore` | `.gitignore` | Low |
| 18 | Verify CHANGELOG date | `CHANGELOG.md` | Medium |
| 19 | Configure repo settings | GitHub UI | High |
| 20 | Create v1.0.0 release | GitHub UI | High |

---

## 6. Implementation Order

**Phase 1 — Core polish (do first)**:
1. Fix `install.sh` and `uninstall.sh` fish path bug (#16)
2. Verify/correct CHANGELOG date (#18)
3. Add CI badge to README (#1)
4. Add "Why ccs?" section (#2)
5. Add troubleshooting to README (#4)
6. Update `.github/ISSUE_TEMPLATE/config.yml` (#14)
7. Create `.editorconfig` (#7)

**Phase 2 — Infrastructure**:
8. Create release workflow (#12)
9. Create `SUPPORT.md` (#9)
10. Create `CODEOWNERS` (#8)
11. Create `Makefile` (#10)
12. Create question issue template (#11)

**Phase 3 — Polish**:
13. Improve demo section with screenshot/GIF (#3)
14. Add acknowledgments to README (#5)
15. Link to changelog (#6)
16. Improve lint workflow (#15)
17. Create stale workflow (#13)
18. Update `.gitignore` (#17)

**Phase 4 — Manual (GitHub UI)**:
19. Configure repository settings (#19)
20. Create v1.0.0 release (#20)

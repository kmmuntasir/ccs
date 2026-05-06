# Product Requirements Document (PRD): ccs

## 1. Project Overview

**Project Name:** ccs (Claude Code Switcher)

**Description:** A command-line utility that allows users to switch between different Claude API providers in Claude Code CLI. Users can configure multiple API providers (e.g., Z.AI, DeepSeek, Kimi, Qwen, MiniMax), enable/disable them, and quickly switch the active provider by updating Claude Code's settings.

**Target Audience:** Developers who use Claude Code CLI and want flexibility in choosing API providers.

**Deployment:** Local tool, distributed as a Git repository.

---

## 2. Core Objectives

1.  **Multi-Provider Support:** Allow configuration of multiple Claude API providers.
2.  **Provider Toggling:** Users must explicitly enable a provider before it can be used.
3.  **Quick Switching:** Switch between enabled providers with a simple interactive menu.
4.  **Persistence:** Store provider configurations in a local JSON file; apply changes to Claude Code's `settings.json`.

---

## 3. Features & Requirements

### 3.1. Configuration Template (`config.template.json`)

*   **Providers List:** Each provider entry contains:
    *   `label`: Display name (format: "Provider Name (Model Title)")
    *   `enabled`: Boolean (default: `false`)
    *   `auth_token`: API key for the provider (placeholder)
    *   `base_url`: API endpoint URL
    *   `haiku_model`: Model identifier for Haiku tier
    *   `sonnet_model`: Model identifier for Sonnet tier
    *   `opus_model`: Model identifier for Opus tier
    *   `default_model`: Default model tier to use

### 3.2. Provider Switching (`switch.sh`)

*   **Interactive Menu:**
    *   Only displays enabled providers.
    *   Shows `[ACTIVE]` tag next to the currently active provider.
    *   Option to select a provider by number.
    *   Option to toggle providers (`T`).
*   **Toggle Mode:**
    *   Lists all providers (both enabled and disabled).
    *   Shows `[ENABLED]` or `[disabled]` status per provider.
    *   Selecting a provider toggles its `enabled` state in `~/.ccs/config.template.json` (or `config.json` in installed location).
*   **Switching Action:**
    *   Updates `~/.claude/settings.json` with:
        *   `ANTHROPIC_AUTH_TOKEN`
        *   `ANTHROPIC_BASE_URL`
        *   `ANTHROPIC_DEFAULT_HAIKU_MODEL`
        *   `ANTHROPIC_DEFAULT_SONNET_MODEL`
        *   `ANTHROPIC_DEFAULT_OPUS_MODEL`
        *   `model` (default tier)
    *   Displays a summary of changes.
    *   Prompts user to restart Claude Code.

### 3.4. Installer (`install.sh`)

*   **Dependency Check:** Verifies `jq` is installed; installs it if missing (via Homebrew, apt, yum, or pacman).
*   **File Setup:**
    *   Creates `~/.ccs/` directory if it doesn't exist.
    *   Copies `config.template.json` to `~/.ccs/config.json` if not present.
*   **First-Run Setup:**
    *   If `~/.claude/settings.json` doesn't exist, creates it with default values.

---

## 4. Technical Architecture

*   **Language:** Bash script with `jq` for JSON processing.
*   **Dependencies:** `jq` (installed automatically if missing).
*   **Configuration Storage:** `~/.ccs/config.json`.
*   **Claude Code Settings:** `~/.claude/settings.json`.
*   **Installation:** Running `install.sh` sets up the tool in `~/.ccs/`.

---

## 5. Edge Cases & Error Handling

*   **No Providers Enabled:** Display a message prompting user to toggle a provider.
*   **Missing `jq`:** `install.sh` installs it automatically.
*   **Missing `config.json`:** `install.sh` copies it from the distribution.
*   **Missing `~/.claude/settings.json`:** `install.sh` creates it with default values.
*   **Invalid Selection:** Display error and re-prompt.
*   **Same Provider Selected:** Notify user that no change is needed.

---

## 6. Folder Structure

**Distribution (Git Repository):**
```
ccs/
├── config.template.json  # Provider configuration template
├── switch.sh              # Main interactive script
├── settings.template.json  # Claude Code settings template
├── install.sh            # Installer script
├── docs/
│   └── PRD.md            # This document
├── README.md             # Project README
└── LICENSE             # License file
```

**Installed Location (`~/.ccs/`):**
```
~/.ccs/
├── config.json          # User's provider configurations
└── switch.sh          # Symlink or copy of switch.sh
```

---

## 7. Out of Scope

*   Automatic provider health checks.
*   API usage tracking or analytics.
*   Provider-specific model mapping beyond Haiku/Sonnet/Opus tiers.
*   User authentication or secure storage of API keys (keys are stored in plaintext in user config).

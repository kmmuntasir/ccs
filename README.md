# ccs - Claude Code Provider Switcher

[![Lint](https://github.com/kmmuntasir/ccs/actions/workflows/lint.yml/badge.svg)](https://github.com/kmmuntasir/ccs/actions/workflows/lint.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/kmmuntasir/ccs)](https://github.com/kmmuntasir/ccs/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/kmmuntasir/ccs)](https://github.com/kmmuntasir/ccs/issues)
[![Shell Script](https://img.shields.io/badge/language-bash-4EAA25.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)]()

> One command to switch between Claude API providers in Claude Code CLI.

## Why ccs?

If you use multiple Claude API providers (Anthropic, OpenRouter, Z.AI, etc.), switching between them means manually editing `~/.claude/settings.json` every time. CCS makes this a single command.

## Demo

```console
$ ccs

==============================
  Claude Provider Switcher
==============================

Available providers:

  1) Z.AI (GLM)  [ACTIVE]
     Default: opus | Top model: glm-5.1
     URL: https://api.z.ai/api/anthropic

  2) AgentRouter (Claude)
     Default: haiku | Top model: claude-opus-4-6
     URL: https://agentrouter.org/

  T) Toggle providers
  +) Add provider
  M) Modify provider
  R) Remove provider
  0) Exit

Select provider [0-T]:
```

## Features

- **Interactive menu** — switch providers, toggle visibility, add/modify/remove entries
- **11 pre-configured providers** — Anthropic, Z.AI, DeepSeek, Qwen, Kimi, and more
- **Zero config editing** — manage everything from the CLI (`ccs add`, `ccs modify`, `ccs remove`)
- **Auto-installs dependencies** — `jq` is installed automatically via your package manager
- **Cross-shell support** — bash, zsh, and fish

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Included Providers](#included-providers)
- [Claude Code Settings](#claude-code-settings)
- [Uninstallation](#uninstallation)
- [Contributing](#contributing)
- [License](#license)
- [Changelog](CHANGELOG.md)

## Requirements

- [jq](https://jqlang.github.io/jq/) — JSON processor (installed automatically by the installer)
- [git](https://git-scm.com/) — required for both quick install and manual install method
- Claude Code CLI installed

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/kmmuntasir/ccs/main/quick-install.sh | bash
```

Then restart your shell or run `source ~/.bashrc` (or `source ~/.zshrc`, or `source ~/.config/fish/config.fish` for Fish) to enable the `ccs` command.

### Manual Install

```bash
git clone https://github.com/kmmuntasir/ccs.git
cd ccs
./install.sh
```

Restart your shell or run `source ~/.bashrc` (or `source ~/.zshrc`, or `source ~/.config/fish/config.fish` for Fish) to enable the `ccs` command.

Or manually:

```bash
mkdir -p ~/.ccs
cp ccs.sh ~/.ccs/ccs.sh
cp config.template.json ~/.ccs/config.json
chmod +x ~/.ccs/ccs.sh
# Add to your shell config:
# ccs() { ~/.ccs/ccs.sh "$@"; }
```

The installer will:
- Install `jq` via your system package manager if not found (supports brew, apt-get, yum, pacman)
- Copy `ccs.sh` to `~/.ccs/`
- Create `~/.ccs/config.json` from template (skipped if already exists)
- Create `~/.claude/settings.json` from template (skipped if already exists)
- Add the `ccs` shell function to `~/.bashrc`, `~/.zshrc`, and `~/.config/fish/config.fish` (whichever exist)

## Updating

When you update CCS (via `git pull` or re-cloning), existing `~/.ccs/config.json` may lack new fields added in later versions. Running `install.sh` again will update the script but skip `config.json` to preserve your credentials. To patch `config.json` with any new fields:

```bash
cd ccs
git pull
./install.sh      # Updates ccs.sh, then runs update.sh automatically
```

Or run the updater directly:

```bash
./update.sh       # Patches config.json with missing fields, preserves existing values
```

`update.sh` is safe to run any time — it only adds fields that don't exist, never overwrites your credentials or custom settings.

## Usage

### Interactive Menu

```bash
ccs
```

The menu only shows enabled providers. Use `T` to toggle which providers are visible.

### Command-Line Arguments

Switch to a provider by key or number:

```bash
ccs glm           # Switch to provider by key
ccs 2             # Switch to provider by number
ccs T             # Toggle providers (lowercase 't' also works)
ccs add           # Interactively add a new provider (auto-enabled)
ccs modify        # Select and modify a provider interactively
ccs modify glm    # Modify a specific provider by key
ccs remove        # Select and remove a provider interactively
ccs remove glm    # Remove a specific provider by key
ccs current       # Show the currently active provider
ccs -h, --help    # Show help message
```

Notes:
- Switching to a disabled provider by key will show an error with a hint to enable it first
- Switching to the currently active provider is a no-op
- You cannot remove the currently active provider (switch away first)
- URLs are automatically normalized with a trailing slash

## Configuration

Edit `~/.ccs/config.json`:

```json
{
  "providers": {
    "glm": {
      "label": "Z.AI (GLM)",
      "enabled": true,
      "auth_token": "your-api-key",
      "base_url": "https://api.z.ai/api/anthropic",
      "haiku_model": "glm-4.7",
      "sonnet_model": "glm-5-turbo",
      "opus_model": "glm-5.1",
      "default_model": "opus",
      "use1MillionContextWindow": false
    }
  }
}
```

### Provider Fields

| Field | Description |
|-------|-------------|
| `label` | Display name (format: "Provider (Model)") |
| `enabled` | `true` to show in menu, `false` to hide |
| `auth_token` | API key for the provider |
| `base_url` | API endpoint URL (trailing slash added automatically) |
| `haiku_model` | Model ID for Haiku tier |
| `sonnet_model` | Model ID for Sonnet tier |
| `opus_model` | Model ID for Opus tier |
| `default_model` | Default tier (haiku/sonnet/opus) |
| `use1MillionContextWindow` | `true` to enable 1M context window for providers that support it, `false` to disable (default) |

`ccs modify` can change all fields including `enabled`, letting you toggle visibility without using the `T` menu.

## Included Providers

Template includes 11 providers (all disabled by default — enable them and add your API keys):

| Provider | Key | URL |
|----------|-----|-----|
| **Z.AI (GLM)** | `glm` | `https://api.z.ai/api/anthropic` |
| **AgentRouter (Claude)** | `agentrouter` | `https://agentrouter.org/` |
| **Anthropic (Native)** | `anthropic` | `https://api.anthropic.com` |
| **Braintrust (Gemini)** | `braintrust` | `https://gateway.braintrust.dev` |
| **DeepSeek (DeepSeek)** | `deepseek` | `https://api.deepseek.com/anthropic/` |
| **Fireworks AI** | `fireworks` | `https://api.fireworks.ai/inference/v1` |
| **Moonshot (Kimi)** | `kimi` | `https://api.moonshot.cn/` |
| **Alibaba (Qwen)** | `qwen` | `https://dashscope.aliyuncs.com/` |
| **MiniMax (MiniMax)** | `minimax` | `https://api.minimax.chat/` |
| **Openrouter** | `openrouter` | `https://openrouter.ai/api/` |
| **LiteLLM (Local Proxy)** | `litellm` | `http://127.0.0.1:4000` |

Add more providers by running `ccs add` or editing `~/.ccs/config.json` directly.

## Claude Code Settings

After switching, `~/.claude/settings.json` is updated with:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5-turbo",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.1",
    "CLAUDE_CODE_DISABLE_1M_CONTEXT": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "DISABLE_TELEMETRY": "1"
  },
  "model": "opus",
  "skipDangerousModePermissionPrompt": false
}
```

The template also sets these optional env vars:
- `CLAUDE_CODE_DISABLE_1M_CONTEXT` — managed per-provider via `use1MillionContextWindow`; set to `"1"` when 1M context is disabled, removed when enabled
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` — blocks non-essential network requests
- `DISABLE_TELEMETRY` — disables telemetry

`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` and `DISABLE_TELEMETRY` are set in the initial `settings.template.json` and are not modified by provider switching. `CLAUDE_CODE_DISABLE_1M_CONTEXT` is managed automatically when you switch providers. Edit `~/.claude/settings.json` directly to change the others.

Restart Claude Code after switching providers.

## Uninstallation

```bash
./uninstall.sh
```

This removes `~/.ccs/` and the `ccs` shell function from your shell config files (`~/.bashrc`, `~/.zshrc`, `~/.config/fish/config.fish`).

Or manually:

```bash
rm -rf ~/.ccs
# Also remove this line from your shell config files:
# ccs() { ~/.ccs/ccs.sh "$@"; }
```

Note: This does not remove `~/.claude/settings.json`.

## Troubleshooting

<details>
<summary><strong>jq not found</strong></summary>

CCS requires `jq`. Re-run the installer or install manually:

```bash
brew install jq          # macOS
sudo apt install jq      # Linux
```

</details>

<details>
<summary><strong>ccs: command not found</strong></summary>

The shell function wasn't added or your shell wasn't restarted:

```bash
source ~/.bashrc   # or ~/.zshrc
```

</details>

<details>
<summary><strong>Settings not taking effect</strong></summary>

Restart Claude Code after switching providers.

</details>

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Acknowledgments

Built with [jq](https://jqlang.github.io/jq/) and [ShellCheck](https://www.shellcheck.net/).

## License

[GNU General Public License v3](LICENSE)

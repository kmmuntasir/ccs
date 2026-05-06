# ccs - Claude Code Provider Switcher

A command-line utility to switch between different Claude API providers in Claude Code CLI.

## Requirements

- [jq](https://jqlang.github.io/jq/) - JSON processor (installed automatically by the installer)
- Claude Code CLI installed

## Installation

```bash
git clone https://github.com/kmmuntasir/ccs.git
cd ccs
./install.sh
```

Restart your shell or run `source ~/.bashrc` (or `source ~/.zshrc`) to enable the `ccs` command.

Or manually or for a different shell:

```bash
mkdir -p ~/.ccs
cp ccs.sh ~/.ccs/ccs.sh
cp config.template.json ~/.ccs/config.json
chmod +x ~/.ccs/ccs.sh
# Add to your shell config:
# ccs() { ~/.ccs/ccs.sh "$@"; }
```

## Usage

### Interactive Menu

```bash
ccs
```

Shows an interactive menu:

```
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
```

### Command-Line Arguments

Switch to a provider by key or number:

```bash
ccs glm           # Switch to provider by key
ccs 2             # Switch to provider by number
ccs T             # Toggle providers
ccs add           # Interactively add a new provider
ccs modify        # Select and modify a provider interactively
ccs modify glm    # Modify a specific provider by key
ccs remove        # Select and remove a provider interactively
ccs remove glm    # Remove a specific provider by key
```

### Configuration

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
      "default_model": "opus"
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
| `base_url` | API endpoint URL |
| `haiku_model` | Model ID for Haiku tier |
| `sonnet_model` | Model ID for Sonnet tier |
| `opus_model` | Model ID for Opus tier |
| `default_model` | Default tier (haiku/sonnet/opus) |

## Included Providers

Template includes placeholders for:

- **Z.AI (GLM)** - `https://api.z.ai/api/anthropic`
- **AgentRouter (Claude)** - `https://agentrouter.org/`
- **DeepSeek (DeepSeek)** - `https://api.deepseek.com/`
- **Moonshot (Kimi)** - `https://api.moonshot.cn/`
- **Alibaba (Qwen)** - `https://dashscope.aliyuncs.com/`
- **MiniMax (MiniMax)** - `https://api.minimax.chat/`

All providers are disabled by default - enable them and add your API keys. Add more providers by running `ccs add` or editing `~/.ccs/config.json` directly.

## Claude Code Settings

After switching, `~/.claude/settings.json` is updated with:

```json
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "your-api-key",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5-turbo",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.1"
  },
  "model": "opus"
}
```

Restart Claude Code after switching providers.

## Uninstallation

```bash
./uninstall.sh
```

Or manually:

```bash
rm -rf ~/.ccs
```

Note: This does not remove `~/.claude/settings.json` or shell config entries.

## License

GNU General Public License v3 (GPLv3)

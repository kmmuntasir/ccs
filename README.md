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

Or manually:

```bash
mkdir -p ~/.ccs
cp switch.sh ~/.ccs/switch.sh
cp config.template.json ~/.ccs/config.json
chmod +x ~/.ccs/switch.sh
```

## Usage

Run the switcher:

```bash
~/.ccs/switch.sh
```

You'll see an interactive menu:

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
  0) Exit
```

### Switching Providers

1. Select a provider number to switch
2. The script updates `~/.claude/settings.json`
3. Restart Claude Code for changes to take effect

### Enabling Providers

1. Select `T` to enter toggle mode
2. Select a provider number to enable/disable
3. Only enabled providers appear in the main menu

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

- **Z.AI (GLM)** - `https://api.z.ai/api/anthropic`
- **AgentRouter (Claude)** - `https://agentrouter.org/`
- **DeepSeek (DeepSeek)** - `https://api.deepseek.com/`
- **Moonshot (Kimi)** - `https://api.moonshot.cn/`
- **Alibaba (Qwen)** - `https://dashscope.aliyuncs.com/`
- **MiniMax (MiniMax)** - `https://api.minimax.chat/`

All providers are disabled by default. Enable them in `config.json` and add your API keys.

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
rm -rf ~/.ccs
```

Note: This does not remove `~/.claude/settings.json`. Delete manually if desired.

## License

MIT

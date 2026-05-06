#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CCS_DIR="$HOME/.ccs"
CLAUDE_DIR="$HOME/.claude"

echo "=============================="
echo "  CCS Installer"
echo "=============================="
echo ""

if ! command -v jq &>/dev/null; then
    echo "jq not found. Installing..."

    if command -v brew &>/dev/null; then
        brew install jq
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y jq
    elif command -v yum &>/dev/null; then
        sudo yum install -y jq
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm jq
    else
        echo "Error: Could not find a package manager to install jq."
        echo "Please install jq manually: https://jqlang.github.io/jq/"
        exit 1
    fi

    echo "jq installed."
    echo ""
fi

echo "jq found."
echo ""

echo "Creating ~/.ccs/ directory..."
mkdir -p "$CCS_DIR"

echo "Copying switch.sh to ~/.ccs/..."
cp "$SCRIPT_DIR/switch.sh" "$CCS_DIR/switch.sh"
chmod +x "$CCS_DIR/switch.sh"

if [[ ! -f "$CCS_DIR/config.json" ]]; then
    echo "Creating config.json from template..."
    cp "$SCRIPT_DIR/config.template.json" "$CCS_DIR/config.json"
else
    echo "config.json already exists. Skipping."
fi

echo ""

if [[ ! -f "$CLAUDE_DIR/settings.json" ]]; then
    echo "Creating ~/.claude/settings.json from template..."
    mkdir -p "$CLAUDE_DIR"
    cp "$SCRIPT_DIR/settings.template.json" "$CLAUDE_DIR/settings.json"
    echo "settings.json created. Edit it with your API key before using."
else
    echo "settings.json already exists. Skipping."
fi

echo ""
echo "=============================="
echo "  Installation complete!"
echo "=============================="
echo ""
echo "Run: ~/.ccs/switch.sh"
echo ""
echo "Note: Edit ~/.ccs/config.json with your API keys."
echo ""
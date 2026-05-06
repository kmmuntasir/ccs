#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CCS_DIR="$HOME/.ccs"
CLAUDE_DIR="$HOME/.claude"
ALIAS_LINE='ccs() { ~/.ccs/ccs.sh "$@"; }'
UPDATED_RC_FILES=()

add_alias() {
    local rc_file="$1"
    if [[ ! -f "$rc_file" ]]; then
        return
    fi

    if grep -q '^ccs()' "$rc_file" 2>/dev/null; then
        echo "ccs function already exists in $rc_file. Skipping."
        return
    fi

    echo "Adding ccs function to $rc_file..."
    echo "" >> "$rc_file"
    echo "# CCS (Claude Code Switcher)" >> "$rc_file"
    echo "$ALIAS_LINE" >> "$rc_file"
    UPDATED_RC_FILES+=("$rc_file")
}

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

echo "Copying ccs.sh to ~/.ccs/..."
cp "$SCRIPT_DIR/ccs.sh" "$CCS_DIR/ccs.sh"
chmod +x "$CCS_DIR/ccs.sh"

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
echo "Adding 'ccs' alias to shell configuration files..."

add_alias "$HOME/.bashrc"
add_alias "$HOME/.zshrc"
add_alias "$HOME/.fish"

if [[ -d "$HOME/.config/fish" ]]; then
    add_alias "$HOME/.config/fish/config.fish"
fi

echo ""
echo "=============================="
echo "  Installation complete!"
echo "=============================="
echo ""
echo "Usage:"
echo "  ccs           - interactive menu"
echo "  ccs glm       - switch to provider by key"
echo "  ccs 2         - switch to provider by number"
echo "  ccs T        - toggle providers"
echo ""

if [[ ${#UPDATED_RC_FILES[@]} -gt 0 ]]; then
    echo "Restart your shell or run:"
    for f in "${UPDATED_RC_FILES[@]}"; do
        echo "  source $f"
    done
else
    echo "ccs function already configured. Just run 'ccs'"
fi
echo ""
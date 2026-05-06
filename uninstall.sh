#!/usr/bin/env bash
# shellcheck shell=bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CCS_DIR="$HOME/.ccs"

echo "=============================="
echo "  CCS Uninstaller"
echo "=============================="
echo ""

if [[ ! -d "$CCS_DIR" ]]; then
    echo "CCS is not installed. Nothing to do."
    exit 0
fi

echo "Removing ~/.ccs/ directory..."
rm -rf "$CCS_DIR"
echo "Done."

echo ""
echo "Removing ccs function from shell configuration files..."

remove_alias() {
    local rc_file="$1"
    if [[ ! -f "$rc_file" ]]; then
        return
    fi

    local tmp=$(mktemp)
    if grep -v '^ccs()' "$rc_file" > "$tmp"; then
        mv "$tmp" "$rc_file"
        echo "Removed from $rc_file"
    else
        rm "$tmp"
    fi
}

remove_alias "$HOME/.bashrc"
remove_alias "$HOME/.zshrc"

if [[ -f "$HOME/.config/fish/config.fish" ]]; then
    remove_alias "$HOME/.config/fish/config.fish"
fi

echo ""
echo "=============================="
echo "  Uninstall complete!"
echo "=============================="
echo ""
echo "Note: ~/.claude/settings.json was not removed."
echo ""
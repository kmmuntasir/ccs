#!/usr/bin/env bash
# shellcheck shell=bash

set -e

CONFIG="$HOME/.ccs/config.json"

echo "=============================="
echo "  CCS Config Updater"
echo "=============================="
echo ""

if [[ ! -f "$CONFIG" ]]; then
    echo "Error: config.json not found at $CONFIG"
    echo "Run install.sh first."
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed."
    exit 1
fi

PATCHED=false

# Patch: add disable1millionContextWindow where missing (default true)
all_have_field=$(jq -r '[.providers[] | has("disable1millionContextWindow")] | all' "$CONFIG")
if [[ "$all_have_field" != "true" ]]; then
    echo "Patching: adding 'disable1millionContextWindow' field..."
    tmp=$(mktemp)
    jq '.providers |= with_entries(
        .value += if .value | has("disable1millionContextWindow") then {} else {"disable1millionContextWindow": true} end
    )' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"
    echo "  -> Added to providers that lacked it (default: true)."
    PATCHED=true
fi

# Future patches go here:
# ------------------------------------------------------------------
# Example:
# all_have_xyz=$(jq -r '[.providers[] | has("someNewField")] | all' "$CONFIG")
# if [[ "$all_have_xyz" != "true" ]]; then
#     echo "Patching: adding 'someNewField' field..."
#     tmp=$(mktemp)
#     jq '.providers |= with_entries(
#         .value += if .value | has("someNewField") then {} else {"someNewField": "defaultValue"} end
#     )' "$CONFIG" > "$tmp"
#     mv "$tmp" "$CONFIG"
#     echo "  -> Added to providers that lacked it (default: defaultValue)."
#     PATCHED=true
# fi
# ------------------------------------------------------------------

if [[ "$PATCHED" == "true" ]]; then
    echo ""
    echo "Config updated successfully."
else
    echo "config.json is already up to date."
fi

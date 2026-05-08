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

# Migration: rename disable1millionContextWindow to use1MillionContextWindow and invert values
any_has_old_field=$(jq -r '[.providers[] | has("disable1millionContextWindow")] | any' "$CONFIG")
if [[ "$any_has_old_field" == "true" ]]; then
    echo "Migrating: renaming 'disable1millionContextWindow' to 'use1MillionContextWindow'..."
    tmp=$(mktemp)
    jq '.providers |= with_entries(
        if .value | has("disable1millionContextWindow") then
            .value.use1MillionContextWindow = (.value.disable1millionContextWindow | not) |
            del(.value.disable1millionContextWindow)
        else . end
    )' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"
    echo "  -> Renamed and inverted values (disable=true -> use=false, disable=false -> use=true)."
    PATCHED=true
fi

# Patch: add use1MillionContextWindow where missing (default false)
all_have_field=$(jq -r '[.providers[] | has("use1MillionContextWindow")] | all' "$CONFIG")
if [[ "$all_have_field" != "true" ]]; then
    echo "Patching: adding 'use1MillionContextWindow' field..."
    tmp=$(mktemp)
    jq '.providers |= with_entries(
        .value += if .value | has("use1MillionContextWindow") then {} else {"use1MillionContextWindow": false} end
    )' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"
    echo "  -> Added to providers that lacked it (default: false)."
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

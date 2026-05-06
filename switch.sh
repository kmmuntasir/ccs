#!/usr/bin/env bash

CCS_DIR="$HOME/.ccs"
CONFIG="$CCS_DIR/config.json"
SETTINGS="$HOME/.claude/settings.json"

show_menu() {
    enabled_keys=($(jq -r '.providers | to_entries[] | select(.value.enabled == true) | .key' "$CONFIG"))

    if [[ ${#enabled_keys[@]} -eq 0 ]]; then
        echo ""
        echo "No providers enabled."
        echo "Select 'T' to enable a provider."
        echo ""
        return
    fi

    current_base_url=$(jq -r '.env.ANTHROPIC_BASE_URL' "$SETTINGS")
    current_provider="unknown"
    for key in "${enabled_keys[@]}"; do
        provider_url=$(jq -r ".providers.$key.base_url" "$CONFIG")
        if [[ "$current_base_url" == "$provider_url" ]]; then
            current_provider="$key"
            break
        fi
    done

    echo ""
    echo "=============================="
    echo "  Claude Provider Switcher"
    echo "=============================="
    echo ""
    echo "Available providers:"
    echo ""

    i=1
    for key in "${enabled_keys[@]}"; do
        label=$(jq -r ".providers.$key.label" "$CONFIG")
        base_url=$(jq -r ".providers.$key.base_url" "$CONFIG")
        default_model=$(jq -r ".providers.$key.default_model" "$CONFIG")
        opus_model=$(jq -r ".providers.$key.opus_model" "$CONFIG")

        if [[ "$key" == "$current_provider" ]]; then
            echo "  $i) $label  [ACTIVE]"
        else
            echo "  $i) $label"
        fi
        echo "     Default: $default_model | Top model: $opus_model"
        echo "     URL: $base_url"
        echo ""
        ((i++))
    done

    echo "  T) Toggle providers"
    echo "  0) Exit"
    echo ""

    read -rp "Select provider [0-T]: " choice

    if [[ "$choice" == "0" || -z "$choice" ]]; then
        echo "Cancelled."
        exit 0
    fi

    if [[ "$choice" == "T" || "$choice" == "t" ]]; then
        toggle_providers
        return
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 || "$choice" -ge "$i" ]]; then
        echo "Error: Invalid selection."
        exit 1
    fi

    selected_key="${enabled_keys[$((choice-1))]}"

    if [[ "$selected_key" == "$current_provider" ]]; then
        echo "Already using '$selected_key'. No change needed."
        exit 0
    fi

    auth_token=$(jq -r ".providers.$selected_key.auth_token" "$CONFIG")
    base_url=$(jq -r ".providers.$selected_key.base_url" "$CONFIG")
    haiku=$(jq -r ".providers.$selected_key.haiku_model" "$CONFIG")
    sonnet=$(jq -r ".providers.$selected_key.sonnet_model" "$CONFIG")
    opus=$(jq -r ".providers.$selected_key.opus_model" "$CONFIG")
    default_model=$(jq -r ".providers.$selected_key.default_model" "$CONFIG")

    tmp=$(mktemp)
    jq --arg tok "$auth_token" \
       --arg url "$base_url" \
       --arg hk "$haiku" \
       --arg sn "$sonnet" \
       --arg op "$opus" \
       --arg dm "$default_model" \
       '.env.ANTHROPIC_AUTH_TOKEN = $tok |
        .env.ANTHROPIC_BASE_URL = $url |
        .env.ANTHROPIC_DEFAULT_HAIKU_MODEL = $hk |
        .env.ANTHROPIC_DEFAULT_SONNET_MODEL = $sn |
        .env.ANTHROPIC_DEFAULT_OPUS_MODEL = $op |
        .model = $dm' "$SETTINGS" > "$tmp"

    mv "$tmp" "$SETTINGS"

    label=$(jq -r ".providers.$selected_key.label" "$CONFIG")
    echo ""
    echo "Switched to: $label"
    echo "Updated fields:"
    echo "  ANTHROPIC_AUTH_TOKEN: **********"
    echo "  ANTHROPIC_BASE_URL: $base_url"
    echo "  HAIKU_MODEL: $haiku"
    echo "  SONNET_MODEL: $sonnet"
    echo "  OPUS_MODEL: $opus"
    echo "  model: $default_model"
    echo ""
    echo "Restart Claude Code for changes to take effect."
}

toggle_providers() {
    all_keys=($(jq -r '.providers | keys[]' "$CONFIG"))

    echo ""
    echo "Toggle providers:"
    echo ""

    i=1
    for key in "${all_keys[@]}"; do
        label=$(jq -r ".providers.$key.label" "$CONFIG")
        enabled=$(jq -r ".providers.$key.enabled" "$CONFIG")
        if [[ "$enabled" == "true" ]]; then
            echo "  $i) $label  [ENABLED]"
        else
            echo "  $i) $label  [disabled]"
        fi
        ((i++))
    done

    echo "  0) Back"
    echo ""

    read -rp "Select provider to toggle [0-$((i-1))]: " choice

    if [[ "$choice" == "0" || -z "$choice" ]]; then
        show_menu
        return
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 || "$choice" -ge "$i" ]]; then
        echo "Error: Invalid selection."
        exit 1
    fi

    selected_key="${all_keys[$((choice-1))]}"
    current_enabled=$(jq -r ".providers.$selected_key.enabled" "$CONFIG")

    if [[ "$current_enabled" == "true" ]]; then
        new_enabled="false"
    else
        new_enabled="true"
    fi

    tmp=$(mktemp)
    jq --arg key "$selected_key" --argjson enabled "$new_enabled" \
       '.providers[$key].enabled = enabled' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"

    label=$(jq -r ".providers.$selected_key.label" "$CONFIG")
    echo ""
    if [[ "$new_enabled" == "true" ]]; then
        echo "Enabled: $label"
    else
        echo "Disabled: $label"
    fi
    echo ""

    toggle_providers
}

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed."
    exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
    echo "Error: config.json not found at $CONFIG"
    exit 1
fi

if [[ ! -f "$SETTINGS" ]]; then
    echo "Error: settings.json not found at $SETTINGS"
    exit 1
fi

keys=($(jq -r '.providers | keys[]' "$CONFIG"))

if [[ ${#keys[@]} -eq 0 ]]; then
    echo "Error: No providers defined in config.json"
    exit 1
fi

show_menu

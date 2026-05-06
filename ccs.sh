#!/usr/bin/env bash
# shellcheck shell=bash disable=SC2207

CCS_DIR="$HOME/.ccs"
CONFIG="$CCS_DIR/config.json"
SETTINGS="$HOME/.claude/settings.json"

switch_to_provider() {
    local selection="$1"
    enabled_keys=($(jq -r \
        '.providers | to_entries[] | select(.value.enabled == true) | .key' \
        "$CONFIG"))
    all_keys=($(jq -r '.providers | keys[]' "$CONFIG"))

    if [[ ${#enabled_keys[@]} -eq 0 ]]; then
        echo "Error: No providers enabled. Run 'ccs T' to enable a provider."
        exit 1
    fi

    local selected_key=""
    local target_exists=false
    for key in "${all_keys[@]}"; do
        if [[ "$key" == "$selection" ]]; then
            target_exists=true
            break
        fi
    done

    if [[ "$target_exists" == "false" ]]; then
        echo "Error: Unknown provider '$selection'"
        exit 1
    fi

    local is_enabled=false
    for key in "${enabled_keys[@]}"; do
        if [[ "$key" == "$selection" ]]; then
            is_enabled=true
            break
        fi
    done

    if [[ "$is_enabled" == "false" ]]; then
        echo "Error: Provider '$selection' is disabled."
        echo "Run 'ccs T' to enable it."
        exit 1
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

    selected_key=""
    if [[ "$selection" =~ ^[0-9]+$ ]]; then
        if [[ "$selection" -lt 1 ]] || \
           [[ "$selection" -gt ${#enabled_keys[@]} ]]; then
            echo "Error: Invalid selection number."
            echo "Available: 1-${#enabled_keys[@]}"
            exit 1
        fi
        selected_key="${enabled_keys[$((selection-1))]}"
    else
        selected_key="$selection"
    fi

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

show_menu() {
    enabled_keys=($(jq -r \
        '.providers | to_entries[] | select(.value.enabled == true) | .key' \
        "$CONFIG"))

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
        echo "     Default: $default_model"
        echo "     Top model: $opus_model"
        echo "     URL: $base_url"
        echo ""
        i=$((i + 1))
    done

    echo "  T) Toggle providers"
    echo "  +) Add provider"
    echo "  M) Modify provider"
    echo "  R) Remove provider"
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

    if [[ "$choice" == "+" ]]; then
        add_provider
        return
    fi

    if [[ "$choice" == "M" || "$choice" == "m" ]]; then
        modify_provider
        return
    fi

    if [[ "$choice" == "R" || "$choice" == "r" ]]; then
        remove_provider
        return
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid selection."
        exit 1
    fi
    if [[ "$choice" -lt 1 || "$choice" -ge "$i" ]]; then
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

add_provider() {
    existing_keys=($(jq -r '.providers | keys[]' "$CONFIG"))

    echo ""
    echo "=============================="
    echo "  Add New Provider"
    echo "=============================="
    echo ""

    # Provider key (unique identifier)
    while true; do
        read -rp "Provider key (lowercase, no spaces): " new_key
        new_key=$(echo "$new_key" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        if [[ -z "$new_key" ]]; then
            echo "Error: Key cannot be empty."
            continue
        fi
        local key_exists=false
        for k in "${existing_keys[@]}"; do
            if [[ "$k" == "$new_key" ]]; then
                key_exists=true
                break
            fi
        done
        if [[ "$key_exists" == "true" ]]; then
            echo "Error: Provider '$new_key' already exists."
            echo "Choose a different key."
            continue
        fi
        break
    done

    # Label
    read -rp "Label (e.g. 'MyProvider (GPT)'): " new_label
    if [[ -z "$new_label" ]]; then
        new_label="$new_key"
    fi

    # Auth token
    read -rp "Auth token (API key): " new_token
    if [[ -z "$new_token" ]]; then
        echo "Error: Auth token cannot be empty."
        exit 1
    fi

    # Base URL
    read -rp "Base URL: " new_url
    if [[ -z "$new_url" ]]; then
        echo "Error: Base URL cannot be empty."
        exit 1
    fi
    # Ensure trailing slash
    if [[ "${new_url: -1}" != "/" ]]; then
        new_url="${new_url}/"
    fi

    # Model IDs
    read -rp "Haiku model ID: " new_haiku
    if [[ -z "$new_haiku" ]]; then
        echo "Error: Haiku model ID cannot be empty."
        exit 1
    fi

    read -rp "Sonnet model ID: " new_sonnet
    if [[ -z "$new_sonnet" ]]; then
        echo "Error: Sonnet model ID cannot be empty."
        exit 1
    fi

    read -rp "Opus model ID: " new_opus
    if [[ -z "$new_opus" ]]; then
        echo "Error: Opus model ID cannot be empty."
        exit 1
    fi

    # Default model
    while true; do
        read -rp "Default model tier (haiku/sonnet/opus): " new_default
        case "$new_default" in
            haiku|sonnet|opus) break ;;
            *) echo "Error: Must be haiku, sonnet, or opus." ;;
        esac
    done

    # Write to config
    tmp=$(mktemp)
    jq --arg key "$new_key" \
        --arg label "$new_label" \
        --arg token "$new_token" \
        --arg url "$new_url" \
        --arg haiku "$new_haiku" \
        --arg sonnet "$new_sonnet" \
        --arg opus "$new_opus" \
        --arg default "$new_default" \
        '.providers[$key] = {
            "label": $label,
            "enabled": true,
            "auth_token": $token,
            "base_url": $url,
            "haiku_model": $haiku,
            "sonnet_model": $sonnet,
            "opus_model": $opus,
            "default_model": $default
        }' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"

    echo ""
    echo "Provider '$new_label' added and enabled."
    echo "  Key: $new_key"
    echo "  URL: $new_url"
    echo "  Default: $new_default"
    echo "  Haiku: $new_haiku | Sonnet: $new_sonnet | Opus: $new_opus"
    echo ""
}

remove_provider() {
    local target="$1"
    all_keys=($(jq -r '.providers | keys[]' "$CONFIG"))

    if [[ ${#all_keys[@]} -eq 0 ]]; then
        echo "Error: No providers to remove."
        exit 1
    fi

    if [[ -z "$target" ]]; then
        echo ""
        echo "=============================="
        echo "  Remove Provider"
        echo "=============================="
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
            i=$((i + 1))
        done

        echo "  0) Cancel"
        echo ""

        read -rp "Select provider to remove [0-$((i-1))]: " choice

        if [[ "$choice" == "0" || -z "$choice" ]]; then
            echo "Cancelled."
            exit 0
        fi

        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            echo "Error: Invalid selection."
            exit 1
        fi
        if [[ "$choice" -lt 1 || "$choice" -ge "$i" ]]; then
            echo "Error: Invalid selection."
            exit 1
        fi

        target="${all_keys[$((choice-1))]}"
    else
        local found=false
        for key in "${all_keys[@]}"; do
            if [[ "$key" == "$target" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == "false" ]]; then
            echo "Error: Unknown provider '$target'."
            exit 1
        fi
    fi

    local label url dm
    label=$(jq -r ".providers.$target.label" "$CONFIG")
    url=$(jq -r ".providers.$target.base_url" "$CONFIG")
    dm=$(jq -r ".providers.$target.default_model" "$CONFIG")

    # Check if this is the currently active provider
    local current_base_url
    current_base_url=$(jq -r '.env.ANTHROPIC_BASE_URL' "$SETTINGS")
    if [[ "$current_base_url" == "$url" ]]; then
        echo ""
        echo "Error: '$label' is the currently active provider."
        echo "Switch to another provider first. Run: ccs"
        exit 1
    fi

    echo ""
    echo "About to remove:"
    echo "  Key: $target"
    echo "  Label: $label"
    echo "  URL: $url"
    echo "  Default: $dm"
    echo ""
    read -rp "Are you sure? [y/N]: " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Cancelled."
        exit 0
    fi

    tmp=$(mktemp)
    jq --arg key "$target" 'del(.providers[$key])' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"

    echo ""
    echo "Removed: $label ($target)"
    echo ""
}

modify_provider() {
    local target="$1"
    all_keys=($(jq -r '.providers | keys[]' "$CONFIG"))

    if [[ ${#all_keys[@]} -eq 0 ]]; then
        echo "Error: No providers to modify."
        exit 1
    fi

    if [[ -z "$target" ]]; then
        echo ""
        echo "=============================="
        echo "  Modify Provider"
        echo "=============================="
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
            i=$((i + 1))
        done

        echo "  0) Cancel"
        echo ""

        read -rp "Select provider to modify [0-$((i-1))]: " choice

        if [[ "$choice" == "0" || -z "$choice" ]]; then
            echo "Cancelled."
            exit 0
        fi

        if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
            echo "Error: Invalid selection."
            exit 1
        fi
        if [[ "$choice" -lt 1 || "$choice" -ge "$i" ]]; then
            echo "Error: Invalid selection."
            exit 1
        fi

        target="${all_keys[$((choice-1))]}"
    else
        local found=false
        for key in "${all_keys[@]}"; do
            if [[ "$key" == "$target" ]]; then
                found=true
                break
            fi
        done
        if [[ "$found" == "false" ]]; then
            echo "Error: Unknown provider '$target'."
            exit 1
        fi
    fi

    local cur_label cur_token cur_url
    local cur_haiku cur_sonnet cur_opus
    local cur_default cur_enabled
    cur_label=$(jq -r ".providers.$target.label" "$CONFIG")
    cur_token=$(jq -r ".providers.$target.auth_token" "$CONFIG")
    cur_url=$(jq -r ".providers.$target.base_url" "$CONFIG")
    cur_haiku=$(jq -r ".providers.$target.haiku_model" "$CONFIG")
    cur_sonnet=$(jq -r ".providers.$target.sonnet_model" "$CONFIG")
    cur_opus=$(jq -r ".providers.$target.opus_model" "$CONFIG")
    cur_default=$(jq -r ".providers.$target.default_model" "$CONFIG")
    cur_enabled=$(jq -r ".providers.$target.enabled" "$CONFIG")

    echo ""
    echo "Modifying: $cur_label ($target)"
    echo "Press Enter to keep current value."
    echo ""

    read -rp "Label [$cur_label]: " new_label
    new_label="${new_label:-$cur_label}"

    read -rp "Auth token [**********]: " new_token
    new_token="${new_token:-$cur_token}"

    read -rp "Base URL [$cur_url]: " new_url
    new_url="${new_url:-$cur_url}"
    if [[ "${new_url: -1}" != "/" ]]; then
        new_url="${new_url}/"
    fi

    read -rp "Haiku model ID [$cur_haiku]: " new_haiku
    new_haiku="${new_haiku:-$cur_haiku}"

    read -rp "Sonnet model ID [$cur_sonnet]: " new_sonnet
    new_sonnet="${new_sonnet:-$cur_sonnet}"

    read -rp "Opus model ID [$cur_opus]: " new_opus
    new_opus="${new_opus:-$cur_opus}"

    while true; do
        read -rp \
            "Default model tier (haiku/sonnet/opus) [$cur_default]: " \
            new_default
        new_default="${new_default:-$cur_default}"
        case "$new_default" in
            haiku|sonnet|opus) break ;;
            *) echo "Error: Must be haiku, sonnet, or opus." ;;
        esac
    done

    local enabled_str="enabled"
    if [[ "$cur_enabled" == "false" ]]; then
        enabled_str="disabled"
    fi
    read -rp "Enabled (true/false) [$enabled_str]: " new_enabled
    if [[ -z "$new_enabled" ]]; then
        new_enabled="$cur_enabled"
    fi

    echo ""
    echo "Changes for '$target':"
    if [[ "$new_label" != "$cur_label" ]]; then
        echo "  label: $cur_label -> $new_label"
    fi
    if [[ "$new_token" != "$cur_token" ]]; then
        echo "  auth_token: ********** -> **********"
    fi
    if [[ "$new_url" != "$cur_url" ]]; then
        echo "  base_url: $cur_url -> $new_url"
    fi
    if [[ "$new_haiku" != "$cur_haiku" ]]; then
        echo "  haiku_model: $cur_haiku -> $new_haiku"
    fi
    if [[ "$new_sonnet" != "$cur_sonnet" ]]; then
        echo "  sonnet_model: $cur_sonnet -> $new_sonnet"
    fi
    if [[ "$new_opus" != "$cur_opus" ]]; then
        echo "  opus_model: $cur_opus -> $new_opus"
    fi
    if [[ "$new_default" != "$cur_default" ]]; then
        echo "  default_model: $cur_default -> $new_default"
    fi
    if [[ "$new_enabled" != "$cur_enabled" ]]; then
        echo "  enabled: $cur_enabled -> $new_enabled"
    fi

    echo ""
    read -rp "Apply changes? [y/N]: " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Cancelled."
        exit 0
    fi

    tmp=$(mktemp)
    jq --arg key "$target" \
        --arg label "$new_label" \
        --arg token "$new_token" \
        --arg url "$new_url" \
        --arg haiku "$new_haiku" \
        --arg sonnet "$new_sonnet" \
        --arg opus "$new_opus" \
        --arg default "$new_default" \
        --argjson enabled "$new_enabled" \
        '.providers[$key] = {
            "label": $label,
            "enabled": $enabled,
            "auth_token": $token,
            "base_url": $url,
            "haiku_model": $haiku,
            "sonnet_model": $sonnet,
            "opus_model": $opus,
            "default_model": $default
        }' "$CONFIG" > "$tmp"
    mv "$tmp" "$CONFIG"

    echo ""
    echo "Updated: $new_label ($target)"
    echo ""
}

show_current() {
    local current_base_url
    current_base_url=$(jq -r '.env.ANTHROPIC_BASE_URL' "$SETTINGS")
    all_keys=($(jq -r '.providers | keys[]' "$CONFIG"))

    for key in "${all_keys[@]}"; do
        local url
        url=$(jq -r ".providers.$key.base_url" "$CONFIG")
        if [[ "$current_base_url" == "$url" ]]; then
            local label dm om
            label=$(jq -r ".providers.$key.label" "$CONFIG")
            dm=$(jq -r ".providers.$key.default_model" "$CONFIG")
            om=$(jq -r ".providers.$key.opus_model" "$CONFIG")
            echo ""
            echo "  $label ($key)"
            echo "  URL: $url"
            echo "  Default: $dm"
            echo "  Top model: $om"
            echo ""
            return
        fi
    done

    echo ""
    echo "  No active provider found"
    echo "  Current URL: $current_base_url"
    echo ""
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
        i=$((i + 1))
    done

    echo "  0) Back"
    echo ""

    read -rp "Select provider to toggle [0-$((i-1))]: " choice

    if [[ "$choice" == "0" || -z "$choice" ]]; then
        show_menu
        return
    fi

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Error: Invalid selection."
        exit 1
    fi
    if [[ "$choice" -lt 1 || "$choice" -ge "$i" ]]; then
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

show_version() {
    local version_file
    version_file="$(cd "$(dirname "$0")" && pwd)/VERSION"
    if [[ -f "$version_file" ]]; then
        echo "ccs $(tr -d '[:space:]' < "$version_file")"
    else
        echo "ccs (version unknown)"
    fi
}

show_help() {
    echo "ccs - Claude Code Provider Switcher"
    echo ""
    echo "Usage: ccs [command]"
    echo ""
    echo "Commands:"
    echo "  (none)          Interactive menu"
    echo "  <key>           Switch to provider by key (e.g. glm, kimi)"
    echo "  <number>        Switch to provider by menu number"
    echo "  T               Toggle provider visibility"
    echo "  add             Interactively add a new provider"
    echo "  modify [key]    Modify a provider (interactive if no key given)"
    echo "  remove [key]    Remove a provider (interactive if no key given)"
    echo "  current         Show the currently active provider"
    echo "  -v, --version   Show version"
    echo "  -h, --help      Show this help message"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ "${1:-}" == "-v" || "${1:-}" == "--version" ]]; then
    show_version
    exit 0
fi

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

if [[ $# -gt 0 ]]; then
    arg="$1"
    if [[ "$arg" == "T" || "$arg" == "t" ]]; then
        toggle_providers
    elif [[ "$arg" == "add" ]]; then
        add_provider
    elif [[ "$arg" == "modify" ]]; then
        modify_provider "$2"
    elif [[ "$arg" == "remove" ]]; then
        remove_provider "$2"
    elif [[ "$arg" == "current" ]]; then
        show_current
    else
        switch_to_provider "$arg"
    fi
else
    show_menu
fi

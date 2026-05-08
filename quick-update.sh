#!/usr/bin/env bash
# shellcheck shell=bash

set -e

REPO_URL="https://github.com/kmmuntasir/ccs.git"
TMP_DIR=$(mktemp -d /tmp/ccs-update.XXXXXX)
CCS_DIR="$HOME/.ccs"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if ! command -v git &>/dev/null; then
    echo "Error: git is required but not installed."
    echo "Install it from:"
    echo "https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
    exit 1
fi

if [[ ! -d "$CCS_DIR" ]]; then
    echo "Error: CCS is not installed at $CCS_DIR"
    echo "Run the installer first:"
    echo "  curl -fsSL https://raw.githubusercontent.com/kmmuntasir/ccs/main/quick-install.sh | bash"
    exit 1
fi

echo "Cloning ccs repository..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/ccs"

echo ""
echo "Updating ccs.sh..."
cp "$TMP_DIR/ccs/ccs.sh" "$CCS_DIR/ccs.sh"
chmod +x "$CCS_DIR/ccs.sh"

if [[ -f "$TMP_DIR/ccs/VERSION" ]]; then
    cp "$TMP_DIR/ccs/VERSION" "$CCS_DIR/VERSION"
fi

echo ""
echo "Running config migration..."
bash "$TMP_DIR/ccs/update.sh"

echo ""
echo "=============================="
echo "  Update complete!"
echo "=============================="
echo ""
echo "ccs is now at the latest version."
echo "Run: ccs"

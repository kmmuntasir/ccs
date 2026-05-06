#!/usr/bin/env bash
# shellcheck shell=bash

set -e

REPO_URL="https://github.com/kmmuntasir/ccs.git"
TMP_DIR=$(mktemp -d /tmp/ccs-install.XXXXXX)

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

echo "Cloning ccs repository..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/ccs"

echo ""
bash "$TMP_DIR/ccs/install.sh"

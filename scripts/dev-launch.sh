#!/usr/bin/env bash
set -euo pipefail

# Launch Claude Code with the local VBW plugin.
# Resolves the absolute path to the repo automatically,
# regardless of the current working directory. Follows symlinks so the
# ~/.local/bin/claude-vbw link installed by dev-setup.sh resolves to the repo.

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  LINK_DIR="$(cd "$(dirname "$SOURCE")" && pwd -P)"
  SOURCE="$(readlink "$SOURCE")"
  case "$SOURCE" in /*) ;; *) SOURCE="$LINK_DIR/$SOURCE" ;; esac
done
SCRIPT_DIR="$(cd "$(dirname "$SOURCE")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

exec claude --plugin-dir "$REPO_DIR" "$@"

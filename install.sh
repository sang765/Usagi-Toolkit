#!/usr/bin/env sh
set -eu

# Compatibility wrapper. The supported installer is now:
#   bunx --bun github:sang765/Usagi-Toolkit install
#
# Keep this file for existing automation, but do not maintain installer logic in Bash.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if command -v bun >/dev/null 2>&1; then
  exec bun "$SCRIPT_DIR/bin/install.js" "$@"
fi

printf '%s\n' 'Bun is required. Install Bun and run:' >&2
printf '%s\n' '  bunx --bun github:sang765/Usagi-Toolkit install' >&2
exit 1

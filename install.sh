#!/usr/bin/env bash
# ============================================================================
# Tsuki Plugin Engineering Toolkit - Installer
#
# Auto-detects installed agent harnesses (Claude Code, OpenCode, Codex,
# Claude Desktop, Cline, Roo Code, Pi/Senpi) and registers this MCP server
# (and, where supported, the Skill) into each one's config.
#
# Every config file this script touches is backed up to "<file>.bak" first.
# Run ./uninstall.sh at any time to reverse everything this script does.
# ============================================================================
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_JS="$SCRIPT_DIR/bin/run.js"
SKILL_SRC="$SCRIPT_DIR/skill"
SERVER_NAME="tsuki-plugin-engineering"

log_info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_skip()  { echo -e "  - $*"; }

PYTHON_CMD=""
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
fi

# ----------------------------------------------------------------------------
# Preflight
# ----------------------------------------------------------------------------

preflight() {
    log_info "Checking runtime..."
    if command -v bun &>/dev/null; then
        log_ok "bun found ($(bun --version))"
    elif command -v node &>/dev/null; then
        local node_major
        node_major="$(node --version | sed -E 's/^v([0-9]+).*/\1/')"
        if [[ "$node_major" -lt 20 ]]; then
            log_warn "Node.js $(node --version) found, but 20+ is required."
        else
            log_ok "node found ($(node --version))"
        fi
    else
        log_warn "Neither bun nor node found. Install one before using this MCP server."
    fi

    if [[ ! -d "$SCRIPT_DIR/node_modules" ]]; then
        log_warn "node_modules/ not found. Run 'npm install' (or 'bun install') in $SCRIPT_DIR first."
    fi

    if [[ -z "$PYTHON_CMD" ]]; then
        log_warn "Python not found — JSON configs will be merged with a best-effort text fallback instead of a JSON-aware merge."
    fi
}

# ----------------------------------------------------------------------------
# JSON config merge (mcpServers / mcp shape)
# ----------------------------------------------------------------------------

# add_mcp_server_json <file> <top_level_key> ("mcpServers" or "mcp")
add_mcp_server_json() {
    local file="$1"
    local key="$2"
    local dir
    dir="$(dirname "$file")"
    mkdir -p "$dir"

    if [[ ! -f "$file" ]]; then
        echo '{}' > "$file"
    else
        cp "$file" "${file}.bak"
    fi

    if [[ -n "$PYTHON_CMD" ]]; then
        "$PYTHON_CMD" - "$file" "$key" "$SERVER_NAME" "$RUN_JS" <<'PYEOF'
import json, sys
file, key, name, run_js = sys.argv[1:5]
with open(file) as f:
    try:
        data = json.load(f)
    except json.JSONDecodeError:
        data = {}
data.setdefault(key, {})
data[key][name] = {"command": "node", "args": [run_js]}
with open(file, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF
        log_ok "Registered MCP server in $file"
    else
        log_warn "Could not JSON-merge $file (no python). Add this manually:"
        echo "  \"$key\": { \"$SERVER_NAME\": { \"command\": \"node\", \"args\": [\"$RUN_JS\"] } }"
    fi
}

# add_mcp_server_toml <file>  (Codex-style [mcp_servers.NAME])
add_mcp_server_toml() {
    local file="$1"
    local dir
    dir="$(dirname "$file")"
    mkdir -p "$dir"
    touch "$file"
    cp "$file" "${file}.bak"

    if grep -q "^\[mcp_servers\.${SERVER_NAME}\]$" "$file" 2>/dev/null; then
        log_skip "$file already has an [mcp_servers.$SERVER_NAME] section, leaving it untouched"
        return
    fi

    {
        echo ""
        echo "[mcp_servers.${SERVER_NAME}]"
        echo "command = \"node\""
        echo "args = [\"${RUN_JS}\"]"
    } >> "$file"
    log_ok "Registered MCP server in $file"
}

link_skill() {
    local dest_dir="$1"
    if [[ ! -d "$SKILL_SRC" ]]; then
        return
    fi
    mkdir -p "$dest_dir"
    local dest="$dest_dir/$SERVER_NAME"
    if [[ -e "$dest" || -L "$dest" ]]; then
        log_skip "Skill already present at $dest, leaving it untouched"
        return
    fi
    if ln -s "$SKILL_SRC" "$dest" 2>/dev/null; then
        log_ok "Linked skill into $dest"
    else
        cp -r "$SKILL_SRC" "$dest"
        log_ok "Copied skill into $dest"
    fi
}

# ----------------------------------------------------------------------------
# Per-harness install
# ----------------------------------------------------------------------------

install_claude_code() {
    if [[ -d "$HOME/.claude" ]] || command -v claude &>/dev/null; then
        log_info "Claude Code detected"
        add_mcp_server_json "$SCRIPT_DIR/.mcp.json" "mcpServers"
        link_skill "$SCRIPT_DIR/.claude/skills"
        link_skill "$HOME/.claude/skills"
    else
        log_skip "Claude Code not detected, skipping"
    fi
}

install_opencode() {
    if [[ -d "$HOME/.config/opencode" ]] || command -v opencode &>/dev/null; then
        log_info "OpenCode detected"
        add_mcp_server_json "$SCRIPT_DIR/opencode.json" "mcp"
        link_skill "$SCRIPT_DIR/.opencode/skills"
        link_skill "$HOME/.config/opencode/skills"
    else
        log_skip "OpenCode not detected, skipping"
    fi
}

install_codex() {
    if [[ -d "$HOME/.codex" ]] || command -v codex &>/dev/null; then
        log_info "Codex detected"
        add_mcp_server_toml "$HOME/.codex/config.toml"
        link_skill "$SCRIPT_DIR/.agents/skills"
        link_skill "$HOME/.agents/skills"
    else
        log_skip "Codex not detected, skipping"
    fi
}

install_pi() {
    if [[ -d "$HOME/.pi" ]]; then
        log_info "Pi/Senpi detected"
        add_mcp_server_json "$SCRIPT_DIR/.pi/mcp.json" "mcpServers"
        link_skill "$SCRIPT_DIR/.pi/skills"
        link_skill "$HOME/.pi/agent/skills"
    else
        log_skip "Pi/Senpi not detected, skipping"
    fi
}

install_claude_desktop() {
    local config=""
    case "$(uname -s)" in
        Darwin*) config="$HOME/Library/Application Support/Claude/claude_desktop_config.json" ;;
        Linux*)  config="$HOME/.config/Claude/claude_desktop_config.json" ;;
    esac
    if [[ -n "$config" && -d "$(dirname "$config")" ]]; then
        log_info "Claude Desktop detected"
        add_mcp_server_json "$config" "mcpServers"
        log_skip "Skills are not supported in Claude Desktop, MCP only"
    else
        log_skip "Claude Desktop not detected, skipping"
    fi
}

install_cline() {
    local config="$HOME/.cline/data/settings/cline_mcp_settings.json"
    if [[ -d "$HOME/.cline" ]]; then
        log_info "Cline detected"
        add_mcp_server_json "$config" "mcpServers"
        log_skip "Skills are not supported in Cline, MCP only"
    else
        log_skip "Cline not detected, skipping"
    fi
}

install_roo_code() {
    local config="$HOME/.config/Code/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json"
    if [[ -d "$(dirname "$config")" ]]; then
        log_info "Roo Code detected"
        add_mcp_server_json "$config" "mcpServers"
        log_skip "Skills are not supported in Roo Code, MCP only"
    else
        log_skip "Roo Code not detected, skipping"
    fi
}

main() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Tsuki Plugin Engineering Toolkit     ${NC}"
    echo -e "${GREEN}  Installer                             ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    preflight
    echo ""

    log_info "Detecting and configuring agent harnesses..."
    install_claude_code
    install_opencode
    install_codex
    install_pi
    install_claude_desktop
    install_cline
    install_roo_code

    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
    echo ""
    log_info "Restart your harness(es) to load the MCP server."
    log_info "If nothing was detected automatically, see README.md > 'Manual MCP configuration'."
    log_info "Run ./uninstall.sh at any time to remove everything this script added."
    echo ""
}

main "$@"

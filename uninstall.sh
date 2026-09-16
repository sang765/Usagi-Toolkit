#!/usr/bin/env bash
# ============================================================================
# Tsuki Plugin Engineering Toolkit - Uninstaller
# ============================================================================
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }

remove_config() {
    local file="$1"
    local backup="${file}.bak"
    if [[ -f "$file" ]]; then
        cp "$file" "$backup"
        $PYTHON_CMD -c "
import json, sys
with open('$file') as f: data = json.load(f)
if 'mcpServers' in data and 'tsuki-plugin-engineering' in data['mcpServers']:
    del data['mcpServers']['tsuki-plugin-engineering']
if 'mcp' in data and 'tsuki-plugin-engineering' in data['mcp']:
    del data['mcp']['tsuki-plugin-engineering']
json.dump(data, sys.stdout, indent=2)
" > "${file}.tmp" && mv "${file}.tmp" "$file"
        log_ok "Removed from $file (backup: $backup)"
    fi
}

remove_toml_config() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.bak"
        # Remove the [mcp_servers.tsuki-plugin-engineering] section
        sed -i '/^\[mcp_servers\.tsuki-plugin-engineering\]$/,/^\[/ { /^\[mcp_servers\.tsuki-plugin-engineering\]$/d; /^\[/!d; }' "$file"
        log_ok "Removed from $file (backup: ${file}.bak)"
    fi
}

remove_skill() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
        log_ok "Removed skill from $dir"
    fi
}

main() {
    echo ""
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}  Tsuki Plugin Engineering Toolkit     ${NC}"
    echo -e "${RED}  Uninstaller                           ${NC}"
    echo -e "${RED}========================================${NC}"
    echo ""

    PYTHON_CMD=""
    if command -v python3 &>/dev/null; then
        PYTHON_CMD="python3"
    elif command -v python &>/dev/null; then
        PYTHON_CMD="python"
    else
        log_warn "Python not found. Will remove files manually."
        PYTHON_CMD="echo"
    fi

    # Remove MCP configs
    log_info "Removing MCP server configurations..."
    remove_config "$SCRIPT_DIR/.mcp.json"
    remove_config "$SCRIPT_DIR/opencode.json"
    remove_config "$SCRIPT_DIR/.pi/mcp.json"
    remove_config "$HOME/.claude.json"
    remove_config "$HOME/.config/opencode/opencode.json"
    remove_config "$HOME/.config/mcp/mcp.json"
    remove_toml_config "$HOME/.codex/config.toml"
    remove_config "$HOME/.cline/data/settings/cline_mcp_settings.json"
    remove_config "$HOME/.config/Code/User/globalStorage/rooveterinaryinc.roo-cline/settings/mcp_settings.json"

    case "$(uname -s)" in
        Darwin*)
            remove_config "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
            ;;
        Linux*)
            remove_config "$HOME/.config/Claude/claude_desktop_config.json"
            ;;
    esac

    # Remove skills
    log_info "Removing Skills..."
    remove_skill "$SCRIPT_DIR/.claude/skills/tsuki-plugin-engineering"
    remove_skill "$SCRIPT_DIR/.opencode/skills/tsuki-plugin-engineering"
    remove_skill "$SCRIPT_DIR/.agents/skills/tsuki-plugin-engineering"
    remove_skill "$HOME/.agents/skills/tsuki-plugin-engineering"
    remove_skill "$HOME/.claude/skills/tsuki-plugin-engineering"
    remove_skill "$HOME/.config/opencode/skills/tsuki-plugin-engineering"
    remove_skill "$HOME/.pi/agent/skills/tsuki-plugin-engineering"
    remove_skill "$SCRIPT_DIR/.pi/skills/tsuki-plugin-engineering"

    # Remove the copied MCP runtime created by the unified installer.
    remove_skill "$SCRIPT_DIR/.tsuki-plugin-engineering"
    remove_skill "$HOME/.tsuki-plugin-engineering"

    # Remove extracted files
    log_info "Removing extracted files..."
    if [[ -d "$SCRIPT_DIR/tsuki-extract" ]]; then
        rm -rf "$SCRIPT_DIR/tsuki-extract"
        log_ok "Removed tsuki-extract/"
    fi

    # Remove venv
    if [[ -d "$SCRIPT_DIR/tsuki-llm-toolkit/.venv" ]]; then
        rm -rf "$SCRIPT_DIR/tsuki-llm-toolkit/.venv"
        log_ok "Removed virtual environment"
    fi

    echo ""
    echo -e "${GREEN}Uninstallation complete!${NC}"
    echo ""
    log_info "Restart your harness to unload the MCP server."
    echo ""
}

main "$@"

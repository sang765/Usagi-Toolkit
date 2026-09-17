# Usagi Toolkit

> Make your agent LLMs can make Usagi plugin without how to code

MCP Server + Agent Skill that enables LLMs (Claude Code, OpenCode, Codex, Claude Desktop, Cline, Roo Code, Pi/Senpi) to research, scaffold, implement, test, and build source plugins for [Usagi](https://github.com/UsagiApp/Usagi) using [Tsuki](https://github.com/UsagiApp/Tsuki).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-20%2B-green.svg)](https://nodejs.org/)

## Table of Contents

- [Why this exists](#why-this-exists)
- [Features](#features)
- [Installation](#installation)
- [Commands](#commands)
- [MCP Tools](#mcp-tools)
- [Usage Examples](#usage-examples)
- [Manual Configuration](#manual-configuration)
- [Supported Harnesses](#supported-harnesses)
- [Architecture](#architecture)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Why this exists

Writing a Usagi source plugin isn't hard, but it requires understanding:

- The Tsuki contract (`MangaSource`, `MangaParser`, filters, chapter/page rules)
- How to research a source: locate its API/HTML entry points, work out metadata, filters, pagination
- How to scaffold, fixture, test, and build the resulting Kotlin plugin correctly — without silently dropping pages, mis-ordering chapters, or fabricating fields

**Usagi Toolkit** gives an LLM the **tools + procedural knowledge** to do the whole workflow itself, safely, and with a lawful-use requirement (public API/HTML only, no CAPTCHA/paywall/anti-bot bypass, no unauthorized decryption).

## Features

- **Auto-detection**: Automatically detects and configures for your agent harness (Claude Code, OpenCode, Codex, etc.)
- **20+ MCP Tools**: Complete toolkit for plugin development lifecycle
- **Agent Skill**: Detailed procedural guide for LLMs to follow
- **Live Testing**: Test existing sources against live sites without code changes
- **Fixture Management**: Generate and validate test fixtures
- **Build Integration**: Automated Gradle builds and artifact inspection
- **Compliance**: Built-in access classification and compliance checks

## Installation

### Requirements

- [Bun](https://bun.sh) (required for the recommended `bunx` installer)
- Node.js ≥ 20 is supported for running the MCP server directly
- `git`
- Optional (for building plugins): `java`, Gradle wrapper, `d8` (Android build-tools)

### Quick Install with Bunx (Recommended)

```bash
# Install and run the harness installer directly from GitHub
bunx --bun github:sang765/Usagi-Toolkit install
```

The installer is implemented in JavaScript and runs through Bun. It detects installed harnesses, registers the MCP server using `bunx`, and links the Skill. No Bash or local dependency installation is required.

The installer will:
1. Check for the Bun runtime
2. Detect installed agent harnesses
3. Register the MCP server in each detected harness
4. Link the agent skill where supported
5. Create backups of existing config files

### Manual Install

```bash
# Clone for development or local customization
git clone https://github.com/sang765/Usagi-Toolkit.git
cd Usagi-Toolkit
bun install

# Run the local Bun installer
bun run bin/install.js

# Copy or symlink the skill directory to your harness's skills directory
# Example for OpenCode:
cp -r skill ~/.config/opencode/skills/tsuki-plugin-engineering

# Add MCP server to your harness config (see Manual Configuration below)
```

### From a local package

```bash
bunx --bun ./tsuki-llm-toolkit-0.2.0.tgz install
```

## Commands

### Installation Commands

| Command | Description |
|---------|-------------|
| `bunx --bun github:sang765/Usagi-Toolkit install` | Auto-detect harnesses and install MCP server + Skill |
| `bunx --bun tsuki-llm-toolkit install` | Install from a published package |
| `bun run bin/install.js` | Run the installer from a cloned checkout |
| `./install.sh` | Deprecated compatibility wrapper for the Bun installer |
| `./uninstall.sh` | Remove all changes made by the installer |
| `bun install` | Install development dependencies |
| `npm run build` | Compile TypeScript to JavaScript |
| `npm run typecheck` | Type-check without emitting files |
| `npm test` | Run smoke tests against test fixtures |

### Development Commands

| Command | Description |
|---------|-------------|
| `npm start` | Start the MCP server using tsx |
| `npm run dev` | Start in development mode with hot reload |
| `npm run lint` | Run linter (if configured) |
| `npm run format` | Format code (if configured) |

### Build Commands (for Generated Plugins)

| Command | Description |
|---------|-------------|
| `./gradlew test` | Run plugin tests |
| `./gradlew jar` | Build plugin JAR |
| `d8 --release plugin.jar --output plugin.jar` | Convert JAR to DEX |
| `./gradlew clean` | Clean build artifacts |

## MCP Tools

### Contract & Environment

| Tool | Description |
|------|-------------|
| `tsuki_contract` | Return the Tsuki contract and required build commands |
| `tsuki_check_dependencies` | Check Bun/Node/npm/Java/Gradle/d8/Git/Android SDK availability |

### Access Classification

| Tool | Description |
|------|-------------|
| `tsuki_classify_access` | Classify a capability as public, authenticated, or paywalled before researching |

### Source Research

| Tool | Description |
|------|-------------|
| `tsuki_fetch_public_source` | Fetch public material from an allowlisted host |
| `tsuki_research_source` | Produce a structured research report for a source |
| `tsuki_discover_endpoints` | Find endpoint, pagination, image, and obfuscation hints |

### Fixture & Schema Analysis

| Tool | Description |
|------|-------------|
| `tsuki_extract_schema` | Extract JSON paths or HTML selector hints from a fixture |
| `tsuki_analyze_filters` | Detect filter candidates from a fixture |
| `tsuki_extract_pages` | Extract candidate page URLs, including lazy attrs and srcset |

### Plugin Generation

| Tool | Description |
|------|-------------|
| `tsuki_scaffold_plugin` | Generate a minimal Kotlin scaffold |
| `tsuki_generate_plugin` | Scaffold + fixtures + test checklist + review report |
| `tsuki_generate_fixtures` | Generate fixture templates |
| `tsuki_generate_tests` | Generate a Kotlin test checklist |

### Code Quality

| Tool | Description |
|------|-------------|
| `tsuki_inspect_plugin` | Scan for methods, metadata, filters, ordering, risky patterns |
| `tsuki_validate_plugin` | Validate against required quality rules (errors/warnings) |

### Live Source Testing

| Tool | Description |
|------|-------------|
| `tsuki_test_source_live` | Test source against live site with no code changes |
| `tsuki_mark_source_broken` | Mark an unfixable source with @Deprecated annotation |

### Chapter & Page QA

| Tool | Description |
|------|-------------|
| `tsuki_normalize_chapters` | Sort oldest→newest, strip navigation entries and duplicates |
| `tsuki_validate_pages` | Check page count, gaps, duplicates, placeholders, ordering |
| `tsuki_check_image_urls` | Check structure, allowlist status, and patterns of image URLs |
| `tsuki_compare_page_counts` | Diff page count/order between two snapshots |

### Build & Artifacts

| Tool | Description |
|------|-------------|
| `tsuki_test_plugin` | Run the Gradle test task, structured result |
| `tsuki_build_plugin` | Run test/JAR build, optional DEX step |
| `tsuki_inspect_artifact` | Inspect JAR/DEX artifacts and class names |

### Maintenance & Reporting

| Tool | Description |
|------|-------------|
| `tsuki_compare_source_versions` | Diff two fixture/API snapshots |
| `tsuki_create_source_report` | Merge research/validation/build results into a Markdown report |

## Usage Examples

### Example 1: Create a New Plugin

```
User: Write a plugin for manga-hub.com

LLM:
1. Call tsuki_check_dependencies → verify environment
2. Call tsuki_contract → read MangaSource.kt, MangaParser.kt
3. Call tsuki_classify_access for:
   - search: https://manga-hub.com/api/search
   - details: https://manga-hub.com/api/manga/{id}
   - chapter_list: https://manga-hub.com/api/manga/{id}/chapters
   - chapter_pages: https://manga-hub.com/api/chapter/{id}/pages
   → Determine which capabilities are public vs authenticated
4. Call tsuki_research_source (scoped to public capabilities only)
5. Call tsuki_discover_endpoints, tsuki_extract_schema, tsuki_analyze_filters
6. Call tsuki_generate_plugin (or tsuki_scaffold_plugin for minimal start)
7. Implement the parser: getList, getDetails, getPages, getPageUrl
8. Call tsuki_generate_fixtures, tsuki_generate_tests
9. Call tsuki_inspect_plugin, then tsuki_validate_plugin
10. Call tsuki_test_plugin, tsuki_build_plugin, tsuki_inspect_artifact
11. Call tsuki_create_source_report → produce handoff report
```

### Example 2: Test an Existing Source

```
User: /test-source MangaDex

LLM:
1. Call tsuki_test_source_live("MangaDex")
   → Extracts domain, CSS selectors, JSON keys from Kotlin file
   → Fetches live domain and checks if literals still match
2. Call tsuki_inspect_plugin → structural/static findings
3. Present test report:
   - What was checked
   - What passed
   - What failed with evidence
   - What's inconclusive
4. If failures found, offer to run /fix-source
```

### Example 3: Fix a Broken Source

```
User: /fix-source MangaHub

LLM:
1. Start from /test-source report (run it first if needed)
2. For each failing check:
   - Investigate root cause using tsuki_fetch_public_source
   - Check if domain moved, CSS class renamed, site restructured
3. Fix only confirmed broken parts:
   - Update specific selector, JSON key, endpoint, or domain literal
   - Keep surrounding logic untouched
4. Re-run tsuki_test_source_live to confirm fixes
5. If unfixable (site shutdown, domain dead):
   - Call tsuki_mark_source_broken with reason
   - Adds @Deprecated annotation + KDoc explanation
6. Report what was fixed, evidence, and what needs human judgment
```

### Example 4: Research a Source

```
User: Research manga-kai.net for plugin development

LLM:
1. Call tsuki_classify_access([
     { name: "search", url: "https://manga-kai.net/search" },
     { name: "details", url: "https://manga-kai.net/manga/example" },
     { name: "chapter_list", url: "https://manga-kai.net/manga/example/chapters" },
     { name: "chapter_pages", url: "https://manga-kai.net/chapter/example" }
   ])
   → Classify each capability as public/authenticated/paywalled
2. Call tsuki_research_source("https://manga-kai.net")
   → Structured research report
3. Call tsuki_discover_endpoints → find API patterns
4. Call tsuki_extract_schema → analyze fixture structure
5. Call tsuki_analyze_filters → detect filter candidates
6. Produce research report with:
   - Access classification per capability
   - API/HTML endpoints
   - Metadata fields
   - Available filters
   - Compliance notes
```

## Manual Configuration

The server communicates over stdio, so any MCP-compatible harness can launch it directly.

### Claude Code / Claude Desktop / Cline / Roo Code

Create or edit `.mcp.json` (or equivalent config file):

```json
{
  "mcpServers": {
    "tsuki-plugin-engineering": {
      "command": "node",
      "args": ["/absolute/path/to/Usagi-Toolkit/bin/run.js"]
    }
  }
}
```

### OpenCode

Create or edit `opencode.json`:

```json
{
  "mcp": {
    "tsuki-plugin-engineering": {
      "type": "local",
      "command": ["node", "/absolute/path/to/Usagi-Toolkit/bin/run.js"],
      "enabled": true
    }
  }
}
```

### Codex

Edit `~/.codex/config.toml`:

```toml
[mcp_servers.tsuki-plugin-engineering]
command = "node"
args = ["/absolute/path/to/Usagi-Toolkit/bin/run.js"]
```

### Pi/Senpi

Create or edit `.pi/mcp.json`:

```json
{
  "mcpServers": {
    "tsuki-plugin-engineering": {
      "command": "node",
      "args": ["/absolute/path/to/Usagi-Toolkit/bin/run.js"]
    }
  }
}
```

### Runtime Selection

If you have [Bun](https://bun.sh) installed, use `"command": "bun"` for faster cold start:

```json
{
  "command": "bun",
  "args": ["/absolute/path/to/Usagi-Toolkit/bin/run.js"]
}
```

Or set the `TSUKI_MCP_RUNTIME` environment variable to force a specific runtime.

## Supported Harnesses

| Harness | MCP Support | Skill Support | Auto-Install |
|---------|-------------|---------------|--------------|
| Claude Code | ✅ | ✅ | ✅ |
| OpenCode | ✅ | ✅ | ✅ |
| Codex | ✅ | ✅ | ✅ |
| Pi/Senpi | ✅ | ✅ | ✅ |
| Claude Desktop | ✅ | ❌ | ✅ |
| Cline | ✅ | ❌ | ✅ |
| Roo Code | ✅ | ❌ | ✅ |

### Skill Support Details

Harnesses with Skill support receive:
- `skill/SKILL.md` - Main procedural guide
- `skill/references/` - Additional documentation

The skill provides LLMs with:
1. Step-by-step workflow for plugin development
2. Parser contracts and requirements
3. Access classification procedures
4. Quality standards and validation rules
5. Slash commands for testing and fixing sources

## Architecture

```
Usagi-Toolkit/
├── server.ts               # MCP server - full Tsuki command suite
├── bin/
│   └── run.js              # stdio launcher (Node/Bun auto-detect)
├── skill/                  # Agent Skill - detailed procedural guide
│   ├── SKILL.md
│   └── references/
│       ├── api_reference.md
│       ├── parser-engineering.md
│       ├── research-checklist.md
│       └── access-classification.md
├── scripts/
│   └── smoke-test.ts       # offline fixture-based smoke test
├── test-fixtures/          # sample chapter fixtures for tests
│   ├── chapters-v1/
│   └── chapters-v2/
├── bin/install.js          # Bun/bunx auto-installer
├── install.sh              # Deprecated compatibility wrapper
├── uninstall.sh            # Remove all changes made by the installer
├── AGENTS.*.md             # harness-specific behavior guides
├── package.json
├── tsconfig.json
└── README.md
```

### Key Components

- **MCP Server** (`server.ts`): Provides 20+ tools for plugin development
- **Agent Skill** (`skill/SKILL.md`): Procedural guide for LLMs
- **Auto-installer** (`bunx ... install`): Detects and configures harnesses without Bash
- **Test Fixtures** (`test-fixtures/`): Sample data for testing

## Development

### Setup

```bash
# Clone the repository
git clone https://github.com/sang765/Usagi-Toolkit.git
cd Usagi-Toolkit

# Install dependencies
bun install

# Start development
npm start
```

### Available Scripts

```bash
# Start the MCP server
npm start

# Build for production
npm run build

# Type-check only
npm run typecheck

# Run tests
npm test
```

### Project Structure

- `server.ts` - Main MCP server implementation
- `bin/run.js` - Entry point for stdio communication
- `skill/` - Agent skill documentation
- `scripts/` - Development and testing scripts
- `test-fixtures/` - Sample data for testing

### Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow TypeScript best practices
- Add tests for new functionality
- Update documentation as needed
- Ensure all tools follow the compliance rules

## License

MIT License - see [LICENSE](LICENSE) for details.

Tsuki, Usagi, and any plugins generated with this toolkit remain governed by their own respective licenses and terms.

## Acknowledgments

- [Usagi](https://github.com/UsagiApp/Usagi) - The manga reader app
- [Tsuki](https://github.com/UsagiApp/Tsuki) - The plugin framework
- [Model Context Protocol](https://modelcontextprotocol.io/) - The MCP standard

## Support

- [GitHub Issues](https://github.com/sang765/Usagi-Toolkit/issues)
- [Documentation](https://github.com/sang765/Usagi-Toolkit/wiki)

## Security

This toolkit is designed for lawful use only. It must never be used to:

- Bypass CAPTCHA, paywalls, authentication, or anti-bot defenses
- Perform unauthorized decryption
- Access protected content without permission
- Violate terms of service of any website

See [`skill/references/access-classification.md`](skill/references/access-classification.md) for detailed compliance guidelines.

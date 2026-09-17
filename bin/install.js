#!/usr/bin/env node
import { existsSync, mkdirSync, readFileSync, writeFileSync, symlinkSync, cpSync, copyFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { homedir, platform } from "node:os";
import { fileURLToPath } from "node:url";

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const HOME = homedir();
const SERVER_NAME = "tsuki-plugin-engineering";
const SKILL_SRC = join(ROOT, "skill");
const args = process.argv.slice(2);
const packageSpec = args.includes("--package") ? args[args.indexOf("--package") + 1] : process.env.TSUKI_BUNX_PACKAGE || "github:sang765/Usagi-Toolkit";
const mcpCommand = "bunx";
const mcpArgs = ["--bun", packageSpec];

const blue = (message) => console.log(`\x1b[34m[INFO]\x1b[0m ${message}`);
const green = (message) => console.log(`\x1b[32m[OK]\x1b[0m ${message}`);
const yellow = (message) => console.log(`\x1b[33m[WARN]\x1b[0m ${message}`);
const skip = (message) => console.log(`  - ${message}`);
const ensureDir = (path) => mkdirSync(dirname(path), { recursive: true });

function backup(path) {
  if (existsSync(path)) copyFileSync(path, `${path}.bak`);
}

function mergeJson(path, key) {
  ensureDir(path);
  backup(path);
  let data = {};
  if (existsSync(path)) {
    try { data = JSON.parse(readFileSync(path, "utf8")); } catch { yellow(`Could not parse ${path}; replacing with a minimal JSON config`); }
  }
  data[key] ??= {};
  data[key][SERVER_NAME] = { command: mcpCommand, args: mcpArgs };
  writeFileSync(path, `${JSON.stringify(data, null, 2)}\n`);
  green(`Registered MCP server in ${path}`);
}

function mergeToml(path) {
  ensureDir(path);
  if (!existsSync(path)) writeFileSync(path, "");
  backup(path);
  const current = readFileSync(path, "utf8");
  const section = `[mcp_servers.${SERVER_NAME}]`;
  if (current.includes(section)) return skip(`${path} already has an [mcp_servers.${SERVER_NAME}] section`);
  const escaped = mcpArgs.map((value) => JSON.stringify(value)).join(", ");
  writeFileSync(path, `${current.trimEnd()}\n\n${section}\ncommand = ${JSON.stringify(mcpCommand)}\nargs = [${escaped}]\n`);
  green(`Registered MCP server in ${path}`);
}

function linkSkill(destination) {
  if (!existsSync(SKILL_SRC)) return;
  const target = join(destination, SERVER_NAME);
  mkdirSync(destination, { recursive: true });
  if (existsSync(target)) return skip(`Skill already present at ${target}`);
  try { symlinkSync(SKILL_SRC, target, "junction"); green(`Linked skill into ${target}`); }
  catch { cpSync(SKILL_SRC, target, { recursive: true }); green(`Copied skill into ${target}`); }
}

function hasHarness(directory, command) {
  return existsSync(directory) || Boolean(command && process.env.PATH?.split(process.platform === "win32" ? ";" : ":").some((dir) => existsSync(join(dir, command))));
}

function install() {
  console.log("\nTsuki Plugin Engineering Toolkit — Bun installer\n");
  blue(`Using Bun package spec: ${packageSpec}`);
  if (!process.versions.bun) yellow("Installer is running under Node; invoke it with bunx for the intended Bun runtime.");
  if (hasHarness(join(HOME, ".claude"), "claude")) { blue("Claude Code detected"); mergeJson(join(process.cwd(), ".mcp.json"), "mcpServers"); linkSkill(join(process.cwd(), ".claude", "skills")); linkSkill(join(HOME, ".claude", "skills")); } else skip("Claude Code not detected");
  if (hasHarness(join(HOME, ".config", "opencode"), "opencode")) { blue("OpenCode detected"); mergeJson(join(process.cwd(), "opencode.json"), "mcp"); linkSkill(join(process.cwd(), ".opencode", "skills")); linkSkill(join(HOME, ".config", "opencode", "skills")); } else skip("OpenCode not detected");
  if (hasHarness(join(HOME, ".codex"), "codex")) { blue("Codex detected"); mergeToml(join(HOME, ".codex", "config.toml")); linkSkill(join(process.cwd(), ".agents", "skills")); linkSkill(join(HOME, ".agents", "skills")); } else skip("Codex not detected");
  if (existsSync(join(HOME, ".pi"))) { blue("Pi/Senpi detected"); mergeJson(join(process.cwd(), ".pi", "mcp.json"), "mcpServers"); linkSkill(join(process.cwd(), ".pi", "skills")); linkSkill(join(HOME, ".pi", "agent", "skills")); } else skip("Pi/Senpi not detected");
  const desktopConfig = platform() === "darwin" ? join(HOME, "Library", "Application Support", "Claude", "claude_desktop_config.json") : join(HOME, ".config", "Claude", "claude_desktop_config.json");
  if (existsSync(dirname(desktopConfig))) { blue("Claude Desktop detected"); mergeJson(desktopConfig, "mcpServers"); skip("Skills are not supported in Claude Desktop; MCP only"); } else skip("Claude Desktop not detected");
  if (existsSync(join(HOME, ".cline"))) { blue("Cline detected"); mergeJson(join(HOME, ".cline", "data", "settings", "cline_mcp_settings.json"), "mcpServers"); skip("Skills are not supported in Cline; MCP only"); } else skip("Cline not detected");
  const rooConfig = join(HOME, ".config", "Code", "User", "globalStorage", "rooveterinaryinc.roo-cline", "settings", "mcp_settings.json");
  if (existsSync(dirname(rooConfig))) { blue("Roo Code detected"); mergeJson(rooConfig, "mcpServers"); skip("Skills are not supported in Roo Code; MCP only"); } else skip("Roo Code not detected");
  console.log("\n\x1b[32mInstallation complete!\x1b[0m");
  blue("Restart detected harnesses to load the MCP server.");
  blue(`Run again: bunx --bun ${packageSpec} install`);
}

install();

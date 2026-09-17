#!/usr/bin/env node
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
if (process.argv[2] === "install") {
  const installer = join(root, "bin", "install.js");
  const child = spawn(process.versions.bun ? process.execPath : process.execPath, [installer, ...process.argv.slice(3)], { cwd: root, stdio: "inherit", env: process.env });
  child.on("exit", (code, signal) => process.exit(signal ? 1 : (code ?? 1)));
  child.on("error", (error) => { console.error(`Unable to start installer: ${error.message}`); process.exit(1); });
} else {
const server = join(root, "server.ts");
const localTsx = join(root, "node_modules", ".bin", process.platform === "win32" ? "tsx.cmd" : "tsx");
const command = process.env.TSUKI_MCP_RUNTIME || (process.versions.bun ? process.execPath : localTsx);
const args = process.versions.bun ? [server, ...process.argv.slice(2)] : [server, ...process.argv.slice(2)];
const child = spawn(command, args, { cwd: root, stdio: "inherit", env: process.env });
child.on("exit", (code, signal) => process.exit(signal ? 1 : (code ?? 1)));
child.on("error", (error) => { console.error(`Unable to start Tsuki MCP server: ${error.message}`); process.exit(1); });
}

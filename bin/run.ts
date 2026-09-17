#!/usr/bin/env bun
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const childArgs = process.argv.slice(3);

function forward(child: ReturnType<typeof spawn>, label: string): void {
  child.on("exit", (code, signal) => process.exit(signal ? 1 : (code ?? 1)));
  child.on("error", (error) => {
    console.error(`Unable to start ${label}: ${error.message}`);
    process.exit(1);
  });
}

if (process.argv[2] === "install") {
  const installer = join(root, "bin", "install.ts");
  forward(spawn(process.execPath, [installer, ...childArgs], { cwd: root, stdio: "inherit", env: process.env }), "installer");
} else {
  const server = join(root, "server.ts");
  const localTsx = join(root, "node_modules", ".bin", process.platform === "win32" ? "tsx.cmd" : "tsx");
  const command = process.env.TSUKI_MCP_RUNTIME || (process.versions.bun ? process.execPath : localTsx);
  forward(spawn(command, [server, ...process.argv.slice(2)], { cwd: root, stdio: "inherit", env: process.env }), "MCP server");
}

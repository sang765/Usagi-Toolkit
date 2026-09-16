import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const root = process.cwd();
const transport = new StdioClientTransport({ command: "npx", args: ["tsx", join(root, "server.ts")] });
const client = new Client({ name: "tsuki-smoke-test", version: "0.2.0" });
await client.connect(transport);

const listed = await client.listTools();
const names = new Set(listed.tools.map((tool) => tool.name));
const required = [
  "tsuki_contract", "tsuki_check_dependencies", "tsuki_research_source", "tsuki_discover_endpoints",
  "tsuki_extract_schema", "tsuki_analyze_filters", "tsuki_extract_pages", "tsuki_validate_pages",
  "tsuki_check_image_urls", "tsuki_compare_page_counts", "tsuki_normalize_chapters", "tsuki_scaffold_plugin",
  "tsuki_generate_plugin", "tsuki_generate_fixtures", "tsuki_generate_tests", "tsuki_inspect_plugin",
  "tsuki_validate_plugin", "tsuki_test_plugin", "tsuki_build_plugin", "tsuki_inspect_artifact",
  "tsuki_compare_source_versions", "tsuki_create_source_report",
];
for (const name of required) if (!names.has(name)) throw new Error(`Missing MCP tool: ${name}`);

function parse(call: Awaited<ReturnType<typeof client.callTool>>) {
  const item = call.content?.[0];
  if (!item || item.type !== "text") throw new Error("Tool did not return text JSON");
  return JSON.parse(item.text);
}

const contract = parse(await client.callTool({ name: "tsuki_contract", arguments: {} }));
if (!contract.manga_source || !contract.manga_parser) throw new Error("Contract documents were not loaded");

const normalized = parse(await client.callTool({
  name: "tsuki_normalize_chapters",
  arguments: { fixture_path: join(root, "test-fixtures/chapters-v1/chapters.json") },
}));
if (normalized.chapters.map((x: { number: number }) => x.number).join(",") !== "1,10") throw new Error("Chapter normalization failed");
if (normalized.removed.length !== 2) throw new Error("Navigation and duplicate removal failed");

const pageValidation = parse(await client.callTool({
  name: "tsuki_validate_pages",
  arguments: { pages: [{ index: 1, url: "https://example.org/1.jpg" }, { index: 3, url: "https://example.org/3.jpg" }], expected_count: 3 },
}));
if (pageValidation.ok || !pageValidation.missing_indexes.includes(2)) throw new Error("Page gap validation failed");

const temp = mkdtempSync(join(tmpdir(), "tsuki-smoke-"));
const generated = parse(await client.callTool({
  name: "tsuki_generate_plugin",
  arguments: { package_name: "com.example.smoke", source_name: "SmokeSource", domain: "example.org", output_dir: temp },
}));
if (!generated.source_file || !readFileSync(generated.source_file, "utf8").includes("SmokeSource")) throw new Error("Plugin generation failed");

const compared = parse(await client.callTool({
  name: "tsuki_compare_source_versions",
  arguments: { before_path: join(root, "test-fixtures/chapters-v1"), after_path: join(root, "test-fixtures/chapters-v2") },
}));
if (!compared.changed.length) throw new Error("Version comparison failed");

await client.close();
rmSync(temp, { recursive: true, force: true });
console.log(`MCP smoke test passed: ${names.size} tools registered`);

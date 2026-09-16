# Tsuki Plugin Engineering Toolkit

MCP Server + Agent Skill — giúp LLM (Claude Code, OpenCode, Codex, ...) học cách research, crawl, lấy API và tạo source plugin cho [Usagi](https://github.com/UsagiApp/Usagi) bằng [Tsuki](https://github.com/UsagiApp/Tsuki).

## Mục đích

Viết plugin Usagi không khó, nhưng cần hiểu:
- Contract của Tsuki (MangaSource, MangaParser, filters, ...)
- Cách research một nguồn: tìm API/HTML, xác định metadata, filters, pagination
- Cách scaffold, build, test plugin

Toolkit này cung cấp cho LLM **công cụ + kiến thức** để tự thực hiện toàn bộ quy trình.

## Cài đặt

```bash
git clone https://github.com/UsagiApp/tsuki-llm-toolkit.git
cd tsuki-llm-toolkit
./install.sh
```

Yêu cầu: [bun](https://bun.sh) hoặc Node.js 20+

## Cấu trúc

```
├── server.ts              # MCP server — expanded Tsuki command suite
├── skill/                 # Agent skill — hướng dẫn chi tiết
│   ├── SKILL.md
│   └── references/
├── docs/                  # Contract snapshots từ Tsuki
│   ├── MangaParser.kt
│   └── MangaSource.kt
├── install.sh             # Auto-detect harness, cài MCP + Skill
└── uninstall.sh
```

## MCP Tools

| Tool | Mô tả |
|------|-------|
| `tsuki_contract` | Trả về contract Tsuki và build commands |
| `tsuki_check_dependencies` | Kiểm tra Bun/Node/npm/Java/Gradle/d8/Git/Android SDK |
| `tsuki_fetch_public_source` | Fetch public material từ host được allowlist |
| `tsuki_research_source` | Tạo structured research report cho một source |
| `tsuki_discover_endpoints` | Tìm endpoint, pagination, image và encoding hints |
| `tsuki_extract_schema` | Trích xuất JSON paths hoặc HTML selector hints |
| `tsuki_analyze_filters` | Phân tích filter candidates từ fixture |
| `tsuki_extract_pages` | Lấy candidate page URLs từ JSON/HTML, lazy attributes và srcset |
| `tsuki_validate_pages` | Kiểm tra page count, gap, duplicate, placeholder và thứ tự |
| `tsuki_check_image_urls` | Kiểm tra cấu trúc, allowlist và pattern của image URLs |
| `tsuki_compare_page_counts` | So sánh số lượng và thứ tự trang giữa hai snapshot |
| `tsuki_normalize_chapters` | Sắp xếp cũ → mới, loại navigation và duplicate |
| `tsuki_scaffold_plugin` | Tạo scaffold Kotlin tối thiểu |
| `tsuki_generate_plugin` | Tạo scaffold + fixtures + test checklist + review |
| `tsuki_generate_fixtures` | Tạo fixture templates |
| `tsuki_generate_tests` | Tạo test checklist Kotlin |
| `tsuki_inspect_plugin` | Quét method, metadata, filter, ordering và risky patterns |
| `tsuki_validate_plugin` | Validate quality rules với error/warning rõ ràng |
| `tsuki_test_plugin` | Chạy Gradle test và trả structured result |
| `tsuki_build_plugin` | Chạy test/JAR build và tùy chọn dex |
| `tsuki_inspect_artifact` | Kiểm tra JAR/DEX và class names |
| `tsuki_compare_source_versions` | So sánh fixture/API snapshot trước và sau |
| `tsuki_create_source_report` | Gộp research/validation/build thành Markdown report |

## Skill

Skill `tsuki-plugin-engineering` hướng dẫn LLM quy trình:

1. Gọi `tsuki_contract` trước khi viết Kotlin
2. Research source: API/HTML endpoints, metadata, filters, pagination
3. Verify terms, robots.txt, rate limits
4. Scaffold → Implement → Test → Build
5. Report: metadata coverage, filter coverage, chapter ordering, compliance

## Hỗ trợ

| Harness | MCP | Skill |
|---------|-----|-------|
| Claude Code | ✅ | ✅ |
| OpenCode | ✅ | ✅ |
| Codex | ✅ | ✅ |
| Pi/Senpi | ✅ | ✅ |
| Claude Desktop | ✅ | ❌ |
| Cline | ✅ | ❌ |
| Roo Code | ✅ | ❌ |

## Ví dụ usage

```
User: Viết plugin cho manga-hub.com

LLM:
1. Gọi `tsuki_check_dependencies` để kiểm tra môi trường
2. Gọi `tsuki_contract` → đọc MangaSource.kt, MangaParser.kt
3. Gọi `tsuki_research_source` → tạo source research report
4. Gọi `tsuki_discover_endpoints`, `tsuki_extract_schema`, `tsuki_analyze_filters`
5. Gọi `tsuki_generate_plugin` hoặc `tsuki_scaffold_plugin`
6. Implement parser: getList, getDetails, getPages, getPageUrl
7. Gọi `tsuki_generate_fixtures`, `tsuki_generate_tests`
8. Gọi `tsuki_inspect_plugin`, sau đó `tsuki_validate_plugin`
9. Gọi `tsuki_test_plugin`, `tsuki_build_plugin` và `tsuki_inspect_artifact`
10. Gọi `tsuki_create_source_report` để tạo report bàn giao

Các tool research chỉ fetch HTTPS public material từ host mặc định an toàn hoặc host được agent truyền rõ trong `allow_hosts`. Không dùng toolkit để vượt CAPTCHA, paywall, authentication, anti-bot, access control hoặc giải mã trái phép.
```

## License

MIT. Tsuki và plugin tạo ra vẫn chịu license riêng.

# Usagi Toolkit

> Giúp LLM agent tạo plugin Usagi mà không cần biết code

MCP Server + Agent Skill giúp LLM (Claude Code, OpenCode, Codex, Claude Desktop, Cline, Roo Code, Pi/Senpi) research, scaffold, implement, test và build source plugin cho [Usagi](https://github.com/UsagiApp/Usagi) bằng [Tsuki](https://github.com/UsagiApp/Tsuki).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-20%2B-green.svg)](https://nodejs.org/)

## Mục lục

- [Tại sao tồn tại](#tại-sao-tồn-tại)
- [Tính năng](#tính-năng)
- [Cài đặt](#cài-đặt)
- [Lệnh](#lệnh)
- [Công cụ MCP](#công-cụ-mcp)
- [Ví dụ sử dụng](#ví-dụ-sử-dụng)
- [Cấu hình thủ công](#cấu-hình-thủ-công)
- [Harness được hỗ trợ](#harness-được-hỗ-trợ)
- [Kiến trúc](#kiến-trúc)
- [Phát triển](#phát-triển)
- [Đóng góp](#đóng-góp)
- [Giấy phép](#giấy-phép)

## Tại sao tồn tại

Viết plugin Usagi không khó, nhưng cần hiểu:

- Contract của Tsuki (`MangaSource`, `MangaParser`, filters, chapter/page rules)
- Cách research một nguồn: tìm API/HTML entry points, xác định metadata, filters, pagination
- Cách scaffold, fixture, test và build plugin Kotlin chính xác — không được tự ý bỏ trang, sắp xếp sai chương, hay bịa field

**Usagi Toolkit** cung cấp cho LLM **công cụ + kiến thức** để thực hiện toàn bộ quy trình một cách an toàn, với yêu cầu sử dụng hợp pháp (chỉ public API/HTML, không bypass CAPTCHA/paywall/anti-bot, không giải mã trái phép).

## Tính năng

- **Tự động phát hiện**: Tự nhận diện và cấu hình cho harness agent (Claude Code, OpenCode, Codex, v.v.)
- **20+ công cụ MCP**: Bộ công cụ hoàn chỉnh cho vòng đời phát triển plugin
- **Agent Skill**: Hướng dẫn quy trình chi tiết cho LLM
- **Test trực tiếp**: Test source hiện có trên site sống mà không cần sửa code
- **Quản lý Fixture**: Tạo và validate fixture test
- **Tích hợp Build**: Tự động build Gradle và kiểm tra artifact
- **Tuân thủ**: Kiểm tra phân loại truy cập và tuân thủ quy định

## Cài đặt

### Yêu cầu

- [Bun](https://bun.sh) (bắt buộc cho installer `bunx` được khuyến nghị)
- Node.js ≥ 20 được hỗ trợ khi chạy MCP server trực tiếp
- `git`
- Tùy chọn (để build plugin): `java`, Gradle wrapper, `d8` (Android build-tools)

### Cài đặt nhanh bằng Bunx (Khuyến nghị)

```bash
# Cài và chạy installer trực tiếp từ GitHub
bunx --bun github:sang765/Usagi-Toolkit install
```

Installer hiện được viết bằng JavaScript và chạy qua Bun. Không cần Bash hoặc cài dependencies cục bộ.

Installer sẽ:
1. Kiểm tra Bun runtime
2. Phát hiện các harness agent đã cài
3. Đăng ký MCP server trong mỗi harness
4. Link agent skill where supported
5. Tạo backup các file config hiện có

### Cài đặt thủ công

```bash
# Clone để phát triển hoặc tùy chỉnh local
git clone https://github.com/sang765/Usagi-Toolkit.git
cd Usagi-Toolkit
bun install

# Chạy Bun installer local
bun run bin/install.ts

# Copy hoặc symlink skill directory vào skills directory của harness
# Ví dụ cho OpenCode:
cp -r skill ~/.config/opencode/skills/tsuki-plugin-engineering

# Thêm MCP server vào config của harness (xem Cấu hình thủ công bên dưới)
```

### Từ local package

```bash
bunx --bun ./tsuki-llm-toolkit-0.2.0.tgz install
```

## Lệnh

### Lệnh cài đặt

| Lệnh | Mô tả |
|------|-------|
| `bunx --bun github:sang765/Usagi-Toolkit install` | Tự phát hiện harness và cài MCP server + Skill |
| `bunx --bun tsuki-llm-toolkit install` | Cài từ package đã publish |
| `bun run bin/install.ts` | Chạy installer từ repository đã clone |
| `./install.sh` | Wrapper tương thích cũ cho Bun installer |
| `./uninstall.sh` | Xóa các thay đổi do installer tạo ra |
| `bun install` | Cài development dependencies |
| `npm run build` | Biên dịch TypeScript sang JavaScript |
| `npm run typecheck` | Kiểm tra type không emit file |
| `npm test` | Chạy smoke test với test fixtures |

### Lệnh phát triển

| Lệnh | Mô tả |
|------|-------|
| `npm start` | Khởi chạy MCP server bằng tsx |
| `npm run dev` | Chạy ở chế độ phát triển với hot reload |
| `npm run lint` | Chạy linter (nếu được cấu hình) |
| `npm run format` | Định dạng code (nếu được cấu hình) |

### Lệnh build (cho Plugin được tạo)

| Lệnh | Mô tả |
|------|-------|
| `./gradlew test` | Chạy test plugin |
| `./gradlew jar` | Build plugin JAR |
| `d8 --release plugin.jar --output plugin.jar` | Chuyển JAR sang DEX |
| `./gradlew clean` | Xóa artifact build |

## Công cụ MCP

### Contract & Môi trường

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_contract` | Trả về contract Tsuki và các lệnh build cần thiết |
| `tsuki_check_dependencies` | Kiểm tra Bun/Node/npm/Java/Gradle/d8/Git/Android SDK |

### Phân loại truy cập

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_classify_access` | Phân loại capability là public, authenticated, hoặc paywalled trước khi research |

### Research nguồn

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_fetch_public_source` | Fetch material public từ host được allowlist |
| `tsuki_research_source` | Tạo structured research report cho source |
| `tsuki_discover_endpoints` | Tìm endpoint, pagination, image và obfuscation hints |

### Phân tích Fixture & Schema

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_extract_schema` | Trích xuất JSON paths hoặc HTML selector hints từ fixture |
| `tsuki_analyze_filters` | Phát hiện filter candidates từ fixture |
| `tsuki_extract_pages` | Trích xuất candidate page URLs, bao gồm lazy attrs và srcset |

### Tạo Plugin

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_scaffold_plugin` | Tạo scaffold Kotlin tối thiểu |
| `tsuki_generate_plugin` | Scaffold + fixtures + test checklist + review report |
| `tsuki_generate_fixtures` | Tạo fixture templates |
| `tsuki_generate_tests` | Tạo test checklist Kotlin |

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_inspect_plugin` | Quét methods, metadata, filters, ordering, risky patterns |
| `tsuki_validate_plugin` | Validate theo quality rules (errors/warnings) |

### Test Source trực tiếp

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_test_source_live` | Test source trên site sống mà không cần sửa code |
| `tsuki_mark_source_broken` | Đánh dấu source không thể sửa với @Deprecated annotation |

### Kiểm tra Chương & Trang

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_normalize_chapters` | Sắp xếp cũ → mới, loại bỏ navigation entries và duplicates |
| `tsuki_validate_pages` | Kiểm tra page count, gaps, duplicates, placeholders, ordering |
| `tsuki_check_image_urls` | Kiểm tra cấu trúc, allowlist status và patterns của image URLs |
| `tsuki_compare_page_counts` | So sánh page count/order giữa hai snapshot |

### Build & Artifacts

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_test_plugin` | Chạy Gradle test task, structured result |
| `tsuki_build_plugin` | Chạy test/JAR build, tùy chọn DEX |
| `tsuki_inspect_artifact` | Kiểm tra JAR/DEX artifacts và class names |

### Bảo trì & Báo cáo

| Công cụ | Mô tả |
|---------|-------|
| `tsuki_compare_source_versions` | So sánh hai fixture/API snapshots |
| `tsuki_create_source_report` | Gộp research/validation/build thành Markdown report |

## Ví dụ sử dụng

### Ví dụ 1: Tạo Plugin mới

```
User: Viết plugin cho manga-hub.com

LLM:
1. Gọi tsuki_check_dependencies → kiểm tra môi trường
2. Gọi tsuki_contract → đọc MangaSource.kt, MangaParser.kt
3. Gọi tsuki_classify_access cho:
   - search: https://manga-hub.com/api/search
   - details: https://manga-hub.com/api/manga/{id}
   - chapter_list: https://manga-hub.com/api/manga/{id}/chapters
   - chapter_pages: https://manga-hub.com/api/chapter/{id}/pages
   → Xác định capability nào là public vs authenticated
4. Gọi tsuki_research_source (scoped cho public capabilities only)
5. Gọi tsuki_discover_endpoints, tsuki_extract_schema, tsuki_analyze_filters
6. Gọi tsuki_generate_plugin (hoặc tsuki_scaffold_plugin nếu muốn minimal)
7. Implement parser: getList, getDetails, getPages, getPageUrl
8. Gọi tsuki_generate_fixtures, tsuki_generate_tests
9. Gọi tsuki_inspect_plugin, sau đó tsuki_validate_plugin
10. Gọi tsuki_test_plugin, tsuki_build_plugin, tsuki_inspect_artifact
11. Gọi tsuki_create_source_report → tạo report bàn giao
```

### Ví dụ 2: Test Source hiện có

```
User: /test-source MangaDex

LLM:
1. Gọi tsuki_test_source_live("MangaDex")
   → Trích xuất domain, CSS selectors, JSON keys từ file Kotlin
   → Fetch domain sống và kiểm tra xem literals còn khớp không
2. Gọi tsuki_inspect_plugin → findings structural/static
3. Trình bày test report:
   - Kiểm tra những gì
   - Cái nào pass
   - Cái nào fail với evidence
   - Cái nào chưa rõ
4. Nếu có failures, đề nghị chạy /fix-source
```

### Ví dụ 3: Sửa Source bị hỏng

```
User: /fix-source MangaHub

LLM:
1. Bắt đầu từ /test-source report (chạy trước nếu chưa có)
2. Với mỗi failing check:
   - Điều tra root cause bằng tsuki_fetch_public_source
   - Kiểm tra domain có chuyển không, CSS class có đổi tên không, site có restructure không
3. Sửa chỉ những phần confirmed broken:
   - Update selector, JSON key, endpoint, hoặc domain literal cụ thể
   - Giữ nguyên logic xung quanh
4. Chạy lại tsuki_test_source_live để xác nhận fixes
5. Nếu không thể sửa (site shutdown, domain chết):
   - Gọi tsuki_mark_source_broken với reason
   - Thêm @Deprecated annotation + KDoc explanation
6. Báo cáo những gì đã sửa, evidence, và phần cần human judgment
```

### Ví dụ 4: Research Source

```
User: Research manga-kai.net để phát triển plugin

LLM:
1. Gọi tsuki_classify_access([
     { name: "search", url: "https://manga-kai.net/search" },
     { name: "details", url: "https://manga-kai.net/manga/example" },
     { name: "chapter_list", url: "https://manga-kai.net/manga/example/chapters" },
     { name: "chapter_pages", url: "https://manga-kai.net/chapter/example" }
   ])
   → Phân loại mỗi capability là public/authenticated/paywalled
2. Gọi tsuki_research_source("https://manga-kai.net")
   → Structured research report
3. Gọi tsuki_discover_endpoints → tìm API patterns
4. Gọi tsuki_extract_schema → phân tích fixture structure
5. Gọi tsuki_analyze_filters → phát hiện filter candidates
6. Tạo research report với:
   - Phân loại truy cập cho mỗi capability
   - API/HTML endpoints
   - Metadata fields
   - Filters có sẵn
   - Compliance notes
```

## Cấu hình thủ công

Server giao tiếp qua stdio, nên bất kỳ harness nào hỗ trợ MCP đều có thể khởi chạy trực tiếp.

### Claude Code / Claude Desktop / Cline / Roo Code

Tạo hoặc sửa `.mcp.json` (hoặc config file tương ứng):

```json
{
  "mcpServers": {
    "tsuki-plugin-engineering": {
      "command": "bun",
      "args": ["/absolute/path/to/Usagi-Toolkit/bin/run.ts"]
    }
  }
}
```

### OpenCode

Tạo hoặc sửa `opencode.json`:

```json
{
  "mcp": {
    "tsuki-plugin-engineering": {
      "type": "local",
      "command": ["node", "/absolute/path/to/Usagi-Toolkit/bin/run.ts"],
      "enabled": true
    }
  }
}
```

### Codex

Sửa `~/.codex/config.toml`:

```toml
[mcp_servers.tsuki-plugin-engineering]
command = "bun"
args = ["/absolute/path/to/Usagi-Toolkit/bin/run.ts"]
```

### Pi/Senpi

Tạo hoặc sửa `.pi/mcp.json`:

```json
{
  "mcpServers": {
    "tsuki-plugin-engineering": {
      "command": "bun",
      "args": ["/absolute/path/to/Usagi-Toolkit/bin/run.ts"]
    }
  }
}
```

### Chọn Runtime

Nếu có [Bun](https://bun.sh), sử dụng `"command": "bun"` để cold start nhanh hơn:

```json
{
  "command": "bun",
  "args": ["/absolute/path/to/Usagi-Toolkit/bin/run.ts"]
}
```

Hoặc set environment variable `TSUKI_MCP_RUNTIME` để force runtime cụ thể.

## Harness được hỗ trợ

| Harness | MCP Support | Skill Support | Auto-Install |
|---------|-------------|---------------|--------------|
| Claude Code | ✅ | ✅ | ✅ |
| OpenCode | ✅ | ✅ | ✅ |
| Codex | ✅ | ✅ | ✅ |
| Pi/Senpi | ✅ | ✅ | ✅ |
| Claude Desktop | ✅ | ❌ | ✅ |
| Cline | ✅ | ❌ | ✅ |
| Roo Code | ✅ | ❌ | ✅ |

### Chi tiết Skill Support

Harness có Skill support sẽ nhận:
- `skill/SKILL.md` - Hướng dẫn quy trình chính
- `skill/references/` - Tài liệu bổ sung

Skill cung cấp cho LLM:
1. Quy trình từng bước để phát triển plugin
2. Parser contracts và requirements
3. Quy trình phân loại truy cập
4. Quality standards và validation rules
5. Slash commands để test và fix sources

## Kiến trúc

```
Usagi-Toolkit/
├── server.ts               # MCP server - full Tsuki command suite
├── bin/
│   └── run.ts              # stdio launcher (Node/Bun auto-detect)
├── skill/                  # Agent Skill - hướng dẫn quy trình chi tiết
│   ├── SKILL.md
│   └── references/
│       ├── api_reference.md
│       ├── parser-engineering.md
│       ├── research-checklist.md
│       └── access-classification.md
├── scripts/
│   └── smoke-test.ts       # offline fixture-based smoke test
├── test-fixtures/          # sample chapter fixtures cho tests
│   ├── chapters-v1/
│   └── chapters-v2/
├── bin/install.ts          # Bun/bunx auto-installer
├── install.sh              # Wrapper tương thích cũ
├── uninstall.sh            # Xóa tất cả thay đổi do installer tạo ra
├── AGENTS.*.md             # harness-specific behavior guides
├── package.json
├── tsconfig.json
└── README.md
```

### Các thành phần chính

- **MCP Server** (`server.ts`): Cung cấp 20+ tools cho phát triển plugin
- **Agent Skill** (`skill/SKILL.md`): Hướng dẫn quy trình cho LLM
- **Auto-installer** (`bunx ... install`): Phát hiện và cấu hình harnesses không cần Bash
- **Test Fixtures** (`test-fixtures/`: Dữ liệu mẫu để test

## Phát triển

### Thiết lập

```bash
# Clone repository
git clone https://github.com/sang765/Usagi-Toolkit.git
cd Usagi-Toolkit

# Cài dependencies
bun install

# Bắt đầu phát triển
npm start
```

### Các lệnh có sẵn

```bash
# Khởi chạy MCP server
npm start

# Build cho production
npm run build

# Kiểm tra type only
npm run typecheck

# Chạy tests
npm test
```

### Cấu trúc dự án

- `server.ts` - Triển khai MCP server chính
- `bin/run.ts` - Entry point cho stdio communication
- `skill/` - Tài liệu agent skill
- `scripts/` - Scripts phát triển và testing
- `test-fixtures/` - Dữ liệu mẫu để test

### Đóng góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push branch (`git push origin feature/amazing-feature`)
5. Mở Pull Request

### Hướng dẫn phát triển

- Tuân thủ TypeScript best practices
- Thêm tests cho functionality mới
- Cập nhật documentation khi cần
- Đảm bảo tất cả tools tuân thủ compliance rules

## Giấy phép

MIT License - xem [LICENSE](LICENSE) để biết chi tiết.

Tsuki, Usagi và bất kỳ plugin nào được tạo bằng toolkit này vẫn chịu license riêng.

## Acknowledgments

- [Usagi](https://github.com/UsagiApp/Usagi) - Ứng dụng đọc manga
- [Tsuki](https://github.com/UsagiApp/Tsuki) - Plugin framework
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP standard

## Hỗ trợ

- [GitHub Issues](https://github.com/sang765/Usagi-Toolkit/issues)
- [Documentation](https://github.com/sang765/Usagi-Toolkit/wiki)

## Bảo mật

Toolkit này được thiết kế để sử dụng hợp pháp only. Tuyệt đối không được sử dụng để:

- Bypass CAPTCHA, paywalls, authentication, hoặc anti-bot defenses
- Thực hiện解 mã trái phép
- Truy cập protected content mà không có permission
- Vi phạm terms of service của bất kỳ website nào

Xem [`skill/references/access-classification.md`](skill/references/access-classification.md) để biết hướng dẫn compliance chi tiết.

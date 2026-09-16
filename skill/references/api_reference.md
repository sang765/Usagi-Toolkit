# Tsuki API reference snapshot

Snapshot source: `UsagiApp/Tsuki` on the `master` branch. Always verify the upstream repository before release.

## Build

```kotlin
implementation("com.github.UsagiApp:Tsuki:<version>")
```

```bash
./gradlew jar
d8 --release build/libs/plugin.jar --output plugin.jar
```

## Core contract

`MangaSource` exposes `name`, `title`, `locale`, `contentType`, and `isBroken`.

`MangaParser` requires or exposes `source`, `availableSortOrders`, `filterCapabilities`, `config`, `configKeyDomain`, `domain`, `getList(offset, order, filter)`, `getDetails(manga)`, `getPages(chapter)`, `getPageUrl(page)`, `getFilterOptions()`, `getFavicons()`, `getRequestHeaders()`, `onCreateConfig(...)`, `getRelatedManga(seed)`, and `resolveLink(link)` where relevant.

`getDetails` must preserve the manga `id`, `url`, and `source`. Use the official source files in the toolkit's `docs/` directory as the detailed snapshot.

## Source quality requirements

Attempt to populate the main title, alternative titles, content type, rating, rating count, authors, status, large cover, thumbnail or secondary cover, description, and tags. Leave a field unavailable when the permitted source does not expose it. Never fabricate values.

Map every source-supported filter to Tsuki where possible, including sort order, included genres, excluded genres, author, status, rating, demographic, release year, and additional documented source filters. Do not invent unsupported filters or silently pretend that a selected filter was applied.

Return chapters oldest-to-newest by default. Remove navigation controls such as “Read from beginning” and “Read latest”, advertisements, recommendations, and duplicate entries. Preserve volume, season, subchapter, and group information when the model supports it.

## Compatibility and security cautions

Tsuki contains deprecated search overloads and compatibility methods. Prefer current filter-based methods and the `HttpUrl` overload for link resolution. Do not infer undocumented behavior from names alone; verify against `UsagiApp/Usagi`, `UsagiApp/plugins`, and compiled tests when available.

Do not bypass CAPTCHA, authentication, paywalls, anti-bot controls, access restrictions, or response encryption. Continue only with an officially documented public API or an officially supported, authorized decryption mechanism; otherwise report the blocker.

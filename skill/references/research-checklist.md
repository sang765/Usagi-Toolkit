# Public source research and QA checklist

Before recording anything else, classify list/search, details, chapter list, chapter pages, and image delivery as public, authenticated, or paywalled per `access-classification.md`, and run `tsuki_classify_access` for each. Only continue this checklist for capabilities classified `public`; document the rest as excluded rather than researching endpoints you cannot lawfully implement.

Record the canonical source URL, locale, content type, and whether an official API exists. Prefer API documentation, then stable public HTML selectors.

Record every metadata field exposed by the source: main title, aliases, content type, rating, rating count, author, status, large cover, thumbnail or secondary cover, description, tags, and other Tsuki-supported fields. Mark unavailable fields explicitly instead of fabricating values.

Record every source-supported filter: sort orders, included and excluded genres, author, status, rating, demographic, release year, and additional documented filters. Confirm each selected filter changes the request or parser behavior.

Record request method, URL template, query parameters, pagination cursor, public headers, response schema, and error statuses. Redact cookies and credentials from fixtures.

Record selectors or JSON paths for title, cover, description, tags, status, chapters, pages, and direct image URLs. Add fixtures for empty, partial, reordered, and malformed responses.

Verify chapter output is oldest-to-newest by default. Remove navigation controls such as “Read from beginning” and “Read latest”, ads, recommendations, and duplicates. Test reversed source order and missing chapter numbers.

Confirm terms of service, robots.txt, API license, copyright restrictions, authentication boundaries, rate limits, and attribution requirements. Stop if the workflow would require bypassing CAPTCHA, login controls, paywalls, signatures, anti-bot controls, access restrictions, or response encryption. Continue only with an officially documented public API or authorized decryption mechanism.

Use conservative timeouts, bounded retries, a descriptive user agent where appropriate, and no concurrency unless the service permits it.

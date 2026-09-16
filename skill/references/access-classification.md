# Access classification: public, authenticated, or paywalled/subscription

Read this reference **before** calling `tsuki_research_source` or writing any Kotlin. Classifying a source's access model wrong is the single most common way a plugin ends up unlawful, broken, or silently degraded. Do this classification explicitly, in writing, before scaffolding anything — it decides whether the source is buildable at all, and if so, what must be left out.

## Why this can't be skipped

`SKILL.md` and `parser-engineering.md` both say "don't bypass CAPTCHA/paywalls/auth/anti-bot" — but that rule is only actionable if the agent first determines *whether* a given request, endpoint, or chapter falls into one of those categories. A source is rarely uniformly one type: the catalog and search are usually public, while specific chapters, resolutions, or download speeds may be gated. Classification must happen **per capability** (list/search, details, chapter list, page/image delivery), not once for the whole site.

## The three classes

### 1. Public

A capability is Public when it is served to an anonymous client with no session, no account-linked cookie, and no credential — and the source's own terms do not prohibit programmatic access to it.

Signals that a capability is Public:
- The response is identical (content, not just status) for a request with no cookies and no `Authorization` header, tested against a real anonymous fetch.
- No login wall, redirect-to-login, or "sign in to continue" interstitial appears before the content.
- No token, session ID, or per-account signature is required in the request or embedded in the response to render the content correctly.
- Terms of service / robots.txt do not forbid automated access to that path (a `Disallow` entry, a "no scraping" clause, or an explicit API terms document restricting non-browser clients are all disqualifying signals — see `research-checklist.md`).

A Public capability is safe to implement fully.

### 2. Authenticated (account required, not paid)

A capability is Authenticated when it requires a logged-in session (any account, free or paid) to render, but does not require a specific paid tier, subscription, or one-time purchase beyond having an account.

Signals:
- An anonymous request returns a login redirect, a truncated/teaser response, or a 401/403 that a logged-in session resolves.
- The site's own documentation, ToS, or UI describes this as "sign up to read" / "free account required" — with no payment mentioned.
- Session cookies or a bearer token obtained via the source's own login flow are what unlocks the content, not a purchase or subscription flag on the account.

**Do not implement credential-based login, session capture, or token minting inside the plugin.** Tsuki plugins operate as anonymous HTTP clients; they must not store, replay, or prompt for user credentials. If a source's *entire* useful surface (search, details, chapters, pages) requires an account, treat the source as **not buildable** and report it as blocked with the reason "account-gated, no anonymous path." If only a secondary field is gated (e.g., a "logged-in users see full description") while the core reading path is public, implement only the public portion and document the gap — never fabricate the missing field and never attempt to authenticate to fill it in.

### 3. Paywalled / subscription / purchased content

A capability is Paywalled when it requires a paid tier, an active subscription, coins/tickets/credits purchased with money, or a per-title/per-chapter purchase — regardless of whether the underlying mechanism looks like "just another login."

Signals:
- Pricing pages, "buy chapter," "unlock with coins," "premium," "early access," or a subscription tier gate the content.
- A logged-in *free* account still cannot access the content, but a paid one can.
- The response encodes DRM, a rotating signed URL tied to a paid entitlement, or a decryption key issued only to paying sessions.

**This is always out of scope, with no exceptions.** Do not implement purchase flows, do not accept a user-supplied paid session/cookie/token as a plugin input, do not attempt to derive or replay the entitlement check, and do not build "bring your own subscription" cookie-passthrough as a workaround — that is still building unauthorized/paywall-bypass tooling even though the *user* technically paid, because the plugin itself has no lawful way to verify the entitlement and the mechanism generalizes to anyone who obtains the cookie. Treat any content behind this signal as **not buildable** for that capability. Report it in `SOURCE_REPORT.md` as a documented, permanent exclusion — not a TODO.

## Classification procedure (do this before scaffolding)

For each capability — list/search, details, chapter list, chapter pages, image delivery — answer in order:

1. **Fetch anonymously.** Use `tsuki_fetch_public_source` / `tsuki_research_source` with no cookies or credentials supplied. Record the actual response: full content, teaser, redirect, or error.
2. **Check for a login wall.** Does an anonymous request get redirected to a login page, or does the UI show a "sign in" interstitial before the content that a fixture-only fetch cannot get past? If yes, this capability is at least Authenticated.
3. **Check for a payment signal.** Does the source's UI, pricing page, or response body mention a subscription, coins/tickets, "premium," per-chapter purchase, or a paid-only badge on this specific content? If yes, this capability is Paywalled, full stop — the answer to step 2 no longer matters.
4. **Check terms/robots explicitly.** Even a technically-anonymous, technically-free response can be off-limits if `robots.txt` disallows the path or the ToS forbid automated/non-browser access to it. Treat a ToS prohibition the same as a technical block: don't implement it, and say so in the report.
5. **Record the verdict per capability** in the research report: `public` / `authenticated` / `paywalled` / `blocked-by-terms`, with the evidence from steps 1 to 4. Do not average or guess at a single verdict for the whole source — a manga's synopsis and cover can be Public while its chapters are Paywalled.

## What to do with a mixed result

- If **list/search + details + at least some chapters + their pages** are Public: build the plugin normally, and document the excluded (Authenticated/Paywalled) chapters or fields as explicitly unavailable rather than silently omitting them from the report.
- If **only metadata is Public** and every chapter is Authenticated or Paywalled: this is not a useful reading source. Report it as blocked and do not scaffold a plugin whose `getPages` can never return real content.
- If classification is ambiguous after steps 1 to 4 (e.g., conflicting signals, unclear ToS wording, region-locked responses that behave differently than expected): stop and report the ambiguity for human review rather than picking the more permissive interpretation. When unsure, treat the capability as **not** Public.

## Common misclassifications to avoid

- **"It's free to sign up, so it's basically public."** No — free-account-required is Authenticated, and the plugin still cannot implement login. Treat it as blocked unless the reading path itself is anonymous.
- **"The paywall is client-side JS, the raw HTML has the images."** If the source's intent (per ToS, pricing page, or UI) is to gate that content behind payment, extracting it from unobfuscated HTML/JSON is still a paywall bypass. Technical ease of extraction does not change the classification — the entitlement signal from step 3 governs, not whether the bytes happen to be reachable.
- **"The user already has a paid subscription and gave me their cookie."** Still out of scope — see the "always out of scope" rule above. A plugin that accepts a bring-your-own paid-session cookie is a general paywall-bypass mechanism regardless of whose cookie it is.
- **"It only rate-limits anonymous users more aggressively, logged-in is just faster."** If the anonymous path returns the same real content, just throttled, that capability is Public; implement conservative rate limiting per `parser-engineering.md` rather than escalating to Authenticated.
- **"Ads/interstitials before the reader count as a paywall."** No — ads and wait timers are not payment or account gates. Classify by the three questions above, not by how annoying the page is.

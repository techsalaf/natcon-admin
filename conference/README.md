# NATCON delegate portal

Outcome: a delegate can register without an app installation, complete a verified payment or submit a transfer claim, retrieve one ticket per delegate, and save an admission QR before travelling.

`index.php` serves the public landing page, individual/group registration, order status, hosted Paystack payment, bank-transfer claims, and email recovery. `ticket.php` shows only the paid-ticket response from the API. `privacy.php` describes collection and access. No credentials or registration payloads are saved in browser storage. Bearer tokens use URL fragments; API requests still require HTTPS and access-log query redaction at deployment.

The portal depends only on the documented `api/natcon.php` boundary, never database or service internals. Registration returns `reference` and `access_token`; resumes use `#reference=...&token=...` or `#order=...&token=...`. Ticket links use `ticket.php#TOKEN` (query-token links are migrated into a fragment on load). Prices are display estimates until the server returns an order amount. Payment verification is exclusively server-side. An offline fallback is informational, never proof of payment. The service worker caches only explicit static assets.

The PDF download uses the browser's Print / Save as PDF dialog. QR image download is available separately. It is not an offline registrar system. Installation support varies by browser; an SVG icon manifest and static service worker are included.

## Validation

Run `node conference/tests/gate.cjs` and `node conference/evals/flows.cjs`, then PHP lint on the three PHP files. The gate runs browser logic with deterministic DOM/fetch fixtures, tests output escaping, formatting, server error handling, and verifies sensitive caching exclusions. Flow evals score error, validation, consent, branding, retrieval, and ticket affordances from source contracts. These automated evals are not a substitute for the browser + gateway rehearsal below.

Before release: run at 390px and 1440px, complete a single and group registration; confirm keyboard focus and invalid email behaviour; test pending, paid, declined, duplicate callback, manual review, and unavailable mail; recover an order; print a ticket; verify QR with two registrar devices; disable network and confirm offline fallback never claims a successful payment. Gateway and delivery tests require configured credentials. No paid LLM calls are necessary for deterministic UI behaviour; subjective design review may be performed through local Claude Code under the repository policy.

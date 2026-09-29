# NATCON registration service

Outcome: a verified payment produces one independently scannable ticket per delegate; repeated payment notifications and scans do not duplicate fulfillment.

Native PHP integrates with the purchased XAMPP application without touching its tables. PDO prepared statements, password_hash, random_bytes, cURL and the bundled PHP QRCode library supply standard primitives. No LLM functionality is needed. Tables use the isolated `natcon_` prefix.

## Setup

Create ignored `.env.natcon` in the repository root from [`.env.natcon.example`](../../.env.natcon.example):

```dotenv
NATCON_DSN=mysql:host=127.0.0.1;dbname=natcon;charset=utf8mb4
NATCON_DB_USER=natcon
NATCON_DB_PASSWORD=replace-locally
NATCON_BASE_URL=https://your-domain.example
PAYSTACK_SECRET_KEY=replace-locally
NATCON_MAIL_FROM=tickets@your-domain.example
```

For isolated local evaluation use `NATCON_DSN=sqlite:C:/absolute/private/path/natcon.sqlite`. Never put the SQLite file in an accessible public directory. Run `php services/natcon/cli.php migrate`. Create staff using `php services/natcon/cli.php staff email@example.com admin "Staff Name"`, supplying password through stdin or the `NATCON_STAFF_PASSWORD` environment variable. Use finance and registrar roles for least privilege. There are no default credentials.

Configure Paystack webhook URL `https://natcon.my360school.com/api/natcon.php?action=webhook`. Use test keys and a test payment first. The browser never decides price or success. Signed webhooks and provider verification match reference, exact amount and currency. Pending and awaiting_review orders may become paid. Cancelled records cannot revive.

Configure PHP's SMTP/sendmail transport, then schedule `php services/natcon/cli.php mail` once per minute. PHP mail acceptance means transport handoff, not inbox delivery; monitor SMTP delivery logs. Failed messages retry up to five times. A process crash after transport handoff may require manual inspection of `sending` records to avoid duplicate email. Outbox delivery is not an exactly-once guarantee; payment issuance is idempotent.

## Contract

Base `/api/natcon.php?action=NAME`. JSON responses `{ok:true,data:...}` or `{ok:false,error:"..."}`. Public GET event, order(reference,token), payment_verify(reference,token), ticket(token), qr(token PNG). Public POST register(payer_name,payer_email,payer_phone,delegates[]), payment_initialize(reference,token), transfer(reference,token,bank_reference,sender_name,paid_on), recover(email). Each delegate must provide name, Gmail/email, course, institution, current level/status, WhatsApp number, state of origin, and NATCONs previously attended (0–99); calling_line is optional when different from WhatsApp. Legacy chapter, accommodation, and accessibility fields remain optional. Migration adds these columns to existing natcon_delegates tables without replacing registrations. Orders carry reference, access_token, amount_kobo, currency,status,delegates. Pending orders do not expose ticket tokens. Mobile attendee POST `account_register(name,email,country_code,phone,password)` and `account_login(country_code,phone,password)` return a 30-day bearer token; send it as `Authorization: Bearer …` to `account_session`, GET/POST `account_profile`, `account_orders`, and POST `account_logout`. Authenticated `register` associates purchases with the account. Passwords use `password_hash`; tokens are stored only as SHA-256 digests and can be revoked.

Staff POST login(email,password) returns user and csrf. GET session refreshes inactivity timeout. All other mutations require `X-CSRF-Token`, with the session cookie. GET dashboard, delegates(q,status), transfers, export CSV, audit. POST checkin(token,mode), entitlement(token,kind,slot), approve_transfer(reference,note), resend(reference), logout. Finance/admin handles transfers/export/resend; registrar/admin handles admission and fulfillment. Sessions expire after one hour inactivity. GET responses contain sensitive data and are never cached. QR tokens are bearer credentials; keep links private.

The original Flutter clients use `/user_api/*.php` and `/orag_api/*.php`; `.htaccess` routes those paths to `api/mobile.php`, which adapts explicitly implemented endpoints to this service. Attendee routes now cover NATCON account login/profile/recovery, event discovery and search, event-specific ticket checkout/payment, owned ticket history/details, coupons, wallet, favorites, reviews, referrals, FAQs/pages, and in-app notifications. Organizer routes cover canonical Admin/Finance/Registrar login, dashboard, scanning, shared event/ticket create/edit/status, coupons, and payout review. The public `conference/` checkout also selects the same published events and ticket types. Unsupported legacy endpoints return 404; do not restore the purchased PHP API folders. Remaining items and each endpoint disposition are in [`docs/natcon-mobile-feature-matrix.md`](../../docs/natcon-mobile-feature-matrix.md).

Build either existing client against this host with `flutter build apk --debug --dart-define=NATCON_BASE_URL=https://natcon.my360school.com` from that app's directory. These Android projects currently need JDK 17; if Android Studio supplies an incompatible newer runtime, set Flutter's Gradle JDK with `flutter config --jdk-dir="C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"` (replace that path with your JDK 17 install), then rebuild. App checkout creates a pending server-priced order first, opens the returned Paystack authorization URL, then verifies the payment against Paystack through NATCON before showing success. Use Paystack test mode in staging; a native build or local evaluation does not prove live provider configuration.

NATCON coupon codes are stored in `natcon_coupons`. Use `discount_type=percent` with `discount_value` from 1 to 100, or `discount_type=fixed` with `discount_value` in kobo. Set `minimum_kobo`, optional `event_id`, `expires_at`, and `usage_limit`; zero usage limit means unlimited. The attendee app's coupon amount is a preview based on the displayed subtotal. Checkout revalidates the code, computes the actual discount in the transaction, and stores the canonical discount and redemption with the order. Cancelling/refunding a coupon order in the staff console releases its redemption count.

Attendee wallet top-ups are restricted to ₦100–₦1,000,000 and initialized/verified by NATCON with Paystack. The attendee app never posts a claimed successful top-up amount; `natcon_wallet_ledger` is credited only after reference, status, exact kobo amount, currency, and account ownership match provider verification. Legacy wallet histories remain read-compatible through the app response adapter. During ticket checkout the authenticated account can request wallet use; NATCON reserves the lesser of the available balance and the coupon-adjusted total in the same transaction as the order. Paystack receives only the remainder. A wallet-only order is marked paid and queues tickets immediately. Cancellation/refund returns the wallet reservation once, while cash refund processing remains a finance/manual provider action.

Arrival is unique per delegate; daily attendance is unique per event date; re-entry requires a prior scan and records each return. The scanner checks the dates of the event on that ticket, rejects cancelled events, and prevents duplicate slots with database keys. Entitlement slots must be consistently named by operations (for example `2026-10-01-lunch`). Offline acceptance is not implemented.

## Validation and release

Run `php services/natcon/tests/gate.php`, `php services/natcon/evals/run.php`, `php services/natcon/evals/mobile-schema.php`, `node conference/tests/gate.cjs`, `node conference/evals/flows.cjs`, `node conference/tests/multi-event-http.e2e.cjs`, `node operations/tests/gate.cjs`, and `node operations/evals/flows.cjs`. Behavioral scenarios in `evals/scenarios.json` still require an explicit staging rehearsal, including actual Paystack test checkout, two phones, and SMTP delivery. Do not claim live payment/mail validation until configured and exercised. PHP needs no restart for code updates unless opcode cache suppresses changes; restart Apache after changing PHP SMTP configuration. No production migration or deployment is performed automatically.

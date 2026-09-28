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

Base `/api/natcon.php?action=NAME`. JSON responses `{ok:true,data:...}` or `{ok:false,error:"..."}`. Public GET event, order(reference,token), payment_verify(reference,token), ticket(token), qr(token PNG). Public POST register(payer_name,payer_email,payer_phone,delegates[]), payment_initialize(reference,token), transfer(reference,token,bank_reference,sender_name,paid_on), recover(email). Each delegate must provide name, Gmail/email, course, institution, current level/status, WhatsApp number, state of origin, and NATCONs previously attended (0–99); calling_line is optional when different from WhatsApp. Legacy chapter, accommodation, and accessibility fields remain optional. Migration adds these columns to existing natcon_delegates tables without replacing registrations. Orders carry reference, access_token, amount_kobo, currency,status,delegates. Pending orders do not expose ticket tokens.

Staff POST login(email,password) returns user and csrf. GET session refreshes inactivity timeout. All other mutations require `X-CSRF-Token`, with the session cookie. GET dashboard, delegates(q,status), transfers, export CSV, audit. POST checkin(token,mode), entitlement(token,kind,slot), approve_transfer(reference,note), resend(reference), logout. Finance/admin handles transfers/export/resend; registrar/admin handles admission and fulfillment. Sessions expire after one hour inactivity. GET responses contain sensitive data and are never cached. QR tokens are bearer credentials; keep links private.

Arrival is unique for the conference; daily attendance unique per Lagos date; re-entry requires a prior scan and records each return. Event dates restrict check-in to October 1–4. Entitlement slots must be consistently named by operations (for example `2026-10-01-lunch`). Unique database keys enforce atomic duplicate prevention. Offline acceptance is not implemented.

## Validation and release

Run `php services/natcon/tests/gate.php`, `php services/natcon/evals/run.php`, `node conference/tests/gate.cjs`, `node conference/evals/flows.cjs`, `node operations/tests/gate.cjs`, and `node operations/evals/flows.cjs`. Behavioral evaluation scenarios in `evals/scenarios.json` require all scenarios to pass in a staffed staging rehearsal, including actual Paystack test checkout, two phones, and SMTP delivery. No paid LLM eval is appropriate for this deterministic workflow. Do not claim live payment/mail validation until configured and exercised. PHP needs no restart for code updates unless opcode cache suppresses changes; restart Apache after changing PHP SMTP configuration. No production migration or deployment is performed automatically.

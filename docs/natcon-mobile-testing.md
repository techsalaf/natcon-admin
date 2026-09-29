# NATCON mobile testing

The attendee app, organizer app, public attendee site, and operations console are being wired to the canonical NATCON service. Shared registrations, tickets, event catalogue, coupon redemptions, payouts, and check-ins use the `natcon_*` records. Changes are local to this branch until the web server receives the code and the NATCON migrations have run.

## Routes

- Public attendee portal: `https://natcon.my360school.com/conference/`. It defaults to the primary NATCON event. A shared catalogue event can be selected in the page, or opened directly with `?event_id=<id>`.
- Staff login for Admin, Finance, and Registrar: `https://natcon.my360school.com/operations/`. The same assigned staff email/password is used in the organizer app. Server-side role checks decide which actions are allowed.
- Attendee app: use its existing sign-up and sign-in screens. Account creation/login is separate from organizer staff login. App registration uses the same event, ticket type, server pricing, Paystack verification, and ticket records as the web portal.
- Organizer app: use staff credentials. Admin manages events, ticket types, coupons, and event status; Finance reviews payouts; Admin and Registrar scan tickets. The app and web console address the same API and check-in records.

The operations page currently has no browser form for secret settings. Paystack and email transport are configured on the server through the private `.env.natcon` and PHP mail transport. Do not put either secret in a Flutter build or commit it. The configured public host must deploy the current code and migrations before these routes can use the new API behavior.

## Build debug APKs

Use Java 17 and the configured Android SDK. From each app directory:

```powershell
flutter test
flutter build apk --debug --dart-define=NATCON_BASE_URL=https://natcon.my360school.com
```

Artifacts are written to `build/app/outputs/flutter-apk/app-debug.apk` in the corresponding app directory. They are debug-signed for direct test installation, not store release. Flutter may warn that the apps' Gradle, Android Gradle Plugin, or Kotlin versions need future upgrades.

## Before a live rehearsal

- Deploy the API code and run `php services/natcon/cli.php migrate` against the intended NATCON database. Keep a database backup and verify the migration output first.
- Use assigned Admin, Finance, and Registrar test accounts. The temporary sample accounts already created for this task are not replacements for normal staff identities, and their credentials were delivered separately.
- Set `PAYSTACK_SECRET_KEY` on the server to the Paystack test key, configure the webhook URL from `services/natcon/README.md`, and complete a real test checkout plus signed webhook rehearsal. Online payment is unavailable until this server setting is active.
- Configure PHP SMTP/sendmail transport and `NATCON_MAIL_FROM`, schedule `php services/natcon/cli.php mail`, and verify delivery of a test ticket and account recovery email. A sender address alone does not configure SMTP.
- Confirm the Firebase project, Android package IDs, signing fingerprints, and push products before testing purchased-app Firebase features. NATCON registration does not depend on Firebase authentication.
- Test the scanner on two devices/browsers to verify that a check-in through one client is a duplicate in the other. Browser camera scanning requires HTTPS and permission.

## Local checks

From the repository root, run:

```powershell
php services/natcon/tests/gate.php
php services/natcon/evals/run.php
php services/natcon/evals/mobile-schema.php
php services/natcon/tests/legacy-accounts.php
php services/natcon/evals/legacy-accounts.php
node services/natcon/tests/legacy-account-cli.cjs
node conference/tests/gate.cjs
node conference/tests/multi-event-http.e2e.cjs
node conference/evals/flows.cjs
node operations/tests/gate.cjs
node operations/evals/flows.cjs
```

The HTTP end-to-end test uses an isolated temporary SQLite database and a local PHP server. It covers published event discovery, event/ticket selection, server-priced registration, and Admin coupon creation without reaching production services. Local gates do not replace the live Paystack, SMTP, or two-device rehearsal.

See the [integration plan](natcon-mobile-integration-plan.md), [feature/API matrix](natcon-mobile-feature-matrix.md), and [NATCON service setup](../services/natcon/README.md) for current scope and remaining work.

# NATCON mobile integration plan

## Outcome

The existing NATCON attendee app, organizer app, and web console use one authenticated API and one source of conference data. A registration or payment completed from either attendee client is visible in the same staff console; a ticket accepted by either scanner cannot be accepted again by the other. Preserve the apps' existing screens and applicable workflows while adding the requested delegate details.

## Current state

- `natcon-user-app` and `natcon-organizer-app` still target the purchased application's `/user_api/` and `/orag_api/` PHP contracts.
- The public host blocks those legacy API paths. Changing the Flutter base URL alone does not translate their request formats.
- The deployed NATCON service uses `api/natcon.php` and `natcon_*` tables. It supports public registrations, Paystack initialization and verification, tickets, shared staff login, staff exports, finance transfer review, and registrar check-in.
- The current public portal is `conference/`; the current shared staff console is `operations/`. Neither legacy app has yet been wired to this API.
- Both current app entry points had been replaced in commit `7cd3454` with `services/mobile/`: the user APK opens `NatconApp(staff: false)` and the organizer APK opens `NatconApp(staff: true)`. This hides the original screens even though their source files remain in the projects.

## Integration rules

1. Keep the two existing Flutter projects and their original UI as the mobile clients. `services/mobile/` can supply shared API code only; it must not replace either app's navigation or screens.
2. Keep `api/natcon.php` and its `natcon_*` records as the system of record for NATCON registrations, payments, delegates, tickets, transfers, and check-ins.
3. Make every web and mobile action that reads or changes NATCON data call this service. Do not reopen the legacy PHP trees wholesale or let one client write a duplicate ticket/order store.
4. Use the same staff identities and server-side role checks on web and organizer clients. Never trust a role selected or supplied by the app.
5. Keep Paystack secrets on the server. Mobile clients request a payment initialization from the API and use the returned provider authorization URL; only verified callbacks/webhooks can issue tickets.
6. Preserve existing attendee account/profile behavior only after tracing its current data and authentication contract. Keep attendee login distinct from staff login unless the existing account model proves they are the same identity.
7. The requested scope now includes every existing attendee and organizer feature: attendee accounts, event discovery, checkout, tickets, wallet, coupons, reviews, favorites, referrals, chat/notifications, organizer event/ticket CMS, scanner, finance/payouts, and manager roles. Implement them against shared NATCON-owned data and APIs. Do not leave them on the blocked legacy backend or silently remove them.

## Work sequence and acceptance checks

### 1. Contract inventory (in progress)

- Enumerate user-app and organizer-app screens, API requests, request fields, response models, and role assumptions. **Complete:** user client has attendee auth/profile, discovery, booking, payments, tickets, wallet, coupons, favorites, reviews, chat and notifications. Organizer client has dashboard, scanner, event/ticket management, ticket types, coupons, payout, notifications, and manager roles.
- Map each call to an existing NATCON API action or a missing contract. **Complete:** NATCON currently covers public registration, order/payment/ticket/recovery and staff dashboard/delegate/transfer/check-in/entitlement actions. Attendee accounts, marketplace catalogue and most legacy organizer CMS endpoints have no NATCON contract.
- Record database ownership for existing attendee and staff identities before any migration.
- Acceptance: every network call in both apps appears in a feature/API matrix with an explicit disposition; no credentials or production data are included in the matrix. The initial inventories are in the task notes; a checked-in endpoint matrix is the next deliverable.

### 2. Canonical NATCON data model and versioned API contract

- Extend the NATCON schema for the attendee identity/profile, multi-event catalogue, ticket types, favourites, wallets/ledger, coupons, reviews, referrals, organizer accounts/roles, event media, payouts and notification/chat records required by the existing screens. Keep current NATCON orders, delegates, payment verification and ticket identities authoritative; add foreign keys or explicit IDs to connect the new entities.
- Define shared request/response shapes for the complete existing client workflows. Preserve the existing phone/password attendee identity experience and map organizer roles to server-enforced NATCON roles.
- Extend the NATCON API behind role, account ownership and audit checks. Keep sensitive payment and wallet math on the server.
- Add contract tests and evaluation scenarios for success, invalid input, wrong role, unauthenticated calls, duplicate payment callbacks, and duplicate scans.
- Acceptance: web and mobile contract tests prove they address the same user, event, order, ticket, wallet ledger, and role permissions.

**Implemented locally:** repeatable migrations provision 23 NATCON-owned tables for attendee accounts/tokens, multi-event commerce, wallet, coupons, reviews, favourites, referrals, payouts, notifications, chat, and content; legacy NATCON orders and delegates are extended additively. Native attendee and staff bearer-token authentication is implemented, including role enforcement through the canonical staff table. The compatibility router supports attendee register/login/profile, canonical Admin/Finance/Registrar login, organizer dashboard metrics, and one-person ticket scanning against the same NATCON check-in records as the web console.

**Still pending:** attendee discovery, checkout/history, wallet/coupon, social/content and messaging flows, plus organizer event/ticket CMS, finance payout, notification, and manager administration workflows. The new domain tables are not all wired to app workflows. No production schema, API, or routing changes have been applied.

### 3. Adapt the existing Flutter clients

- Update API/repository code and models in the existing projects; preserve their navigation, presentation, and all existing features.
- Add all required delegate fields: name, email, course, institution, level/status, WhatsApp, optional calling line, state of origin, and previous NATCON attendance. Extend attendee registration/profile inputs without removing the existing phone/password account flow.
- Reconcile attendee sign-in/profile flows with the existing attendee identity store before changing authentication behavior.
- Use the server payment authorization URL so app and web checkout share Paystack verification and ticket issuance.
- Acceptance: user app retains account sign-in and can register, complete a test payment, and retrieve the same ticket as the web portal; organizer roles sign in with the web credentials and see only permitted actions; wallet and coupon totals match server calculations; app and web scans share duplicate-prevention behavior; organizer-managed changes appear in the web console.

### 4. Release and rollout

- Build debug APKs, test with test credentials and Paystack test mode, and run two-device scan checks.
- Deploy API/schema changes before distributing apps. Keep legacy paths blocked unless a narrowly scoped, audited compatibility route is required.
- Document environment setup, build commands, role matrix, rollback steps, and known legacy features that remain out of scope.
- Acceptance: all local gate tests and app builds pass; no live payment or mail behavior is claimed before its provider rehearsal succeeds.

## Risks and boundaries

- The old apps contain a broad event-platform feature set, and the current NATCON schema is single-event. The requested scope is to add that feature set to NATCON, not silently narrow the apps.
- NATCON currently has a staff identity table but no attendee account table. Implement attendee identities with compatibility for the existing phone/password UX. Do not delete or rewrite legacy accounts; design and test any data import as a reversible migration before production.
- Mobile camera access requires device permission. Online ticket creation, payment confirmation, and scanning require network access; offline check-in is not currently supported.
- Production credentials and database changes remain server-side. No production changes are made as part of local contract implementation without the required release approval.

## Progress log

- 2026-09-29: Plan created. Confirmed the original Flutter clients call blocked legacy API routes and the NATCON API has a separate registration/staff model.
- 2026-09-29: Read-only inventory found both `main.dart` files launch the prototype rather than their original app navigation. User app uses phone/password accounts and legacy marketplace endpoints; organizer uses `Orgnizer`/`SCANNER`/`MANAGER` legacy roles and many event-CMS endpoints. NATCON staff roles are `admin`/`finance`/`registrar`, and its API is cookie+CSRF based. Restoring original entry points and preserving their screens is required before client integration.
- 2026-09-29: User confirmed all existing features must be added to the shared NATCON backend. Both original Flutter app entry points are restored locally from project import commit `31c6a2d`; current screens are preserved while API/data integration proceeds.
- 2026-09-29: Added the full app feature/API matrix and updated mobile setup docs. Both app entrypoint regression tests and four-scenario entrypoint evaluations per app pass. CI now runs these checks.
- 2026-09-29: Added initial additive NATCON schemas for all inventoried mobile feature domains. SQLite gate/eval checks assert all 22 tables exist and that running migrations twice is safe. These schemas are not yet connected to app/API workflows.
- 2026-09-29: Added revocable attendee/staff bearer tokens, attendee account endpoints, compatibility login/profile routes, canonical staff role labels in the organizer login UI, organizer dashboard translation, and per-ticket QR/booking scan routing to NATCON check-in. Both apps now revoke server tokens on sign-out and use NATCON authentication without a Firebase-auth dependency. This slice remains local pending full endpoint coverage and release validation.

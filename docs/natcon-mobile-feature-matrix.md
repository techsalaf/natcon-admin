# NATCON mobile feature and API matrix

This inventory compares the screens and requests in the existing Flutter source with the canonical NATCON API. The installed app entry points must launch the existing app navigation; the shared `services/mobile` prototype must not replace them.

## Attendee app (`natcon-user-app`)

| Existing capability | Existing client contract | NATCON contract / gap | Planned handling |
|---|---|---|---|
| Phone/password signup, login, password reset, profile and photo | `/user_api/u_reg_user.php`, `u_login_user.php`, `mobile_check.php`, `u_forget_password.php`, `u_profile_edit.php`, `pro_image.php`; `UserLogin` stored in GetStorage and Firebase | Attendee account/token tables and register, login, session, profile, orders, logout actions | Register, login, duplicate-phone check and basic name/email profile editing are adapted. Password recovery and profile image storage are pending. No legacy account import has run. |
| Home, event details, categories and search | `u_home_data.php`, `u_event_data.php`, `u_event_type_price.php`, `u_cat_event.php`, `u_search_event.php` | `natcon_events`, `natcon_categories`, `natcon_ticket_types` | Home, event details, event price and checkout now share the seeded NATCON event and ticket type in the database. Category/search APIs remain pending until their workflows are wired to the catalogue. |
| Booking, group delegates and Paystack | `book_ticket.php`, `u_paymentgateway.php`, `/paystack/index.php`; client sends price/tax/wallet/coupon totals | `POST register` accepts delegates and computes price from `natcon_ticket_types`; coupon and authenticated wallet portions are calculated/reserved server-side; Paystack charges only the remaining balance; payment verification and webhook settle the order | NATCON web checkout and adapted mobile checkout share event, ticket price, wallet ledger, orders, and payment verification. Wallet-only orders issue tickets immediately. |
| Ticket history, details, cancellation | `ticket_status_wise.php`, `ticket_information.php`, `ticket_cancle.php` | Account-owned, paid-only history/detail compatibility actions use the same NATCON ticket tokens | Paid tickets created for a signed-in NATCON attendee are listed and retrieved with ownership checks. Attendee cancellation is disabled by policy; refunds remain staff-managed and wallet reservations are released once by the staff refund path. |
| Wallet, coupons, reviews, favorites, referrals, chat, notifications, pages and FAQs | `u_wallet_*`, `u_coupon*`, `rate_update.php`, `u_fav*`, referral, Firebase/OneSignal, page/FAQ/notification endpoints | Wallet balance/history, Paystack top-up, partial/full wallet checkout, cancellation/refund release, coupon redemption, ticket-owner reviews, favorites, published FAQ/page reads, account-scoped in-app notifications, and reward-free referral attribution/conversion tracking use NATCON records. Legacy client credit route rejects writes. Chat, referral rewards, alternate gateways and push delivery remain incomplete by policy or implementation. | Server calculates wallet/coupon totals. Reviews require an owned paid ticket; one review per account/event can be updated. Referrals are tracked at signup and first paid ticket only; no rewards are credited. Continue remaining workflows with ownership/role checks and tests. |

## Organizer app (`natcon-organizer-app`)

| Existing capability | Existing client contract | NATCON contract / gap | Planned handling |
|---|---|---|---|
| Organizer, Scanner and Manager login | `/orag_api/u_login_user.php`; role values `Orgnizer`, `SCANNER`, `MANAGER`; Firebase also used | `natcon_staff` canonical roles `admin`, `finance`, `registrar`; revocable mobile token | Implemented mobile login. UI offers Admin, Finance, Registrar; authorization uses the stored server role. |
| Dashboard and event listings | `u_dashboard.php`, `list_event.php`, `event_status_wise.php`, `event_information.php` | `dashboard`, `delegates`, `organizerEvents`, `organizerEventDetails` over `natcon_events` and ticket sales | Dashboard aggregates and the organizer's event list, status filter, and details now read canonical NATCON event/ticket/revenue records. Create/edit/status-change event CMS actions remain pending; organizer listing currently displays the conference records already in the shared catalogue. |
| QR and booking-ID scanner | `qr_ticket_verify.php`, `id_ticket_verify.php`; expects legacy booking/event/organizer JSON | `checkin(token, mode)`; accepts personal NATCON ticket token and enforces admin/registrar role and duplicate rules | QR route accepts individual ticket tokens and calls canonical arrival check-in. Manual single-ticket lookup is adapted. A multi-delegate booking must be scanned one personal ticket at a time. |
| Event/ticket type CMS, categories, restrictions, coupons, artists, gallery, covers | Multiple `/orag_api/*.php` CRUD endpoints | Canonical event and ticket-type rows now seed idempotently; supporting NATCON-owned tables exist | All workflows are in approved scope. CMS APIs, validation, role rules, organizer client wiring and web-console synchronization remain pending. |
| Payouts, bank transfer review, manager roles, notifications, profile | `payout_list.php`, `request_withdraw.php`, `payout_review.php`, `list_role.php`, notification/profile/OTP APIs | Payout requests use paid NATCON ticket revenue less pending, approved, and completed payouts. Admin requests; Finance approves/rejects and records manual transfer reference. Audit records capture each transition. | Payout workflow is wired to shared NATCON data in web and organizer API; organizer app exposes Admin request and Finance review actions. No transfer is initiated by the app. Manager-role administration, notifications, and profile/OTP remain open. |

## Shared NATCON API actions already available

- Public attendee: `event`, `register`, `order`, `payment_initialize`, `payment_verify`, `transfer`, `recover`, `ticket`, `qr`.
- Staff: `login`, `session`, `logout`, `dashboard`, `delegates`, `export`, `checkin`, `entitlement`, `transfers`, `approve_transfer`, `cancel`, `resend`, `audit`.
- Current schema tables: `natcon_orders`, `natcon_delegates`, `natcon_staff`, `natcon_checkins`, `natcon_claims`, `natcon_audit`, plus supporting payment/outbox/rate-limit tables.

## Required mobile API changes

1. Preserve cookie and CSRF semantics if supported by both apps, or add a revocable bearer-token contract for native clients. Do not place staff role claims or Paystack secrets in app code.
2. Add attendee account ownership/history only after identity compatibility is decided. Public order access tokens remain private bearer credentials.
3. Keep order totals, payment verification, ticket issuance and duplicate scan prevention exclusively server-side.
4. Expose only the actions each NATCON role may perform. Web and mobile must share the same authorization rules and underlying records.

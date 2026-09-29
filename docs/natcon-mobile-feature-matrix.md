# NATCON mobile feature and API matrix

This inventory compares the screens and requests in the existing Flutter source with the canonical NATCON API. The installed app entry points must launch the existing app navigation; the shared `services/mobile` prototype must not replace them.

## Attendee app (`natcon-user-app`)

| Existing capability | Existing client contract | NATCON contract / gap | Planned handling |
|---|---|---|---|
| Phone/password signup, login, password reset, profile and photo | `/user_api/u_reg_user.php`, `u_login_user.php`, `mobile_check.php`, `u_forget_password.php`, `u_profile_edit.php`, `pro_image.php`; `UserLogin` stored in GetStorage and Firebase | No attendee account table or auth actions | Preserve the experience only after choosing how legacy attendee identities map to a NATCON-owned identity. No account migration yet. |
| Home, event details, categories and search | `u_home_data.php`, `u_event_data.php`, `u_event_type_price.php`, `u_cat_event.php`, `u_search_event.php` | `GET event` returns one NATCON conference and server price; no catalogue/categories | Adapt discovery to the NATCON conference while retaining its existing navigation and event detail screen. |
| Booking, group delegates and Paystack | `book_ticket.php`, `u_paymentgateway.php`, `/paystack/index.php`; client sends price/tax/wallet/coupon totals | `POST register` accepts delegates and computes price server-side; `payment_initialize`, `payment_verify`, and webhook confirm payments | Replace client-calculated checkout with server-priced NATCON orders, the requested per-delegate fields, and server-issued payment authorization. |
| Ticket history, details, cancellation | `ticket_status_wise.php`, `ticket_information.php`, `ticket_cancle.php` | `order`, `ticket`, `qr`; there is no attendee login/history or cancellation action | Add secure account-owned order history only after identity mapping; preserve private ticket retrieval and use shared NATCON ticket tokens. Cancellation/refund policy needs product mapping. |
| Wallet, coupons, reviews, favorites, referrals, chat, notifications, pages and FAQs | `u_wallet_*`, `u_coupon*`, `rate_update.php`, `u_fav*`, referral, Firebase/OneSignal, page/FAQ/notification endpoints | No corresponding NATCON wallet, coupon, review, favorite, referral, or chat data; public event content/FAQ is available in the portal | Do not direct these calls to dead legacy routes or silently delete the screens. Disposition depends on product scope and user decision. |

## Organizer app (`natcon-organizer-app`)

| Existing capability | Existing client contract | NATCON contract / gap | Planned handling |
|---|---|---|---|
| Organizer, Scanner and Manager login | `/orag_api/u_login_user.php`; role values `Orgnizer`, `SCANNER`, `MANAGER`; Firebase also used | `natcon_staff` has `admin`, `finance`, `registrar`; login uses PHP session + CSRF; no mobile token contract | Use server-returned NATCON role, not a client role picker. Map legacy identities only after confirming account ownership and permissions. |
| Dashboard and event listings | `u_dashboard.php`, `list_event.php`, `event_status_wise.php`, `event_information.php` | `dashboard`, `delegates` for the single NATCON event | Map dashboard counts and delegate data to NATCON records; do not invent multiple event records. |
| QR and booking-ID scanner | `qr_ticket_verify.php`, `id_ticket_verify.php`; expects legacy booking/event/organizer JSON | `checkin(token, mode)`; accepts personal NATCON ticket token and enforces admin/registrar role and duplicate rules | Preserve camera/manual scan UI; adapt QR parsing and result presentation to NATCON ticket tokens and scan modes. |
| Event/ticket type CMS, categories, restrictions, coupons, artists, gallery, covers | Multiple `/orag_api/*.php` CRUD endpoints | No NATCON CRUD APIs; conference identity/pricing are server-configured | Keep existing source intact. Integrate only when product scope decides whether these are required for this single event. |
| Payouts, bank transfer review, manager roles, notifications, profile | `payout_list.php`, `request_withdraw.php`, `list_role.php`, notification/profile/OTP APIs | NATCON supports submitted bank transfers, reconciliation, exports, resend and audit; no payout, arbitrary manager-role, or Firebase notification API | Map Finance to the existing transfer/reconciliation workflow; keep privileges server-enforced. Other behaviors need explicit mapping. |

## Shared NATCON API actions already available

- Public attendee: `event`, `register`, `order`, `payment_initialize`, `payment_verify`, `transfer`, `recover`, `ticket`, `qr`.
- Staff: `login`, `session`, `logout`, `dashboard`, `delegates`, `export`, `checkin`, `entitlement`, `transfers`, `approve_transfer`, `cancel`, `resend`, `audit`.
- Current schema tables: `natcon_orders`, `natcon_delegates`, `natcon_staff`, `natcon_checkins`, `natcon_claims`, `natcon_audit`, plus supporting payment/outbox/rate-limit tables.

## Required mobile API changes

1. Preserve cookie and CSRF semantics if supported by both apps, or add a revocable bearer-token contract for native clients. Do not place staff role claims or Paystack secrets in app code.
2. Add attendee account ownership/history only after identity compatibility is decided. Public order access tokens remain private bearer credentials.
3. Keep order totals, payment verification, ticket issuance and duplicate scan prevention exclusively server-side.
4. Expose only the actions each NATCON role may perform. Web and mobile must share the same authorization rules and underlying records.

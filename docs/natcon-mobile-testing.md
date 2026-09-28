# NATCON mobile testing

The purchased Flutter apps are separate clients for the legacy MagicMate API. The deployed NATCON backend is `api/natcon.php`; it does not implement the apps' `/user_api/` or `/orag_api/` contracts. Those legacy routes are intentionally blocked on the public host. Therefore, a successful APK build permits installation and UI inspection, but does not make login, booking, payment, QR check-in, or legacy event management work against NATCON.

## Build debug APKs

After Android SDK licenses have been accepted and Android SDK Platform 33, Build Tools 34, Java 17, and Flutter/Dart are available, run:

```powershell
cd natcon-user-app
flutter build apk --debug --dart-define=NATCON_BASE_URL=https://natcon.my360school.com

cd ../natcon-organizer-app
flutter build apk --debug --dart-define=NATCON_BASE_URL=https://natcon.my360school.com
```

Artifacts are written under each app's `build/app/outputs/flutter-apk/`. These debug APKs use debug signing and are for direct device installation only; they are not Play Store releases. Flutter's `NATCON_BASE_URL` define only changes the host. It does not translate the old API contract into the NATCON service contract.

The organizer app includes a camera scanner, but its verifier calls the legacy `/orag_api/qr_ticket_verify.php` route and cannot validate NATCON tickets. For NATCON testing, use the role-based HTTPS staff console at `/operations/`, which uses `/api/natcon.php` and supports the registrar camera/manual scanner.

## Before testing a full NATCON flow

- Create admin, finance, and registrar users with the NATCON CLI. The sample accounts created for this task are temporary and use the credentials given separately.
- Configure a Paystack test secret in the server-only `.env.natcon`, then complete a test checkout and signed webhook rehearsal. Without it, online payment is disabled; bank-transfer review remains available.
- Configure PHP SMTP/sendmail and `NATCON_MAIL_FROM`, then send and receive a test ticket. A sender address alone does not configure mail transport.
- Confirm the configured Firebase project, Android package IDs, SHA-1 fingerprints, and enabled Firebase products before relying on push/auth/cloud features in the old apps. Their checked-in Firebase files belong to the purchased app setup and do not connect them to NATCON registration.
- Use two registrar phones or browsers to verify duplicate scan behavior. Camera scanning requires HTTPS and browser camera permission.

The NATCON web portal remains the working attendee registration and ticket channel. Connecting the old native apps requires a separate mobile integration against the NATCON API or a dedicated compatibility adapter; no app login or registration contract should be inferred from an APK compiling.

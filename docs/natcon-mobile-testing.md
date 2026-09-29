# NATCON mobile testing

The attendee and organizer Flutter projects retain their original screens and navigation. Their app entry points were restored locally after an earlier change had launched a small `services/mobile` prototype instead. The restored screens still call the purchased app's legacy `/user_api/` and `/orag_api/` contracts, while the deployed NATCON backend is `api/natcon.php`; the legacy routes remain blocked on the public host. So the original screens are back in source, but attendee login, booking, payment, organizer login, scanning, and management are not yet integrated with the live NATCON service.

## Build debug APKs

After Android SDK licenses have been accepted and Android SDK Platform 33, Build Tools 34, Java 17, and Flutter/Dart are available, run:

```powershell
cd natcon-user-app
flutter build apk --debug --dart-define=NATCON_BASE_URL=https://natcon.my360school.com

cd ../natcon-organizer-app
flutter build apk --debug --dart-define=NATCON_BASE_URL=https://natcon.my360school.com
```

Artifacts are written under each app's `build/app/outputs/flutter-apk/`. These debug APKs use debug signing and are for direct device installation only; they are not Play Store releases. Flutter's `NATCON_BASE_URL` define only changes the host. It does not translate the old API contract into the NATCON service contract.

The organizer app includes a camera scanner, but its verifier calls the legacy `/orag_api/qr_ticket_verify.php` route and cannot validate NATCON tickets yet. Until the integration work is complete, use the role-based HTTPS staff console at `/operations/`, which uses `/api/natcon.php` and supports the registrar camera/manual scanner.

## Before testing a full NATCON flow

- Create admin, finance, and registrar users with the NATCON CLI. The sample accounts created for this task are temporary and use the credentials given separately.
- Configure a Paystack test secret in the server-only `.env.natcon`, then complete a test checkout and signed webhook rehearsal. Without it, online payment is disabled; bank-transfer review remains available.
- Configure PHP SMTP/sendmail and `NATCON_MAIL_FROM`, then send and receive a test ticket. A sender address alone does not configure mail transport.
- Confirm the configured Firebase project, Android package IDs, SHA-1 fingerprints, and enabled Firebase products before relying on push/auth/cloud features in the old apps. Their checked-in Firebase files belong to the purchased app setup and do not connect them to NATCON registration.
- Use two registrar phones or browsers to verify duplicate scan behavior. Camera scanning requires HTTPS and browser camera permission.

The NATCON web portal remains the working attendee registration and ticket channel. See [the integration plan](natcon-mobile-integration-plan.md) and [feature/API matrix](natcon-mobile-feature-matrix.md) for the shared-backend work. An APK compiling alone does not prove that its login, registration, payment, or scanner calls reach NATCON.

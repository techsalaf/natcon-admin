# Temporary host deployment runbook

Target: `https://natcon.my360school.com`, web root `/home/pnzjqabw/natcon`.

The release replaces the old public event-management UI with the NATCON public portal at `/conference/`, the protected staff console at `/operations/`, and the isolated registration API at `/api/natcon.php`. The old purchased source is retained on the server but is denied from public access by the new root `.htaccess` rules.

## Before production deployment

1. Back up `/home/pnzjqabw/natcon` through the host control panel or SSH to a path outside the web root.
2. Create a dedicated MySQL database and user with access only to that database. Do not use the old app's `root` database account.
3. Create `/home/pnzjqabw/natcon/.env.natcon` from `.env.natcon.example`, using the host's MySQL DSN, this exact base URL, a Paystack test secret, and a real ticket-sending address. Keep it readable only by the hosting account.
4. Upload the release files while excluding `.git`, `var`, every `.env*` file, build outputs, and the legacy Flutter build folders.
5. Run `php services/natcon/cli.php migrate` once. It creates only `natcon_*` tables.
6. Create separately named `admin`, `finance`, and `registrar` accounts with `php services/natcon/cli.php staff …`. Supply each password through stdin or `NATCON_STAFF_PASSWORD`, never as a shell argument.
7. Configure the Paystack webhook as `https://natcon.my360school.com/api/natcon.php?action=webhook` and schedule `php /home/pnzjqabw/natcon/services/natcon/cli.php mail` every minute after SMTP has been tested.

## Release rehearsal

Perform the following with Paystack test keys before switching to live keys:

1. Register one delegate and a two-person group.
2. Complete one Paystack test payment. Confirm two tickets for the group, one QR code per delegate, and no extra ticket email after refreshing the callback page.
3. Submit a bank transfer, then have Finance approve only after matching the statement amount and reference.
4. Scan a valid ticket from two registrar devices. The second scan must return “already checked in.” Scan a pending, cancelled, and malformed ticket too.
5. Test ticket recovery and the staff CSV export.
6. Run the local gate commands in `services/natcon/README.md` against the final release source.

Do not expose online card payment until the webhook, callback, and ticket email rehearsal all pass.

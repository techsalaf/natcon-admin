const fs = require('node:fs');
const router = fs.readFileSync('../../api/mobile.php', 'utf8');
const organizerLogin = fs.readFileSync('../../natcon-organizer-app/lib/Login_flow/Login_screen.dart', 'utf8');
const organizerAuth = fs.readFileSync('../../natcon-organizer-app/lib/api_screens/natcon_http.dart', 'utf8');
const organizerShell = fs.readFileSync('../../natcon-organizer-app/lib/Bottombar_screen.dart', 'utf8');
const attendeeProfile = fs.readFileSync('../../natcon-user-app/lib/screen/profile/profile_screen.dart', 'utf8');
const attendeeCheckout = fs.readFileSync('../../natcon-user-app/lib/screen/order_details.dart', 'utf8');
const delegateForm = fs.readFileSync('../../natcon-user-app/lib/screen/natcon_delegate_details.dart', 'utf8');
const attendeeApi = fs.readFileSync('../../natcon-user-app/lib/controller/bookevent_controller.dart', 'utf8');
const checks = [
  ['organizer UI exposes the three canonical staff roles', ['Admin', 'Finance', 'Registrar'].every(role => organizerLogin.includes(`"${role}"`))],
  ['legacy organizer role values map to NATCON server roles', router.includes("'admin'=>'Orgnizer','finance'=>'MANAGER','registrar'=>'SCANNER'")],
  ['canonical labels map to the legacy client response without trusting the selector', router.includes("'Admin'=>'Orgnizer','Finance'=>'MANAGER','Registrar'=>'SCANNER'") && router.includes("$requested!==$expected")],
  ['dashboard requires an authenticated staff bearer token', router.includes("$endpoint==='u_dashboard.php'") && router.includes('staffForToken($db)')],
  ['scan route calls canonical NATCON check-in and checks role', router.includes('qr_ticket_verify.php') && router.includes("['admin','registrar']") && router.includes('\\Natcon\\checkin(')],
  ['organizer HTTP client sends tokens only to NATCON API paths', organizerAuth.includes("uri.path.contains('/orag_api/')") && organizerAuth.includes("headers['Authorization'] = 'Bearer $token'")],
  ['mobile account login and registration use NATCON-owned accounts', router.includes("$endpoint==='u_reg_user.php'") && router.includes('createAccount($db,$in)') && router.includes('loginAccount($db,$in)')],
  ['both apps revoke their server token and clear it on sign-out', organizerShell.includes("action=logout") && organizerShell.includes("remove('NATCON_ACCESS_TOKEN')") && attendeeProfile.includes('action=account_logout') && attendeeProfile.includes("remove('NATCON_ACCESS_TOKEN')")],
  ['attendee history and ticket detail are routed through account-owned service functions', router.includes("ticket_status_wise.php") && router.includes('mobileTicketHistory($db,(int)$account[\'id\'],$c)') && router.includes('mobileTicketInfo($db,(int)$account[\'id\'],$token,$c)')],
  ['attendee checkout creates a NATCON order and initializes server-side Paystack', attendeeCheckout.includes('createNatconOrder(') && attendeeCheckout.includes('initializeNatconPayment(') && attendeeCheckout.includes('verifyNatconPayment(')],
  ['checkout collects all required delegate fields and requires privacy consent before request', ['name','email','course','institution','level','whatsapp','calling_line','state_origin','times_attended'].every(field => delegateForm.includes(`'${field}'`)) && delegateForm.includes('_consent') && attendeeApi.includes("'consent': true")],
  ['attendee event discovery, detail and ticket-price routes use NATCON service data', ['u_home_data.php','u_event_data.php','u_event_type_price.php'].every(endpoint => router.includes(endpoint)) && router.includes('mobileEventCard($db,$c)') && router.includes('mobileEventDetails($db,$c') && router.includes('mobileTicketType($db,$c)')],
  ['attendee favorites, FAQs, pages and notifications use NATCON-owned records', ['u_fav.php','u_favlist.php','u_faq.php','u_pagelist.php','notification.php'].every(endpoint => router.includes(endpoint)) && router.includes('toggleFavorite($db') && router.includes('favoriteEvents($db') && router.includes('mobileFaqs($db)') && router.includes('mobilePages($db)') && router.includes('mobileNotifications($db')],
];
for (const [name, passed] of checks) console.log(`${passed ? 'PASS' : 'FAIL'} ${name}`);
if (checks.some(([, passed]) => !passed)) process.exitCode = 1;

const fs = require('node:fs');
const path = require('node:path');
const repo = path.resolve(__dirname, '../../..');
const read = file => fs.readFileSync(path.join(repo, file), 'utf8');
const router = read('api/mobile.php');
const natconApi = read('api/natcon.php');
const organizerLogin = read('natcon-organizer-app/lib/Login_flow/Login_screen.dart');
const organizerAuth = read('natcon-organizer-app/lib/api_screens/natcon_http.dart');
const organizerShell = read('natcon-organizer-app/lib/Bottombar_screen.dart');
const attendeeProfile = read('natcon-user-app/lib/screen/profile/profile_screen.dart');
const attendeeCheckout = read('natcon-user-app/lib/screen/order_details.dart');
const delegateForm = read('natcon-user-app/lib/screen/natcon_delegate_details.dart');
const attendeeApi = read('natcon-user-app/lib/controller/bookevent_controller.dart');
const attendeeAuth = read('natcon-user-app/lib/Api/natcon_http.dart');
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
  ['attendee coupons are listed and validated by NATCON and sent with checkout', ['u_couponlist.php','u_check_coupon.php'].every(endpoint => router.includes(endpoint)) && router.includes('availableCoupons($db') && router.includes('applicableCoupon($db') && attendeeApi.includes("'coupon_code': couponCode.trim()")],
  ['wallet balance and top-ups require NATCON Paystack verification', natconApi.includes("$action==='wallet_initialize'") && natconApi.includes("$action==='wallet_verify'") && natconApi.includes('confirmWalletTopup($db') && router.includes("$endpoint==='u_wallet_up.php'") && router.includes('Wallet credits are added only after NATCON verifies your payment.') && read('natcon-user-app/lib/screen/addwallet/addwallet_screen.dart').includes('initializeNatconTopup()')],
  ['attendee wallet checkout sends the opt-in to server-side checkout math', attendeeCheckout.includes('useWallet: status == true') && attendeeApi.includes("if (useWallet) 'use_wallet': true") && read('services/natcon/bootstrap.php').includes("'SPEND-'.$ref")],
  ['reviews require a paid account-owned ticket and appear in shared event details', router.includes("$endpoint==='rate_update.php'") && router.includes('submitReview($db,(int)$account[\'id\']') && router.includes("mobileReviews($db,(int)$primary['id'])") && read('natcon-user-app/lib/controller/mybooking_controller.dart').includes("'ticket_id': orderID") && attendeeAuth.includes("uri.path.endsWith('/api/mobile.php')") && attendeeAuth.includes("uri.queryParameters['client']")],
  ['signup referral codes are validated and conversion tracking remains reward-free', read('natcon-user-app/lib/controller/signup_controller.dart').includes('referralCode.text.trim()') && router.includes("$endpoint==='getdata.php'") && router.includes('referralSummary($db,(int)$account[\'id\'])') && read('services/natcon/bootstrap.php').includes('markReferralConverted($db,(int)$o[\'account_id\'])') && read('natcon-user-app/lib/screen/profile/refer&earn_screen.dart').includes('Wallet rewards are currently disabled.')],
];
for (const [name, passed] of checks) console.log(`${passed ? 'PASS' : 'FAIL'} ${name}`);
if (checks.some(([, passed]) => !passed)) process.exitCode = 1;

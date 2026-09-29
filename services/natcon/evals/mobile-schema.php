<?php
declare(strict_types=1);
require dirname(__DIR__).'/bootstrap.php';
use function Natcon\migrate;
$db=new PDO('sqlite::memory:',null,null,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
migrate($db);migrate($db);
$tables=array_flip(array_column($db->query("SELECT name FROM sqlite_master WHERE type='table'")->fetchAll(),'name'));
$required=['natcon_accounts','natcon_mobile_tokens','natcon_categories','natcon_events','natcon_ticket_types','natcon_wallet_ledger','natcon_coupons','natcon_coupon_redemptions','natcon_favorites','natcon_reviews','natcon_referrals','natcon_payouts','natcon_event_media','natcon_artists','natcon_event_facilities','natcon_event_restrictions','natcon_event_profiles','natcon_faqs','natcon_pages','natcon_notifications','natcon_devices','natcon_chat_threads','natcon_chat_messages','natcon_otp_challenges'];
$missing=array_values(array_filter($required,static fn($table)=>!isset($tables[$table])));
$score=count($required)-count($missing);
echo json_encode(['suite'=>'mobile-feature-schema','passed'=>$score,'total'=>count($required),'score'=>$score/count($required),'threshold'=>1,'missing'=>$missing],JSON_PRETTY_PRINT)."\n";
exit($missing?1:0);

<?php
declare(strict_types=1);
namespace Natcon;

function config(): array {
    $file = dirname(__DIR__, 2) . '/.env.natcon';
    if (is_file($file)) foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        if (preg_match('/^([A-Z_0-9]+)=(.*)$/', trim($line), $m) && getenv($m[1]) === false) putenv($m[1].'='.trim($m[2], " \t\"'"));
    }
    return ['dsn'=>getenv('NATCON_DSN') ?: '', 'db_user'=>getenv('NATCON_DB_USER') ?: '', 'db_password'=>getenv('NATCON_DB_PASSWORD') ?: '',
        'base_url'=>rtrim(getenv('NATCON_BASE_URL') ?: 'http://localhost/natcon-admin','/'), 'secret'=>getenv('PAYSTACK_SECRET_KEY') ?: '',
        'name'=>'NATCON 2026 · Reformation', 'theme'=>'Knowledge with Purpose: Raising Responsible Muslim Leaders.',
        'start_date'=>'2026-10-01','end_date'=>'2026-10-04','venue'=>'Shaykh Idrees Fazazi Mogaji Central Mosque, Iwo, Osun State',
        'currency'=>'NGN','earlybird_end'=>'2026-09-15','capacity'=>(int)(getenv('NATCON_CAPACITY')?:0),'registration_closes'=>getenv('NATCON_REGISTRATION_CLOSES')?:'2026-10-04 23:59:59','bank'=>['name'=>'LOTUS Bank','account_name'=>'THE ACHIEVER AMBASSADOR (NATCON ACC)','account_number'=>'1014319395']];
}
function database(array $c): \PDO {
    if (!$c['dsn']) throw new \RuntimeException('NATCON database is not configured. Run the setup instructions.');
    return new \PDO($c['dsn'],$c['db_user'],$c['db_password'],[\PDO::ATTR_ERRMODE=>\PDO::ERRMODE_EXCEPTION,\PDO::ATTR_DEFAULT_FETCH_MODE=>\PDO::FETCH_ASSOC,\PDO::ATTR_EMULATE_PREPARES=>false]);
}
function migrate(\PDO $db): void {
    $id=$db->getAttribute(\PDO::ATTR_DRIVER_NAME)==='sqlite'?'INTEGER PRIMARY KEY AUTOINCREMENT':'BIGINT PRIMARY KEY AUTO_INCREMENT';
    foreach ([
        "natcon_orders (id $id, reference VARCHAR(64) NOT NULL UNIQUE, access_token VARCHAR(64) NOT NULL UNIQUE, payer_name VARCHAR(150) NOT NULL, payer_email VARCHAR(190) NOT NULL, payer_phone VARCHAR(40) NOT NULL, amount_kobo INTEGER NOT NULL, currency VARCHAR(3) NOT NULL, status VARCHAR(30) NOT NULL, bank_reference VARCHAR(190), sender_name VARCHAR(150), paid_on VARCHAR(30), created_at VARCHAR(30) NOT NULL, paid_at VARCHAR(30))",
        "natcon_delegates (id $id, reference VARCHAR(64) NOT NULL, name VARCHAR(150) NOT NULL, email VARCHAR(190), phone VARCHAR(40), chapter VARCHAR(150), state VARCHAR(100), education VARCHAR(100), accommodation VARCHAR(100), accessibility TEXT, course VARCHAR(150), institution VARCHAR(190), level VARCHAR(80), whatsapp VARCHAR(40), calling_line VARCHAR(40), state_origin VARCHAR(100), times_attended INTEGER NOT NULL DEFAULT 0, ticket_token VARCHAR(64) NOT NULL UNIQUE)",
        "natcon_staff (id $id, name VARCHAR(150) NOT NULL, email VARCHAR(190) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL, role VARCHAR(30) NOT NULL)",
        "natcon_checkins (id $id, delegate_id BIGINT NOT NULL, slot VARCHAR(80) NOT NULL, staff_id BIGINT NOT NULL, checked_at VARCHAR(30) NOT NULL, UNIQUE(delegate_id,slot))",
        "natcon_claims (id $id, delegate_id BIGINT NOT NULL, kind VARCHAR(30) NOT NULL, slot VARCHAR(80) NOT NULL, staff_id BIGINT NOT NULL, created_at VARCHAR(30) NOT NULL, UNIQUE(delegate_id,kind,slot))",
        "natcon_audit (id $id, actor VARCHAR(100) NOT NULL, action VARCHAR(60) NOT NULL, reference VARCHAR(100), detail TEXT, created_at VARCHAR(30) NOT NULL)",
        "natcon_outbox (id $id, recipient VARCHAR(190) NOT NULL, subject VARCHAR(190) NOT NULL, body TEXT NOT NULL, status VARCHAR(20) NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, created_at VARCHAR(30) NOT NULL, sent_at VARCHAR(30))",
        "natcon_limits (bucket VARCHAR(100) PRIMARY KEY, count INTEGER NOT NULL, window_start INTEGER NOT NULL)",
        "natcon_transfer_receipts (bank_reference VARCHAR(190) PRIMARY KEY, reference VARCHAR(64) NOT NULL UNIQUE, amount_kobo INTEGER NOT NULL, staff_id BIGINT NOT NULL, verified_at VARCHAR(30) NOT NULL)",
        "natcon_locks (name VARCHAR(50) PRIMARY KEY, value INTEGER NOT NULL)",
        "natcon_accounts (id $id, name VARCHAR(150) NOT NULL, email VARCHAR(190) NOT NULL UNIQUE, country_code VARCHAR(12) NOT NULL DEFAULT '', phone VARCHAR(40) NOT NULL, password_hash VARCHAR(255) NOT NULL, profile_image TEXT, referral_code VARCHAR(32) NOT NULL UNIQUE, referred_by BIGINT, wallet_balance_kobo INTEGER NOT NULL DEFAULT 0, status VARCHAR(20) NOT NULL DEFAULT 'active', created_at VARCHAR(30) NOT NULL, updated_at VARCHAR(30), UNIQUE(country_code,phone))",
        "natcon_mobile_tokens (id $id, token_hash CHAR(64) NOT NULL UNIQUE, principal_type VARCHAR(20) NOT NULL, principal_id BIGINT NOT NULL, role VARCHAR(30), expires_at VARCHAR(30) NOT NULL, revoked_at VARCHAR(30), created_at VARCHAR(30) NOT NULL)",
        "natcon_categories (id $id, title VARCHAR(150) NOT NULL, image_url TEXT, status VARCHAR(20) NOT NULL DEFAULT 'active', sort_order INTEGER NOT NULL DEFAULT 0)",
        "natcon_events (id $id, owner_staff_id BIGINT, category_id BIGINT, title VARCHAR(190) NOT NULL, slug VARCHAR(190) NOT NULL UNIQUE, description TEXT, venue VARCHAR(255), latitude VARCHAR(40), longitude VARCHAR(40), starts_at VARCHAR(30), ends_at VARCHAR(30), currency VARCHAR(3) NOT NULL DEFAULT 'NGN', status VARCHAR(20) NOT NULL DEFAULT 'draft', created_at VARCHAR(30) NOT NULL, updated_at VARCHAR(30))",
        "natcon_ticket_types (id $id, event_id BIGINT NOT NULL, label VARCHAR(120) NOT NULL, description TEXT, price_kobo INTEGER NOT NULL, capacity INTEGER NOT NULL DEFAULT 0, sales_start VARCHAR(30), sales_end VARCHAR(30), status VARCHAR(20) NOT NULL DEFAULT 'active', created_at VARCHAR(30) NOT NULL, UNIQUE(event_id,label))",
        "natcon_wallet_ledger (id $id, account_id BIGINT NOT NULL, direction VARCHAR(10) NOT NULL, amount_kobo INTEGER NOT NULL, reference VARCHAR(100) NOT NULL UNIQUE, status VARCHAR(20) NOT NULL, description VARCHAR(255) NOT NULL, created_at VARCHAR(30) NOT NULL)",
        "natcon_coupons (id $id, event_id BIGINT, code VARCHAR(64) NOT NULL UNIQUE, title VARCHAR(150) NOT NULL, discount_type VARCHAR(10) NOT NULL, discount_value INTEGER NOT NULL, minimum_kobo INTEGER NOT NULL DEFAULT 0, usage_limit INTEGER NOT NULL DEFAULT 0, usage_count INTEGER NOT NULL DEFAULT 0, expires_at VARCHAR(30), status VARCHAR(20) NOT NULL DEFAULT 'active', created_at VARCHAR(30) NOT NULL)",
        "natcon_coupon_redemptions (id $id, coupon_id BIGINT NOT NULL, account_id BIGINT NOT NULL, order_reference VARCHAR(64) NOT NULL UNIQUE, discount_kobo INTEGER NOT NULL, created_at VARCHAR(30) NOT NULL)",
        "natcon_favorites (id $id, account_id BIGINT NOT NULL, event_id BIGINT NOT NULL, created_at VARCHAR(30) NOT NULL, UNIQUE(account_id,event_id))",
        "natcon_reviews (id $id, account_id BIGINT NOT NULL, event_id BIGINT NOT NULL, order_reference VARCHAR(64) NOT NULL, rating INTEGER NOT NULL, comment TEXT, status VARCHAR(20) NOT NULL DEFAULT 'published', created_at VARCHAR(30) NOT NULL, UNIQUE(account_id,event_id))",
        "natcon_referrals (id $id, referrer_account_id BIGINT NOT NULL, referred_account_id BIGINT NOT NULL UNIQUE, referral_code VARCHAR(32) NOT NULL, reward_kobo INTEGER NOT NULL DEFAULT 0, status VARCHAR(20) NOT NULL DEFAULT 'pending', created_at VARCHAR(30) NOT NULL)",
        "natcon_payouts (id $id, staff_id BIGINT NOT NULL, amount_kobo INTEGER NOT NULL, bank_name VARCHAR(120) NOT NULL, account_name VARCHAR(150) NOT NULL, account_number VARCHAR(40) NOT NULL, note TEXT, status VARCHAR(20) NOT NULL DEFAULT 'pending', reviewed_by BIGINT, reviewed_at VARCHAR(30), created_at VARCHAR(30) NOT NULL)",
        "natcon_event_media (id $id, event_id BIGINT NOT NULL, media_type VARCHAR(20) NOT NULL, url TEXT NOT NULL, title VARCHAR(190), sort_order INTEGER NOT NULL DEFAULT 0, status VARCHAR(20) NOT NULL DEFAULT 'active')",
        "natcon_artists (id $id, event_id BIGINT NOT NULL, name VARCHAR(150) NOT NULL, role VARCHAR(120), image_url TEXT, status VARCHAR(20) NOT NULL DEFAULT 'active')",
        "natcon_event_facilities (id $id, event_id BIGINT NOT NULL, title VARCHAR(150) NOT NULL, description TEXT, status VARCHAR(20) NOT NULL DEFAULT 'active')",
        "natcon_event_restrictions (id $id, event_id BIGINT NOT NULL, title VARCHAR(150) NOT NULL, description TEXT, status VARCHAR(20) NOT NULL DEFAULT 'active')",
        "natcon_event_facility_links (event_id BIGINT NOT NULL, facility_id BIGINT NOT NULL, UNIQUE(event_id,facility_id))",
        "natcon_event_restriction_links (event_id BIGINT NOT NULL, restriction_id BIGINT NOT NULL, UNIQUE(event_id,restriction_id))",
        "natcon_media_assets (id $id, event_id BIGINT NOT NULL, asset_type VARCHAR(30) NOT NULL, image_base64 MEDIUMTEXT NOT NULL, mime_type VARCHAR(30) NOT NULL, created_at VARCHAR(30) NOT NULL)",
        "natcon_event_profiles (event_id BIGINT PRIMARY KEY, disclaimer TEXT, tags TEXT, video_urls TEXT, image_base64 MEDIUMTEXT, cover_base64 MEDIUMTEXT, updated_at VARCHAR(30))",
        "natcon_faqs (id $id, question VARCHAR(255) NOT NULL, answer TEXT NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'active', sort_order INTEGER NOT NULL DEFAULT 0)",
        "natcon_pages (id $id, slug VARCHAR(190) NOT NULL UNIQUE, title VARCHAR(190) NOT NULL, content TEXT NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'published', updated_at VARCHAR(30))",
        "natcon_notifications (id $id, account_id BIGINT NOT NULL, title VARCHAR(190) NOT NULL, body TEXT NOT NULL, channel VARCHAR(20) NOT NULL DEFAULT 'in_app', read_at VARCHAR(30), created_at VARCHAR(30) NOT NULL)",
        "natcon_devices (id $id, account_id BIGINT NOT NULL, provider VARCHAR(20) NOT NULL, device_token VARCHAR(512) NOT NULL UNIQUE, updated_at VARCHAR(30) NOT NULL)",
        "natcon_chat_threads (id $id, account_id BIGINT NOT NULL, event_id BIGINT, status VARCHAR(20) NOT NULL DEFAULT 'open', created_at VARCHAR(30) NOT NULL, updated_at VARCHAR(30))",
        "natcon_chat_messages (id $id, thread_id BIGINT NOT NULL, sender_type VARCHAR(20) NOT NULL, sender_id BIGINT NOT NULL, message TEXT NOT NULL, created_at VARCHAR(30) NOT NULL)",
        "natcon_otp_challenges (id $id, destination VARCHAR(190) NOT NULL, channel VARCHAR(20) NOT NULL, code_hash VARCHAR(255) NOT NULL, expires_at VARCHAR(30) NOT NULL, consumed_at VARCHAR(30), attempts INTEGER NOT NULL DEFAULT 0, created_at VARCHAR(30) NOT NULL)",
        "natcon_legacy_account_imports (id $id, batch_id VARCHAR(80) NOT NULL, source_table VARCHAR(80) NOT NULL, source_id VARCHAR(80) NOT NULL, target_id BIGINT NOT NULL, target_fingerprint CHAR(64) NOT NULL, wallet_kobo INTEGER NOT NULL DEFAULT 0, created_at VARCHAR(30) NOT NULL, UNIQUE(source_table,source_id), UNIQUE(batch_id,target_id))",
        "natcon_account_media (id $id, account_id BIGINT NOT NULL, image_base64 MEDIUMTEXT NOT NULL, mime_type VARCHAR(30) NOT NULL, created_at VARCHAR(30) NOT NULL, updated_at VARCHAR(30))"
    ] as $schema) $db->exec('CREATE TABLE IF NOT EXISTS '.$schema);
    $driver=$db->getAttribute(\PDO::ATTR_DRIVER_NAME);
    $profileColumns=$driver==='sqlite'?array_column($db->query('PRAGMA table_info(natcon_event_profiles)')->fetchAll(),'name'):array_column(query($db,"SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='natcon_event_profiles'")->fetchAll(),'COLUMN_NAME');
    foreach(['image_base64'=>'MEDIUMTEXT NULL','cover_base64'=>'MEDIUMTEXT NULL'] as $column=>$type)if(!in_array($column,$profileColumns,true))$db->exec("ALTER TABLE natcon_event_profiles ADD COLUMN $column $type");
    $couponColumns=$driver==='sqlite'?array_column($db->query('PRAGMA table_info(natcon_coupons)')->fetchAll(),'name'):array_column(query($db,"SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='natcon_coupons'")->fetchAll(),'COLUMN_NAME');
    foreach(['subtitle'=>'VARCHAR(150) NULL','description'=>'TEXT NULL'] as $column=>$type)if(!in_array($column,$couponColumns,true))$db->exec("ALTER TABLE natcon_coupons ADD COLUMN $column $type");
    $ignore=$driver==='sqlite'?'INSERT OR IGNORE':'INSERT IGNORE';$db->exec("$ignore INTO natcon_event_facility_links(event_id,facility_id) SELECT event_id,id FROM natcon_event_facilities");$db->exec("$ignore INTO natcon_event_restriction_links(event_id,restriction_id) SELECT event_id,id FROM natcon_event_restrictions");
    // Add commerce ownership/discount fields to existing conference orders without rewriting records.
    $orderColumns=$driver==='sqlite'
        ? array_column($db->query('PRAGMA table_info(natcon_orders)')->fetchAll(), 'name')
        : array_column(query($db,"SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='natcon_orders'")->fetchAll(), 'COLUMN_NAME');
    foreach(['event_id'=>'BIGINT NULL','ticket_type_id'=>'BIGINT NULL','account_id'=>'BIGINT NULL','coupon_id'=>'BIGINT NULL','subtotal_kobo'=>'INTEGER NULL','discount_kobo'=>'INTEGER NOT NULL DEFAULT 0','wallet_kobo'=>'INTEGER NOT NULL DEFAULT 0','tax_kobo'=>'INTEGER NOT NULL DEFAULT 0'] as $column=>$type)
        if(!in_array($column,$orderColumns,true)) $db->exec("ALTER TABLE natcon_orders ADD COLUMN $column $type");
    $delegateColumns=$driver==='sqlite'
        ? array_column($db->query('PRAGMA table_info(natcon_delegates)')->fetchAll(), 'name')
        : array_column(query($db,"SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='natcon_delegates'")->fetchAll(), 'COLUMN_NAME');
    if(!in_array('account_id',$delegateColumns,true)) $db->exec('ALTER TABLE natcon_delegates ADD COLUMN account_id BIGINT NULL');
    // Safe, repeatable upgrade for delegates already registered on an older release.
    $columns=$driver==='sqlite'
        ? array_column($db->query('PRAGMA table_info(natcon_delegates)')->fetchAll(), 'name')
        : array_column(query($db,"SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='natcon_delegates'")->fetchAll(), 'COLUMN_NAME');
    foreach(['course'=>'VARCHAR(150) NULL','institution'=>'VARCHAR(190) NULL','level'=>'VARCHAR(80) NULL','whatsapp'=>'VARCHAR(40) NULL','calling_line'=>'VARCHAR(40) NULL','state_origin'=>'VARCHAR(100) NULL','times_attended'=>'INTEGER NOT NULL DEFAULT 0'] as $column=>$type)
        if(!in_array($column,$columns,true)) $db->exec("ALTER TABLE natcon_delegates ADD COLUMN $column $type");
    $insert=$db->getAttribute(\PDO::ATTR_DRIVER_NAME)==='sqlite'?'INSERT OR IGNORE':'INSERT IGNORE';
    $db->exec("$insert INTO natcon_locks(name,value) VALUES('registration',0)");
    $db->exec("$insert INTO natcon_locks(name,value) VALUES('payout',0)");
    seedPrimaryConference($db,config());
}
function now(): string { return gmdate('Y-m-d H:i:s'); }
function query(\PDO $db,string $sql,array $args=[]): \PDOStatement { $q=$db->prepare($sql);$q->execute($args);return $q; }
function issueMobileToken(\PDO $db,string $type,int $id,?string $role=null): string {
    $token=bin2hex(random_bytes(32));query($db,'INSERT INTO natcon_mobile_tokens(token_hash,principal_type,principal_id,role,expires_at,created_at) VALUES(?,?,?,?,?,?)',[hash('sha256',$token),$type,$id,$role,gmdate('Y-m-d H:i:s',time()+60*60*24*30),now()]);return $token;
}
function accountForToken(\PDO $db): ?array {
    $headers=function_exists('getallheaders')?getallheaders():[];$auth=$_SERVER['HTTP_AUTHORIZATION']??($headers['Authorization']??'');
    if(!preg_match('/^Bearer ([a-f0-9]{64})$/i',$auth,$m))return null;
    $row=query($db,"SELECT a.id,a.name,a.email,a.country_code,a.phone,a.profile_image,a.referral_code,a.wallet_balance_kobo,t.id AS token_id FROM natcon_mobile_tokens t JOIN natcon_accounts a ON a.id=t.principal_id WHERE t.token_hash=? AND t.principal_type='attendee' AND t.revoked_at IS NULL AND t.expires_at>? AND a.status='active'",[hash('sha256',strtolower($m[1])),now()])->fetch();return $row?:null;
}
function staffForToken(\PDO $db): ?array {
    $headers=function_exists('getallheaders')?getallheaders():[];$auth=$_SERVER['HTTP_AUTHORIZATION']??($headers['Authorization']??'');
    if(!preg_match('/^Bearer ([a-f0-9]{64})$/i',$auth,$m))return null;
    $row=query($db,"SELECT s.id,s.name,s.email,s.role,t.id AS token_id FROM natcon_mobile_tokens t JOIN natcon_staff s ON s.id=t.principal_id WHERE t.token_hash=? AND t.principal_type='staff' AND t.revoked_at IS NULL AND t.expires_at>?",[hash('sha256',strtolower($m[1])),now()])->fetch();return $row?:null;
}
function createAccount(\PDO $db,array $in): array {
    $name=clean($in['name']??'',150);$email=strtolower(clean($in['email']??'',190));$country=clean($in['country_code']??$in['ccode']??'',12);$phone=clean($in['phone']??$in['mobile']??'',40);$password=(string)($in['password']??'');
    if(!$name||!filter_var($email,FILTER_VALIDATE_EMAIL)||!$phone||!preg_match('/^[+0-9 -]{6,40}$/',$phone)||strlen($password)<8||strlen($password)>128)throw new \InvalidArgumentException('Provide your name, a valid email, phone number, and password of at least 8 characters.');
    $referralCode=strtoupper(clean($in['refercode']??$in['referral_code']??'',32));$referrer=null;
    if($referralCode!==''){$referrer=query($db,'SELECT id FROM natcon_accounts WHERE referral_code=? AND status=?',[$referralCode,'active'])->fetchColumn();if(!$referrer)throw new \InvalidArgumentException('That referral code is not valid.');}
    $referral=strtoupper(bin2hex(random_bytes(6)));
    $db->beginTransaction();try{query($db,'INSERT INTO natcon_accounts(name,email,country_code,phone,password_hash,referral_code,referred_by,status,created_at) VALUES(?,?,?,?,?,?,?,?,?)',[$name,$email,$country,$phone,password_hash($password,PASSWORD_DEFAULT),$referral,$referrer?:null,'active',now()]);$id=(int)$db->lastInsertId();if($referrer)query($db,'INSERT INTO natcon_referrals(referrer_account_id,referred_account_id,referral_code,reward_kobo,status,created_at) VALUES(?,?,?,?,?,?)',[$referrer,$id,$referralCode,0,'pending',now()]);$db->commit();}
    catch(\Throwable $e){if($db->inTransaction())$db->rollBack();if($e instanceof \PDOException&&in_array((string)$e->getCode(),['23000','23505'],true))throw new \InvalidArgumentException('An account already uses that email or phone number.');throw $e;}
    $account=query($db,'SELECT id,name,email,country_code,phone,profile_image,referral_code,wallet_balance_kobo FROM natcon_accounts WHERE id=?',[$id])->fetch();$account['access_token']=issueMobileToken($db,'attendee',$id);return $account;
}
function referralSummary(\PDO $db,int $accountId): array {
    $account=query($db,'SELECT referral_code FROM natcon_accounts WHERE id=?',[$accountId])->fetch();if(!$account)throw new \InvalidArgumentException('Attendee account is unavailable.');
    return ['code'=>$account['referral_code'],'signupcredit'=>'0.00','refercredit'=>'0.00','tracked'=>(int)query($db,'SELECT COUNT(*) FROM natcon_referrals WHERE referrer_account_id=?',[$accountId])->fetchColumn(),'converted'=>(int)query($db,"SELECT COUNT(*) FROM natcon_referrals WHERE referrer_account_id=? AND status='converted'",[$accountId])->fetchColumn()];
}
function requestAccountPasswordReset(\PDO $db,string $email): void {
    $email=strtolower(clean($email,190));if(!filter_var($email,FILTER_VALIDATE_EMAIL))throw new \InvalidArgumentException('Enter a valid account email address.');
    limit($db,'password-reset:'.hash('sha256',$email),3,3600);
    $account=query($db,"SELECT id,name FROM natcon_accounts WHERE email=? AND status='active'",[$email])->fetch();
    if(!$account)return;
    $code=(string)random_int(100000,999999);$expires=(new \DateTimeImmutable('+15 minutes',new \DateTimeZone('UTC')))->format('Y-m-d H:i:s');
    $db->beginTransaction();try{
        query($db,"UPDATE natcon_otp_challenges SET consumed_at=? WHERE destination=? AND channel='password_reset' AND consumed_at IS NULL",[now(),$email]);
        query($db,'INSERT INTO natcon_otp_challenges(destination,channel,code_hash,expires_at,attempts,created_at) VALUES(?,?,?,?,?,?)',[$email,'password_reset',password_hash($code,PASSWORD_DEFAULT),$expires,0,now()]);
        $body="Assalamu alaykum {$account['name']},\n\nYour NATCON password reset code is {$code}. It expires in 15 minutes and can be used once. If you did not request this, ignore this email.";
        query($db,'INSERT INTO natcon_outbox(recipient,subject,body,status,created_at) VALUES(?,?,?,?,?)',[$email,'NATCON password reset code',$body,'pending',now()]);$db->commit();
    }catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
function resetAccountPassword(\PDO $db,string $email,string $code,string $password): void {
    $email=strtolower(clean($email,190));$code=clean($code,6);
    if(!filter_var($email,FILTER_VALIDATE_EMAIL)||!preg_match('/^[0-9]{6}$/',$code)||strlen($password)<8||strlen($password)>128)throw new \InvalidArgumentException('Enter the email code and a password of at least 8 characters.');
    $db->beginTransaction();try{
        $challenge=query($db,"SELECT id,code_hash,expires_at,attempts FROM natcon_otp_challenges WHERE destination=? AND channel='password_reset' AND consumed_at IS NULL ORDER BY id DESC LIMIT 1",[$email])->fetch();
        $account=query($db,"SELECT id FROM natcon_accounts WHERE email=? AND status='active'",[$email])->fetch();
        if(!$challenge||!$account||(int)$challenge['attempts']>=5||$challenge['expires_at']<now())throw new \InvalidArgumentException('The code is invalid or expired. Request a new code.');
        if(!password_verify($code,$challenge['code_hash'])){query($db,'UPDATE natcon_otp_challenges SET attempts=attempts+1 WHERE id=? AND attempts<5',[$challenge['id']]);$db->commit();throw new \InvalidArgumentException('The code is invalid or expired. Request a new code.');}
        $consumed=query($db,"UPDATE natcon_otp_challenges SET consumed_at=?,attempts=attempts+1 WHERE id=? AND consumed_at IS NULL AND attempts<5",[now(),$challenge['id']]);if($consumed->rowCount()!==1)throw new \InvalidArgumentException('The code has already been used. Request a new code.');
        query($db,'UPDATE natcon_accounts SET password_hash=?,updated_at=? WHERE id=?',[password_hash($password,PASSWORD_DEFAULT),now(),$account['id']]);query($db,"UPDATE natcon_mobile_tokens SET revoked_at=? WHERE principal_type='attendee' AND principal_id=? AND revoked_at IS NULL",[now(),$account['id']]);audit($db,'account:'.$account['id'],'password_reset',$email);$db->commit();
    }catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
function markReferralConverted(\PDO $db,int $accountId): bool {
    if($accountId<1)return false;
    return query($db,"UPDATE natcon_referrals SET status='converted' WHERE referred_account_id=? AND status='pending'",[$accountId])->rowCount()>0;
}
function payoutBalance(\PDO $db): array {
    $revenue=(int)query($db,"SELECT COALESCE(SUM(amount_kobo+wallet_kobo),0) FROM natcon_orders WHERE status='paid'")->fetchColumn();
    $reserved=(int)query($db,"SELECT COALESCE(SUM(amount_kobo),0) FROM natcon_payouts WHERE status IN ('pending','approved','paid')")->fetchColumn();
    return ['revenue_kobo'=>$revenue,'reserved_kobo'=>$reserved,'available_kobo'=>max(0,$revenue-$reserved)];
}
function payoutNairaToKobo(mixed $amount): int {
    if(!is_scalar($amount)||!preg_match('/^(?:0|[1-9]\d{0,8})(?:\.\d{1,2})?$/',trim((string)$amount)))throw new \InvalidArgumentException('Enter a valid payout amount with up to two decimal places.');
    [$whole,$fraction]=array_pad(explode('.',(string)$amount,2),2,'');return ((int)$whole*100)+(int)str_pad($fraction,2,'0');
}
function requestPayout(\PDO $db,int $staffId,int $amountKobo,array $details): array {
    $type=clean($details['r_type']??'',32);if(!in_array($type,['BANK Transfer','UPI','Paypal'],true))throw new \InvalidArgumentException('Choose a supported payout destination.');
    if($amountKobo<100)throw new \InvalidArgumentException('The minimum payout request is ₦1.00.');
    $bank=clean($details['bank_name']??'',120);$name=clean($details['acc_name']??'',150);$account=clean($details['acc_number']??'',40);$ifsc=clean($details['ifsc_code']??'',24);$upi=clean($details['upi_id']??'',190);$paypal=strtolower(clean($details['paypal_id']??'',190));
    if($type==='BANK Transfer'&&(!$bank||!$name||!preg_match('/^[0-9]{8,40}$/',$account)))throw new \InvalidArgumentException('Provide a bank name, account holder, and valid account number.');
    if($type==='UPI'&&!preg_match('/^[A-Za-z0-9._-]{2,100}@[A-Za-z0-9.-]{2,80}$/',$upi))throw new \InvalidArgumentException('Provide a valid UPI ID.');
    if($type==='Paypal'&&!filter_var($paypal,FILTER_VALIDATE_EMAIL))throw new \InvalidArgumentException('Provide a valid PayPal email.');
    $note=json_encode(['method'=>$type,'request_note'=>clean($details['note']??'',1000),'ifsc_code'=>$ifsc,'upi_id'=>$upi,'paypal_id'=>$paypal],JSON_UNESCAPED_SLASHES);
    $db->beginTransaction();try{
        query($db,"UPDATE natcon_locks SET value=value+1 WHERE name='payout'");$available=payoutBalance($db)['available_kobo'];if($amountKobo>$available)throw new \InvalidArgumentException('Payout amount exceeds available paid ticket revenue.');
        query($db,'INSERT INTO natcon_payouts(staff_id,amount_kobo,bank_name,account_name,account_number,note,status,created_at) VALUES(?,?,?,?,?,?,?,?)',[$staffId,$amountKobo,$bank,$name,$account,$note,'pending',now()]);$id=(int)$db->lastInsertId();audit($db,(string)$staffId,'payout_requested',(string)$id,['amount_kobo'=>$amountKobo,'method'=>$type]);$db->commit();return ['payout_id'=>$id,'status'=>'pending','amount_kobo'=>$amountKobo,'available_kobo'=>$available-$amountKobo];
    }catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
function payoutHistory(\PDO $db,int $staffId,string $role): array {
    if(!in_array($role,['admin','finance'],true))throw new \InvalidArgumentException('Your role cannot view payout records.');
    $rows=$role==='finance'?query($db,'SELECT p.*,s.name AS requester FROM natcon_payouts p JOIN natcon_staff s ON s.id=p.staff_id ORDER BY p.id DESC LIMIT 500')->fetchAll():query($db,'SELECT p.*,s.name AS requester FROM natcon_payouts p JOIN natcon_staff s ON s.id=p.staff_id WHERE p.staff_id=? ORDER BY p.id DESC LIMIT 500',[$staffId])->fetchAll();
    return array_map(static function($r){$extra=json_decode((string)$r['note'],true);$extra=is_array($extra)?$extra:[];return ['payout_id'=>(string)$r['id'],'staff_id'=>(string)$r['staff_id'],'requester'=>$r['requester'],'amt'=>number_format((int)$r['amount_kobo']/100,2,'.',''),'amount_kobo'=>(int)$r['amount_kobo'],'status'=>$r['status'],'proof'=>'','r_date'=>$r['created_at'],'r_type'=>$extra['method']??'BANK Transfer','acc_number'=>$r['account_number'],'bank_name'=>$r['bank_name'],'acc_name'=>$r['account_name'],'ifsc_code'=>$extra['ifsc_code']??'','upi_id'=>$extra['upi_id']??'','paypal_id'=>$extra['paypal_id']??'','note'=>$extra['request_note']??'','reviewed_by'=>$r['reviewed_by'],'reviewed_at'=>$r['reviewed_at']];},$rows);
}
function reviewPayout(\PDO $db,int $financeId,int $payoutId,string $status,string $note): array {
    $note=clean($note,1000);if(!in_array($status,['approved','rejected','paid'],true))throw new \InvalidArgumentException('Choose approved, rejected, or paid.');
    if(($status==='paid'&&strlen($note)<8)||($status!=='paid'&&strlen($note)<4))throw new \InvalidArgumentException('Enter a review note; paid requests also need the bank transfer reference.');
    $db->beginTransaction();try{$p=query($db,'SELECT status,amount_kobo,staff_id FROM natcon_payouts WHERE id=?',[$payoutId])->fetch();if(!$p)throw new \InvalidArgumentException('Payout request not found.');$valid=($status==='paid'&&$p['status']==='approved')||(($status==='approved'||$status==='rejected')&&$p['status']==='pending');if(!$valid)throw new \InvalidArgumentException('This payout request has already been reviewed or cannot take that transition.');$updated=query($db,'UPDATE natcon_payouts SET status=?,reviewed_by=?,reviewed_at=? WHERE id=? AND status=?',[$status,$financeId,now(),$payoutId,$p['status']]);if($updated->rowCount()!==1)throw new \InvalidArgumentException('This payout request was updated by another Finance user. Refresh and try again.');audit($db,(string)$financeId,'payout_'.$status,(string)$payoutId,['requester_id'=>(int)$p['staff_id'],'amount_kobo'=>(int)$p['amount_kobo'],'note'=>$note]);$db->commit();return ['payout_id'=>$payoutId,'status'=>$status];}catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
function loginAccount(\PDO $db,array $in): array {
    $country=clean($in['country_code']??$in['ccode']??'',12);$phone=clean($in['phone']??$in['mobile']??'',40);$password=(string)($in['password']??'');
    $account=query($db,"SELECT id,name,email,country_code,phone,profile_image,referral_code,wallet_balance_kobo,password_hash FROM natcon_accounts WHERE country_code=? AND phone=? AND status='active'",[$country,$phone])->fetch();
    if(!$account||!password_verify($password,$account['password_hash']))throw new \InvalidArgumentException('Phone number or password is incorrect.');
    unset($account['password_hash']);$account['access_token']=issueMobileToken($db,'attendee',(int)$account['id']);return $account;
}
function updateAccountProfile(\PDO $db,int $id,array $in): array {
    $name=clean($in['name']??'',150);$email=strtolower(clean($in['email']??'',190));if(!$name||!filter_var($email,FILTER_VALIDATE_EMAIL))throw new \InvalidArgumentException('Provide a name and valid email address.');
    try{query($db,'UPDATE natcon_accounts SET name=?,email=?,updated_at=? WHERE id=?',[$name,$email,now(),$id]);}catch(\PDOException $e){if(in_array((string)$e->getCode(),['23000','23505'],true))throw new \InvalidArgumentException('That email is already used by another account.');throw $e;}
    return query($db,'SELECT id,name,email,country_code,phone,profile_image,referral_code,wallet_balance_kobo FROM natcon_accounts WHERE id=?',[$id])->fetch();
}
function updateAccountProfileImage(\PDO $db,int $id,array $in): array {
    $encoded=(string)($in['img']??$in['image']??'');if($encoded===''||$encoded==='0')throw new \InvalidArgumentException('Choose a profile image.');$encoded=organizerImageBase64($encoded,null);$bytes=base64_decode((string)$encoded,true);$mime=match(true){is_string($bytes)&&str_starts_with($bytes,"\xFF\xD8\xFF")=>'image/jpeg',is_string($bytes)&&str_starts_with($bytes,"\x89PNG\r\n\x1A\n")=>'image/png',is_string($bytes)&&substr($bytes,0,4)==='GIF8'=>'image/gif',is_string($bytes)&&substr($bytes,0,4)==='RIFF'&&substr($bytes,8,4)==='WEBP'=>'image/webp',default=>throw new \InvalidArgumentException('Choose a valid JPEG, PNG, GIF, or WebP profile image.')};
    $db->beginTransaction();try{$old=query($db,'SELECT profile_image FROM natcon_accounts WHERE id=? AND status=?',[$id,'active'])->fetchColumn();if($old===false)throw new \InvalidArgumentException('Account is unavailable.');$assetId=preg_match('/^api\/mobile-media\.php\?account_asset_id=([1-9]\d{0,9})$/',(string)$old,$match)?(int)$match[1]:0;$asset=$assetId?query($db,'SELECT id FROM natcon_account_media WHERE id=? AND account_id=?',[$assetId,$id])->fetchColumn():false;if($asset)query($db,'UPDATE natcon_account_media SET image_base64=?,mime_type=?,updated_at=? WHERE id=? AND account_id=?',[$encoded,$mime,now(),$assetId,$id]);else{query($db,'INSERT INTO natcon_account_media(account_id,image_base64,mime_type,created_at) VALUES(?,?,?,?)',[$id,$encoded,$mime,now()]);$assetId=(int)$db->lastInsertId();}query($db,'UPDATE natcon_accounts SET profile_image=?,updated_at=? WHERE id=?',['api/mobile-media.php?account_asset_id='.$assetId,now(),$id]);audit($db,(string)$id,'profile_image_updated',(string)$assetId,['mime_type'=>$mime,'bytes'=>strlen($bytes)]);$db->commit();return query($db,'SELECT id,name,email,country_code,phone,profile_image,referral_code,wallet_balance_kobo FROM natcon_accounts WHERE id=?',[$id])->fetch();}catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
function mobileTicketHistory(\PDO $db,int $accountId,array $c): array {
    $orders=query($db,"SELECT o.reference,o.created_at,o.paid_at,o.event_id,d.ticket_token,d.name,tt.label,e.title event_title,e.starts_at,e.venue FROM natcon_orders o JOIN natcon_delegates d ON d.reference=o.reference LEFT JOIN natcon_ticket_types tt ON tt.id=o.ticket_type_id LEFT JOIN natcon_events e ON e.id=o.event_id WHERE o.account_id=? AND o.status='paid' ORDER BY o.created_at DESC,d.id ASC",[$accountId])->fetchAll();
    $data=[];foreach($orders as $ticket)$data[]=['event_id'=>(string)($ticket['event_id']??''),'event_title'=>$ticket['event_title']??$c['name'],'event_img'=>'','event_sdate'=>substr((string)($ticket['starts_at']??$c['start_date']),0,10),'event_place_name'=>$ticket['venue']??$c['venue'],'ticket_id'=>$ticket['ticket_token'],'total_ticket'=>'1','ticket_type'=>$ticket['label']?:'Delegate','book_mintues'=>0];
    return $data;
}
function mobileTicketInfo(\PDO $db,int $accountId,string $token,array $c): array {
    $ticket=query($db,"SELECT d.*,o.payer_name,o.payer_email,o.payer_phone,o.amount_kobo,o.wallet_kobo,o.bank_reference,o.reference,o.status,o.event_id,tt.label ticket_label,e.title event_title,e.starts_at event_starts_at,e.venue event_venue,e.latitude event_latitude,e.longitude event_longitude FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference LEFT JOIN natcon_ticket_types tt ON tt.id=o.ticket_type_id LEFT JOIN natcon_events e ON e.id=o.event_id WHERE d.ticket_token=? AND o.account_id=? AND o.status='paid'",[$token,$accountId])->fetch();
    if(!$ticket)throw new \InvalidArgumentException('Paid ticket not found in this account.');
    $paidCount=max(1,(int)query($db,'SELECT COUNT(*) FROM natcon_delegates WHERE reference=?',[$ticket['reference']])->fetchColumn());$unit=round(((int)$ticket['amount_kobo']+(int)($ticket['wallet_kobo']??0))/$paidCount);$amount=number_format($unit/100,2,'.','');
    return ['ticket_id'=>$ticket['ticket_token'],'ticket_title'=>$ticket['event_title']??$c['name'],'start_time'=>substr((string)($ticket['event_starts_at']??$c['start_date']),0,10),'event_address'=>$ticket['event_venue']??$c['venue'],'event_address_title'=>$ticket['event_venue']??$c['venue'],'event_latitude'=>$ticket['event_latitude']??'0','event_longtitude'=>$ticket['event_longitude']??'0','sponsore_id'=>'NATCON','sponsore_img'=>'','sponsore_title'=>'The Achiever Ambassadors Islamic Foundation','qrcode'=>$ticket['ticket_token'],'unique_code'=>$ticket['reference'],'ticket_username'=>$ticket['name'],'ticket_mobile'=>$ticket['whatsapp']?:$ticket['phone'],'ticket_email'=>$ticket['email'],'ticket_rate'=>'0','ticket_type'=>$ticket['ticket_label']??'Delegate','total_ticket'=>'1','ticket_subtotal'=>$amount,'ticket_cou_amt'=>'0','ticket_wall_amt'=>'0','ticket_tax'=>'0','ticket_total_amt'=>$amount,'ticket_p_method'=>$ticket['bank_reference']?'Bank Transfer':'Paystack','ticket_transaction_id'=>$ticket['bank_reference']?:$ticket['reference'],'ticket_status'=>'paid'];
}
function seedPrimaryConference(\PDO $db,array $c): int {
    $category=query($db,"SELECT id FROM natcon_categories WHERE title='NATCON' ORDER BY id LIMIT 1")->fetchColumn();
    if(!$category){query($db,'INSERT INTO natcon_categories(title,image_url,status,sort_order) VALUES(?,?,?,?)',['NATCON',null,'active',0]);$category=(int)$db->lastInsertId();}
    $event=query($db,"SELECT id FROM natcon_events WHERE slug='natcon-2026'")->fetch();
    if(!$event){query($db,'INSERT INTO natcon_events(owner_staff_id,category_id,title,slug,description,venue,starts_at,ends_at,currency,status,created_at) VALUES(NULL,?,?,?,?,?,?,?,?,?,?)',[$category,$c['name'],'natcon-2026',$c['theme'],$c['venue'],$c['start_date'].' 00:00:00',$c['end_date'].' 23:59:59','NGN','published',now()]);$id=(int)$db->lastInsertId();}
    else $id=(int)$event['id'];
    query($db,'UPDATE natcon_events SET category_id=? WHERE id=? AND category_id IS NULL',[$category,$id]);
    $earlyEnd=$c['earlybird_end'].' 23:59:59';$standardStart=gmdate('Y-m-d H:i:s',strtotime($earlyEnd.' UTC')+1);
    foreach([['NATCON Early Bird',700000,null,$earlyEnd],['NATCON Delegate',800000,$standardStart,null]] as [$label,$price,$start,$end]){
        $exists=query($db,'SELECT id FROM natcon_ticket_types WHERE event_id=? AND label=?',[$id,$label])->fetchColumn();
        if(!$exists)query($db,'INSERT INTO natcon_ticket_types(event_id,label,description,price_kobo,capacity,sales_start,sales_end,status,created_at) VALUES(?,?,?,?,?,?,?,?,?)',[$id,$label,'Personal admission ticket for NATCON 2026.',$price,(int)$c['capacity'],$start,$end,'active',now()]);
    }
    return $id;
}
function primaryConference(\PDO $db): array {
    $row=query($db,"SELECT * FROM natcon_events WHERE slug='natcon-2026' AND status='published'")->fetch();
    if(!$row)throw new \RuntimeException('The canonical NATCON 2026 event is not seeded. Run the NATCON migration.');
    return $row;
}
function publishedEvent(\PDO $db,string $eventId): array {
    if(!preg_match('/^[1-9]\d{0,9}$/',$eventId))throw new \InvalidArgumentException('Choose a valid NATCON event.');
    $row=query($db,"SELECT * FROM natcon_events WHERE id=? AND status='published'",[(int)$eventId])->fetch();if(!$row)throw new \InvalidArgumentException('This event is not available for registration.');return $row;
}
function activeTicketType(\PDO $db,int $eventId): array {
    $at=now();$row=query($db,"SELECT * FROM natcon_ticket_types WHERE event_id=? AND status='active' AND (sales_start IS NULL OR sales_start<=?) AND (sales_end IS NULL OR sales_end>=?) ORDER BY price_kobo ASC,id ASC LIMIT 1",[$eventId,$at,$at])->fetch();
    if(!$row)throw new \InvalidArgumentException('NATCON ticket sales are not open. Contact the organizers.');
    return $row;
}
function mobileEventCard(\PDO $db,array $c): array {$event=primaryConference($db);return ['event_id'=>(string)$event['id'],'event_title'=>$event['title'],'event_img'=>'','event_sdate'=>substr((string)$event['starts_at'],0,10),'event_place_name'=>$event['venue']];}
function mobileEventCards(\PDO $db,int $limit=100): array {
    $limit=max(1,min(100,$limit));$rows=query($db,"SELECT e.id,e.title,e.starts_at,e.venue,p.image_base64 FROM natcon_events e LEFT JOIN natcon_event_profiles p ON p.event_id=e.id WHERE e.status='published' ORDER BY e.starts_at DESC,e.id DESC LIMIT $limit")->fetchAll();
    return array_map(static fn($r)=>['event_id'=>(string)$r['id'],'event_title'=>$r['title'],'event_img'=>eventImageUrl((int)$r['id'],$r['image_base64']??''),'event_sdate'=>substr((string)$r['starts_at'],0,10),'event_place_name'=>$r['venue']??''],$rows);
}
function eventImageUrl(int $eventId,mixed $image): string {return $image?rtrim(config()['base_url'],'/').'/api/mobile-media.php?event_id='.$eventId.'&kind=image':'';}
function mobileEventCategories(\PDO $db): array {
    $rows=query($db,"SELECT c.id,c.title,c.image_url,COUNT(e.id) AS total_event FROM natcon_categories c JOIN natcon_events e ON e.category_id=c.id AND e.status='published' WHERE c.status='active' GROUP BY c.id,c.title,c.image_url ORDER BY c.sort_order,c.title")->fetchAll();
    return array_map(static fn($row)=>['id'=>(string)$row['id'],'title'=>$row['title'],'cat_img'=>$row['image_url']??'','cover_img'=>'','total_event'=>(int)$row['total_event']],$rows);
}
function mobileEventSearch(\PDO $db,string $keyword=''): array {
    $keyword=clean($keyword,100);$rows=$keyword===''?query($db,"SELECT e.id,e.title,e.starts_at,e.venue,p.image_base64 FROM natcon_events e LEFT JOIN natcon_event_profiles p ON p.event_id=e.id WHERE e.status='published' ORDER BY e.starts_at DESC,e.id DESC LIMIT 100")->fetchAll():query($db,"SELECT DISTINCT e.id,e.title,e.starts_at,e.venue,p.image_base64 FROM natcon_events e LEFT JOIN natcon_categories c ON c.id=e.category_id LEFT JOIN natcon_event_profiles p ON p.event_id=e.id WHERE e.status='published' AND (e.title LIKE ? OR e.description LIKE ? OR e.venue LIKE ? OR c.title LIKE ?) ORDER BY e.starts_at DESC,e.id DESC LIMIT 100",array_fill(0,4,'%'.$keyword.'%'))->fetchAll();
    return array_map(static fn($row)=>['event_id'=>(string)$row['id'],'event_title'=>$row['title'],'event_img'=>eventImageUrl((int)$row['id'],$row['image_base64']??''),'event_sdate'=>substr((string)$row['starts_at'],0,10),'event_place_name'=>$row['venue']??''],$rows);
}
function mobileEventsByCategory(\PDO $db,string $categoryId): array {
    if(!preg_match('/^[1-9]\d{0,8}$/',$categoryId))throw new \InvalidArgumentException('Choose a valid event category.');
    $rows=query($db,"SELECT e.id,e.title,e.starts_at,e.venue,p.image_base64 FROM natcon_events e JOIN natcon_categories c ON c.id=e.category_id LEFT JOIN natcon_event_profiles p ON p.event_id=e.id WHERE e.status='published' AND c.status='active' AND c.id=? ORDER BY e.starts_at DESC,e.id DESC LIMIT 100",[(int)$categoryId])->fetchAll();
    return array_map(static fn($row)=>['event_id'=>(string)$row['id'],'event_title'=>$row['title'],'event_img'=>eventImageUrl((int)$row['id'],$row['image_base64']??''),'event_sdate'=>substr((string)$row['starts_at'],0,10),'event_place_name'=>$row['venue']??''],$rows);
}
function organizerEventRow(\PDO $db,array $event): array {
    $type=query($db,"SELECT id,label,price_kobo,capacity FROM natcon_ticket_types WHERE event_id=? AND status='active' ORDER BY price_kobo,id LIMIT 1",[$event['id']])->fetch();
    $paid=(int)query($db,"SELECT COUNT(*) FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE o.event_id=? AND o.status='paid'",[$event['id']])->fetchColumn();
    $start=(string)($event['starts_at']??'');$end=(string)($event['ends_at']??'');$today=(new \DateTimeImmutable('now',new \DateTimeZone('Africa/Lagos')))->format('Y-m-d');$progress=$event['status']==='cancelled'?'Cancelled':($event['status']==='completed'?'Past':($today<substr($start,0,10)?'Upcoming':($today>substr($end,0,10)?'Past':'Today')));
    $profile=query($db,'SELECT disclaimer,tags,video_urls,image_base64,cover_base64 FROM natcon_event_profiles WHERE event_id=?',[$event['id']])->fetch()?:[];
    $base=rtrim(config()['base_url'],'/').'/api/mobile-media.php?event_id='.(int)$event['id'];$image=!empty($profile['image_base64'])?$base.'&kind=image':'';$cover=!empty($profile['cover_base64'])?$base.'&kind=cover':'';
    return ['event_id'=>(string)$event['id'],'event_title'=>$event['title'],'event_cat_id'=>(string)($event['category_id']??''),'event_cat_name'=>'NATCON','event_cover_img'=>$cover,'event_image'=>$image,'event_status'=>$event['status'],'event_start_date'=>substr($start,0,10),'event_start_time'=>substr($start,11,8),'event_end_time'=>substr($end,11,8),'event_address'=>$event['venue']??'','event_description'=>$event['description']??'','event_disclaimer'=>$profile['disclaimer']??'','event_latitude'=>$event['latitude']??'0','event_longtitude'=>$event['longitude']??'0','event_progress'=>$progress,'event_place_name'=>$event['venue']??'','event_facility_id'=>implode(',',eventSelectionIds($db,(int)$event['id'],'facility')),'event_restict_id'=>implode(',',eventSelectionIds($db,(int)$event['id'],'restriction')),'event_tags'=>$profile['tags']??'NATCON','event_vurls'=>$profile['video_urls']??'','type_id'=>(string)($type['id']??''),'event_type_list'=>$type['label']??'','ticket_price'=>number_format((int)($type['price_kobo']??0)/100,2,'.',''),'total_ticket'=>(int)($type['capacity']??0),'total_book_ticket'=>$paid];
}
function eventSelectionIds(\PDO $db,int $eventId,string $kind): array {
    return match($kind){'facility'=>array_map('strval',array_column(query($db,'SELECT facility_id FROM natcon_event_facility_links WHERE event_id=? ORDER BY facility_id',[$eventId])->fetchAll(),'facility_id')),'restriction'=>array_map('strval',array_column(query($db,'SELECT restriction_id FROM natcon_event_restriction_links WHERE event_id=? ORDER BY restriction_id',[$eventId])->fetchAll(),'restriction_id')),default=>throw new \InvalidArgumentException('Unknown event content kind.')};
}
function organizerEvents(\PDO $db): array {
    return array_map(static fn($event)=>organizerEventRow($db,$event),query($db,'SELECT * FROM natcon_events ORDER BY starts_at DESC,id DESC')->fetchAll());
}
function organizerEventDetails(\PDO $db,string $eventId): array {
    $event=query($db,'SELECT * FROM natcon_events WHERE id=?',[clean($eventId,32)])->fetch();if(!$event)throw new \InvalidArgumentException('NATCON event not found.');$row=organizerEventRow($db,$event);
    $content=eventContent($db,(int)$event['id']);
    return ['event_id'=>$row['event_id'],'event_title'=>$row['event_title'],'event_cover_img'=>$row['event_cover_img'],'event_image'=>$row['event_image'],'event_status'=>$row['event_status'],'event_start_date'=>$row['event_start_date'],'event_start_time'=>$row['event_start_time'],'event_end_time'=>$row['event_end_time'],'event_address'=>$row['event_address'],'event_description'=>$row['event_description'],'event_disclaimer'=>$row['event_disclaimer'],'event_latitude'=>$row['event_latitude'],'event_longtitude'=>$row['event_longtitude'],'event_progress'=>$row['event_progress'],'event_place_name'=>$row['event_place_name'],'event_type_list'=>$row['event_type_list'],'event_revnue'=>(int)query($db,"SELECT COALESCE(SUM(amount_kobo+wallet_kobo),0) FROM natcon_orders WHERE event_id=? AND status='paid'",[$event['id']])->fetchColumn(),'ticket_price'=>$row['ticket_price'],'event_tags'=>$row['event_tags'],'event_vurls'=>$row['event_vurls'],'total_ticket'=>$row['total_ticket'],'total_book_ticket'=>$row['total_book_ticket'],'gallerydata'=>$content['gallery'],'artistdata'=>$content['artists'],'facilitydata'=>$content['facilities'],'restrictiondata'=>$content['restrictions'],'joined_user'=>[],'attend_user'=>[],'notjoined_user'=>[],'total_review'=>[]];
}
function eventContent(\PDO $db,int $eventId): array {
    $media=query($db,"SELECT id,media_type,url,title FROM natcon_event_media WHERE event_id=? AND status='active' ORDER BY sort_order,id",[$eventId])->fetchAll();
    $artists=query($db,"SELECT id,name,role,image_url FROM natcon_artists WHERE event_id=? AND status='active' ORDER BY id",[$eventId])->fetchAll();
    $facilities=query($db,"SELECT f.id,f.title,f.description FROM natcon_event_facility_links l JOIN natcon_event_facilities f ON f.id=l.facility_id WHERE l.event_id=? AND f.status='active' ORDER BY f.id",[$eventId])->fetchAll();
    $restrictions=query($db,"SELECT r.id,r.title,r.description FROM natcon_event_restriction_links l JOIN natcon_event_restrictions r ON r.id=l.restriction_id WHERE l.event_id=? AND r.status='active' ORDER BY r.id",[$eventId])->fetchAll();
    return ['gallery'=>array_values(array_map(static fn($r)=>eventContentAssetUrl((string)$r['url']),array_filter($media,static fn($r)=>$r['media_type']==='gallery'))),'artists'=>array_map(static fn($r)=>['artist_img'=>eventContentAssetUrl((string)($r['image_url']??'')),'artist_title'=>$r['name'],'artist_role'=>$r['role']??'','id'=>(string)$r['id']],$artists),'facilities'=>array_map(static fn($r)=>['facility_img'=>'','facility_title'=>$r['title'],'description'=>$r['description']??'','id'=>(string)$r['id']],$facilities),'restrictions'=>array_map(static fn($r)=>['restriction_img'=>'','restriction_title'=>$r['title'],'description'=>$r['description']??'','id'=>(string)$r['id']],$restrictions)];
}
function eventContentAssetUrl(string $value): string {
    if(!preg_match('/^natcon-asset:([1-9]\d{0,9})$/',$value,$m))return $value;return rtrim(config()['base_url'],'/').'/api/mobile-media.php?asset_id='.$m[1];
}
function saveEventContentAsset(\PDO $db,int $eventId,string $kind,mixed $raw,?string $previous): ?string {
    $raw=(string)$raw;if($raw===''||$raw==='0')return $previous;if(preg_match('#^https://#i',$raw))return clean($raw,2000);$encoded=organizerImageBase64($raw,null);$bytes=base64_decode((string)$encoded,true);$mime=match(true){is_string($bytes)&&str_starts_with($bytes,"\xFF\xD8\xFF")=>'image/jpeg',is_string($bytes)&&str_starts_with($bytes,"\x89PNG\r\n\x1A\n")=>'image/png',is_string($bytes)&&substr($bytes,0,4)==='GIF8'=>'image/gif',is_string($bytes)&&substr($bytes,0,4)==='RIFF'&&substr($bytes,8,4)==='WEBP'=>'image/webp',default=>throw new \InvalidArgumentException('Choose a valid event image.')};query($db,'INSERT INTO natcon_media_assets(event_id,asset_type,image_base64,mime_type,created_at) VALUES(?,?,?,?,?)',[$eventId,$kind,$encoded,$mime,now()]);return 'natcon-asset:'.(string)$db->lastInsertId();
}
function organizerEventContentList(\PDO $db,string $kind,string $eventId=''): array {
    if($eventId!==''&&!preg_match('/^[1-9]\d{0,9}$/',$eventId))throw new \InvalidArgumentException('Choose a valid NATCON event.');$filter=$eventId!==''?' AND x.event_id=?':'';$args=$eventId!==''?[(int)$eventId]:[];
    if(in_array($kind,['facility','restriction'],true)){$table=$kind==='facility'?'natcon_event_facilities':'natcon_event_restrictions';$rows=query($db,"SELECT x.*,e.title event_title FROM $table x JOIN natcon_events e ON e.id=x.event_id WHERE x.status='active'$filter ORDER BY x.title,x.id",$args)->fetchAll();return array_map(static fn($r)=>['id'=>(string)$r['id'],'event_id'=>(string)$r['event_id'],'event_title'=>$r['event_title'],'title'=>$r['title'],'img'=>'','status'=>'1'],$rows);}
    if($kind==='artist'){$rows=query($db,"SELECT x.*,e.title event_title FROM natcon_artists x JOIN natcon_events e ON e.id=x.event_id WHERE x.status='active'$filter ORDER BY x.name,x.id",$args)->fetchAll();return array_map(static fn($r)=>['id'=>(string)$r['id'],'event_id'=>(string)$r['event_id'],'event_title'=>$r['event_title'],'image'=>eventContentAssetUrl((string)($r['image_url']??'')),'title'=>$r['name'],'arole'=>$r['role']??'','status'=>'1'],$rows);}
    if($kind==='gallery'){$rows=query($db,"SELECT x.*,e.title event_title FROM natcon_event_media x JOIN natcon_events e ON e.id=x.event_id WHERE x.media_type='gallery'$filter ORDER BY x.sort_order,x.id",$args)->fetchAll();return array_map(static fn($r)=>['id'=>(string)$r['id'],'event_id'=>(string)$r['event_id'],'event_title'=>$r['event_title'],'image'=>eventContentAssetUrl((string)$r['url']),'status'=>$r['status']==='active'?'1':'0'],$rows);}
    throw new \InvalidArgumentException('Unknown NATCON event content collection.');
}
function saveOrganizerEventContent(\PDO $db,string $kind,array $in,?int $recordId,int $staffId): array {
    $eventId=filter_var($in['event_id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);if(!$eventId||!query($db,'SELECT id FROM natcon_events WHERE id=?',[$eventId])->fetchColumn())throw new \InvalidArgumentException('Choose a NATCON event.');$status=match((string)($in['status']??'1')){'1','active'=>'active','0','inactive'=>'inactive',default=>throw new \InvalidArgumentException('Choose an active or inactive status.')};
    $table=match($kind){'facility'=>'natcon_event_facilities','restriction'=>'natcon_event_restrictions','artist'=>'natcon_artists','gallery'=>'natcon_event_media',default=>throw new \InvalidArgumentException('Unknown NATCON event content type.')};$old=$recordId?query($db,"SELECT * FROM $table WHERE id=? AND event_id=?",[$recordId,$eventId])->fetch():null;if($recordId&&!$old)throw new \InvalidArgumentException('Event content record not found for this event.');
    if(in_array($kind,['facility','restriction'],true)){$title=clean($in['title']??$in[$kind.'_title']??'',150);$description=clean($in['description']??'',2000);if($title==='')throw new \InvalidArgumentException('Enter a title for this event detail.');if($recordId)query($db,"UPDATE $table SET title=?,description=?,status=? WHERE id=? AND event_id=?",[$title,$description,$status,$recordId,$eventId]);else query($db,"INSERT INTO $table(event_id,title,description,status) VALUES(?,?,?,?)",[$eventId,$title,$description,$status]);}
    elseif($kind==='artist'){$name=clean($in['artist_name']??$in['name']??'',150);$role=clean($in['artist_role']??$in['role']??'',120);if($name==='')throw new \InvalidArgumentException('Enter the artist or speaker name.');$image=saveEventContentAsset($db,(int)$eventId,'artist',$in['img']??'0',$old['image_url']??null);if($recordId)query($db,'UPDATE natcon_artists SET name=?,role=?,image_url=?,status=? WHERE id=? AND event_id=?',[$name,$role,$image,$status,$recordId,$eventId]);else query($db,'INSERT INTO natcon_artists(event_id,name,role,image_url,status) VALUES(?,?,?,?,?)',[$eventId,$name,$role,$image,$status]);}
    else{$image=saveEventContentAsset($db,(int)$eventId,'gallery',$in['img']??($in['url']??''),$old['url']??null);if(!$image)throw new \InvalidArgumentException('Choose a gallery image or secure image URL.');if($recordId)query($db,"UPDATE natcon_event_media SET url=?,status=? WHERE id=? AND event_id=? AND media_type='gallery'",[$image,$status,$recordId,$eventId]);else query($db,'INSERT INTO natcon_event_media(event_id,media_type,url,title,status) VALUES(?,?,?,?,?)',[$eventId,'gallery',$image,clean($in['title']??'Event gallery',190),$status]);}
    $id=$recordId?: (int)$db->lastInsertId();if(in_array($kind,['facility','restriction'],true)){[$link,$column]=$kind==='facility'?['natcon_event_facility_links','facility_id']:['natcon_event_restriction_links','restriction_id'];$ignore=$db->getAttribute(\PDO::ATTR_DRIVER_NAME)==='sqlite'?'INSERT OR IGNORE':'INSERT IGNORE';query($db,"$ignore INTO $link(event_id,$column) VALUES(?,?)",[(int)$eventId,$id]);}
    audit($db,(string)$staffId,'event_'.$kind.($recordId?'_updated':'_created'),(string)$id,['event_id'=>(int)$eventId,'status'=>$status]);return ['saved'=>true,'id'=>(string)$id];
}
function organizerCategories(\PDO $db): array {
    return array_map(static fn($r)=>['id'=>(string)$r['id'],'title'=>$r['title'],'img'=>$r['image_url']??'','cat_img'=>$r['image_url']??'','cover'=>'','status'=>'1','cover_img'=>'','total_event'=>(int)$r['total_event']],query($db,"SELECT c.id,c.title,c.image_url,COUNT(e.id) total_event FROM natcon_categories c LEFT JOIN natcon_events e ON e.category_id=c.id WHERE c.status='active' GROUP BY c.id,c.title,c.image_url ORDER BY c.sort_order,c.title")->fetchAll());
}
function organizerCoupons(\PDO $db,string $eventId=''): array {
    if($eventId!==''&&!preg_match('/^[1-9]\d{0,9}$/',$eventId))throw new \InvalidArgumentException('Choose a valid NATCON event.');$args=[];$where='';if($eventId!==''){$where=' WHERE c.event_id=?';$args[]=(int)$eventId;}
    $rows=query($db,'SELECT c.*,e.title event_title FROM natcon_coupons c LEFT JOIN natcon_events e ON e.id=c.event_id'.$where.' ORDER BY c.created_at DESC,c.id DESC',$args)->fetchAll();
    return array_map(static fn($r)=>['id'=>(string)$r['id'],'sponsore_id'=>(string)($r['event_id']??''),'event_id'=>(string)($r['event_id']??''),'event_title'=>$r['event_title']??'All events','coupon_img'=>'','title'=>$r['title'],'coupon_code'=>$r['code'],'subtitle'=>$r['subtitle']?:$r['title'],'expire_date'=>substr((string)($r['expires_at']?:'2099-12-31'),0,10),'min_amt'=>number_format((int)$r['minimum_kobo']/100,2,'.',''),'coupon_val'=>$r['discount_type']==='percent'?(string)$r['discount_value']:number_format((int)$r['discount_value']/100,2,'.',''),'discount_type'=>$r['discount_type'],'description'=>$r['description']??'','usage_limit'=>(int)$r['usage_limit'],'usage_count'=>(int)$r['usage_count'],'status'=>$r['status']==='active'?'1':'0'],$rows);
}
function saveOrganizerCoupon(\PDO $db,array $in,?int $couponId=null): array {
    $code=strtoupper(clean($in['coupon_code']??'',64));$title=clean($in['title']??'',150);$subtitle=clean($in['subtitle']??$title,150);$description=clean($in['description']??'',2000);$eventInput=clean($in['event_id']??'',32);$eventId=$eventInput===''?(int)primaryConference($db)['id']:(int)$eventInput;$type=clean($in['discount_type']??'fixed',10);$status=match((string)($in['status']??'1')){'1','active'=>'active','0','inactive'=>'inactive',default=>throw new \InvalidArgumentException('Choose an active or inactive coupon.')};$expiry=clean($in['expire_date']??'',10);$minimum=trim((string)($in['min_amt']??''));$value=trim((string)($in['coupon_val']??''));$limit=filter_var($in['usage_limit']??0,FILTER_VALIDATE_INT,['options'=>['min_range'=>0,'max_range'=>10000000]]);
    if($code===''||!preg_match('/^[A-Z0-9_-]{3,64}$/',$code)||$title===''||!query($db,'SELECT id FROM natcon_events WHERE id=?',[$eventId])->fetchColumn())throw new \InvalidArgumentException('Choose an event and enter a valid coupon code and title.');if(!in_array($type,['fixed','percent'],true)||$limit===false)throw new \InvalidArgumentException('Choose a valid discount type and usage limit.');
    if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$expiry)||!checkdate((int)substr($expiry,5,2),(int)substr($expiry,8,2),(int)substr($expiry,0,4)))throw new \InvalidArgumentException('Enter a valid coupon expiry date.');
    if(!preg_match('/^\d{1,8}(?:\.\d{1,2})?$/',$minimum)||!preg_match($type==='percent'?'/^\d{1,3}$/':'/^\d{1,8}(?:\.\d{1,2})?$/',$value))throw new \InvalidArgumentException('Enter a valid minimum spend and discount value.');$minimumKobo=(int)round((float)$minimum*100);$discount=$type==='percent'?(int)$value:(int)round((float)$value*100);if($minimumKobo<0||($type==='percent'&&($discount<1||$discount>100))||($type==='fixed'&&$discount<1))throw new \InvalidArgumentException('Coupon discount is outside the allowed range.');
    $duplicate=query($db,'SELECT id FROM natcon_coupons WHERE code=? AND id<>?',[$code,$couponId??0])->fetchColumn();if($duplicate)throw new \InvalidArgumentException('That coupon code is already in use.');
    if($couponId){$existing=query($db,'SELECT usage_count FROM natcon_coupons WHERE id=?',[$couponId])->fetch();if(!$existing)throw new \InvalidArgumentException('Coupon not found.');if($limit>0&&$limit<(int)$existing['usage_count'])throw new \InvalidArgumentException('Usage limit cannot be lower than completed redemptions.');query($db,'UPDATE natcon_coupons SET event_id=?,code=?,title=?,subtitle=?,description=?,discount_type=?,discount_value=?,minimum_kobo=?,usage_limit=?,expires_at=?,status=? WHERE id=?',[$eventId,$code,$title,$subtitle,$description,$type,$discount,$minimumKobo,(int)$limit,$expiry.' 23:59:59',$status,$couponId]);}else query($db,'INSERT INTO natcon_coupons(event_id,code,title,subtitle,description,discount_type,discount_value,minimum_kobo,usage_limit,expires_at,status,created_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)',[$eventId,$code,$title,$subtitle,$description,$type,$discount,$minimumKobo,(int)$limit,$expiry.' 23:59:59',$status,now()]);
    $id=$couponId?: (int)$db->lastInsertId();audit($db,(string)($in['_staff_id']??''),$couponId?'coupon_updated':'coupon_created',(string)$id,['event_id'=>$eventId,'code'=>$code,'discount_type'=>$type,'status'=>$status]);return ['saved'=>true,'coupon_id'=>(string)$id];
}
function syncEventContentSelection(\PDO $db,int $eventId,string $kind,mixed $raw): void {
    [$table,$link,$column]=match($kind){'facility'=>['natcon_event_facilities','natcon_event_facility_links','facility_id'],'restriction'=>['natcon_event_restrictions','natcon_event_restriction_links','restriction_id'],default=>throw new \InvalidArgumentException('Unknown event content kind.')};
    $ids=[];foreach(explode(',',clean($raw,2000)) as $value){$value=trim($value);if($value==='')continue;if(!preg_match('/^[1-9]\d{0,9}$/',$value))throw new \InvalidArgumentException('Choose valid event facilities and restrictions.');$id=(int)$value;if(!query($db,"SELECT id FROM $table WHERE id=? AND status='active'",[$id])->fetchColumn())throw new \InvalidArgumentException('A selected event facility or restriction is unavailable.');$ids[$id]=$id;}
    query($db,"DELETE FROM $link WHERE event_id=?",[$eventId]);foreach($ids as $id)query($db,"INSERT INTO $link(event_id,$column) VALUES(?,?)",[$eventId,$id]);
}
function organizerEventInput(array $in): array {
    $title=clean($in['title']??'',190);$venue=clean($in['pname']??$in['address']??'',255);$date=clean($in['sdate']??'',10);$start=clean($in['stime']??'',20);$end=clean($in['etime']??'',20);
    if($title===''||$venue==='')throw new \InvalidArgumentException('Enter an event title and venue.');
    if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$date)||!strtotime($date)||!preg_match('/^(\d{1,2}):(\d{2})(?::(\d{2}))?$/',$start,$sm)||!preg_match('/^(\d{1,2}):(\d{2})(?::(\d{2}))?$/',$end,$em))throw new \InvalidArgumentException('Enter a valid event date and start/end times.');
    foreach([$sm,$em] as $timeParts)if((int)$timeParts[1]>23||(int)$timeParts[2]>59||(int)($timeParts[3]??0)>59)throw new \InvalidArgumentException('Enter a valid event date and start/end times.');
    $start=sprintf('%02d:%02d:%02d',(int)$sm[1],(int)$sm[2],(int)($sm[3]??0));$end=sprintf('%02d:%02d:%02d',(int)$em[1],(int)$em[2],(int)($em[3]??0));
    if(!checkdate((int)substr($date,5,2),(int)substr($date,8,2),(int)substr($date,0,4)))throw new \InvalidArgumentException('Enter a valid event date.');
    $category=clean($in['cat_id']??'',16);if(!preg_match('/^[1-9]\d{0,8}$/',$category))throw new \InvalidArgumentException('Choose an active NATCON category.');
    $legacyStatus=(string)($in['status']??'1');$status=match(strtolower($legacyStatus)){'1','publish','published'=>'published','0','unpublish','draft'=>'draft','archived'=>'archived',default=>throw new \InvalidArgumentException('Choose Publish or Unpublish.')};
    $lat=clean($in['latitude']??'',40);$lon=clean($in['longtitude']??$in['longitude']??'',40);
    if(($lat!==''&&(!is_numeric($lat)||abs((float)$lat)>90))||($lon!==''&&(!is_numeric($lon)||abs((float)$lon)>180)))throw new \InvalidArgumentException('Enter valid map coordinates.');
    return ['title'=>$title,'venue'=>$venue,'description'=>clean($in['cdesc']??'',12000),'date'=>$date,'start'=>$start,'end'=>$end,'category'=>(int)$category,'status'=>$status,'latitude'=>$lat,'longitude'=>$lon];
}
function saveOrganizerEvent(\PDO $db,array $in,?int $eventId=null): array {
    $v=organizerEventInput($in);if(!query($db,"SELECT id FROM natcon_categories WHERE id=? AND status='active'",[$v['category']])->fetchColumn())throw new \InvalidArgumentException('Choose an active NATCON category.');
    $db->beginTransaction();try{$stamp=now();if($eventId){$existing=query($db,'SELECT id FROM natcon_events WHERE id=?',[$eventId])->fetchColumn();if(!$existing)throw new \InvalidArgumentException('NATCON event not found.');query($db,'UPDATE natcon_events SET category_id=?,title=?,description=?,venue=?,latitude=?,longitude=?,starts_at=?,ends_at=?,status=?,updated_at=? WHERE id=?',[$v['category'],$v['title'],$v['description'],$v['venue'],$v['latitude'],$v['longitude'],$v['date'].' '.$v['start'],$v['date'].' '.$v['end'],$v['status'],$stamp,$eventId]);}else{$slug='natcon-event-'.bin2hex(random_bytes(8));query($db,'INSERT INTO natcon_events(owner_staff_id,category_id,title,slug,description,venue,latitude,longitude,starts_at,ends_at,currency,status,created_at,updated_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)',[(int)($in['_staff_id']??0),$v['category'],$v['title'],$slug,$v['description'],$v['venue'],$v['latitude'],$v['longitude'],$v['date'].' '.$v['start'],$v['date'].' '.$v['end'],'NGN',$v['status'],$stamp,$stamp]);$eventId=(int)$db->lastInsertId();}
        $staffId=(int)($in['_staff_id']??0);$previous=query($db,'SELECT * FROM natcon_event_profiles WHERE event_id=?',[$eventId])->fetch()?:[];$image=organizerImageBase64($in['img']??'', $previous['image_base64']??null);$cover=organizerImageBase64($in['cover']??'', $previous['cover_base64']??null);$profileValues=[clean($in['disclaimer']??$previous['disclaimer']??'',6000),clean($in['tags']??$previous['tags']??'',2000),clean($in['vurls']??$previous['video_urls']??'',4000),$image,$cover,$stamp];if($previous)query($db,'UPDATE natcon_event_profiles SET disclaimer=?,tags=?,video_urls=?,image_base64=?,cover_base64=?,updated_at=? WHERE event_id=?',[...$profileValues,$eventId]);else query($db,'INSERT INTO natcon_event_profiles(disclaimer,tags,video_urls,image_base64,cover_base64,updated_at,event_id) VALUES(?,?,?,?,?,?,?)',[...$profileValues,$eventId]);
        if(array_key_exists('facility_id',$in))syncEventContentSelection($db,(int)$eventId,'facility',$in['facility_id']);if(array_key_exists('restict_id',$in))syncEventContentSelection($db,(int)$eventId,'restriction',$in['restict_id']);
        audit($db,(string)$staffId,isset($existing)?'event_updated':'event_created',(string)$eventId,['title'=>$v['title'],'status'=>$v['status']]);$db->commit();return organizerEventDetails($db,(string)$eventId);
    }catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
function setOrganizerEventStatus(\PDO $db,string $eventId,string $action,int $staffId): array {
    $id=filter_var($eventId,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);if(!$id||!in_array($action,['complete','cancel'],true))throw new \InvalidArgumentException('Choose a valid event action.');
    $db->beginTransaction();try{$event=query($db,'SELECT id,title,status FROM natcon_events WHERE id=?',[$id])->fetch();if(!$event)throw new \InvalidArgumentException('NATCON event not found.');if($event['status']==='cancelled')throw new \InvalidArgumentException('A cancelled event cannot be changed.');$status=$action==='complete'?'completed':'cancelled';query($db,'UPDATE natcon_events SET status=?,updated_at=? WHERE id=?',[$status,now(),$id]);audit($db,(string)$staffId,'event_'.$action,(string)$id,['previous_status'=>$event['status'],'status'=>$status,'paid_orders_preserved'=>true]);$db->commit();return organizerEventDetails($db,(string)$id);}catch(\Throwable $e){if($db->inTransaction())$db->rollBack();throw $e;}
}
function organizerImageBase64(mixed $input,?string $previous): ?string {
    $input=(string)$input;if($input===''||$input==='0')return $previous;if(strlen($input)>3500000)throw new \InvalidArgumentException('Event images must be 2.5 MB or smaller.');$bytes=base64_decode($input,true);if($bytes===false||strlen($bytes)>2621440)throw new \InvalidArgumentException('Choose a valid image no larger than 2.5 MB.');
    $mime=match(true){str_starts_with($bytes,"\xFF\xD8\xFF")=>'image/jpeg',str_starts_with($bytes,"\x89PNG\r\n\x1A\n")=>'image/png',substr($bytes,0,4)==='GIF8'=>'image/gif',substr($bytes,0,4)==='RIFF'&&substr($bytes,8,4)==='WEBP'=>'image/webp',default=>null};if(!$mime)throw new \InvalidArgumentException('Use a JPEG, PNG, GIF, or WebP event image.');return $input;
}
function organizerTicketTypes(\PDO $db,string $eventId=''): array {
    if($eventId!==''&&!preg_match('/^[1-9]\d{0,9}$/',$eventId))throw new \InvalidArgumentException('Choose a valid NATCON event.');
    if($eventId!==''&&!query($db,'SELECT id FROM natcon_events WHERE id=?',[(int)$eventId])->fetchColumn())throw new \InvalidArgumentException('NATCON event not found.');
    $rows=$eventId!==''?query($db,'SELECT t.*,e.title AS event_title FROM natcon_ticket_types t JOIN natcon_events e ON e.id=t.event_id WHERE t.event_id=? ORDER BY t.id',[(int)$eventId])->fetchAll():query($db,'SELECT t.*,e.title AS event_title FROM natcon_ticket_types t JOIN natcon_events e ON e.id=t.event_id ORDER BY e.starts_at DESC,t.id')->fetchAll();
    return array_map(static fn($r)=>['id'=>(string)$r['id'],'event_title'=>$r['event_title'],'event_id'=>(string)$r['event_id'],'image'=>'','type'=>$r['label'],'price'=>number_format((int)$r['price_kobo']/100,2,'.',''),'tlimit'=>(string)$r['capacity'],'description'=>$r['description']??'','status'=>$r['status']==='active'?'1':'0'],$rows);
}
function saveOrganizerTicketType(\PDO $db,array $in,?int $typeId=null): array {
    $eventId=filter_var($in['event_id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]);$label=clean($in['etype']??'',120);$description=clean($in['description']??'',4000);$price=trim((string)($in['price']??''));$capacity=filter_var($in['tlimit']??0,FILTER_VALIDATE_INT,['options'=>['min_range'=>0,'max_range'=>10000000]]);$status=match((string)($in['status']??'1')){'1'=>'active','0'=>'inactive',default=>throw new \InvalidArgumentException('Choose an active or inactive ticket type.')};
    if(!$eventId||!query($db,'SELECT id FROM natcon_events WHERE id=?',[$eventId])->fetchColumn()||$label==='')throw new \InvalidArgumentException('Choose an event and enter a ticket type name.');if($capacity===false||!preg_match('/^\d{1,8}(?:\.\d{1,2})?$/',$price))throw new \InvalidArgumentException('Enter a valid ticket price and capacity.');$kobo=(int)round((float)$price*100);if($kobo<0||$kobo>100000000000)throw new \InvalidArgumentException('Ticket price is outside the allowed range.');
    if($typeId){$old=query($db,'SELECT event_id FROM natcon_ticket_types WHERE id=?',[$typeId])->fetch();if(!$old)throw new \InvalidArgumentException('Ticket type not found.');if((int)$old['event_id']!==(int)$eventId)throw new \InvalidArgumentException('Ticket type does not belong to this event.');$sold=(int)query($db,"SELECT COUNT(*) FROM natcon_orders WHERE ticket_type_id=? AND status IN ('paid','pending','awaiting_review')",[$typeId])->fetchColumn();if($capacity>0&&$capacity<$sold)throw new \InvalidArgumentException('Capacity cannot be lower than tickets already sold or reserved.');query($db,'UPDATE natcon_ticket_types SET label=?,description=?,price_kobo=?,capacity=?,status=? WHERE id=?',[$label,$description,$kobo,(int)$capacity,$status,$typeId]);}else query($db,'INSERT INTO natcon_ticket_types(event_id,label,description,price_kobo,capacity,status,created_at) VALUES(?,?,?,?,?,?,?)',[(int)$eventId,$label,$description,$kobo,(int)$capacity,$status,now()]);
    audit($db,(string)($in['_staff_id']??''),$typeId?'ticket_type_updated':'ticket_type_created',(string)($typeId?:$db->lastInsertId()),['event_id'=>(int)$eventId,'label'=>$label,'price_kobo'=>$kobo,'capacity'=>(int)$capacity,'status'=>$status]);return ['saved'=>true];
}
function mobileEventDetails(\PDO $db,array $c,?int $accountId=null,string $eventId=''): array {
    $event=$eventId===''?primaryConference($db):publishedEvent($db,$eventId);$type=mobileTicketTypes($db,$c,(string)$event['id'])[0]??null;$paid=(int)query($db,"SELECT COUNT(*) FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE o.status='paid' AND o.event_id=?",[$event['id']])->fetchColumn();$cap=$type?(int)$type['TotalTicket']:0;$favorite=0;$profile=query($db,'SELECT disclaimer,tags,video_urls,image_base64,cover_base64 FROM natcon_event_profiles WHERE event_id=?',[$event['id']])->fetch()?:[];$base=rtrim(config()['base_url'],'/').'/api/mobile-media.php?event_id='.(int)$event['id'];$image=!empty($profile['image_base64'])?$base.'&kind=image':'';$cover=!empty($profile['cover_base64'])?$base.'&kind=cover':'';
    if($accountId)$favorite=(int)query($db,'SELECT COUNT(*) FROM natcon_favorites WHERE account_id=? AND event_id=?',[$accountId,$event['id']])->fetchColumn();
    $start=substr((string)$event['starts_at'],0,10);$end=substr((string)$event['ends_at'],0,10);$tags=array_values(array_filter(array_map('trim',explode(',',(string)($profile['tags']??'')))));$videos=array_values(array_filter(array_map('trim',explode(',',(string)($profile['video_urls']??'')))));
    $content=eventContent($db,(int)$event['id']);
    return ['event_id'=>(string)$event['id'],'event_title'=>$event['title'],'event_img'=>$image,'event_cover_img'=>$cover?[$cover]:[],'event_sdate'=>$start,'event_time_day'=>$start===$end?$start:$start.' – '.$end,'event_address_title'=>$event['venue'],'event_address'=>$event['venue'],'event_latitude'=>$event['latitude']??'0','event_longtitude'=>$event['longitude']??'0','event_disclaimer'=>$profile['disclaimer']??'Each delegate must present their own paid event ticket.','event_about'=>$event['description'],'event_tags'=>$tags,'event_video_urls'=>$videos,'event_gallery'=>$content['gallery'],'event_artists'=>$content['artists'],'event_facilities'=>$content['facilities'],'event_restrictions'=>$content['restrictions'],'ticket_price'=>$type['ticket_price']??'0.00','IS_BOOKMARK'=>$favorite?1:0,'sponsore_id'=>'NATCON','sponsore_img'=>'','sponsore_name'=>'The Achiever Ambassadors Islamic Foundation','sponsore_mobile'=>'','total_ticket'=>$type?($cap?:99999):0,'is_joined'=>$accountId?(int)query($db,"SELECT COUNT(*) FROM natcon_orders WHERE account_id=? AND status='paid' AND event_id=?",[$accountId,$event['id']])->fetchColumn():0,'total_book_ticket'=>$paid,'member_list'=>[]];
}
function mobileTicketTypes(\PDO $db,array $c,string $eventId=''): array {
    $event=$eventId===''?primaryConference($db):publishedEvent($db,$eventId);$at=now();$rows=query($db,"SELECT * FROM natcon_ticket_types WHERE event_id=? AND status='active' AND (sales_start IS NULL OR sales_start<=?) AND (sales_end IS NULL OR sales_end>=?) ORDER BY price_kobo,id",[$event['id'],$at,$at])->fetchAll();
    return array_map(static function($type)use($db){$capacity=(int)$type['capacity'];$sold=(int)query($db,"SELECT COUNT(*) FROM natcon_orders WHERE ticket_type_id=? AND status IN ('paid','pending','awaiting_review')",[$type['id']])->fetchColumn();$price=number_format((int)$type['price_kobo']/100,2,'.','');return ['typeid'=>(string)$type['id'],'ticket_type'=>$type['label'],'ticket_price'=>$price,'TotalTicket'=>$capacity?:99999,'description'=>$type['description']??'','remainTicket'=>$capacity>0?max(0,$capacity-$sold):99999,'tPrice'=>$price];},$rows);
}
function mobileTicketType(\PDO $db,array $c,string $eventId=''): array {
    return mobileTicketTypes($db,$c,$eventId)[0]??throw new \InvalidArgumentException('Tickets for this event are not on sale.');
}
function toggleFavorite(\PDO $db,int $accountId,string $eventId): bool {
    $event=publishedEvent($db,$eventId);
    $exists=query($db,'SELECT id FROM natcon_favorites WHERE account_id=? AND event_id=?',[$accountId,$event['id']])->fetchColumn();
    if($exists){query($db,'DELETE FROM natcon_favorites WHERE account_id=? AND event_id=?',[$accountId,$event['id']]);return false;}
    query($db,'INSERT INTO natcon_favorites(account_id,event_id,created_at) VALUES(?,?,?)',[$accountId,$event['id'],now()]);return true;
}
function mobileReviews(\PDO $db,int $eventId): array {
    return array_map(static fn($r)=>['user_img'=>$r['profile_image']??'','customername'=>$r['name'],'rate_number'=>(string)$r['rating'],'rate_text'=>$r['comment']??''],query($db,"SELECT r.rating,r.comment,a.name,a.profile_image FROM natcon_reviews r JOIN natcon_accounts a ON a.id=r.account_id WHERE r.event_id=? AND r.status='published' ORDER BY r.created_at DESC,r.id DESC LIMIT 100",[$eventId])->fetchAll());
}
function submitReview(\PDO $db,int $accountId,string $ticketToken,int $rating,string $comment): array {
    if($rating<1||$rating>5)throw new \InvalidArgumentException('Choose a rating from 1 to 5 stars.');
    $comment=clean($comment,2000);
    $ticket=query($db,"SELECT o.reference,o.event_id FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE d.ticket_token=? AND o.account_id=? AND o.status='paid'",[$ticketToken,$accountId])->fetch();
    if(!$ticket)throw new \InvalidArgumentException('Only an attendee with a paid NATCON ticket can review this event.');
    $eventId=(int)$ticket['event_id'];$existing=query($db,'SELECT id FROM natcon_reviews WHERE account_id=? AND event_id=?',[$accountId,$eventId])->fetchColumn();
    if($existing){query($db,'UPDATE natcon_reviews SET order_reference=?,rating=?,comment=?,status=?,created_at=? WHERE id=?',[$ticket['reference'],$rating,$comment,'published',now(),$existing]);}
    else query($db,'INSERT INTO natcon_reviews(account_id,event_id,order_reference,rating,comment,status,created_at) VALUES(?,?,?,?,?,?,?)',[$accountId,$eventId,$ticket['reference'],$rating,$comment,'published',now()]);
    audit($db,(string)$accountId,'event_review',$ticket['reference'],['event_id'=>$eventId,'rating'=>$rating]);
    return ['submitted'=>true,'reviews'=>mobileReviews($db,$eventId)];
}
function favoriteEvents(\PDO $db,int $accountId): array {
    $rows=query($db,"SELECT e.id,e.title,e.starts_at,e.venue FROM natcon_favorites f JOIN natcon_events e ON e.id=f.event_id WHERE f.account_id=? AND e.status='published' ORDER BY f.created_at DESC",[$accountId])->fetchAll();
    return array_map(static fn($row)=>['event_id'=>(string)$row['id'],'event_title'=>$row['title'],'event_img'=>'','event_sdate'=>substr((string)$row['starts_at'],0,10),'event_place_name'=>$row['venue']],$rows);
}
function mobileFaqs(\PDO $db): array {return array_map(static fn($r)=>['id'=>(string)$r['id'],'store_id'=>null,'question'=>$r['question'],'answer'=>$r['answer'],'status'=>$r['status']],query($db,"SELECT id,question,answer,status FROM natcon_faqs WHERE status IN ('active','published') ORDER BY sort_order,id")->fetchAll());}
function mobilePages(\PDO $db): array {return array_map(static fn($r)=>['title'=>$r['title'],'description'=>$r['content']],query($db,"SELECT title,content FROM natcon_pages WHERE status='published' ORDER BY title")->fetchAll());}
function mobileNotifications(\PDO $db,int $accountId): array {return array_map(static fn($r)=>['id'=>(string)$r['id'],'uid'=>(string)$r['account_id'],'datetime'=>$r['created_at'],'title'=>$r['title'],'description'=>$r['body'],'is_read'=>$r['read_at']!==null],query($db,'SELECT id,account_id,title,body,created_at,read_at FROM natcon_notifications WHERE account_id=? ORDER BY created_at DESC,id DESC',[$accountId])->fetchAll());}
function markMobileNotificationRead(\PDO $db,int $accountId,string $notificationId): bool {
    if(!preg_match('/^[1-9]\d{0,9}$/',$notificationId))throw new \InvalidArgumentException('Choose a valid notification.');
    return query($db,'UPDATE natcon_notifications SET read_at=? WHERE id=? AND account_id=? AND read_at IS NULL',[now(),(int)$notificationId,$accountId])->rowCount()>0;
}
function walletHistory(\PDO $db,int $accountId): array {
    return array_map(static function($row){$credit=$row['direction']==='credit';return ['message'=>$row['description'],'status'=>$credit?'Credit':'Debit','amt'=>number_format((int)$row['amount_kobo']/100,2,'.',''),'tdate'=>$row['created_at']];},query($db,'SELECT direction,amount_kobo,description,created_at FROM natcon_wallet_ledger WHERE account_id=? AND status IN (\'paid\',\'completed\') ORDER BY id DESC',[$accountId])->fetchAll());
}
function initializeWalletTopup(\PDO $db,array $c,int $accountId,int $amountKobo): array {
    if($amountKobo<10000||$amountKobo>100000000)throw new \InvalidArgumentException('Wallet top-up must be between ₦100 and ₦1,000,000.');
    $account=query($db,'SELECT email FROM natcon_accounts WHERE id=? AND status=?',[$accountId,'active'])->fetch();if(!$account)throw new \InvalidArgumentException('Attendee account is unavailable.');
    $reference='WAL-'.strtoupper(bin2hex(random_bytes(10)));
    query($db,'INSERT INTO natcon_wallet_ledger(account_id,direction,amount_kobo,reference,status,description,created_at) VALUES(?,?,?,?,?,?,?)',[$accountId,'credit',$amountKobo,$reference,'pending','Wallet top-up',now()]);
    try{return gateway($c,'transaction/initialize',['email'=>$account['email'],'amount'=>$amountKobo,'currency'=>'NGN','reference'=>$reference,'callback_url'=>$c['base_url'].'/conference/#wallet_reference='.rawurlencode($reference)]);}
    catch(\Throwable $e){query($db,"UPDATE natcon_wallet_ledger SET status='failed' WHERE reference=? AND status='pending'",[$reference]);throw $e;}
}
function confirmWalletTopup(\PDO $db,int $accountId,string $reference,array $payment): array {
    $db->beginTransaction();try{
        $entry=query($db,'SELECT * FROM natcon_wallet_ledger WHERE reference=? AND account_id=? AND direction=?',[$reference,$accountId,'credit'])->fetch();
        if(!$entry||($payment['status']??'')!=='success'||(string)($payment['reference']??'')!==$reference||(int)($payment['amount']??0)!==(int)$entry['amount_kobo']||($payment['currency']??'')!=='NGN')throw new \InvalidArgumentException('Verified wallet payment does not match this top-up.');
        if($entry['status']==='paid'){$balance=(int)query($db,'SELECT wallet_balance_kobo FROM natcon_accounts WHERE id=?',[$accountId])->fetchColumn();$db->commit();return ['wallet_balance_kobo'=>$balance,'credited'=>false];}
        if($entry['status']!=='pending')throw new \InvalidArgumentException('This wallet top-up is no longer payable.');
        $changed=query($db,"UPDATE natcon_wallet_ledger SET status='paid' WHERE id=? AND status='pending'",[$entry['id']])->rowCount();
        if(!$changed)throw new \InvalidArgumentException('This wallet top-up was already processed.');
        query($db,'UPDATE natcon_accounts SET wallet_balance_kobo=wallet_balance_kobo+?,updated_at=? WHERE id=?',[$entry['amount_kobo'],now(),$accountId]);
        audit($db,(string)$accountId,'wallet_topup_confirmed',$reference,['amount_kobo'=>(int)$entry['amount_kobo']]);$balance=(int)query($db,'SELECT wallet_balance_kobo FROM natcon_accounts WHERE id=?',[$accountId])->fetchColumn();$db->commit();return ['wallet_balance_kobo'=>$balance,'credited'=>true];
    }catch(\Throwable $e){$db->rollBack();throw $e;}
}
function availableCoupons(\PDO $db,int $subtotalKobo=0,string $eventId=''): array {
    $event=$eventId===''?primaryConference($db):publishedEvent($db,$eventId);$rows=query($db,"SELECT * FROM natcon_coupons WHERE status='active' AND (event_id IS NULL OR event_id=?) AND (expires_at IS NULL OR DATE(expires_at)>=?) AND (usage_limit=0 OR usage_count<usage_limit) ORDER BY id DESC",[$event['id'],gmdate('Y-m-d')])->fetchAll();
    return array_map(static function($r)use($subtotalKobo){$expiry=$r['expires_at']?:'2026-12-31 23:59:59';$discount=$r['discount_type']==='percent'?(int)floor($subtotalKobo*(int)$r['discount_value']/100):(int)$r['discount_value'];$value=number_format(min($subtotalKobo,max(0,$discount))/100,2,'.','');return ['id'=>(string)$r['id'],'c_img'=>'','expire_date'=>substr((string)$expiry,0,10),'description'=>$r['title'],'coupon_val'=>$value,'coupon_code'=>$r['code'],'coupon_title'=>$r['title'],'coupon_subtitle'=>$r['title'],'min_amt'=>number_format((int)$r['minimum_kobo']/100,2,'.','')];},$rows);
}
function applicableCoupon(\PDO $db,string $code,int $subtotal,string $eventId=''): array {
    $event=$eventId===''?primaryConference($db):publishedEvent($db,$eventId);$coupon=query($db,"SELECT * FROM natcon_coupons WHERE code=? AND status='active' AND (event_id IS NULL OR event_id=?) AND (expires_at IS NULL OR DATE(expires_at)>=?) AND (usage_limit=0 OR usage_count<usage_limit)",[$code,$event['id'],gmdate('Y-m-d')])->fetch();
    if(!$coupon)throw new \InvalidArgumentException('This coupon is invalid, expired, or fully redeemed.');
    if($subtotal<(int)$coupon['minimum_kobo'])throw new \InvalidArgumentException('The order does not meet this coupon’s minimum spend.');
    if($coupon['discount_type']==='percent'){
        if((int)$coupon['discount_value']<1||(int)$coupon['discount_value']>100)throw new \RuntimeException('Coupon percentage is misconfigured.');
        $discount=(int)floor($subtotal*(int)$coupon['discount_value']/100);
    }elseif($coupon['discount_type']==='fixed')$discount=(int)$coupon['discount_value'];
    else throw new \RuntimeException('Coupon type is misconfigured.');
    return [$coupon,min($subtotal,max(0,$discount))];
}
function releaseCouponRedemption(\PDO $db,int $couponId,string $reference): bool {
    $deleted=query($db,'DELETE FROM natcon_coupon_redemptions WHERE coupon_id=? AND order_reference=?',[$couponId,$reference]);
    if(!$deleted->rowCount())return false;
    query($db,'UPDATE natcon_coupons SET usage_count=CASE WHEN usage_count>0 THEN usage_count-1 ELSE 0 END WHERE id=?',[$couponId]);return true;
}
function clean($v,int $max=190): string { if (!is_scalar($v) && $v!==null) throw new \InvalidArgumentException('Invalid field value.'); return mb_substr(trim((string)$v),0,$max); }
function audit(\PDO $db,string $actor,string $action,string $reference='',array $detail=[]): void { query($db,'INSERT INTO natcon_audit(actor,action,reference,detail,created_at) VALUES(?,?,?,?,?)',[$actor,$action,$reference,json_encode($detail),now()]); }
function event(array $c,?\PDO $db=null,?string $eventId=null): array {
    $base=array_intersect_key($c,array_flip(['name','theme','start_date','end_date','venue','currency','earlybird_end','bank']));
    if(!$db){$date=(new \DateTimeImmutable('now',new \DateTimeZone('Africa/Lagos')))->format('Y-m-d');return $base+['price_kobo'=>$date<=$c['earlybird_end']?700000:800000,'payment_enabled'=>$c['secret']!==''];}
    $selected=$eventId===null?primaryConference($db):publishedEvent($db,$eventId);$types=mobileTicketTypes($db,$c,(string)$selected['id']);$type=$types[0]??null;
    return array_replace($base,['event_id'=>(int)$selected['id'],'name'=>$selected['title'],'theme'=>$selected['description'],'start_date'=>substr((string)$selected['starts_at'],0,10),'end_date'=>substr((string)$selected['ends_at'],0,10),'venue'=>$selected['venue'],'currency'=>$selected['currency'],'price_kobo'=>(int)round((float)($type['ticket_price']??0)*100),'ticket_types'=>$types,'payment_enabled'=>$c['secret']!=='']);
}
function order(\PDO $db,string $reference,string $token): array {
    $o=query($db,'SELECT * FROM natcon_orders WHERE reference=? AND access_token=?',[$reference,$token])->fetch();
    if (!$o) throw new \InvalidArgumentException('Registration not found.');
    unset($o['id']); $o['delegates']=query($db,'SELECT id,name,ticket_token FROM natcon_delegates WHERE reference=?',[$reference])->fetchAll();
    if($o['status']!=='paid') foreach($o['delegates'] as &$d) unset($d['ticket_token']);
    return $o;
}
function register(\PDO $db,array $c,array $in,?int $accountId=null): array {
    if(($in['consent']??false)!==true)throw new \InvalidArgumentException('Accept the privacy notice before registering.');
    $eventId=clean($in['event_id']??'',32);if($eventId==='')$eventId=(string)primaryConference($db)['id'];$selectedEvent=publishedEvent($db,$eventId);$registrationCloses=(string)$c['registration_closes'];if((int)$selectedEvent['id']!==(int)primaryConference($db)['id'])$registrationCloses=(string)($selectedEvent['ends_at']??$registrationCloses);
    if((new \DateTimeImmutable('now',new \DateTimeZone('Africa/Lagos')))->format('Y-m-d H:i:s')>$registrationCloses)throw new \InvalidArgumentException('Registration has closed. Contact the organizers.');
    $name=clean($in['payer_name']??'',150);$email=strtolower(clean($in['payer_email']??''));$phone=clean($in['payer_phone']??'',40);$delegates=$in['delegates']??[];
    if(!$name || !filter_var($email,FILTER_VALIDATE_EMAIL) || !$phone || !is_array($delegates) || count($delegates)<1 || count($delegates)>50) throw new \InvalidArgumentException('Provide payer name, valid email, phone, and between 1 and 50 delegates.');
    foreach($delegates as $d) {
        if(!is_array($d)||!clean($d['name']??'',150) || !filter_var(clean($d['email']??''),FILTER_VALIDATE_EMAIL)) throw new \InvalidArgumentException('Every delegate needs a name and valid Gmail or email address.');
        foreach(['course','institution','level','whatsapp','state_origin'] as $required) if(!clean($d[$required]??'')) throw new \InvalidArgumentException('Complete each delegate’s course, institution, level, WhatsApp number, and state of origin.');
        if(!preg_match('/^\d{1,2}$/',clean($d['times_attended']??'')) || (int)$d['times_attended']>99) throw new \InvalidArgumentException('Enter NATCON attendance from 0 to 99.');
    }
    $eventId=(int)$selectedEvent['id'];$requestedTypeId=clean($in['ticket_type_id']??'',32);$type=$requestedTypeId!==''?query($db,"SELECT * FROM natcon_ticket_types WHERE id=? AND event_id=? AND status='active' AND (sales_start IS NULL OR sales_start<=?) AND (sales_end IS NULL OR sales_end>=?)",[$requestedTypeId,$eventId,now(),now()])->fetch():activeTicketType($db,$eventId);if(!$type)throw new \InvalidArgumentException('The selected ticket type is not available for this event.');$ref='TAA-'.strtoupper(bin2hex(random_bytes(6)));$token=bin2hex(random_bytes(32));$subtotal=(int)$type['price_kobo']*count($delegates);$couponCode=clean($in['coupon_code']??'',64);$coupon=null;$discount=0;$amount=$subtotal;$walletSpend=0;$useWallet=($in['use_wallet']??false)===true;
    if($useWallet&&!$accountId)throw new \InvalidArgumentException('Sign in to use your NATCON wallet.');
    $db->beginTransaction();try {
        // Serialize capacity reservation across workers, including SQLite test deployments.
        query($db,"UPDATE natcon_locks SET value=value+1 WHERE name='registration'");
        $reserved=(int)query($db,"SELECT COUNT(*) FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE o.status IN ('pending','awaiting_review','paid') AND o.ticket_type_id=?",[$type['id']])->fetchColumn();
        if((int)$type['capacity']>0 && $reserved+count($delegates)>(int)$type['capacity'])throw new \InvalidArgumentException('Registration capacity has been reached. Contact the organizers.');
        if($couponCode!==''){
            if(!$accountId)throw new \InvalidArgumentException('Sign in to redeem a coupon.');
            [$coupon,$discount]=applicableCoupon($db,$couponCode,$subtotal,(string)$eventId);$amount=$subtotal-$discount;
            $updated=query($db,'UPDATE natcon_coupons SET usage_count=usage_count+1 WHERE id=? AND status=? AND (usage_limit=0 OR usage_count<usage_limit)',[$coupon['id'],'active']);if(!$updated->rowCount())throw new \InvalidArgumentException('This coupon was just fully redeemed.');
        }
        if($useWallet&&$amount>0){$balance=(int)query($db,'SELECT wallet_balance_kobo FROM natcon_accounts WHERE id=? AND status=?',[$accountId,'active'])->fetchColumn();$walletSpend=min($balance,$amount);if($walletSpend>0){$debited=query($db,'UPDATE natcon_accounts SET wallet_balance_kobo=wallet_balance_kobo-?,updated_at=? WHERE id=? AND wallet_balance_kobo>=?',[$walletSpend,now(),$accountId,$walletSpend]);if(!$debited->rowCount())throw new \InvalidArgumentException('Wallet balance changed. Refresh and try again.');$amount-=$walletSpend;}}
        $orderStatus=$amount===0?'paid':'pending';
        query($db,'INSERT INTO natcon_orders(reference,access_token,payer_name,payer_email,payer_phone,amount_kobo,currency,status,created_at,account_id,event_id,ticket_type_id,subtotal_kobo,coupon_id,discount_kobo,wallet_kobo,paid_at) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',[$ref,$token,$name,$email,$phone,$amount,$selectedEvent['currency']?:'NGN',$orderStatus,now(),$accountId,$eventId,$type['id'],$subtotal,$coupon['id']??null,$discount,$walletSpend,$amount===0?now():null]);
        if($walletSpend>0)query($db,'INSERT INTO natcon_wallet_ledger(account_id,direction,amount_kobo,reference,status,description,created_at) VALUES(?,?,?,?,?,?,?)',[$accountId,'debit',$walletSpend,'SPEND-'.$ref,$amount===0?'paid':'pending','NATCON ticket checkout '.$ref,now()]);
        if($coupon)query($db,'INSERT INTO natcon_coupon_redemptions(coupon_id,account_id,order_reference,discount_kobo,created_at) VALUES(?,?,?,?,?)',[$coupon['id'],$accountId,$ref,$discount,now()]);
        foreach($delegates as $d) query($db,'INSERT INTO natcon_delegates(reference,name,email,phone,chapter,state,education,accommodation,accessibility,course,institution,level,whatsapp,calling_line,state_origin,times_attended,ticket_token) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',[$ref,clean($d['name'],150),strtolower(clean($d['email'],190)),clean($d['whatsapp'],40),clean($d['chapter']??'',150),clean($d['state_origin'],100),clean($d['level'],80),clean($d['accommodation']??'',100),clean($d['accessibility']??'',1000),clean($d['course'],150),clean($d['institution'],190),clean($d['level'],80),clean($d['whatsapp'],40),clean($d['calling_line']??'',40),clean($d['state_origin'],100),(int)$d['times_attended'],bin2hex(random_bytes(32))]);
        audit($db,$accountId?(string)$accountId:'public','registered',$ref,['delegates'=>count($delegates),'coupon_id'=>$coupon['id']??null,'discount_kobo'=>$discount,'wallet_kobo'=>$walletSpend,'consent'=>true,'privacy_version'=>'2026-09-28']);$db->commit();
    }catch(\Throwable $e){$db->rollBack();throw $e;}
    if($amount===0){if($accountId)markReferralConverted($db,$accountId);queueTickets($db,$c,$ref);}
    return order($db,$ref,$token)+['payment_enabled'=>$amount>0&&$c['secret']!==''];
}
function releaseWalletReservation(\PDO $db,int $accountId,string $reference): bool {
    if($accountId<1)return false;
    $entry=query($db,'SELECT id,amount_kobo,status FROM natcon_wallet_ledger WHERE account_id=? AND reference=? AND direction=?',[$accountId,'SPEND-'.$reference,'debit'])->fetch();
    if(!$entry||!in_array($entry['status'],['pending','paid'],true))return false;
    $changed=query($db,"UPDATE natcon_wallet_ledger SET status='refunded' WHERE id=? AND status IN ('pending','paid')",[$entry['id']])->rowCount();
    if(!$changed)return false;
    query($db,'UPDATE natcon_accounts SET wallet_balance_kobo=wallet_balance_kobo+?,updated_at=? WHERE id=?',[$entry['amount_kobo'],now(),$accountId]);
    return true;
}
function queueTickets(\PDO $db,array $c,string $ref): void {
    $o=query($db,'SELECT * FROM natcon_orders WHERE reference=? AND status=?',[$ref,'paid'])->fetch();if(!$o)throw new \InvalidArgumentException('Only paid registrations have tickets.');
    $event=query($db,'SELECT title,starts_at,ends_at,venue FROM natcon_events WHERE id=?',[$o['event_id']??null])->fetch()?:['title'=>$c['name'],'starts_at'=>$c['start_date'],'ends_at'=>$c['end_date'],'venue'=>$c['venue']];$eventTitle=(string)$event['title'];$start=substr((string)$event['starts_at'],0,10);$end=substr((string)$event['ends_at'],0,10);
    $ds=query($db,'SELECT name,email,ticket_token FROM natcon_delegates WHERE reference=?',[$ref])->fetchAll();
    $body="Assalamu alaykum {$o['payer_name']},\nYour {$eventTitle} registration {$ref} is confirmed.\n\n";
    foreach($ds as $d)$body.=$d['name'].': '.$c['base_url'].'/conference/ticket.php#'.$d['ticket_token']."\n";
    $body.="\n{$start}".($end!==$start?' to '.$end:'')." · {$event['venue']}. Present your personal ticket at the venue. Keep these links private.";
    query($db,'INSERT INTO natcon_outbox(recipient,subject,body,status,created_at) VALUES(?,?,?,?,?)',[$o['payer_email'],'Your tickets for '.$eventTitle,$body,'pending',now()]);
    foreach($ds as $d)if($d['email'] && strcasecmp($d['email'],$o['payer_email'])!==0)query($db,'INSERT INTO natcon_outbox(recipient,subject,body,status,created_at) VALUES(?,?,?,?,?)',[$d['email'],'Your personal ticket for '.$eventTitle,"Assalamu alaykum {$d['name']},\nYour ticket: ".$c['base_url'].'/conference/ticket.php#'.$d['ticket_token']."\nKeep this link private.",'pending',now()]);
}
function recover(\PDO $db,array $c,string $email): void {
    $orders=query($db,"SELECT * FROM natcon_orders WHERE payer_email=? AND status IN ('pending','awaiting_review','paid')",[$email])->fetchAll();
    foreach($orders as $o){
        if($o['status']==='paid'){queueTickets($db,$c,$o['reference']);continue;}
        query($db,'INSERT INTO natcon_outbox(recipient,subject,body,status,created_at) VALUES(?,?,?,?,?)',[$email,'Your NATCON registration link',"Continue your registration securely: ".$c['base_url'].'/conference/#reference='.$o['reference'].'&token='.$o['access_token'],'pending',now()]);
    }
    // Delegates can recover their own paid ticket without receiving their group payer's credentials.
    foreach(query($db,"SELECT d.name,d.ticket_token FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE d.email=? AND o.payer_email<>? AND o.status='paid'",[$email,$email])->fetchAll() as $d)query($db,'INSERT INTO natcon_outbox(recipient,subject,body,status,created_at) VALUES(?,?,?,?,?)',[$email,'Your personal NATCON ticket',$c['base_url'].'/conference/ticket.php#'.$d['ticket_token'],'pending',now()]);
}
function confirmPayment(\PDO $db,array $c,string $ref,array $payment,string $actor='paystack',?array $receipt=null): bool {
    $db->beginTransaction();try {
        $o=query($db,'SELECT * FROM natcon_orders WHERE reference=?',[$ref])->fetch();
        if(!$o || ($payment['status']??'')!=='success' || (string)($payment['reference']??'')!==$ref || (int)($payment['amount']??0)!==(int)$o['amount_kobo'] || ($payment['currency']??'')!==$o['currency'])throw new \InvalidArgumentException('Payment does not match this registration.');
        if(!in_array($o['status'],['pending','awaiting_review','paid'],true))throw new \InvalidArgumentException('This registration cannot receive payment.');
        if($receipt!==null && $o['status']!=='paid'){
            if($o['status']!=='awaiting_review'||(int)($receipt['amount_kobo']??0)!==(int)$o['amount_kobo'])throw new \InvalidArgumentException('Verified bank amount does not match the registration total.');
            $bankRef=strtoupper(trim((string)$o['bank_reference']));
            if(!$bankRef)throw new \InvalidArgumentException('Missing bank transaction reference.');
            try{query($db,'INSERT INTO natcon_transfer_receipts(bank_reference,reference,amount_kobo,staff_id,verified_at) VALUES(?,?,?,?,?)',[$bankRef,$ref,$o['amount_kobo'],(int)$actor,now()]);}
            catch(\PDOException $e){if(in_array((string)$e->getCode(),['23000','23505'],true))throw new \InvalidArgumentException('This bank transaction has already been reconciled.');throw $e;}
        }
        $changed=query($db,"UPDATE natcon_orders SET status='paid',paid_at=? WHERE reference=? AND status IN ('pending','awaiting_review')",[now(),$ref])->rowCount()>0;
        if($changed){query($db,"UPDATE natcon_wallet_ledger SET status='paid' WHERE reference=? AND direction='debit' AND status='pending'",['SPEND-'.$ref]);if(!empty($o['account_id']))markReferralConverted($db,(int)$o['account_id']);queueTickets($db,$c,$ref);audit($db,$actor,'payment_confirmed',$ref,['amount_kobo'=>$o['amount_kobo'],'wallet_kobo'=>(int)($o['wallet_kobo']??0)]);}
        $db->commit();return $changed;
    }catch(\Throwable $e){$db->rollBack();throw $e;}
}
function gateway(array $c,string $path,?array $body=null): array {
    if(!$c['secret'])throw new \RuntimeException('Online payment is not configured. Use bank transfer or contact the organizers.');
    $h=curl_init('https://api.paystack.co/'.$path);curl_setopt_array($h,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_TIMEOUT=>25,CURLOPT_HTTPHEADER=>['Authorization: Bearer '.$c['secret'],'Content-Type: application/json'],CURLOPT_SSL_VERIFYPEER=>true]);
    if($body!==null)curl_setopt_array($h,[CURLOPT_POST=>true,CURLOPT_POSTFIELDS=>json_encode($body)]);
    $raw=curl_exec($h);$status=curl_getinfo($h,CURLINFO_RESPONSE_CODE);curl_close($h);$result=json_decode((string)$raw,true);
    if($status!==200 || !is_array($result) || empty($result['status']))throw new \RuntimeException('Payment provider could not complete the request. Please retry.');return $result['data'];
}
function delegate(\PDO $db,string $token): array {
    $d=query($db,"SELECT d.*,o.status,o.payer_name,o.amount_kobo,o.event_id FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE d.ticket_token=?",[$token])->fetch();
    if(!$d||$d['status']!=='paid')throw new \InvalidArgumentException('Ticket is invalid or payment is not confirmed.');return $d;
}
function checkin(\PDO $db,array $c,string $token,string $mode,int $staff,?string $date=null): array {
    $date=$date??(new \DateTimeImmutable('now',new \DateTimeZone('Africa/Lagos')))->format('Y-m-d');
    if(!in_array($mode,['arrival','daily','reentry'],true))throw new \InvalidArgumentException('Choose arrival, daily, or reentry.');
    $d=delegate($db,$token);$event=query($db,'SELECT starts_at,ends_at,status FROM natcon_events WHERE id=?',[$d['event_id']])->fetch();if(($event['status']??'')==='cancelled')throw new \InvalidArgumentException('This event was cancelled. Contact Admin about your paid registration.');$start=substr((string)($event['starts_at']??$c['start_date']),0,10);$end=substr((string)($event['ends_at']??$c['end_date']),0,10);
    if($date<$start||$date>$end)throw new \InvalidArgumentException('Check-in is available only during this event.');
    $slot=$mode==='arrival'?'arrival':($mode==='daily'?'daily:'.$date:'reentry:'.bin2hex(random_bytes(12)));$at=now();
    if($mode==='reentry'&&!query($db,'SELECT id FROM natcon_checkins WHERE delegate_id=? LIMIT 1',[$d['id']])->fetch())throw new \InvalidArgumentException('Record initial arrival before re-entry.');
    try{query($db,'INSERT INTO natcon_checkins(delegate_id,slot,staff_id,checked_at) VALUES(?,?,?,?)',[$d['id'],$slot,$staff,$at]);$result='accepted';audit($db,(string)$staff,'checkin',$d['reference'],['delegate_id'=>$d['id'],'mode'=>$mode]);}
    catch(\PDOException $e){if(!in_array((string)$e->getCode(),['23000','23505'],true))throw $e;$result='already_checked_in';$at=query($db,'SELECT checked_at FROM natcon_checkins WHERE delegate_id=? AND slot=?',[$d['id'],$slot])->fetchColumn();}
    return ['result'=>$result,'delegate'=>$d,'checked_at'=>$at];
}
function limit(\PDO $db,string $key,int $max=15,int $seconds=300): void {
    $key=hash('sha256',$key);$t=time();
    $db->beginTransaction();try {
        $insert=$db->getAttribute(\PDO::ATTR_DRIVER_NAME)==='sqlite'?'INSERT OR IGNORE':'INSERT IGNORE';query($db,"$insert INTO natcon_limits(bucket,count,window_start) VALUES(?,0,?)",[$key,$t]);
        query($db,'UPDATE natcon_limits SET count=0,window_start=? WHERE bucket=? AND window_start<?',[$t,$key,$t-$seconds]);
        query($db,'UPDATE natcon_limits SET count=count+1 WHERE bucket=?',[$key]);$n=query($db,'SELECT count FROM natcon_limits WHERE bucket=?',[$key])->fetchColumn();$db->commit();
    }catch(\Throwable $e){$db->rollBack();throw $e;}if($n>$max)throw new \InvalidArgumentException('Too many attempts. Please wait a few minutes.');
}

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
        "natcon_faqs (id $id, question VARCHAR(255) NOT NULL, answer TEXT NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'active', sort_order INTEGER NOT NULL DEFAULT 0)",
        "natcon_pages (id $id, slug VARCHAR(190) NOT NULL UNIQUE, title VARCHAR(190) NOT NULL, content TEXT NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'published', updated_at VARCHAR(30))",
        "natcon_notifications (id $id, account_id BIGINT NOT NULL, title VARCHAR(190) NOT NULL, body TEXT NOT NULL, channel VARCHAR(20) NOT NULL DEFAULT 'in_app', read_at VARCHAR(30), created_at VARCHAR(30) NOT NULL)",
        "natcon_devices (id $id, account_id BIGINT NOT NULL, provider VARCHAR(20) NOT NULL, device_token VARCHAR(512) NOT NULL UNIQUE, updated_at VARCHAR(30) NOT NULL)",
        "natcon_chat_threads (id $id, account_id BIGINT NOT NULL, event_id BIGINT, status VARCHAR(20) NOT NULL DEFAULT 'open', created_at VARCHAR(30) NOT NULL, updated_at VARCHAR(30))",
        "natcon_chat_messages (id $id, thread_id BIGINT NOT NULL, sender_type VARCHAR(20) NOT NULL, sender_id BIGINT NOT NULL, message TEXT NOT NULL, created_at VARCHAR(30) NOT NULL)",
        "natcon_otp_challenges (id $id, destination VARCHAR(190) NOT NULL, channel VARCHAR(20) NOT NULL, code_hash VARCHAR(255) NOT NULL, expires_at VARCHAR(30) NOT NULL, consumed_at VARCHAR(30), attempts INTEGER NOT NULL DEFAULT 0, created_at VARCHAR(30) NOT NULL)"
    ] as $schema) $db->exec('CREATE TABLE IF NOT EXISTS '.$schema);
    $driver=$db->getAttribute(\PDO::ATTR_DRIVER_NAME);
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
    $referral=strtoupper(bin2hex(random_bytes(6)));
    try{query($db,'INSERT INTO natcon_accounts(name,email,country_code,phone,password_hash,referral_code,status,created_at) VALUES(?,?,?,?,?,?,?,?)',[$name,$email,$country,$phone,password_hash($password,PASSWORD_DEFAULT),$referral,'active',now()]);}
    catch(\PDOException $e){if(in_array((string)$e->getCode(),['23000','23505'],true))throw new \InvalidArgumentException('An account already uses that email or phone number.');throw $e;}
    $id=(int)$db->lastInsertId();$account=query($db,'SELECT id,name,email,country_code,phone,profile_image,referral_code,wallet_balance_kobo FROM natcon_accounts WHERE id=?',[$id])->fetch();$account['access_token']=issueMobileToken($db,'attendee',$id);return $account;
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
function mobileTicketHistory(\PDO $db,int $accountId,array $c): array {
    $orders=query($db,"SELECT o.reference,o.created_at,o.paid_at,d.ticket_token,d.name FROM natcon_orders o JOIN natcon_delegates d ON d.reference=o.reference WHERE o.account_id=? AND o.status='paid' ORDER BY o.created_at DESC,d.id ASC",[$accountId])->fetchAll();
    $data=[];foreach($orders as $ticket)$data[]=['event_id'=>'NATCON-2026','event_title'=>$c['name'],'event_img'=>'','event_sdate'=>$c['start_date'],'event_place_name'=>$c['venue'],'ticket_id'=>$ticket['ticket_token'],'total_ticket'=>'1','ticket_type'=>'Delegate','book_mintues'=>0];
    return $data;
}
function mobileTicketInfo(\PDO $db,int $accountId,string $token,array $c): array {
    $ticket=query($db,"SELECT d.*,o.payer_name,o.payer_email,o.payer_phone,o.amount_kobo,o.bank_reference,o.reference,o.status FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE d.ticket_token=? AND o.account_id=? AND o.status='paid'",[$token,$accountId])->fetch();
    if(!$ticket)throw new \InvalidArgumentException('Paid ticket not found in this account.');
    $paidCount=max(1,(int)query($db,'SELECT COUNT(*) FROM natcon_delegates WHERE reference=?',[$ticket['reference']])->fetchColumn());$unit=round((int)$ticket['amount_kobo']/$paidCount);$amount=number_format($unit/100,2,'.','');
    return ['ticket_id'=>$ticket['ticket_token'],'ticket_title'=>$c['name'],'start_time'=>$c['start_date'],'event_address'=>$c['venue'],'event_address_title'=>$c['venue'],'event_latitude'=>'0','event_longtitude'=>'0','sponsore_id'=>'NATCON','sponsore_img'=>'','sponsore_title'=>'The Achiever Ambassadors Islamic Foundation','qrcode'=>$ticket['ticket_token'],'unique_code'=>$ticket['reference'],'ticket_username'=>$ticket['name'],'ticket_mobile'=>$ticket['whatsapp']?:$ticket['phone'],'ticket_email'=>$ticket['email'],'ticket_rate'=>'0','ticket_type'=>'Delegate','total_ticket'=>'1','ticket_subtotal'=>$amount,'ticket_cou_amt'=>'0','ticket_wall_amt'=>'0','ticket_tax'=>'0','ticket_total_amt'=>$amount,'ticket_p_method'=>$ticket['bank_reference']?'Bank Transfer':'Paystack','ticket_transaction_id'=>$ticket['bank_reference']?:$ticket['reference'],'ticket_status'=>'paid'];
}
function clean($v,int $max=190): string { if (!is_scalar($v) && $v!==null) throw new \InvalidArgumentException('Invalid field value.'); return mb_substr(trim((string)$v),0,$max); }
function audit(\PDO $db,string $actor,string $action,string $reference='',array $detail=[]): void { query($db,'INSERT INTO natcon_audit(actor,action,reference,detail,created_at) VALUES(?,?,?,?,?)',[$actor,$action,$reference,json_encode($detail),now()]); }
function event(array $c): array { $date=(new \DateTimeImmutable('now',new \DateTimeZone('Africa/Lagos')))->format('Y-m-d');return array_intersect_key($c,array_flip(['name','theme','start_date','end_date','venue','currency','earlybird_end','bank']))+['price_kobo'=>$date<=$c['earlybird_end']?700000:800000,'payment_enabled'=>$c['secret']!=='']; }
function order(\PDO $db,string $reference,string $token): array {
    $o=query($db,'SELECT * FROM natcon_orders WHERE reference=? AND access_token=?',[$reference,$token])->fetch();
    if (!$o) throw new \InvalidArgumentException('Registration not found.');
    unset($o['id']); $o['delegates']=query($db,'SELECT id,name,ticket_token FROM natcon_delegates WHERE reference=?',[$reference])->fetchAll();
    if($o['status']!=='paid') foreach($o['delegates'] as &$d) unset($d['ticket_token']);
    return $o;
}
function register(\PDO $db,array $c,array $in,?int $accountId=null): array {
    if(($in['consent']??false)!==true)throw new \InvalidArgumentException('Accept the privacy notice before registering.');
    if((new \DateTimeImmutable('now',new \DateTimeZone('Africa/Lagos')))->format('Y-m-d H:i:s')>$c['registration_closes'])throw new \InvalidArgumentException('Registration has closed. Contact the organizers.');
    $name=clean($in['payer_name']??'',150);$email=strtolower(clean($in['payer_email']??''));$phone=clean($in['payer_phone']??'',40);$delegates=$in['delegates']??[];
    if(!$name || !filter_var($email,FILTER_VALIDATE_EMAIL) || !$phone || !is_array($delegates) || count($delegates)<1 || count($delegates)>50) throw new \InvalidArgumentException('Provide payer name, valid email, phone, and between 1 and 50 delegates.');
    foreach($delegates as $d) {
        if(!is_array($d)||!clean($d['name']??'',150) || !filter_var(clean($d['email']??''),FILTER_VALIDATE_EMAIL)) throw new \InvalidArgumentException('Every delegate needs a name and valid Gmail or email address.');
        foreach(['course','institution','level','whatsapp','state_origin'] as $required) if(!clean($d[$required]??'')) throw new \InvalidArgumentException('Complete each delegate’s course, institution, level, WhatsApp number, and state of origin.');
        if(!preg_match('/^\d{1,2}$/',clean($d['times_attended']??'')) || (int)$d['times_attended']>99) throw new \InvalidArgumentException('Enter NATCON attendance from 0 to 99.');
    }
    $ref='TAA-'.strtoupper(bin2hex(random_bytes(6)));$token=bin2hex(random_bytes(32));$amount=event($c)['price_kobo']*count($delegates);
    $db->beginTransaction();try {
        // Serialize capacity reservation across workers, including SQLite test deployments.
        query($db,"UPDATE natcon_locks SET value=value+1 WHERE name='registration'");
        $reserved=(int)query($db,"SELECT COUNT(*) FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE o.status IN ('pending','awaiting_review','paid')")->fetchColumn();
        if($c['capacity']>0 && $reserved+count($delegates)>$c['capacity'])throw new \InvalidArgumentException('Registration capacity has been reached. Contact the organizers.');
        query($db,'INSERT INTO natcon_orders(reference,access_token,payer_name,payer_email,payer_phone,amount_kobo,currency,status,created_at,account_id) VALUES(?,?,?,?,?,?,?,?,?,?)',[$ref,$token,$name,$email,$phone,$amount,'NGN','pending',now(),$accountId]);
        foreach($delegates as $d) query($db,'INSERT INTO natcon_delegates(reference,name,email,phone,chapter,state,education,accommodation,accessibility,course,institution,level,whatsapp,calling_line,state_origin,times_attended,ticket_token) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',[$ref,clean($d['name'],150),strtolower(clean($d['email'],190)),clean($d['whatsapp'],40),clean($d['chapter']??'',150),clean($d['state_origin'],100),clean($d['level'],80),clean($d['accommodation']??'',100),clean($d['accessibility']??'',1000),clean($d['course'],150),clean($d['institution'],190),clean($d['level'],80),clean($d['whatsapp'],40),clean($d['calling_line']??'',40),clean($d['state_origin'],100),(int)$d['times_attended'],bin2hex(random_bytes(32))]);
        audit($db,'public','registered',$ref,['delegates'=>count($delegates),'consent'=>true,'privacy_version'=>'2026-09-28']);$db->commit();
    }catch(\Throwable $e){$db->rollBack();throw $e;}
    return order($db,$ref,$token)+['payment_enabled'=>$c['secret']!==''];
}
function queueTickets(\PDO $db,array $c,string $ref): void {
    $o=query($db,'SELECT * FROM natcon_orders WHERE reference=? AND status=?',[$ref,'paid'])->fetch();if(!$o)throw new \InvalidArgumentException('Only paid registrations have tickets.');
    $ds=query($db,'SELECT name,email,ticket_token FROM natcon_delegates WHERE reference=?',[$ref])->fetchAll();
    $body="Assalamu alaykum {$o['payer_name']},\nYour NATCON registration {$ref} is confirmed.\n\n";
    foreach($ds as $d)$body.=$d['name'].': '.$c['base_url'].'/conference/ticket.php#'.$d['ticket_token']."\n";
    $body.="\nOctober 1–4, 2026. Present your personal ticket at the venue. Keep these links private.";
    query($db,'INSERT INTO natcon_outbox(recipient,subject,body,status,created_at) VALUES(?,?,?,?,?)',[$o['payer_email'],'Your NATCON 2026 tickets',$body,'pending',now()]);
    foreach($ds as $d)if($d['email'] && strcasecmp($d['email'],$o['payer_email'])!==0)query($db,'INSERT INTO natcon_outbox(recipient,subject,body,status,created_at) VALUES(?,?,?,?,?)',[$d['email'],'Your personal NATCON 2026 ticket',"Assalamu alaykum {$d['name']},\nYour ticket: ".$c['base_url'].'/conference/ticket.php#'.$d['ticket_token']."\nKeep this link private.",'pending',now()]);
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
        if($changed){queueTickets($db,$c,$ref);audit($db,$actor,'payment_confirmed',$ref,['amount_kobo'=>$o['amount_kobo']]);}
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
    $d=query($db,"SELECT d.*,o.status,o.payer_name,o.amount_kobo FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE d.ticket_token=?",[$token])->fetch();
    if(!$d||$d['status']!=='paid')throw new \InvalidArgumentException('Ticket is invalid or payment is not confirmed.');return $d;
}
function checkin(\PDO $db,array $c,string $token,string $mode,int $staff,?string $date=null): array {
    $date=$date??(new \DateTimeImmutable('now',new \DateTimeZone('Africa/Lagos')))->format('Y-m-d');
    if($date<$c['start_date']||$date>$c['end_date'])throw new \InvalidArgumentException('Check-in is available only during October 1–4, 2026.');
    if(!in_array($mode,['arrival','daily','reentry'],true))throw new \InvalidArgumentException('Choose arrival, daily, or reentry.');
    $d=delegate($db,$token);$slot=$mode==='arrival'?'arrival':($mode==='daily'?'daily:'.$date:'reentry:'.bin2hex(random_bytes(12)));$at=now();
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

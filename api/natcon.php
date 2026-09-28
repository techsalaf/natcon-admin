<?php
declare(strict_types=1);
require_once dirname(__DIR__).'/services/natcon/bootstrap.php';
use function Natcon\{config,database,query,clean,event,order,register,gateway,confirmPayment,queueTickets,recover,delegate,checkin,audit,now,limit};
header('X-Content-Type-Options: nosniff');header('Cache-Control: no-store');header('Content-Type: application/json; charset=utf-8');
ini_set('session.use_strict_mode', '1');
session_name('natcon_staff');session_set_cookie_params(['httponly'=>true,'secure'=>!empty($_SERVER['HTTPS'])&&$_SERVER['HTTPS']!=='off','samesite'=>'Strict','path'=>'/']);session_start();
function respond($data): never {echo json_encode(['ok'=>true,'data'=>$data],JSON_UNESCAPED_SLASHES);exit;}
function requireStaff(array $roles): array {if(empty($_SESSION['user'])||($_SESSION['last_active']??0)<time()-3600){http_response_code(401);throw new InvalidArgumentException('Please sign in.');}if(!in_array($_SESSION['user']['role'],$roles,true)){http_response_code(403);throw new InvalidArgumentException('Your role cannot perform this action.');}$_SESSION['last_active']=time();return $_SESSION['user'];}
try {
    $c=config();$action=clean($_GET['action']??'event',50);$method=$_SERVER['REQUEST_METHOD'];
    if($action==='event'&&$method==='GET')respond(event($c));
    $db=database($c);$raw=file_get_contents('php://input');if(strlen($raw)>100000)throw new InvalidArgumentException('Request is too large.');
    $in=$raw!==''?json_decode($raw,true):[];if(!is_array($in))throw new InvalidArgumentException('Invalid JSON request.');
    $getActions=['session','order','payment_verify','ticket','qr','dashboard','delegates','transfers','export','audit'];
    if($action!=='webhook' && !in_array($action,$getActions,true) && $method!=='POST'){http_response_code(405);throw new InvalidArgumentException('Use POST for this action.');}
    if(in_array($action,$getActions,true)&&$method!=='GET'){http_response_code(405);throw new InvalidArgumentException('Use GET for this action.');}
    if($action==='register'){limit($db,'register:'.($_SERVER['REMOTE_ADDR']??''),20);respond(register($db,$c,$in));}
    if($action==='order')respond(order($db,clean($_GET['reference']??''),clean($_GET['token']??'')));
    if($action==='payment_initialize'){
        $o=order($db,clean($in['reference']??''),clean($in['token']??''));if(!in_array($o['status'],['pending','awaiting_review'],true))throw new InvalidArgumentException('This registration cannot accept a payment.');
        respond(gateway($c,'transaction/initialize',['email'=>$o['payer_email'],'amount'=>(int)$o['amount_kobo'],'currency'=>$o['currency'],'reference'=>$o['reference'],'callback_url'=>$c['base_url'].'/conference/#reference='.rawurlencode($o['reference']).'&token='.$o['access_token']]));
    }
    if($action==='payment_verify'){$o=order($db,clean($_GET['reference']??''),clean($_GET['token']??''));$p=gateway($c,'transaction/verify/'.rawurlencode($o['reference']));confirmPayment($db,$c,$o['reference'],$p);respond(order($db,$o['reference'],$o['access_token']));}
    if($action==='webhook'){
        if($method!=='POST'||!$c['secret']||!hash_equals(hash_hmac('sha512',$raw,$c['secret']),$_SERVER['HTTP_X_PAYSTACK_SIGNATURE']??'')){http_response_code(403);throw new InvalidArgumentException('Invalid webhook signature.');}
        if(($in['event']??'')==='charge.success'){ $p=$in['data']??[];confirmPayment($db,$c,clean($p['reference']??''),$p); }respond(['received'=>true]);
    }
    if($action==='transfer'){
        $o=order($db,clean($in['reference']??''),clean($in['token']??''));$br=clean($in['bank_reference']??'');$sender=clean($in['sender_name']??'',150);$day=clean($in['paid_on']??'',30);
        if(!$br||!$sender||!preg_match('/^\d{4}-\d{2}-\d{2}$/',$day))throw new InvalidArgumentException('Provide bank reference, sender name, and payment date.');
        if($o['status']==='paid')throw new InvalidArgumentException('Already paid.');
        query($db,"UPDATE natcon_orders SET status='awaiting_review',bank_reference=?,sender_name=?,paid_on=? WHERE reference=? AND status<>'paid'",[$br,$sender,$day,$o['reference']]);audit($db,'public','transfer_submitted',$o['reference']);respond(['status'=>'awaiting_review']);
    }
    if($action==='recover'){
        limit($db,'recover:'.($_SERVER['REMOTE_ADDR']??''),5);$email=strtolower(clean($in['email']??''));
        if(!filter_var($email,FILTER_VALIDATE_EMAIL))throw new InvalidArgumentException('Enter a valid email address.');
        recover($db,$c,$email);respond(['message'=>'If a registration matches this email, a secure link will be sent.']);
    }
    if($action==='ticket')respond(delegate($db,clean($_GET['token']??''))+['event'=>event($c)]);
    if($action==='qr'){$d=delegate($db,clean($_GET['token']??''));require_once dirname(__DIR__).'/qr/phpqrcode.php';header('Content-Type: image/png');\QRcode::png($d['ticket_token'],false,QR_ECLEVEL_M,7,2);exit;}
    if($action==='login'){
        limit($db,'login:'.($_SERVER['REMOTE_ADDR']??''),10);$u=query($db,'SELECT * FROM natcon_staff WHERE email=?',[strtolower(clean($in['email']??''))])->fetch();
        if(!$u||!password_verify((string)($in['password']??''),$u['password_hash'])){http_response_code(401);throw new InvalidArgumentException('Email or password is incorrect.');}
        unset($u['password_hash']);session_regenerate_id(true);$_SESSION['user']=$u;$_SESSION['csrf']=bin2hex(random_bytes(32));$_SESSION['last_active']=time();audit($db,(string)$u['id'],'login');respond(['user'=>$u,'csrf'=>$_SESSION['csrf']]);
    }
    $user=requireStaff(['admin','finance','registrar']);
    if($action==='session')respond(['user'=>$user,'csrf'=>$_SESSION['csrf']]);
    if($method==='POST'&&!hash_equals($_SESSION['csrf']??'',$_SERVER['HTTP_X_CSRF_TOKEN']??'')){http_response_code(403);throw new InvalidArgumentException('Session verification failed. Refresh and try again.');}
    if($action==='logout'){$_SESSION=[];session_destroy();respond(['logged_out'=>true]);}
    if($action==='dashboard'){
        respond(['total_delegates'=>(int)query($db,'SELECT COUNT(*) FROM natcon_delegates')->fetchColumn(),'paid_delegates'=>(int)query($db,"SELECT COUNT(*) FROM natcon_delegates d JOIN natcon_orders o ON d.reference=o.reference WHERE o.status='paid'")->fetchColumn(),'checked_in'=>(int)query($db,'SELECT COUNT(DISTINCT delegate_id) FROM natcon_checkins')->fetchColumn(),'revenue_kobo'=>(int)query($db,"SELECT COALESCE(SUM(amount_kobo),0) FROM natcon_orders WHERE status='paid'")->fetchColumn(),'pending_transfers'=>(int)query($db,"SELECT COUNT(*) FROM natcon_orders WHERE status='awaiting_review'")->fetchColumn(),'chapters'=>query($db,'SELECT chapter,COUNT(*) AS total FROM natcon_delegates GROUP BY chapter ORDER BY total DESC')->fetchAll()]);
    }
    if($action==='delegates'||$action==='export'){
        $sql='SELECT d.*,o.status,o.amount_kobo,o.payer_name,o.payer_email,CASE WHEN EXISTS(SELECT 1 FROM natcon_checkins c WHERE c.delegate_id=d.id) THEN 1 ELSE 0 END AS checked_in FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE 1=1';$args=[];
        if(!empty($_GET['q'])){$sql.=' AND (d.name LIKE ? OR d.phone LIKE ? OR d.reference LIKE ? OR d.email LIKE ?)';$v='%'.clean($_GET['q']).'%';$args=[$v,$v,$v,$v];}
        if(!empty($_GET['status'])){$sql.=' AND o.status=?';$args[]=clean($_GET['status']);}$rows=query($db,$sql.' ORDER BY d.id DESC',$args)->fetchAll();
        if($action==='delegates')respond($rows);
        requireStaff(['admin','finance']);header('Content-Type: text/csv; charset=utf-8');header('Content-Disposition: attachment; filename="natcon-delegates.csv"');$out=fopen('php://output','w');$keys=['id','name','email','whatsapp','calling_line','course','institution','level','state_origin','times_attended','chapter','reference','status','checked_in','accommodation','accessibility'];fputcsv($out,$keys);
        foreach($rows as $r)fputcsv($out,array_map(static function($k)use($r){$v=(string)($r[$k]??'');return preg_match('/^[=+@\-\t\r]/',$v)?"'".$v:$v;},$keys));exit;
    }
    if($action==='checkin'){requireStaff(['admin','registrar']);respond(checkin($db,$c,clean($in['token']??''),clean($in['mode']??'arrival'),(int)$user['id']));}
    if($action==='entitlement'){
        requireStaff(['admin','registrar']);$d=delegate($db,clean($in['token']??''));$kind=clean($in['kind']??'');$slot=clean($in['slot']??'',80);if(!in_array($kind,['meal','material','accommodation'],true)||!$slot)throw new InvalidArgumentException('Choose a benefit and slot.');
        try{query($db,'INSERT INTO natcon_claims(delegate_id,kind,slot,staff_id,created_at) VALUES(?,?,?,?,?)',[$d['id'],$kind,$slot,$user['id'],now()]);audit($db,(string)$user['id'],'entitlement',$d['reference'],['kind'=>$kind,'slot'=>$slot]);respond(['result'=>'accepted','delegate'=>$d]);}catch(PDOException $e){if(!in_array((string)$e->getCode(),['23000','23505'],true))throw $e;respond(['result'=>'already_claimed','delegate'=>$d]);}
    }
    requireStaff(['admin','finance']);
    if($action==='transfers')respond(query($db,"SELECT reference,payer_name,payer_email,payer_phone,amount_kobo,bank_reference,sender_name,paid_on,created_at FROM natcon_orders WHERE status='awaiting_review' ORDER BY created_at")->fetchAll());
    if($action==='approve_transfer'){
        $ref=clean($in['reference']??'');$note=clean($in['note']??'',1000);$verifiedAmount=(int)($in['verified_amount_kobo']??0);
        if(strlen($note)<10)throw new InvalidArgumentException('Enter the bank statement reference and reconciliation note.');$o=query($db,'SELECT * FROM natcon_orders WHERE reference=?',[$ref])->fetch();
        if(!$o||$o['status']!=='awaiting_review')throw new InvalidArgumentException('No submitted transfer is awaiting reconciliation.');
        confirmPayment($db,$c,$ref,['status'=>'success','reference'=>$ref,'amount'=>$o['amount_kobo'],'currency'=>$o['currency']],(string)$user['id'],['amount_kobo'=>$verifiedAmount]);audit($db,(string)$user['id'],'transfer_approved',$ref,['note'=>$note,'verified_amount_kobo'=>$verifiedAmount]);respond(['status'=>'paid']);
    }
    if($action==='cancel'){
        $ref=clean($in['reference']??'');$status=clean($in['status']??'',20);$reason=clean($in['reason']??'',1000);
        if(!in_array($status,['cancelled','refunded'],true)||strlen($reason)<10)throw new InvalidArgumentException('Choose a valid status and enter the reconciliation reason.');
        $db->beginTransaction();try{
            $o=query($db,'SELECT status FROM natcon_orders WHERE reference=?',[$ref])->fetch();
            if(!$o||in_array($o['status'],['cancelled','refunded'],true))throw new InvalidArgumentException('This registration cannot be changed.');
            query($db,'UPDATE natcon_orders SET status=? WHERE reference=?',[$status,$ref]);audit($db,(string)$user['id'],'order_'.$status,$ref,['reason'=>$reason]);$db->commit();
        }catch(Throwable $e){$db->rollBack();throw $e;}
        respond(['status'=>$status]);
    }
    if($action==='resend'){queueTickets($db,$c,clean($in['reference']??''));audit($db,(string)$user['id'],'tickets_resent',clean($in['reference']??''));respond(['queued'=>true]);}
    if($action==='audit')respond(query($db,'SELECT * FROM natcon_audit ORDER BY id DESC LIMIT 200')->fetchAll());
    http_response_code(404);throw new InvalidArgumentException('Unknown action.');
}catch(InvalidArgumentException $e){if(http_response_code()<400)http_response_code(400);echo json_encode(['ok'=>false,'error'=>$e->getMessage()]);}
catch(Throwable $e){error_log('NATCON: '.$e->getMessage());http_response_code(503);echo json_encode(['ok'=>false,'error'=>'Service temporarily unavailable. Please contact the organizers or retry shortly.']);}

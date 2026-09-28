<?php
declare(strict_types=1);
require dirname(__DIR__).'/bootstrap.php';
use function Natcon\{config,migrate,register,confirmPayment,query,order,checkin,delegate,recover};
$db=new PDO('sqlite::memory:',null,null,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);migrate($db);$c=config();$checks=0;
function check($yes,string $label): void {global $checks;if(!$yes)throw new RuntimeException($label);$checks++;}
function rejects(callable $fn,string $label):void {try{$fn();}catch(InvalidArgumentException $e){check(true,$label);return;}throw new RuntimeException($label);}
$o=register($db,$c,['payer_name'=>'Test Payer','payer_email'=>'payer@example.test','payer_phone'=>'08000000000','amount_kobo'=>1,'consent'=>true,'delegates'=>[['name'=>'Delegate One','chapter'=>'Iwo'],['name'=>'Delegate Two']]]);
check((int)$o['amount_kobo']===1600000,'Server prices group registration');check(!isset($o['delegates'][0]['ticket_token']),'Unpaid tokens hidden');
$p=['status'=>'success','reference'=>$o['reference'],'amount'=>1600000,'currency'=>'NGN'];
rejects(fn()=>confirmPayment($db,$c,$o['reference'],array_replace($p,['amount'=>1])),'Reject wrong amount');
rejects(fn()=>confirmPayment($db,$c,$o['reference'],array_replace($p,['currency'=>'USD'])),'Reject currency');
rejects(fn()=>confirmPayment($db,$c,$o['reference'],array_replace($p,['reference'=>'other'])),'Reject reference');
check(confirmPayment($db,$c,$o['reference'],$p),'First confirmation changes status');check(!confirmPayment($db,$c,$o['reference'],$p),'Webhook replay idempotent');check((int)query($db,'SELECT COUNT(*) FROM natcon_outbox')->fetchColumn()===1,'One ticket email');
$paid=order($db,$o['reference'],$o['access_token']);$token=$paid['delegates'][0]['ticket_token'];check(strlen($token)===64,'Opaque ticket');
check(checkin($db,$c,$token,'arrival',1,'2026-10-02')['result']==='accepted','Arrival on second day');check(checkin($db,$c,$token,'arrival',2,'2026-10-02')['result']==='already_checked_in','Duplicate denied across registrar');
check(checkin($db,$c,$token,'daily',1,'2026-10-03')['result']==='accepted','Daily attendance');check(checkin($db,$c,$token,'daily',2,'2026-10-03')['result']==='already_checked_in','Daily duplicate denied');
rejects(fn()=>checkin($db,$c,$token,'arrival',1,'2026-10-05'),'After conference rejected');rejects(fn()=>delegate($db,'bad'),'Invalid token rejected');
rejects(fn()=>order($db,$o['reference'],'wrong'),'Order secret required');
query($db,"UPDATE natcon_orders SET status='cancelled' WHERE reference=?",[$o['reference']]);rejects(fn()=>confirmPayment($db,$c,$o['reference'],$p),'Cancelled order cannot revive');
rejects(fn()=>register($db,$c,['payer_name'=>'A','payer_email'=>'bad','payer_phone'=>'x','consent'=>true,'delegates'=>[['name'=>'A']]]),'Bad email');
rejects(fn()=>register($db,$c,['payer_name'=>'A','payer_email'=>'good@example.test','payer_phone'=>'x','delegates'=>[['name'=>'A']]]),'Consent required');
// Finance can only reconcile the exact credit and never reuse a bank reference.
$transfer=register($db,$c,['payer_name'=>'Transfer Payer','payer_email'=>'transfer@example.test','payer_phone'=>'08000000004','consent'=>true,'delegates'=>[['name'=>'Transfer Delegate']]]);
query($db,"UPDATE natcon_orders SET status='awaiting_review',bank_reference='GATE-TRANSFER-001' WHERE reference=?",[$transfer['reference']]);
$transferPayment=['status'=>'success','reference'=>$transfer['reference'],'amount'=>(int)$transfer['amount_kobo'],'currency'=>'NGN'];
rejects(fn()=>confirmPayment($db,$c,$transfer['reference'],$transferPayment,'1',['amount_kobo'=>1]),'Reject wrong reconciled bank amount');
check(confirmPayment($db,$c,$transfer['reference'],$transferPayment,'1',['amount_kobo'=>(int)$transfer['amount_kobo']]),'Finance reconciliation confirms exact credit');
$again=register($db,$c,['payer_name'=>'Duplicate Bank','payer_email'=>'duplicate@example.test','payer_phone'=>'08000000005','consent'=>true,'delegates'=>[['name'=>'Duplicate Delegate']]]);
query($db,"UPDATE natcon_orders SET status='awaiting_review',bank_reference='GATE-TRANSFER-001' WHERE reference=?",[$again['reference']]);
$againPayment=['status'=>'success','reference'=>$again['reference'],'amount'=>(int)$again['amount_kobo'],'currency'=>'NGN'];
rejects(fn()=>confirmPayment($db,$c,$again['reference'],$againPayment,'1',['amount_kobo'=>(int)$again['amount_kobo']]),'Reject reused bank transaction');
recover($db,$c,'transfer@example.test');
check((int)query($db,"SELECT COUNT(*) FROM natcon_outbox WHERE recipient='transfer@example.test'")->fetchColumn()>=2,'Paid ticket recovery is queued');
echo "PASS $checks backend gate assertions\n";

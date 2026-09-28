<?php
declare(strict_types=1);
require __DIR__.'/bootstrap.php';
use function Natcon\{config,database,migrate,query,now,audit};
if(PHP_SAPI!=='cli'){http_response_code(404);exit;}
$c=config();$db=database($c);$command=$argv[1]??'help';
try{
if($command==='migrate'){migrate($db);echo "NATCON tables are ready. Existing script tables were not changed.\n";}
elseif($command==='staff'){
    $email=strtolower($argv[2]??'');$role=$argv[3]??'registrar';$name=$argv[4]??'NATCON staff';$password=getenv('NATCON_STAFF_PASSWORD')?:'';
    if(!$password){fwrite(STDOUT,"Password (stdin; terminal may echo): ");$password=trim(fgets(STDIN));}
    if(!filter_var($email,FILTER_VALIDATE_EMAIL)||strlen($password)<12||!in_array($role,['admin','finance','registrar'],true))throw new RuntimeException('Valid email, role, and password of at least 12 characters required.');
    query($db,'INSERT INTO natcon_staff(name,email,password_hash,role) VALUES(?,?,?,?)',[$name,$email,password_hash($password,PASSWORD_DEFAULT),$role]);echo "Staff account created.\n";
}elseif($command==='mail'){
    $from=getenv('NATCON_MAIL_FROM')?:'';if(!filter_var($from,FILTER_VALIDATE_EMAIL))throw new RuntimeException('Set NATCON_MAIL_FROM and configure PHP SMTP/sendmail before dispatch.');
    // Claim each message before delivery. Failed messages retry on a subsequent run.
    $rows=query($db,"SELECT * FROM natcon_outbox WHERE status='pending' AND attempts<5 ORDER BY id LIMIT 100")->fetchAll();$sent=0;$failed=0;
    foreach($rows as $row){if(!query($db,"UPDATE natcon_outbox SET status='sending',attempts=attempts+1 WHERE id=? AND status='pending'",[$row['id']])->rowCount())continue;
        $ok=mail($row['recipient'],$row['subject'],$row['body'],['From'=>$from,'Content-Type'=>'text/plain; charset=UTF-8']);
        query($db,'UPDATE natcon_outbox SET status=?,sent_at=? WHERE id=?',[$ok?'sent':'pending',$ok?now():null,$row['id']]);$ok?$sent++:$failed++;
    }audit($db,'cli','mail_dispatch','',['sent'=>$sent,'failed'=>$failed]);echo json_encode(['sent'=>$sent,'failed'=>$failed])."\n";
}else echo "Commands: migrate | staff email role name (NATCON_STAFF_PASSWORD env or stdin) | mail\n";
}catch(Throwable $e){fwrite(STDERR,$e->getMessage()."\n");exit(1);}

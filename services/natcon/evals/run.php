<?php
declare(strict_types=1);
require dirname(__DIR__).'/bootstrap.php';
use function Natcon\{config,migrate,register,confirmPayment,order,checkin,event};
$pass=0;$total=0;$failures=[];
foreach([1,2,10,50] as $size)foreach(['2026-09-30','2026-10-01','2026-10-02','2026-10-03','2026-10-04','2026-10-05'] as $date){
    $total++;try{
        $db=new PDO('sqlite::memory:',null,null,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);migrate($db);$c=config();$o=register($db,$c,['payer_name'=>'Adebayo Ọlá','payer_email'=>'test@example.test','payer_phone'=>'08000000000','consent'=>true,'delegates'=>array_fill(0,$size,['name'=>'Delegate <script> & Ọlá'])]);
        confirmPayment($db,$c,$o['reference'],['reference'=>$o['reference'],'status'=>'success','currency'=>'NGN','amount'=>event($c)['price_kobo']*$size]);$o=order($db,$o['reference'],$o['access_token']);
        if(count(array_unique(array_column($o['delegates'],'ticket_token')))!==$size)throw new RuntimeException('Ticket collision');
        $allowed=$date>='2026-10-01'&&$date<='2026-10-04';$accepted=false;
        try{$result=checkin($db,$c,$o['delegates'][0]['ticket_token'],'arrival',1,$date);$accepted=$result['result']==='accepted';}catch(InvalidArgumentException $e){}
        if($accepted!==$allowed)throw new RuntimeException('Wrong date policy');$pass++;
    }catch(Throwable $e){$failures[]=['size'=>$size,'date'=>$date,'error'=>$e->getMessage()];}
}
echo json_encode(['passed'=>$pass,'total'=>$total,'score'=>$pass/$total,'threshold'=>1,'failures'=>$failures],JSON_PRETTY_PRINT)."\n";exit($pass===$total?0:1);

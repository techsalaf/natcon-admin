<?php
require_once dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
$uid = $data['uid'];
$cat_id = $data['cat_id'];
if ($uid == '' || $cat_id == '') {
$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Something Went wrong  try again !");
} else {
$pop = array();
$event = $evmulti->query(
"select id,title,img,place_name,sdate,stime,etime from tbl_event
where event_status='Pending'
and status=1
and cid=".$cat_id."
 order by sdate desc"
);
$ev = array();
while ($row = $event->fetch_assoc()) {
$ev['event_id'] = $row['id'];
$ev['event_title'] = $row['title'];
$ev['event_img'] = $row['img'];
$date=date_create($row['sdate']);
$ev['event_sdate'] = date_format($date,"D ,M d").'-'
                 .date("g:i A", strtotime($row['stime'])).' TO '.date("g:i A", strtotime($row['etime'])) ;
$ev['event_place_name'] = $row['place_name'];
$pop[] = $ev;
}
if (empty($pop)) {
$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Search Data Not Get!!","CatEventData"=>[]);
} else {
$returnArr = array("ResponseCode"=>"200",
"Result"=>"true",
"ResponseMsg"=>"Search Data Get Successfully!",
"CatEventData"=>$pop);
}

}
echo json_encode($returnArr);

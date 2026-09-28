<?php
require_once dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require_once dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['event_id'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
$event_id = $data['event_id'];
$user = $evmulti->query("
    SELECT uid,total_ticket,type
    FROM `tbl_ticket`
    where eid=".$event_id."
    and ticket_type!='Cancelled'"
);
$po = array();
$uo = array();
while ($row = $user->fetch_assoc()) {
$udata = $evmulti->query("SELECT pro_pic,name FROM `tbl_user` where id=".$row['uid']."")->fetch_assoc();
$po['user_img'] = empty($udata['pro_pic']) ? 'images/user.png' : $udata['pro_pic'];
$po['customername'] = $udata['name'];
$po['Total_ticket_purchase'] = $row['total_ticket'];
$po['Total_type'] = $row['type'];
$uo[] = $po;
}


$returnArr = array(
"JoinedUserdata"=>empty($uo) ? [] : $uo,
"ResponseCode" => "200",
 "Result" => "true",
"ResponseMsg" => "Joined User Information Get Successfully!!!"
    );
}
echo json_encode($returnArr);

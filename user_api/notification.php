<?php
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['uid'] == '') {
    $returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Something Went Wrong!");
} else {
    $uid =  $evmulti->real_escape_string($data['uid']);
    $check = $evmulti->query("select * from tbl_notification where uid=".$uid." order by id desc");
    $op = array();
    while ($row = $check->fetch_assoc()) {
        $op[] = $row;
    }
    $returnArr = array(
        "NotificationData"=>$op,
        "ResponseCode"=>"200",
        "Result"=>"true",
        "ResponseMsg"=>"Notification List Get Successfully!!"
    );
}
echo json_encode($returnArr);

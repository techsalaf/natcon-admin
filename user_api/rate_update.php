<?php
require_once dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require_once dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['uid'] == '' || $data['ticket_id'] == '') {
 $returnArr = array("ResponseCode"=>"401",
 "Result"=>"false",
 "ResponseMsg"=>"Something Went Wrong!"
);
} else {
$tid = $evmulti->real_escape_string($data['ticket_id']);
$uid =  $evmulti->real_escape_string($data['uid']);
$total_star = $evmulti->real_escape_string($data['total_star']);
$review_comment = $evmulti->real_escape_string($data['review_comment']);
$check_status = $evmulti->query("select * from tbl_ticket where uid=".$uid." and id=".$tid."")->fetch_assoc();
$table="tbl_ticket";
$field = array('total_star'=>"$total_star",'review_comment'=>"$review_comment",'is_review'=>1);
$where = "where uid=".$uid." and id=".$tid."";
$h = new Event();
$check = $h->evmultiupdateData_Api($field,$table,$where);
$returnArr = array("ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"Ticket  Review Done successfully!");
}
echo json_encode($returnArr);

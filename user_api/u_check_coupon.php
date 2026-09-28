<?php
require_once dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
$uid  = $data['uid'];
$cid  = $data['cid'];
if ($uid == '' || $cid == '') {
$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Something Went Wrong!");
} else {
$getcinfo = $evmulti->query("select * from tbl_coupon where id=".$cid."");
$cinfo = $getcinfo->num_rows;
if ($cinfo !=0) {
$returnArr = array("ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"Coupon Applied Successfully!!");
} else {
$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Coupon Not Exist!!");
}
}
echo json_encode($returnArr);

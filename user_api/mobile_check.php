<?php
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['mobile'] == '' ||  $data['ccode'] == '') {
$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Something Went Wrong!");
} else {
$mobile = strip_tags(mysqli_real_escape_string($evmulti,$data['mobile']));
$ccode    = strip_tags(mysqli_real_escape_string($evmulti, $data['ccode']));
$chek = $evmulti->query("select * from tbl_user where mobile='".$mobile."' and ccode='" . $ccode . "'")->num_rows;

if ($chek != 0) {
$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Already Exist Mobile Number!");
} else {
$returnArr = array("ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"New Number!");
}
}
echo json_encode($returnArr);

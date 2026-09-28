<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");
$sel = $evmulti->query("select * from tbl_payment_list where status =1 ");
$myarray = [];
while ($row = $sel->fetch_assoc()) {
    $myarray[] = $row;
}
$returnArr = [
    "paymentdata" => $myarray,
    "ResponseCode" => "200",
    "Result" => "true",
    "ResponseMsg" => "Payment Gateway List Founded!",
];
echo json_encode($returnArr);

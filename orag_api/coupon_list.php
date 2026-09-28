<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
if ($data["orag_id"] == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $orag_id = $data["orag_id"];

    $vop = [];
    $gal = $evmulti->query(
        "SELECT * FROM `tbl_coupon` where sponsore_id=" . $orag_id . ""
    );
    while ($tog = $gal->fetch_assoc()) {
        $vop[] = $tog;
    }

    $returnArr = [
        "coupondata" => empty($vop) ? [] : $vop,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Coupon List Get Successfully!!!",
    ];
}
echo json_encode($returnArr);


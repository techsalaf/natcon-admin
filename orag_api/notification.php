<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
if ($data["orag_id"] == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $orag_id = $evmulti->real_escape_string($data["orag_id"]);

    $check = $evmulti->query(
        "select * from tbl_snotification where orag_id=" .
            $orag_id .
            " order by id desc"
    );
    $op = [];
    while ($row = $check->fetch_assoc()) {
        $op[] = $row;
    }
    $returnArr = [
        "NotificationData" => $op,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Notification List Get Successfully!!",
    ];
}
echo json_encode($returnArr);

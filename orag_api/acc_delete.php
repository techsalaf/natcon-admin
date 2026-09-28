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
    $table = "tbl_sponsore";
    $field = "status=0";
    $where = "where id=" . $orag_id . "";
    $h = new Event();
    $check = $h->evmultiupdateData_single($field, $table, $where);
    $returnArr = [
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Account Delete Successfully!!",
    ];
}
echo json_encode($returnArr);

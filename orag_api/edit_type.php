<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$status = $data["status"];
$event_id = $data["event_id"];
$etype = $evmulti->real_escape_string($data["etype"]);
$description = $evmulti->real_escape_string($data["description"]);
$price = $data["price"];
$tlimit = $data["tlimit"];
$orag_id = $data["orag_id"];
$record_id = $data["record_id"];

if (
    $status == "" ||
    $orag_id == "" ||
    $event_id == "" ||
    $etype == "" ||
    $price == "" ||
    $tlimit == "" ||
    $record_id == ""
) {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $check_record = $evmulti->query(
        "select * from tbl_type_price where sponsore_id=" .
            $orag_id .
            "  and id=" .
            $record_id .
            ""
    )->num_rows;
    if ($check_record != 0) {
        $table = "tbl_type_price";
        $field = [
            "status" => $status,
            "price" => $price,
            "event_id" => $event_id,
            "tlimit" => $tlimit,
            "type" => $etype,
            "description" => $description,
        ];
        $where = "where id=" . $record_id . " and sponsore_id=" . $orag_id . "";
        $h = new Event();
        $check = $h->evmultiupdateData($field, $table, $where);

        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Type & Price  Update Successfully",
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Type & Price  Update On Your Own !!",
        ];
    }
}

echo json_encode($returnArr);


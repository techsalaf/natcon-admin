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
if (
    $status == "" or
    $orag_id == "" or
    $event_id == "" or
    $etype == "" or
    $price == "" or
    $tlimit == ""
) {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $check_record = $evmulti->query(
        "select * from tbl_event where sponsore_id=" .
            $orag_id .
            "  and id=" .
            $event_id .
            ""
    )->num_rows;
    if ($check_record != 0) {
        $table = "tbl_type_price";
        $field_values = [
            "status",
            "event_id",
            "type",
            "price",
            "tlimit",
            "sponsore_id",
            "description",
        ];
        $data_values = [
            "$status",
            "$event_id",
            "$etype",
            "$price",
            "$tlimit",
            "$orag_id",
            "$description",
        ];

        $h = new Event();
        $check = $h->evmultiinsertdata_Api($field_values, $data_values, $table);
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Type & Price  Add Successfully",
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Event Not Found!!!",
        ];
    }
}

echo json_encode($returnArr);


<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

$status = $data["status"];
$event_id = $evmulti->real_escape_string($data["event_id"]);
$orag_id = $data["orag_id"];
$record_id = $data["record_id"];
if ($orag_id == "" || $status == "" || $event_id == "" || $record_id == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $check_owner = $evmulti->query(
        "select * from tbl_event where id=" .
            $event_id .
            " and sponsore_id=" .
            $orag_id .
            ""
    )->num_rows;
    if ($check_owner != 0) {
        $check_record = $evmulti->query(
            "select * from tbl_cover where eid=" .
                $event_id .
                " and sponsore_id=" .
                $orag_id .
                " and id=" .
                $record_id .
                ""
        )->num_rows;
        if ($check_record != 0) {
            if ($data["img"] == "0") {
                $table = "tbl_cover";
                $field = ["status" => $status, "eid" => $event_id];
                $where = "where id=" . $record_id . "";
                $h = new Event();
                $check = $h->evmultiupdateData_Api($field, $table, $where);
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "ResponseMsg" => "Cover Image Update Successfully",
                ];
            } else {
                $img = $data["img"];
                $img = str_replace("data:image/png;base64,", "", $img);
                $img = str_replace(" ", "+", $img);
                $datavb = base64_decode($img);
                $path = "images/cover/" . uniqid() . ".png";
                $fname = dirname(dirname(__FILE__)) . "/" . $path;
                file_put_contents($fname, $datavb);
                $table = "tbl_cover";
                $field = [
                    "status" => $status,
                    "img" => $path,
                    "eid" => $event_id,
                ];
                $where = "where id=" . $record_id . "";
                $h = new Event();
                $check = $h->evmultiupdateData_Api($field, $table, $where);
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "ResponseMsg" => "Cover Image Update Successfully",
                ];
            }
        } else {
            $returnArr = [
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" => "Cover Image Update On Your Own!",
            ];
        }
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Cover Image Update On Your Own!!",
        ];
    }
}

echo json_encode($returnArr);


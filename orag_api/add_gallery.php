<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

$status = $data["status"];
$orag_id = $evmulti->real_escape_string($data["orag_id"]);
$event_id = $data["event_id"];
if ($status == "" or $orag_id == "" or $event_id == "") {
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
        $img = $data["img"];
        $img = str_replace("data:image/png;base64,", "", $img);
        $img = str_replace(" ", "+", $img);
        $datavb = base64_decode($img);
        $path = "images/gallery/" . uniqid() . ".png";
        $fname = dirname(dirname(__FILE__)) . "/" . $path;
        file_put_contents($fname, $datavb);
        $table = "tbl_gallery";
        $field_values = ["img", "status", "sponsore_id", "eid"];
        $data_values = ["$path", "$status", "$orag_id", "$event_id"];

        $h = new Event();
        $check = $h->evmultiinsertdata_Api($field_values, $data_values, $table);
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Gallery Image Add Successfully",
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


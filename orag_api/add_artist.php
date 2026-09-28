<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

$status = $data["status"];
$orag_id = $evmulti->real_escape_string($data["orag_id"]);
$title = $evmulti->real_escape_string($data["artist_name"]);
$arole = $evmulti->real_escape_string($data["artist_role"]);
$event_id = $data["event_id"];
if (
    $status == "" ||
    $orag_id == "" ||
    $event_id == "" ||
    $title == "" ||
    $arole == ""
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
        $img = $data["img"];
        $img = str_replace("data:image/png;base64,", "", $img);
        $img = str_replace(" ", "+", $img);
        $datavb = base64_decode($img);
        $path = "images/artist/" . uniqid() . ".png";
        $fname = dirname(dirname(__FILE__)) . "/" . $path;
        file_put_contents($fname, $datavb);

        $table = "tbl_artist";
        $field_values = [
            "img",
            "status",
            "sponsore_id",
            "eid",
            "arole",
            "title",
        ];
        $data_values = [
            "$path",
            "$status",
            "$orag_id",
            "$event_id",
            "$arole",
            "$title",
        ];

        $h = new Event();
        $check = $h->evmultiinsertdata_Api($field_values, $data_values, $table);
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Artist  Add Successfully",
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


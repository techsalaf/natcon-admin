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

    $pol = [];
    $c = [];
    $gal = $evmulti->query(
        "SELECT * FROM `tbl_event` where sponsore_id=" .
            $orag_id .
            " and event_status='Pending' order by id desc"
    );
    while ($row = $gal->fetch_assoc()) {
        $pol["event_id"] = $row["id"];
        $pol["event_title"] = $row["title"];
        $c[] = $pol;
    }

    $returnArr = [
        "GeneralEventdata" => empty($c) ? [] : $c,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Event Get Successfully!!!",
    ];
}
echo json_encode($returnArr);


<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";

header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$orag_id = $data["orag_id"];
if ($orag_id == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $pol = [];
    $c = [];
    $eventlist = $evmulti
        ->query(
            "SELECT GROUP_CONCAT(`id`) as event_id FROM `tbl_event` WHERE sponsore_id=" .
                $orag_id .
                " and (event_status='Completed' or event_status='Cancelled')"
        )
        ->fetch_assoc();
        $event_id = $eventlist["event_id"] ?? 0;
    $sel = $evmulti->query(
        "SELECT * FROM `tbl_cover` where sponsore_id=" .
            $orag_id .
            " and eid NOT IN (" .
            $event_id .
            ")"
    );
    while ($row = $sel->fetch_assoc()) {
        $pol["id"] = $row["id"];
        $type = $evmulti
            ->query("select title from tbl_event where id=" . $row["eid"] . "")
            ->fetch_assoc();
        $pol["event_title"] = $type["title"];
        $pol["event_id"] = $row["eid"];
        $pol["image"] = $row["img"];

        $pol["status"] = $row["status"];

        $c[] = $pol;
    }
    if (empty($c)) {
        $returnArr = [
            "extralist" => [],
            "ResponseCode" => "200",
            "Result" => "false",
            "ResponseMsg" => "Cover Image List Not Founded!",
        ];
    } else {
        $returnArr = [
            "extralist" => $c,
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Cover Image  List Founded!",
        ];
    }
}
echo json_encode($returnArr);


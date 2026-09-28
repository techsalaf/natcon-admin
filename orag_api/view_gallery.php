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

    $eventlist = $evmulti
        ->query(
            "SELECT GROUP_CONCAT(`id`) as event_id FROM `tbl_event` WHERE sponsore_id=" .
                $orag_id .
                " and (event_status='Completed' or event_status='Cancelled')"
        )
        ->fetch_assoc();
        $event_id = $eventlist["event_id"] ?? 0;
    $pol = [];
    $c = [];
    $gal = $evmulti->query(
        "SELECT * FROM `tbl_gallery` where sponsore_id=" .
            $orag_id .
            " and eid NOT IN (" .
            $event_id .
            ")"
    );
    while ($row = $gal->fetch_assoc()) {
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

    $returnArr = [
        "gallerydata" => empty($c) ? [] : $c,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Gallery Photos Get Successfully!!!",
    ];
}
echo json_encode($returnArr);


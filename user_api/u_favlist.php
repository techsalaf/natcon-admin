<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$uid = $data["uid"];
if ($uid == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went wrong  try again !",
    ];
} else {
    $pop = [];
    $favlist = $evmulti
        ->query(
            "SELECT GROUP_CONCAT(`eid`) as fav_event FROM `tbl_fav` WHERE uid=" .
                $uid .
                ""
        )
        ->fetch_assoc();
    if (empty($favlist["fav_event"])) {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Favourite Event Data Not Get!!",
            "FavEventData" => [],
        ];
    } else {
        $event = $evmulti->query(
            "select id,title,img,place_name,sdate,stime,etime from tbl_event
where event_status='Pending'
and status=1
and id IN(" .
                $favlist["fav_event"] .
                ") order by sdate desc"
        );
        $ev = [];
        while ($row = $event->fetch_assoc()) {
            $ev["event_id"] = $row["id"];
            $ev["event_title"] = $row["title"];
            $ev["event_img"] = $row["img"];
            $date = date_create($row["sdate"]);
            $ev["event_sdate"] =
                date_format($date, "D ,M d") .
                "-" .
                date("g:i A", strtotime($row["stime"])) .
                " TO " .
                date("g:i A", strtotime($row["etime"]));
            $ev["event_place_name"] = $row["place_name"];
            $pop[] = $ev;
        }

        if (empty($pop)) {
            $returnArr = [
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" => "Favourite Event Data Not Get!!",
                "FavEventData" => [],
            ];
        } else {
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "ResponseMsg" => "Favourite Event List Get Successfully!",
                "FavEventData" => $pop,
            ];
        }
    }
}
echo json_encode($returnArr);

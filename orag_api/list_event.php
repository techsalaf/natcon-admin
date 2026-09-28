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
        $pol["event_cat_id"] = $row["cid"];
        $ctname = $evmulti
            ->query(
                "SELECT title FROM `tbl_category` where id=" . $row["cid"] . ""
            )
            ->fetch_assoc();
        $pol["event_cat_name"] = $ctname["title"];
        $pol["event_cover_img"] = $row["cover_img"];
        $pol["event_image"] = $row["img"];
        $pol["event_status"] = $row["status"];
        $pol["event_start_date"] = $row["sdate"];
        $pol["event_start_time"] = $row["stime"];
        $pol["event_end_time"] = $row["etime"];
        $pol["event_address"] = $row["address"];
        $pol["event_description"] = $row["description"];
        $pol["event_disclaimer"] = $row["disclaimer"];
        $pol["event_latitude"] = $row["latitude"];
        $pol["event_longtitude"] = $row["longtitude"];
        $pol["event_progress"] = $row["event_status"];
        $pol["event_place_name"] = $row["place_name"];
        $pol["event_facility_id"] = empty($row["facility_id"]) ? "" : $row["facility_id"];
        $pol["event_restict_id"] = empty($row["restict_id"]) ? "" : $row["restict_id"];
        $pol["event_tags"] = empty($row["tags"]) ? "" : $row["tags"];
        $pol["event_vurls"] = empty($row["vurls"]) ? "" : $row["vurls"];
        $c[] = $pol;
    }

    $returnArr = [
        "Eventdata" => empty($c) ? [] : $c,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Event Get Successfully!!!",
    ];
}
echo json_encode($returnArr);


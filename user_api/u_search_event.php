<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$uid = $data["uid"];
$keyword = $data["keyword"];
if ($uid == "" or $keyword == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went wrong  try again !",
    ];
} else {
    $pop = [];

    $event = $evmulti->query(
        "select id,title,img,place_name,sdate,stime,etime
 from tbl_event where event_status='Pending'
  and status=1
   and title COLLATE utf8mb4_general_ci like '%" .
            $keyword .
            "%' order by sdate desc"
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
            "ResponseMsg" => "Search Data Not Get!!",
            "SearchData" => [],
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Search Data Get Successfully!",
            "SearchData" => $pop,
        ];
    }
}
echo json_encode($returnArr);

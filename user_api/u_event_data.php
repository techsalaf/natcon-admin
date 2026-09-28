<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
define('STATUS', ' and status=1');
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$uid = $data["uid"];
$eid = $data["event_id"];
if ($uid == "" || $eid == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went wrong  try again !",
    ];
} else {
    $v = [];
    $g = [];
    $s = [];
    $f = [];
    $r = [];
    $eventlist = $evmulti
        ->query("select * from tbl_event where status=1 and id=" . $eid . "")
        ->fetch_assoc();
    $nav = [];

    $cover_img = [];
    $nav["event_id"] = $eventlist["id"];
    $nav["event_title"] = $eventlist["title"];
    $nav["event_img"] = $eventlist["img"];
    $cover_img[] = $eventlist["cover_img"];
    $check = $evmulti->query(
        "select * from tbl_cover where eid=" . $eid .STATUS
    );
    while ($co = $check->fetch_assoc()) {
        array_push($cover_img, $co["img"]);
    }
    $nav["event_cover_img"] = $cover_img;
    $date = date_create($eventlist["sdate"]);
    $nav["event_sdate"] = date_format($date, "d F, Y");
    $nav["event_time_day"] =
        date_format($date, "l") .
        "," .
        date("g:i A", strtotime($eventlist["stime"])) .
        " TO " .
        date("g:i A", strtotime($eventlist["etime"]));
    $nav["event_address_title"] = $eventlist["place_name"];
    $nav["event_address"] = $eventlist["address"];
    $nav["event_latitude"] = $eventlist["latitude"];
    $nav["event_longtitude"] = $eventlist["longtitude"];
    $nav["event_disclaimer"] = $eventlist["disclaimer"];
    $nav["event_about"] = $eventlist["description"];
    $nav["event_tags"] = empty($eventlist["tags"])
        ? []
        : explode(",", $eventlist["tags"]);
    $nav["event_video_urls"] = empty($eventlist["vurls"])
        ? []
        : explode(",", $eventlist["vurls"]);
    $counter = $evmulti->query(
        "select * from tbl_type_price where event_id=" .
            $eid .
            " order by price "
    )->num_rows;
    if ($counter > 1) {
        $getprice = $evmulti
            ->query(
                "select min(price) as minprice from tbl_type_price
where event_id=" .
                    $eid .
                    ""
            )
            ->fetch_assoc();
        $getprices = $evmulti
            ->query(
                "select max(price) as  maxprice from tbl_type_price
where event_id=" .
                    $eid .
                    ""
            )
            ->fetch_assoc();
        $nav["ticket_price"] =
            $getprice["minprice"] .
            $set["currency"] .
            "-" .
            $getprices["maxprice"] .
            $set["currency"];
    } else {
        $getprice = $evmulti
            ->query(
                "select price from tbl_type_price where event_id=" . $eid . ""
            )
            ->fetch_assoc();
        $nav["ticket_price"] =
            $getprice["price"] == 0
                ? "Free"
                : $getprice["price"] . $set["currency"];
    }
    $nav["IS_BOOKMARK"] = $evmulti->query(
        "select * from tbl_fav
where uid=" .
            $uid .
            "
and eid=" .
            $eventlist["id"] .
            ""
    )->num_rows;
    $sp = $evmulti
        ->query(
            "select * from tbl_sponsore
where id=" .
                $eventlist["sponsore_id"] .
                ""
        )
        ->fetch_assoc();
    $nav["sponsore_id"] = $sp["id"];
    $nav["sponsore_img"] = $sp["img"];
    $nav["sponsore_name"] = $sp["title"];
    $nav["sponsore_mobile"] = $sp["mobile"];
    $gettotal = $evmulti
        ->query(
            "select sum(tlimit) as totalticket from tbl_type_price
where event_id=" .
                $eid .
                ""
        )
        ->fetch_assoc();
    $nav["total_ticket"] = intval($gettotal["totalticket"]);
    $joined = $evmulti->query(
        "select * from tbl_ticket
where uid=" .
            $uid .
            "
and eid=" .
            $eid .
            "
and ticket_type='Booked'"
    )->num_rows;
    if ($joined != 0) {
        $vjoin = 1;
    } else {
        $vjoin = 0;
    }
    $nav["is_joined"] = $vjoin;
    $bn = $evmulti
        ->query(
            "select sum(`total_ticket`) as book_ticket from tbl_ticket
where eid=" .
                $eid .
                "
and ticket_type!='Cancelled'"
        )
        ->fetch_assoc();
    $bookticket = empty($bn["book_ticket"]) ? 0 : $bn["book_ticket"];
    $nav["total_book_ticket"] = intval($bookticket);
    $ulist = $evmulti->query(
        "SELECT DISTINCT uid,eid FROM `tbl_ticket` WHERE eid=" .
            $eventlist["id"] .
            ""
    );
    $member = [];
    while ($rp = $ulist->fetch_assoc()) {
        $getpic = $evmulti
            ->query("select pro_pic from tbl_user where id=" . $rp["uid"] . "")
            ->fetch_assoc();
        $member[] = empty($getpic["pro_pic"])
            ? "images/user.png"
            : $getpic["pro_pic"];
    }
    $nav["member_list"] = $member;
    $gal = $evmulti->query(
        "select * from tbl_gallery where eid=" . $eid .STATUS
    );
    while ($row = $gal->fetch_assoc()) {
        $g[] = $row["img"];
    }
    $spon = $evmulti->query(
        "select * from tbl_artist where eid=" . $eid .STATUS
    );
    $sponsore = [];
    while ($row = $spon->fetch_assoc()) {
        $sponsore["artist_img"] = $row["img"];
        $sponsore["artist_title"] = $row["title"];
        $sponsore["artist_role"] = $row["arole"];
        $s[] = $sponsore;
    }
    if (!empty($eventlist["facility_id"])) {
        $spon = $evmulti->query(
            "select * from tbl_facility where id IN(" .
                $eventlist["facility_id"] .
                ")"
        );
        $sponsore = [];
        while ($row = $spon->fetch_assoc()) {
            $sponsore["facility_img"] = $row["img"];
            $sponsore["facility_title"] = $row["title"];
            $f[] = $sponsore;
        }
    }
    if (!empty($eventlist["restict_id"])) {
        $spon = $evmulti->query(
            "select * from tbl_restriction where id IN(" .
                $eventlist["restict_id"] .
                ")"
        );
        $sponsore = [];
        while ($row = $spon->fetch_assoc()) {
            $sponsore["restriction_img"] = $row["img"];
            $sponsore["restriction_title"] = $row["title"];
            $r[] = $sponsore;
        }
    }
    $user = $evmulti->query(
        "SELECT uid,total_star,review_comment FROM `tbl_ticket` where eid=" .
            $eid .
            " and is_review=1"
    );
    $po = [];
    $uo = [];
    while ($row = $user->fetch_assoc()) {
        $udata = $evmulti
            ->query(
                "SELECT pro_pic,name,ccode,mobile FROM `tbl_user` where id=" .
                    $row["uid"] .
                    ""
            )
            ->fetch_assoc();
        $po["user_img"] = empty($udata["pro_pic"])
            ? "images/user.png"
            : $udata["pro_pic"];
        $po["customername"] = $udata["name"];
        $po["rate_number"] = $row["total_star"];
        $po["rate_text"] = $row["review_comment"];
        $uo[] = $po;
    }
    $returnArr = [
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Event Data Get Successfully!",
        "EventData" => $nav,
        "Event_gallery" => $g,
        "Event_Artist" => $s,
        "Event_Facility" => $f,
        "Event_Restriction" => $r,
        "reviewdata" => $uo,
    ];
}
echo json_encode($returnArr);

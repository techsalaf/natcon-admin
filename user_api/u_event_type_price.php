<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
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
    $tick = [];
    $ticket = [];
    $getprice = $evmulti->query(
        "select * from tbl_type_price where event_id=" . $eid . ""
    );
    while ($row = $getprice->fetch_assoc()) {
        $tick["typeid"] = $row["id"];
        $tick["ticket_type"] = $row["type"];
        $tick["ticket_price"] = $row["price"];
        $tick["TotalTicket"] = intval($row["tlimit"]);
        $tick["description"] = $row["description"];
        $bn = $evmulti
            ->query(
                "select sum(`total_ticket`) as book_ticket from tbl_ticket where eid=" .
                    $eid .
                    " and typeid=" .
                    $row["id"] .
                    " and ticket_type!='Cancelled'"
            )
            ->fetch_assoc();
        $bookticket = empty($bn["book_ticket"]) ? 0 : $bn["book_ticket"];
        $tick["remainTicket"] = $row["tlimit"] - $bookticket;
        if (!$tick["remainTicket"] <= 0) {
        
            $ticket[] = $tick;
        }
    }
    $returnArr = [
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Event Type & Price Get Successfully!",
        "EventTypePrice" => $ticket,
    ];
}
echo json_encode($returnArr);

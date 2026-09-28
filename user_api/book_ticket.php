<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
define("SELECT_WALLET", "select wallet from tbl_user where id=");
define("CONTENT_TYPE", "Content-Type: application/json; charset=utf-8");
define("ONESIGNAL_URL", "https://onesignal.com/api/v1/notifications");
define("AUTORIZATION", "Authorization: Basic ");
define("ID_WHERE", "where id=");
function generateRandom()
{
    require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
    $sixdigitrandomnumber = "tic_" . bin2hex(random_bytes(14));
    $crefer = $evmulti->query(
        "select * from tbl_ticket where uniq_id='" . $sixdigitrandomnumber . "'"
    )->num_rows;
    if ($crefer != 0) {
        generateRandom();
    } else {
        return $sixdigitrandomnumber;
    }
}

header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$uid = $data["uid"];
$eid = $data["eid"];
$type = $data["type"];
$typeid = $data["typeid"];
$price = $data["price"];
$subtotal = $data["subtotal"];
$couamt = $data["cou_amt"];
$totalticket = $data["total_ticket"];
$totalamt = $data["total_amt"];
$tax = $data["tax"];
$sponsoreid = $data["sponsore_id"];
$wallamt = $data["wall_amt"];
$pmethodid = $data["p_method_id"];
$plimit = $data["plimit"];
$uniqid = generateRandom();
$transactionid = $data["transaction_id"];
$getcommission = $evmulti
    ->query("select commission from tbl_sponsore where id=" . $sponsoreid . "")
    ->fetch_assoc();
$commission = $getcommission["commission"];

if (
    $pmethodid == "" ||
    $transactionid == "" ||
    $typeid == "" ||
    $uid == "" ||
    $tax == "" ||
    $eid == "" ||
    $type == "" ||
    $price == "" ||
    $subtotal == "" ||
    $couamt == "" ||
    $totalticket == "" ||
    $totalamt == "" ||
    $sponsoreid == ""
) {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went wrong  try again !",
    ];
} else {
    $timestamp = date("Y-m-d H:i:s");
    $game = $evmulti
        ->query("select title from tbl_event where id=" . $eid . "")
        ->fetch_assoc();
    $udata = $evmulti
        ->query("select name from tbl_user where id=" . $uid . "")
        ->fetch_assoc();
    $name = $udata["name"];
    $totalticketv = $evmulti
        ->query(
            "SELECT sum(`total_ticket`) as tiketcount FROM `tbl_ticket`
where eid=" .
                $eid .
                "
 and typeid=" .
                $typeid .
                "
and ticket_type='Booked'"
        )
        ->fetch_assoc();
    $joined = empty($totalticketv["tiketcount"])
        ? 0
        : intval($totalticketv["tiketcount"]);
    $remain_ticket = $plimit - $joined;
    $eventstatus = $evmulti->query(
        "select * from tbl_event
where id=" .
            $eid .
            "
and (event_status='Cancelled' or event_status='Completed' or status=0)"
    )->num_rows;
    if ($eventstatus != 0) {
        if ($pmethodid == 11) {
            $returnArr = [
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" =>
                    "We cannot book your tickets because the event has been cancelled, completed, or unpublished!!",
            ];

            $eventtitle = $game["title"];

            $content = [
                "en" =>
                    $name .
                    ', We cannot book your
tickets because the event #' .
                    $eventtitle .
                    '
has been cancelled, completed, or unpublished.',
            ];
            $heading = [
                "en" =>
                    "We cannot book your tickets because the event has been cancelled, completed, or unpublished.",
            ];

            $fields = [
                "app_id" => $set["one_key"],
                "data" => ["event_id" => $eid, "type" => "normal"],
                "filters" => [
                    [
                        "field" => "tag",
                        "key" => "user_id",
                        "relation" => "=",
                        "value" => $uid,
                    ],
                ],
                "contents" => $content,
                "headings" => $heading,
            ];
            $fields = json_encode($fields);
            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, ONESIGNAL_URL);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                CONTENT_TYPE,
                AUTORIZATION . $set["one_hash"],
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            curl_close($ch);
        } else {
            $vp = $evmulti->query(SELECT_WALLET . $uid)->fetch_assoc();

            if ($pmethodid == 3) {
                $totalamts = $wallamt;
            } else {
                $totalamts = $totalamt + $wallamt;
            }

            $mt = floatval($vp["wallet"]) + floatval($totalamts);
            $table = "tbl_user";
            $field = ["wallet" => "$mt"];
            $where = ID_WHERE . $uid;
            $h = new Event();
            $check = $h->evmultiupdateData_Api($field, $table, $where);

            $table = "wallet_report";
            $field_values = ["uid", "message", "status", "amt", "tdate"];
            $data_values = [
                "$uid",
                "Refund Amount To Wallet Which Is Used For Booking Game " .
                $game["title"],
                "Credit",
                "$totalamts",
                "$timestamp",
            ];

            $h = new Event();
            $checks = $h->evmultiinsertdata_Api(
                $field_values,
                $data_values,
                $table
            );
            $returnArr = [
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" =>
                    "Due to the event being cancelled, completed,
or unpublished, we refunded your amount to your wallet!",
            ];
            $eventtitle = $game["title"];

            $content = [
                "en" =>
                    $name .
                    ", Your Booking For Event ID #" .
                    $eventtitle .
                    " Amount Has Been Refund To Wallet.",
            ];
            $heading = [
                "en" =>
                    "Due to the event being cancelled,
completed, or unpublished, we refunded your amount to your wallet!",
            ];

            $fields = [
                "app_id" => $set["one_key"],
                "data" => ["event_id" => $eid, "type" => "normal"],
                "filters" => [
                    [
                        "field" => "tag",
                        "key" => "user_id",
                        "relation" => "=",
                        "value" => $uid,
                    ],
                ],
                "contents" => $content,
                "headings" => $heading,
            ];
            $fields = json_encode($fields);

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, ONESIGNAL_URL);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                CONTENT_TYPE,
                AUTORIZATION . $set["one_hash"],
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            curl_close($ch);

            $title_mains =
                "Your Booking For Event #" .
                $eventtitle .
                " Amount Has Been Refund To Wallet!!";
            $descriptions =
                "Due to the event being cancelled, completed, or unpublished, we refunded your amount to your wallet.!";

            $table = "tbl_notification";
            $field_values = ["uid", "datetime", "title", "description"];
            $data_values = [
                "$uid",
                "$timestamp",
                "$title_mains",
                "$descriptions",
            ];

            $h = new Event();
            $h->evmultiinsertdata_Api($field_values, $data_values, $table);
        }
    } elseif ($remain_ticket < $totalticket) {
        if ($pmethodid == 11) {
            $returnArr = [
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" =>
                    "Free Ticket Slot As You Asked Not Availble Please Refresh And Check Availble Seats!!",
            ];
            $eventtitle = $game["title"];
            $content = [
                "en" =>
                    $name .
                    ", Your Booking For Event #" .
                    $eventtitle .
                    " Slot Not Availble Please Check Again How Many There.",
            ];
            $heading = [
                "en" =>
                    "Free Ticket Slot As You Asked Not Availble Please Refresh And Check Availble Seats!!",
            ];

            $fields = [
                "app_id" => $set["one_key"],
                "data" => ["event_id" => $eid, "type" => "normal"],
                "filters" => [
                    [
                        "field" => "tag",
                        "key" => "user_id",
                        "relation" => "=",
                        "value" => $uid,
                    ],
                ],
                "contents" => $content,
                "headings" => $heading,
            ];
            $fields = json_encode($fields);

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, ONESIGNAL_URL);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                CONTENT_TYPE,
                AUTORIZATION . $set["one_hash"],
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            $response = curl_exec($ch);
            curl_close($ch);
        } else {
            $vp = $evmulti->query(SELECT_WALLET . $uid)->fetch_assoc();
            if ($pmethodid == 3) {
                $totalamts = $wallamt;
            } else {
                $totalamts = $totalamt + $wallamt;
            }

            $mt = floatval($vp["wallet"]) + floatval($totalamts);
            $table = "tbl_user";
            $field = ["wallet" => "$mt"];
            $where = ID_WHERE . $uid;
            $h = new Event();
            $check = $h->evmultiupdateData_Api($field, $table, $where);

            $table = "wallet_report";
            $field_values = ["uid", "message", "status", "amt", "tdate"];
            $data_values = [
                "$uid",
                "Refund Amount To Wallet Which Is Used For Booking Event " .
                $game["title"],
                "Credit",
                "$totalamts",
                "$timestamp",
            ];

            $h = new Event();
            $checks = $h->evmultiinsertdata_Api(
                $field_values,
                $data_values,
                $table
            );
            $returnArr = [
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" => "We regret to inform you that we are unable to book your tickets
for the selected range, as there is no availability at this time.
Therefore, we will process a full refund of the ticket amount back to your wallet!",
            ];
            $eventtitle = $game["title"];

            $content = [
                "en" =>
                    $name .
                    ", Your Booking For Event #" .
                    $eventtitle .
                    " Amount Has Been Refund To Wallet.",
            ];
            $heading = [
                "en" =>
                    "Your Total Ticket Not Able To Booking That
Range Of slot Not Availble So We Refund Amount To Wallet!",
            ];

            $fields = [
                "app_id" => $set["one_key"],
                "data" => ["event_id" => $eid, "type" => "normal"],
                "filters" => [
                    [
                        "field" => "tag",
                        "key" => "user_id",
                        "relation" => "=",
                        "value" => $uid,
                    ],
                ],
                "contents" => $content,
                "headings" => $heading,
            ];
            $fields = json_encode($fields);

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, ONESIGNAL_URL);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                CONTENT_TYPE,
                AUTORIZATION . $set["one_hash"],
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            curl_close($ch);

            $title_mains =
                "Your Booking For Event #" .
                $eventtitle .
                " Amount Has Been Refund To Wallet!!";
            $descriptions = 'We regret to inform you that we
 are unable to book your tickets for the selected range,
  as there is no availability at this time. Therefore, we will process a full
   refund of the ticket amount back to your wallet!';

            $table = "tbl_notification";
            $field_values = ["uid", "datetime", "title", "description"];
            $data_values = [
                "$uid",
                "$timestamp",
                "$title_mains",
                "$descriptions",
            ];

            $h = new Event();
            $h->evmultiinsertdata_Api($field_values, $data_values, $table);
        }
    } else {
        $vp = $evmulti->query(SELECT_WALLET . $uid)->fetch_assoc();
        if ($vp["wallet"] >= $data["wall_amt"]) {
            $table = "tbl_ticket";
            $field_values = [
                "p_method_id",
                "transaction_id",
                "eid",
                "type",
                "price",
                "subtotal",
                "cou_amt",
                "total_ticket",
                "total_amt",
                "uid",
                "wall_amt",
                "typeid",
                "tax",
                "sponsore_id",
                "commission",
                "book_time",
                "uniq_id",
            ];
            $data_values = [
                "$pmethodid",
                "$transactionid",
                "$eid",
                "$type",
                "$price",
                "$subtotal",
                "$couamt",
                "$totalticket",
                "$totalamt",
                "$uid",
                "$wallamt",
                "$typeid",
                "$tax",
                "$sponsoreid",
                "$commission",
                "$timestamp",
                "$uniqid",
            ];
            $h = new Event();
            $oid = $h->evmultiinsertdata_Api_Id(
                $field_values,
                $data_values,
                $table
            );

            if ($wallamt != 0) {
                $mt = intval($vp["wallet"]) - intval($wallamt);
                $table = "tbl_user";
                $field = ["wallet" => "$mt"];
                $where = ID_WHERE . $uid;
                $h = new Event();
                $check = $h->evmultiupdateData_Api($field, $table, $where);

                $table = "wallet_report";
                $field_values = ["uid", "message", "status", "amt", "tdate"];
                $data_values = [
                    "$uid",
                    "Wallet Used in Booking Id#" . $oid,
                    "Debit",
                    "$wallamt",
                    "$timestamp",
                ];

                $h = new Event();
                $checks = $h->evmultiinsertdata_Api(
                    $field_values,
                    $data_values,
                    $table
                );
            }

            $content = [
                "en" =>
                    $name . ", Your Ticket Booking #" . $oid . " Successfully.",
            ];
            $heading = [
                "en" => "Book Ticket Successfully!!",
            ];

            $fields = [
                "app_id" => $set["one_key"],
                "included_segments" => ["Active Users"],
                "data" => ["order_id" => $oid, "type" => "normal"],
                "filters" => [
                    [
                        "field" => "tag",
                        "key" => "user_id",
                        "relation" => "=",
                        "value" => $uid,
                    ],
                ],
                "contents" => $content,
                "headings" => $heading,
            ];
            $fields = json_encode($fields);

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, ONESIGNAL_URL);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                CONTENT_TYPE,
                AUTORIZATION . $set["one_hash"],
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            curl_close($ch);
            $content = [
                "en" => "Ticket Booking Event #" . $eid . " Received.",
            ];
            $heading = [
                "en" => "Event Book Ticket Received!!",
            ];

            $fields = [
                "app_id" => $set["s_key"],
                "included_segments" => ["Active Users"],
                "data" => ["order_id" => $oid, "type" => "normal"],
                "filters" => [
                    [
                        "field" => "tag",
                        "key" => "orag_id",
                        "relation" => "=",
                        "value" => $sponsoreid,
                    ],
                ],
                "contents" => $content,
                "headings" => $heading,
            ];
            $fields = json_encode($fields);

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, ONESIGNAL_URL);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                CONTENT_TYPE,
                AUTORIZATION . $set["s_hash"],
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            curl_close($ch);

            $title_mains = "Book Ticket Successfully!!";
            $descriptions = "Book Ticket #" . $oid . " Successfully.";

            $table = "tbl_notification";
            $field_values = ["uid", "datetime", "title", "description"];
            $data_values = [
                "$uid",
                "$timestamp",
                "$title_mains",
                "$descriptions",
            ];

            $h = new Event();
            $h->evmultiinsertdata_Api($field_values, $data_values, $table);

            $title_mains = "Book Ticket Received!!";
            $descriptions = "Book Ticket Event#" . $eid . " Received.";

            $table = "tbl_snotification";
            $field_values = ["orag_id", "datetime", "title", "description"];
            $data_values = [
                "$sponsoreid",
                "$timestamp",
                "$title_mains",
                "$descriptions",
            ];

            $h = new Event();
            $h->evmultiinsertdata_Api($field_values, $data_values, $table);

            $tbwallet = $evmulti->query(SELECT_WALLET . $uid)->fetch_assoc();
            if ($totalticket == 1) {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "ResponseMsg" => "Book Ticket Successfully!!!",
                    "wallet" => $tbwallet["wallet"],
                    "order_id" => $oid,
                ];
            } else {
                $returnArr = [
                    "ResponseCode" => "200",
                    "Result" => "true",
                    "ResponseMsg" => "Book Tickets Successfully!!!",
                    "wallet" => $tbwallet["wallet"],
                    "order_id" => $oid,
                ];
            }
        } else {
            $tbwallet = $evmulti->query(SELECT_WALLET . $uid)->fetch_assoc();
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "false",
                "ResponseMsg" =>
                    "Wallet Balance Not There As Per Booking Refresh One Time Screen!!!",
                "wallet" => $tbwallet["wallet"],
            ];
        }
    }
}

echo json_encode($returnArr);

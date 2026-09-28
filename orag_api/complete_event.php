<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
if ($data["event_id"] == "" || $data["orag_id"] == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $event_id = $data["event_id"];
    $orag_id = $data["orag_id"];

    $check_owner = $evmulti->query(
        "select * from tbl_event where sponsore_id=" .
            $orag_id .
            " and id=" .
            $event_id .
            ""
    )->num_rows;
    if ($check_owner != 0) {
        $table = "tbl_event";
        $field = "event_status='Completed'";
        $where = "where id=" . $event_id . "";
        $h = new Event();
        $check = $h->evmultiupdateData_single($field, $table, $where);

        $table = "tbl_ticket";
        $field = "ticket_type='Completed'";
        $where = "where eid=" . $event_id . " and ticket_type='Booked'";
        $h = new Event();
        $h->evmultiupdateData_single($field, $table, $where);

        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Event Successfully Completed!",
        ];

        $a = $evmulti->query(
            "SELECT uid,id FROM `tbl_ticket` where eid=" .
                $event_id .
                " and is_verify=1"
        );
        while ($row = $a->fetch_assoc()) {
            $uid = $row["uid"];

            $udata = $evmulti
                ->query("select name from tbl_user where id=" . $uid . "")
                ->fetch_assoc();
            $name = $udata["name"];

            $content = [
                "en" =>
                    $name .
                    ", Your Joined Event #" .
                    $event_id .
                    " Has Been Completed.",
            ];
            $heading = [
                "en" => "Event Completed. Now Provide Review About Event!!",
            ];

            $fields = [
                "app_id" => $set["one_key"],
                "included_segments" => ["Active Users"],
                "data" => ["event_id" => $event_id, "status" => "Completed"],
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
            curl_setopt(
                $ch,
                CURLOPT_URL,
                "https://onesignal.com/api/v1/notifications"
            );
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                "Content-Type: application/json; charset=utf-8",
                "Authorization: Basic " . $set["one_hash"],
            ]);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HEADER, false);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            curl_close($ch);

            $timestamp = date("Y-m-d H:i:s");

            $title_mains = "Event Completed!!";
            $descriptions = "Event ID #" . $event_id . " Has Been Completed.";

            $table = "tbl_notification";
            $field_values = ["uid", "datetime", "title", "description"];
            $data_values = [
                "$uid",
                "$timestamp",
                "$title_mains",
                "$descriptions",
            ];

            $h = new Eventmania();
            $h->eventinsertdata_Api($field_values, $data_values, $table);
        }
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "You are Not Owner Of This Event!!",
        ];
    }
}
echo json_encode($returnArr);

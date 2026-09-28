<?php
require_once dirname(__DIR__) . '/filemanager/evconfing.php';
require_once dirname(__DIR__) . '/filemanager/event.php';

header('Content-type: application/json');

$data = json_decode(file_get_contents('php://input'), true);

if (empty($data['orag_id']) || empty($data['status'])) {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    );
} else {
    $status = $data['status'];
    $orag_id = $data['orag_id'];
    $date = date("Y-m-d");
    $events = array();

    if ($status == 'Today') {
$sel = $evmulti->query("
SELECT *
FROM tbl_event
WHERE sponsore_id = {$orag_id}
AND event_status = 'Pending'
AND sdate = '{$date}'
ORDER BY id DESC
");
} elseif ($status == 'Upcoming') {
        $sel = $evmulti->query("
SELECT *
FROM tbl_event
WHERE sponsore_id = {$orag_id}
AND event_status = 'Pending'
AND sdate > '{$date}'
ORDER BY id DESC
");
    } else {
        $sel = $evmulti->query("
SELECT *
FROM tbl_event
WHERE sponsore_id = {$orag_id}
AND (event_status = 'Completed' OR event_status = 'Cancelled')
ORDER BY id DESC"
);
    }

    if ($sel->num_rows > 0) {
        while ($row = $sel->fetch_assoc()) {
            $event = array();
            $event['event_id'] = $row['id'];
            $event['event_title'] = $row['title'];
            $event['event_img'] = $row['img'];
            $date = date_create($row['sdate']);
            $event['event_sdate'] = date_format($date, "d F");
            $event['event_place_name'] = $row['place_name'];
            $events[] = $event;
        }

        $returnArr = array(
            "order_data" => $events,
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Events Get successfully!",
        );
    } else {
        if ($status == 'Today') {
            $msg = 'No Today Events Found!';
        } elseif ($status == 'Upcoming') {
            $msg = 'No Upcoming Events Found!';
        } else {
            $msg = 'No Cancelled OR Completed Events Found!!';
        }

        $returnArr = array(
            "order_data" => array(),
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => $msg,
        );
    }
}

echo json_encode($returnArr);

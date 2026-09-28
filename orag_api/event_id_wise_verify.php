<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['ticket_code'] == '' or $data['event_id'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
	$ticket_code = $data['ticket_code'];
	$event_id = $data['event_id'];
	$check_code = $evmulti->query("select * from tbl_ticket where BINARY uniq_id='" . $ticket_code . "' and eid=".$event_id."")->num_rows; 
	if($check_code != 0)
	{
		$fetch_code = $evmulti->query("select sponsore_id,id,uid,eid from tbl_ticket where uniq_id='" . $ticket_code . "' and eid=".$event_id."")->fetch_assoc(); 
	
	$sponsore_id = $fetch_code['sponsore_id'];
	$id = $fetch_code['id'];
	$uid = $fetch_code['uid'];
	$date = date("Y-m-d");
	$check_verify = $evmulti->query("select * from tbl_ticket where sponsore_id=" . $sponsore_id . " and id=".$id." and uid=".$uid." and eid=".$event_id." and is_verify=1")->num_rows;
	$check_start_or_not = $evmulti->query("select * from tbl_event where sdate='" . $date . "' and id=".$event_id."")->num_rows;
	if($check_start_or_not !=0)
	{
	if($check_verify != 0)
	{
		$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Ticket Already Verified!!"
    );
	}
	else 
	{
	$table = "tbl_ticket";
            $field = "is_verify=1";
            $where = "where sponsore_id=" . $sponsore_id . " and id=".$id." and uid=".$uid." and eid=".$event_id."";
            $h = new Event();
            $check = $h->evmultiupdateData_single($field, $table, $where);
			
			$returnArr = array(
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Ticket Verify Successfully!!"
        );
	}
	}
	else 
	{
		$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Event Date Not Today Check On Ticket Event Date!!"
    );
	}
	}
	else 
	{
		$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Unique Code Not Found!!"
    );
			}
}
echo json_encode($returnArr);
?>
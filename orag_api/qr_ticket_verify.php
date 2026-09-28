<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['orag_id'] == '' or $data['ticket_id'] == '' or $data['uid'] == '' or $data['event_id'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
	$sponsore_id = $data['orag_id'];
	$id = $data['ticket_id'];
	$uid = $data['uid'];
	$event_id = $data['event_id'];
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
		$count = $evmulti->query("select * from tbl_ticket where sponsore_id=" . $sponsore_id . " and id=".$id." and uid=".$uid." and eid=".$event_id."")->num_rows;
	if($count != 0)
	{
		$count_pen = $evmulti->query("select * from tbl_ticket where sponsore_id=" . $sponsore_id . " and id=".$id." and uid=".$uid." and eid=".$event_id." and event_status='Pending'")->num_rows;
		
		if($count_pen != 0)
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
		else 
		{
		$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Ticket Already Completed or Cancelled!!");	
		}
	}
	else 
	{
		$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Ticket Not Found!!");
	}
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
echo json_encode($returnArr);
?>
<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if($data['uid'] == '' or $data['ticket_id'] == '' or $data['cancle_comment'] == '')
{
 $returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Something Went Wrong!");    
}
else
{
	 $tid = $evmulti->real_escape_string($data['ticket_id']);
 $uid =  $evmulti->real_escape_string($data['uid']);
 $cancle_comment = $evmulti->real_escape_string($data['cancle_comment']);
 
 $check_status = $evmulti->query("select * from tbl_ticket where uid=".$uid." and id=".$tid."")->fetch_assoc();
 if($check_status['ticket_type'] == 'Cancelled')
 {
	 $returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Already Cancelled Ticket!");    
 }
 else 
 {
	 $timestamp = date("Y-m-d H:i:s");
	$to_time = strtotime($check_status['book_time']);
    $from_time = strtotime($timestamp);
	$gonmin = round(abs($to_time - $from_time) / 60,2);
	if($gonmin < 10)
	{
 $table="tbl_ticket";
  $field = array('ticket_type'=>'Cancelled','cancle_comment'=>"$cancle_comment");
  $where = "where uid=".$uid." and id=".$tid."";
$h = new Event();
	  $check = $h->evmultiupdateData_Api($field,$table,$where);
 $returnArr = array("ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"Ticket  Cancelled successfully!");
 
 $a = $evmulti->query("SELECT total_amt,eid,wall_amt,p_method_id,price FROM `tbl_ticket` where id=".$tid."")->fetch_assoc();
 $eid = $a['eid'];
 
 if($a['p_method_id'] == 11)
 {
	 
 }
else 
{
 if($a['p_method_id'] == 3)
	{
		$total_amt = $a['wall_amt'];
	}
	else {
		
	$total_amt = $a['total_amt']+$a['wall_amt'];
	}
	
	$vp = $evmulti->query("select wallet from tbl_user where id=".$uid."")->fetch_assoc();
	$mt = floatval($vp['wallet']) + floatval($total_amt);
  $table="tbl_user";
  $field = array('wallet'=>"$mt");
  $where = "where id=".$uid."";
$h = new Event();
	  $check = $h->evmultiupdateData_Api($field,$table,$where);
	  $timestamp = date("Y-m-d H:i:s");
	  $game = $evmulti->query("select title from tbl_event where id=".$eid."")->fetch_assoc();
	  $table="wallet_report";
  $field_values=array("uid","message","status","amt","tdate");
  $data_values=array("$uid",'Refund Amount To Wallet Which Is Used For Booking Event '.$game['title'],'Credit',"$total_amt","$timestamp");
   
      $h = new Event();
	  $checks = $h->evmultiinsertdata_Api($field_values,$data_values,$table);
	
}
	}
	else 
	{
	$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"After 10 Min Not Able To Cancelled Tickets!!");    	
	}
 }
}
echo json_encode($returnArr);
?>
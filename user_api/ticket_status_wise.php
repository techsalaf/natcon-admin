<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if($data['uid'] == '' or $data['status'] == '')
{ 
 $returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Something Went Wrong!");    
}
else
{	
 $uid =  strip_tags(mysqli_real_escape_string($evmulti,$data['uid']));
 $status = $data['status'];
 if($status == 'Active')
 {
  $sel = $evmulti->query("select * from tbl_ticket where uid=".$uid." and ticket_type ='Booked' order by id desc");
 }
 else 
 {
	 $sel = $evmulti->query("select * from tbl_ticket where uid=".$uid." and (ticket_type ='Completed' or ticket_type ='Cancelled') order by id desc");
 }
  if($sel->num_rows != 0)
  {
  $nav = array();
  $v = array();
  while($row = $sel->fetch_assoc())
    {
	$getevent = $evmulti->query("select * from tbl_event where id=".$row['eid']."")->fetch_assoc();
	$nav['event_id'] = $getevent['id'];
	$nav['event_title'] = $getevent['title'];
	$nav['event_img'] = $getevent['img'];
	$date=date_create($getevent['sdate']);
	$nav['event_sdate'] = date_format($date,"d F");
	$nav['event_place_name'] = $getevent['place_name'];
	$nav['ticket_id'] = $row['id'];
	$nav['total_ticket'] = $row['total_ticket'];
	$nav['ticket_type'] = $row['type'];
	$nav['ticket_status'] = $row['ticket_type'];
	$timestamp = date("Y-m-d H:i:s");
	$to_time = strtotime($row['book_time']);
    $from_time = strtotime($timestamp);
    $nav['book_mintues'] = round(abs($to_time - $from_time) / 60,2);
	$v[] = $nav;
	}
   
   
      
            
    $returnArr = array("order_data"=>$v,"ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"Ticket Get successfully!");
  }
  else 
  {
	  if($status == 'Active')
 {
	$returnArr = array("order_data"=>[],"ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"No Paid Ticket Found!");   
 }
 else 
 {
	 $returnArr = array("order_data"=>[],"ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"No Cancelled OR Completed Ticket Found!");   
 }
  }
}
echo json_encode($returnArr);
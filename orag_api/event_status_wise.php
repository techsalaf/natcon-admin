<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['orag_id'] == '' or $data['status'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
	$status = $data['status'];
	$orag_id = $data['orag_id'];
	$date = date("Y-m-d");
	
	if($status == 'Today')
	{
		$sel = $evmulti->query("select * from tbl_event where sponsore_id=".$orag_id." and event_status ='Pending' and sdate='".$date."' order by id desc");
	}
	else if($status == 'Upcoming')
	{
		
		$sel = $evmulti->query("select * from tbl_event where sponsore_id=".$orag_id." and event_status ='Pending' and sdate >'".$date."' order by id desc");
	}
	else
	{
		$sel = $evmulti->query("select * from tbl_event where sponsore_id=".$orag_id." and (event_status ='Completed' or event_status ='Cancelled')  order by id desc");
	}
	
	if($sel->num_rows != 0)
  {
	  $nav = array();
  $v = array();
  while($row = $sel->fetch_assoc())
    {
	$nav['event_id'] = $row['id'];
	$nav['event_title'] = $row['title'];
	$nav['event_img'] = $row['img'];
	$date=date_create($row['sdate']);
	$nav['event_sdate'] = date_format($date,"d F");
	$nav['event_place_name'] = $row['place_name'];
	$v[] = $nav;
	}
	
	$returnArr = array("order_data"=>$v,"ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"Events Get successfully!");
  }
  else 
  {
	  if($status == 'Today')
 {
	$returnArr = array("order_data"=>[],"ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"No Today Events Found!");   
 }
 else if($status == 'Upcoming')
 {
	 $returnArr = array("order_data"=>[],"ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"No Upcoming Events Found!");   
 }
 else 
 {
	 $returnArr = array("order_data"=>[],"ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"No Cancelled OR Completed Events Found!!");  
 }
  }
}
echo json_encode($returnArr);
?>
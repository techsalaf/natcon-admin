<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['orag_id'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
	
	$orag_id = $data['orag_id'];
	$type = $data['type'];
		
			$pol = array();
$c = array();
			
			if($type == 'SCANNER')
			{
			$gal = $evmulti->query("SELECT * FROM `tbl_omanager` where orag_id=".$orag_id." and manager_type='SCANNER'");
			}
			else if($type == 'MANAGER')
			{
			$gal = $evmulti->query("SELECT * FROM `tbl_omanager` where orag_id=".$orag_id." and manager_type='MANAGER'");
			}
			else 
			{
			$gal = $evmulti->query("SELECT * FROM `tbl_omanager` where orag_id=".$orag_id."");	
			}
			while($row = $gal->fetch_assoc())
			{
		$pol['id'] = $row['id'];
		
		$pol['name'] = $row['name'];
		$pol['manager_type'] = $row['manager_type'];
		$pol['status'] = $row['status'];
				 $pol['email'] = $row['email'];
				 $pol['password'] = $row['password'];
				$c[] = $pol;
			}
			
		
		
		$returnArr = array(
		"Managerdata"=>empty($c) ? [] : $c,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Role List Get Successfully!!!"
    );
}
echo json_encode($returnArr);
?>
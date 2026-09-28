<?php
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
     ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
	$status = $data["status"];
    $orag_id = $evmulti->real_escape_string($data["orag_id"]);
	$name = $evmulti->real_escape_string($data["name"]);
	$email = $evmulti->real_escape_string($data["email"]);
	$password = $evmulti->real_escape_string($data["password"]);
	$manager_type = $data["manager_type"];
	$record_id = $data["record_id"];
	
if ($status == '' or $orag_id == '' or $manager_type == '' or $password == '' or $email == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
	$check_record = $evmulti->query("select * from tbl_omanager where email='" . $email . "' and id!=".$record_id."")->num_rows;
	if($check_record !=0)
{
$returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Email Already Used!!!"
    );
		
}
else 
{
	
	
$table = "tbl_omanager";
                $field = ["status" => $status,"orag_id"=>$orag_id,"manager_type"=>$manager_type,"name"=>$name,"email"=>$email,"password"=>$password];
                $where = "where id=" . $record_id . "";
                $h = new Event();
                $check = $h->evmultiupdateData_Api($field, $table, $where);
				
            
			$returnArr    = array(
                "ResponseCode" => "200",
                "Result" => "true",
                "ResponseMsg" => "Role  Update Successfully"
            );
}	
	}

echo json_encode($returnArr);
?>
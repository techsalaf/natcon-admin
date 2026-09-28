<?php
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
$data = json_decode(file_get_contents('php://input'), true);
header('Content-type: text/json');
if ($data['email'] == '' or $data['password'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
    $email   = strip_tags(mysqli_real_escape_string($evmulti, $data['email']));
    $ccode    = strip_tags(mysqli_real_escape_string($evmulti, $data['ccode']));
    $password = strip_tags(mysqli_real_escape_string($evmulti, $data['password']));
    $type = $data['type'];
	if($type == 'Orgnizer')
	{
    $chek   = $evmulti->query("select * from tbl_sponsore where   email='" . $email . "' and status = 1 and password='" . $password . "'");
    $status = $evmulti->query("select * from tbl_sponsore where status = 1");
    if ($status->num_rows != 0) {
        if ($chek->num_rows != 0) {
            $c = $evmulti->query("select * from tbl_sponsore where  email='" . $email . "' and status = 1 and password='" . $password . "'")->fetch_assoc();
            
            $returnArr = array(
                "OragnizerLogin" => $c,
                "currency" => $set['currency'],
                "ResponseCode" => "200",
                "Result" => "true",
				"Type"=>"Admin",
                "ResponseMsg" => "Login successfully!"
            );
        } else {
            $returnArr = array(
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" => "Invalid Mobile Number Or Email Address or Password!!!"
            );
        }
    } else {
        $returnArr = array(
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Your Status Deactivate!!!"
        );
    }
	}
	else if($type == 'SCANNER')
	{
	$chek   = $evmulti->query("select * from tbl_omanager where   email='" . $email . "' and status = 1 and password='" . $password . "' and manager_type='SCANNER'");
    $status = $evmulti->query("select * from tbl_omanager where status = 1");
    if ($status->num_rows != 0) {
        if ($chek->num_rows != 0) {
            $c = $evmulti->query("select * from tbl_omanager where  email='" . $email . "' and status = 1 and password='" . $password . "' and manager_type='SCANNER'")->fetch_assoc();
            
            $p = array();
            $p["id"] = $c["orag_id"];
            $p["name"] = $c["name"];
            $p["email"] = $c["email"];
            $p["password"] = $c["password"];
            $p["manager_type"] = $c["manager_type"];
            $p["status"] = $c["status"];
            $returnArr = array(
                "OragnizerLogin" => $p,
                "currency" => $set['currency'],
                "ResponseCode" => "200",
                "Result" => "true",
				"Type"=>"SCANNER",
                "ResponseMsg" => "Login successfully!"
            );
        } else {
            $returnArr = array(
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" => "Invalid  Email Address or Password!!!"
            );
        }
    } else {
        $returnArr = array(
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Your Status Deactivate!!!"
        );
    }	
	}
	else 
	{
	$chek   = $evmulti->query("select * from tbl_omanager where   email='" . $email . "' and status = 1 and password='" . $password . "' and manager_type='MANAGER'");
    $status = $evmulti->query("select * from tbl_omanager where status = 1");
    if ($status->num_rows != 0) {
        if ($chek->num_rows != 0) {
            $c = $evmulti->query("select * from tbl_omanager where  email='" . $email . "' and status = 1 and password='" . $password . "' and manager_type='MANAGER'")->fetch_assoc();
            
            $p = array();
            $p["id"] = $c["orag_id"];
            $p["name"] = $c["name"];
            $p["email"] = $c["email"];
            $p["password"] = $c["password"];
            $p["manager_type"] = $c["manager_type"];
            $p["status"] = $c["status"];
            
            $returnArr = array(
                "OragnizerLogin" => $p,
                "currency" => $set['currency'],
                "ResponseCode" => "200",
                "Result" => "true",
				"Type"=>"MANAGER",
                "ResponseMsg" => "Login successfully!"
            );
        } else {
            $returnArr = array(
                "ResponseCode" => "401",
                "Result" => "false",
                "ResponseMsg" => "Invalid  Email Address or Password!!!"
            );
        }
    } else {
        $returnArr = array(
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Your Status Deactivate!!!"
        );
    }	
	}
}

echo json_encode($returnArr);
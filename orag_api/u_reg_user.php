<?php
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);


if ($data['name'] == '' or $data['mobile'] == '' or $data['password'] == '' or $data['ccode'] == '' or $data['email'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
    
	
	$mobile = $data['ccode'].$data['mobile'];
	$email = $data['email'];
	$password = $data['password'];
	$title = $evmulti->real_escape_string($data['name']);
	$img = $data['img'];
    $img = str_replace('data:image/png;base64,', '', $img);
    $img = str_replace(' ', '+', $img);
	$datavb = base64_decode($img);
	$path = 'images/sponsore/'.uniqid().'.png';
	$fname = dirname( dirname(__FILE__) ).'/'.$path;
	file_put_contents($fname, $datavb);
	$chek = $evmulti->query("select * from tbl_sponsore where email='".$email."'")->num_rows;
	if($chek!=0)
	{
		$returnArr = array("ResponseCode"=>"200","Result"=>"false","ResponseMsg"=>"Email Address Already Used!!");
	}
	else 
	{
		
	$table="tbl_sponsore";
  $field_values=array("img","title","mobile","email","password","is_verify");
  $data_values=array("$path","$title","$mobile","$email","$password",'0');
  
$h = new Event();
	  $check = $h->evmultiinsertdata_Api_Id($field_values,$data_values,$table);
	   $c = $evmulti->query("select * from tbl_sponsore where id=" . $check . "")->fetch_assoc();
	  $returnArr = array(
                "OragnizerLogin" => $c,
                "currency" => $set['currency'],
                "ResponseCode" => "200",
                "Result" => "true",
                "ResponseMsg" => "Login successfully!"
            );
}
}
echo json_encode($returnArr);
<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

$mobile = $data["mobile"];
$password = $data["password"];
$ccode = $data["ccode"];
if ($mobile == "" or $password == "" or $ccode == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went wrong  try again !",
    ];
} else {
    $mobile = strip_tags(mysqli_real_escape_string($evmulti, $mobile));
    $ccode = strip_tags(mysqli_real_escape_string($evmulti, $ccode));
    $password = strip_tags(mysqli_real_escape_string($evmulti, $password));

    $counter = $evmulti->query(
        "select * from tbl_user where mobile='" . $mobile . "'"
    );

    if ($counter->num_rows != 0) {
        $table = "tbl_user";
        $field = ["password" => $password];
        $where = "where mobile=" . $mobile . "";
        $h = new Event();
        $check = $h->evmultiupdateData_Api($field, $table, $where);

        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Password Changed Successfully!!!!!",
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "mobile Not Matched!!!!",
        ];
    }
}

echo json_encode($returnArr);

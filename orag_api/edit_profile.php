<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

$email = $data["email"];
$password = $data["password"];
$record_id = $data["orag_id"];
$title = $evmulti->real_escape_string($data["name"]);

if ($email == "" || $password == "" || $record_id == "" || $title == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $c = $evmulti
        ->query(
            "select * from tbl_sponsore where  email='" .
                $email .
                "' and status = 1 and password='" .
                $password .
                "'"
        )
        ->fetch_assoc();
    $table = "tbl_sponsore";
    $field = ["email" => $email, "title" => $title, "password" => $password];
    $where = "where id=" . $record_id . "";
    $h = new Event();
    $check = $h->evmultiupdateData_Api($field, $table, $where);
    $returnArr = [
        "OragnizerLogin" => $c,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Update Profile Successfully",
    ];
}
echo json_encode($returnArr);

<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
if ($data["name"] == "" or $data["password"] == "" or $data["uid"] == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $name = strip_tags(mysqli_real_escape_string($evmulti, $data["name"]));
    $lname = strip_tags(mysqli_real_escape_string($evmulti, $data["lname"]));

    $password = strip_tags(
        mysqli_real_escape_string($evmulti, $data["password"])
    );

    $uid = strip_tags(mysqli_real_escape_string($evmulti, $data["uid"]));
    $checkimei = $evmulti->query(
        "select * from tbl_user where  `id`=" . $uid . ""
    )->num_rows;

    if ($checkimei == 0) {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "User Not Exist!!!!",
        ];
    } else {
        $table = "tbl_user";
        $field = ["name" => $name, "password" => $password];
        $where = "where id=" . $uid . "";
        $h = new Event();
        $check = $h->evmultiupdateData_Api($field, $table, $where);

        $c = $evmulti
            ->query("select * from tbl_user where  `id`=" . $uid . "")
            ->fetch_assoc();
        $returnArr = [
            "UserLogin" => $c,
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Profile Update successfully!",
        ];
    }
}

echo json_encode($returnArr);

<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

if ($data["uid"] == "" or $data["wallet"] == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $wallet = strip_tags(mysqli_real_escape_string($evmulti, $data["wallet"]));
    $uid = strip_tags(mysqli_real_escape_string($evmulti, $data["uid"]));
    $checkimei = mysqli_num_rows(
        mysqli_query(
            $evmulti,
            "select * from tbl_user where  `id`=" . $uid . ""
        )
    );

    if ($checkimei != 0) {
        $vp = $evmulti
            ->query("select * from tbl_user where id=" . $uid . "")
            ->fetch_assoc();

        $table = "tbl_user";
        $field = ["wallet" => $vp["wallet"] + $wallet];
        $where = "where id=" . $uid . "";
        $h = new Event();
        $check = $h->evmultiupdateData_Api($field, $table, $where);

        $timestamp = date("Y-m-d H:i:s");

        $table = "wallet_report";
        $field_values = ["uid", "message", "status", "amt", "tdate"];
        $data_values = [
            "$uid",
            "Wallet Balance Added!!",
            "Credit",
            "$wallet",
            "$timestamp",
        ];

        $h = new Event();
        $checks = $h->evmultiinsertdata_Api(
            $field_values,
            $data_values,
            $table
        );

        $wallet = $evmulti
            ->query("select * from tbl_user where id=" . $uid . "")
            ->fetch_assoc();
        $returnArr = [
            "wallet" => $wallet["wallet"],
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Wallet Update successfully!",
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "User Deactivate By Admin!!!!",
        ];
    }
}

echo json_encode($returnArr);

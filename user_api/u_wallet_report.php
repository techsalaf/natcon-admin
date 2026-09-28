<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
if ($data["uid"] == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $uid = strip_tags(mysqli_real_escape_string($evmulti, $data["uid"]));
    $checkimei = mysqli_num_rows(
        mysqli_query(
            $evmulti,
            "select * from tbl_user where  `id`=" . $uid . ""
        )
    );

    if ($checkimei != 0) {
        $wallet = $evmulti
            ->query("select * from tbl_user where id=" . $uid . "")
            ->fetch_assoc();

        $sel = $evmulti->query(
            "select message,status,amt,tdate from wallet_report where uid=" .
                $uid .
                " order by id desc"
        );
        $myarray = [];
        $l = 0;
        $k = 0;
        $p = [];
        while ($row = $sel->fetch_assoc()) {
            if ($row["status"] == "Credit") {
                $l = $l + $row["amt"];
            } else {
                $k = $k + $row["amt"];
            }
            $p["message"] = $row["message"];
            $p["status"] = $row["status"];
            $p["amt"] = $row["amt"];
            $p["tdate"] = date("jS F, h:i A", strtotime($row["tdate"]));
            $myarray[] = $p;
        }
        $returnArr = [
            "Walletitem" => $myarray,
            "wallet" => $wallet["wallet"],
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Wallet Report Get Successfully!",
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Request To Update Own Device!!!!",
        ];
    }
}

echo json_encode($returnArr);

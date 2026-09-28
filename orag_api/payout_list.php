<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";

$data = json_decode(file_get_contents("php://input"), true);
$owner_id = $data["orag_id"];
header("Content-type: text/json");
if ($owner_id == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went wrong  try again !",
    ];
} else {
    $count = $evmulti->query(
        "select * from  payout_setting where owner_id=" . $owner_id . ""
    )->num_rows;
    if ($count != 0) {
        $cy = $evmulti->query(
            "select * from  payout_setting where owner_id=" .
                $owner_id .
                " order by id desc"
        );
        $p = [];
        $q = [];
        while ($adata = $cy->fetch_assoc()) {
            $p["payout_id"] = $adata["id"];
            $p["amt"] = $adata["amt"];
            $p["status"] = $adata["status"];
            $p["proof"] = $adata["proof"];
            $p["r_date"] = $adata["r_date"];
            $p["r_type"] = $adata["r_type"];
            $p["acc_number"] = $adata["acc_number"];
            $p["bank_name"] = $adata["bank_name"];
            $p["acc_name"] = $adata["acc_name"];
            $p["ifsc_code"] = $adata["ifsc_code"];
            $p["upi_id"] = $adata["upi_id"];
            $p["paypal_id"] = $adata["paypal_id"];
            $q[] = $p;
        }
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Payout List Get Successfully!!!",
            "Payoutlist" => $q,
        ];
    } else {
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Payout List Not Found!!",
            "Payoutlist" => [],
        ];
    }
}
echo json_encode($returnArr);


<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

$status = $data["status"];
$orag_id = $evmulti->real_escape_string($data["orag_id"]);
$description = $evmulti->real_escape_string($data["description"]);
$title = $evmulti->real_escape_string($data["title"]);
$subtitle = $evmulti->real_escape_string($data["subtitle"]);

$coupon_code = $data["coupon_code"];
$expire_date = $data["expire_date"];
$min_amt = $data["min_amt"];

$coupon_val = $data["coupon_val"];
$record_id = $data["record_id"];
if (
    $status == "" ||
    $orag_id == "" ||
    $description == "" ||
    $subtitle == "" ||
    $title == "" ||
    $coupon_code == "" ||
    $expire_date == "" ||
    $min_amt == "" ||
    $coupon_val == "" ||
    $record_id == ""
) {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $check_record = $evmulti->query(
        "select * from tbl_coupon where sponsore_id=" .
            $orag_id .
            "  and id=" .
            $record_id .
            ""
    )->num_rows;
    if ($check_record != 0) {
        if ($data["img"] == "0") {
            $table = "tbl_coupon";
            $field = [
                "status" => $status,
                "description" => $description,
                "subtitle" => $subtitle,
                "title" => $title,
                "coupon_code" => $coupon_code,
                "expire_date" => $expire_date,
                "min_amt" => $min_amt,
                "coupon_val" => $coupon_val,
            ];
            $where = "where id=" . $record_id . "";
            $h = new Event();
            $check = $h->evmultiupdateData_Api($field, $table, $where);
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "ResponseMsg" => "Coupon Update Successfully",
            ];
        } else {
            $img = $data["img"];
            $img = str_replace("data:image/png;base64,", "", $img);
            $img = str_replace(" ", "+", $img);
            $datavb = base64_decode($img);
            $path = "images/coupon/" . uniqid() . ".png";
            $fname = dirname(dirname(__FILE__)) . "/" . $path;
            file_put_contents($fname, $datavb);
            $table = "tbl_coupon";
            $field = [
                "status" => $status,
                "coupon_img" => $path,
                "description" => $description,
                "subtitle" => $subtitle,
                "title" => $title,
                "coupon_code" => $coupon_code,
                "expire_date" => $expire_date,
                "min_amt" => $min_amt,
                "coupon_val" => $coupon_val,
            ];
            $where = "where id=" . $record_id . "";
            $h = new Event();
            $check = $h->evmultiupdateData_Api($field, $table, $where);
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "ResponseMsg" => "Coupon Update Successfully",
            ];
        }
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Coupon Update On Your Own!",
        ];
    }
}

echo json_encode($returnArr);


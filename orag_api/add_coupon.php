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

if (
    $status == "" ||
    $orag_id == "" ||
    $description == "" ||
    $subtitle == "" ||
    $title == "" ||
    $coupon_code == "" ||
    $expire_date == "" ||
    $min_amt == "" ||
    $coupon_val == ""
) {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
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
    $field_values = [
        "coupon_img",
        "status",
        "sponsore_id",
        "description",
        "subtitle",
        "title",
        "coupon_code",
        "expire_date",
        "min_amt",
        "coupon_val",
    ];
    $data_values = [
        "$path",
        "$status",
        "$orag_id",
        "$description",
        "$subtitle",
        "$title",
        "$coupon_code",
        "$expire_date",
        "$min_amt",
        "$coupon_val",
    ];

    $h = new Event();
    $check = $h->evmultiinsertdata_Api($field_values, $data_values, $table);
    $returnArr = [
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Coupon  Add Successfully",
    ];
}

echo json_encode($returnArr);

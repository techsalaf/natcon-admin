<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$status = $data["status"];
$title = $evmulti->real_escape_string($data["title"]);
$address = $evmulti->real_escape_string($data["address"]);
$tags = $evmulti->real_escape_string($data["tags"]);
$vurls = $evmulti->real_escape_string($data["vurls"]);
$description = $evmulti->real_escape_string($data["cdesc"]);
$disclaimer = $evmulti->real_escape_string($data["disclaimer"]);
$status = $data["status"];
$orag_id = $data["orag_id"];
$facility_id = $data["facility_id"];
$restict_id = $data["restict_id"];
$place_name = $evmulti->real_escape_string($data["pname"]);
$sdate = $data["sdate"];
$stime = $data["stime"];
$etime = $data["etime"];
$cid = $data["cat_id"];
$latitude = $data["latitude"];
$longtitude = $data["longtitude"];

if (
    $status == "" ||
    $orag_id == "" ||
    $address == "" ||
    $title == "" ||
    $description == "" ||
    $disclaimer == "" ||
    $place_name == "" ||
    $sdate == "" ||
    $stime == "" ||
    $etime == "" ||
    $cid == "" ||
    $latitude == "" ||
    $longtitude == ""
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
    $path = "images/event/" . uniqid() . ".png";
    $fname = dirname(dirname(__FILE__)) . "/" . $path;
    file_put_contents($fname, $datavb);

    $imgs = $data["cover"];
    $imgs = str_replace("data:image/png;base64,", "", $imgs);
    $imgs = str_replace(" ", "+", $imgs);
    $datavbs = base64_decode($imgs);
    $paths = "images/event/" . uniqid() . ".png";
    $fnames = dirname(dirname(__FILE__)) . "/" . $paths;
    file_put_contents($fnames, $datavbs);

    $table = "tbl_event";
    $field_values = [
        "tags",
        "vurls",
        "cid",
        "title",
        "img",
        "cover_img",
        "sdate",
        "stime",
        "etime",
        "address",
        "status",
        "description",
        "disclaimer",
        "latitude",
        "longtitude",
        "place_name",
        "sponsore_id",
        "facility_id",
        "restict_id",
    ];
    $data_values = [
        "$tags",
        "$vurls",
        "$cid",
        "$title",
        "$path",
        "$paths",
        "$sdate",
        "$stime",
        "$etime",
        "$address",
        "$status",
        "$description",
        "$disclaimer",
        "$latitude",
        "$longtitude",
        "$place_name",
        "$orag_id",
        "$facility_id",
        "$restict_id",
    ];

    $h = new Event();
    $check = $h->evmultiinsertdata($field_values, $data_values, $table);
    $returnArr = [
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Event  Add Successfully",
    ];
}
echo json_encode($returnArr);

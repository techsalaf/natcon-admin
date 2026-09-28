<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

if ($data["orag_id"] == "" || $data["img"] == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $orag_id = $evmulti->real_escape_string($data["orag_id"]);
    $img = $data["img"];
    $img = str_replace("data:image/png;base64,", "", $img);
    $img = str_replace(" ", "+", $img);
    $data = base64_decode($img);
    $path = "images/sponsore/" . uniqid() . ".png";
    $fname = dirname(dirname(__FILE__)) . "/" . $path;

    file_put_contents($fname, $data);

    $table = "tbl_sponsore";
    $field = ["img" => $path];
    $where = "where id=" . $orag_id . "";
    $h = new Event();
    $check = $h->evmultiupdateData_Api($field, $table, $where);
    $c = $evmulti
        ->query("select * from tbl_sponsore where id=" . $orag_id . "")
        ->fetch_assoc();
    $returnArr = [
        "OragnizerLogin" => $c,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Profile Image Upload Successfully!!",
    ];
}
echo json_encode($returnArr);


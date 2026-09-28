<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
$data = json_decode(file_get_contents("php://input"), true);
header("Content-type: text/json");
$uid = $data["uid"];
$eid = $data["eid"];

if ($uid == "" || $eid == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went wrong  try again !",
    ];
} else {
    $check = $evmulti->query(
        "select * from tbl_fav where uid=" . $uid . " and eid=" . $eid . ""
    )->num_rows;
    if ($check != 0) {
        $table = "tbl_fav";
        $where = "where uid=" . $uid . " and eid=" . $eid . "";
        $h = new Event();
        $check = $h->evmultiDeleteData_Api($where, $table);

        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Event Successfully Removed In Favourite List !!",
        ];
    } else {
        $table = "tbl_fav";
        $field_values = ["uid", "eid"];
        $data_values = ["$uid", "$eid"];
        $h = new Event();
        $check = $h->evmultiinsertdata_Api($field_values, $data_values, $table);
        $returnArr = [
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Event Successfully Saved In Favourite List!!!",
        ];
    }
}
echo json_encode($returnArr);


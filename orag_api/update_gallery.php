<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";
require dirname(dirname(__FILE__)) . "/filemanager/event.php";
header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);

$status = $data["status"];
$orag_id = $evmulti->real_escape_string($data["orag_id"]);
$cat_id = $evmulti->real_escape_string($data["cat_id"]);
$user_id = $data["uid"];
$record_id = $data["record_id"];
if ($status == "" || $orag_id == "" || $record_id == "") {
    $returnArr = [
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!",
    ];
} else {
    $check_record = $evmulti->query(
        "select * from tbl_gallery where sponsore_id=" .
            $orag_id .
            "  and id=" .
            $record_id .
            ""
    )->num_rows;
    if ($check_record != 0) {
        if ($data["img"] == "0") {
            $table = "tbl_gallery";
            $field = ["status" => $status];
            $where = "where id=" . $record_id . "";
            $h = new Event();
            $check = $h->evmultiupdateData_Api($field, $table, $where);
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "ResponseMsg" => "Gallery Image Update Successfully",
            ];
        } else {
            $img = $data["img"];
            $img = str_replace("data:image/png;base64,", "", $img);
            $img = str_replace(" ", "+", $img);
            $datavb = base64_decode($img);
            $path = "images/gallery/" . uniqid() . ".png";
            $fname = dirname(dirname(__FILE__)) . "/" . $path;
            file_put_contents($fname, $datavb);
            $table = "tbl_gallery";
            $field = ["status" => $status, "img" => $path];
            $where = "where id=" . $record_id . "";
            $h = new Event();
            $check = $h->evmultiupdateData_Api($field, $table, $where);
            $returnArr = [
                "ResponseCode" => "200",
                "Result" => "true",
                "ResponseMsg" => "Gallery Image Update Successfully",
            ];
        }
    } else {
        $returnArr = [
            "ResponseCode" => "401",
            "Result" => "false",
            "ResponseMsg" => "Gallery Image Update On Your Own !!",
        ];
    }
}

echo json_encode($returnArr);
?>

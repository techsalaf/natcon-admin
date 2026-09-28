<?php
require dirname(dirname(__FILE__)) . "/filemanager/evconfing.php";

header("Content-type: text/json");
$data = json_decode(file_get_contents("php://input"), true);
$pol = [];
$c = [];
$sel = $evmulti->query("select * from tbl_page where status=1");
while ($row = $sel->fetch_assoc()) {
    $pol["title"] = $row["title"];

    $pol["description"] = $row["description"];

    $c[] = $pol;
}
if (empty($c)) {
    $returnArr = [
        "pagelist" => $c,
        "ResponseCode" => "200",
        "Result" => "false",
        "ResponseMsg" => "Pages Not Founded!",
    ];
} else {
    $returnArr = [
        "pagelist" => $c,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Pages List Founded!",
    ];
}
echo json_encode($returnArr);


<?php
require_once dirname(__DIR__) . '/filemanager/evconfig.php';
require_once dirname(__DIR__) . '/filemanager/event.php';

header('Content-type: application/json');

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['uid']) || $data['uid'] === '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => false,
        "ResponseMsg" => "Something Went Wrong!");
} else {
    $uid = $data['uid'];
    $table = "tbl_user";
    $field = "status = 0";
    $where = "WHERE id = " . $uid;
    $h = new Event();
    $check = $h->evmultiupdateData_single($field, $table, $where);
    if ($check) {
        $returnArr = array(
            "ResponseCode" => "200",
            "Result" => true,
            "ResponseMsg" => "Account Deleted Successfully!!"
        );
    } else {
        $returnArr = array(
            "ResponseCode" => "401",
            "Result" => false,
            "ResponseMsg" => "Failed to delete account!"
        );
    }
}

echo json_encode($returnArr);

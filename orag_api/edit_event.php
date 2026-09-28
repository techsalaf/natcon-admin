<?php
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data        = json_decode(file_get_contents('php://input'), true);
$status      = $data["status"];
$title       = $evmulti->real_escape_string($data['title']);
$address     = $evmulti->real_escape_string($data['address']);
$tags        = $evmulti->real_escape_string($data['tags']);
$vurls       = $evmulti->real_escape_string($data['vurls']);
$description = $evmulti->real_escape_string($data['cdesc']);
$disclaimer  = $evmulti->real_escape_string($data['disclaimer']);
$status      = $data['status'];
$orag_id     = $data['orag_id'];
$facility_id = $data['facility_id'];
$restict_id  = $data['restict_id'];
$place_name  = $evmulti->real_escape_string($data['pname']);
$sdate       = $data['sdate'];
$stime       = $data['stime'];
$etime       = $data['etime'];
$cid         = $data['cat_id'];
$latitude    = $data['latitude'];
$longtitude  = $data['longtitude'];
$record_id   = $data['record_id'];

if ($status == '' or $orag_id == '' or $address == '' or $title == ''  or $description == '' or $disclaimer == ''  or $place_name == '' or $sdate == '' or $stime == '' or $etime == '' or $cid == '' or $latitude == '' or $longtitude == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
    
    if ($data['img'] == '0' and  $data['cover'] != '0') {
        $imgs    = $data['cover'];
        $imgs    = str_replace('data:image/png;base64,', '', $imgs);
        $imgs    = str_replace(' ', '+', $imgs);
        $datavbs = base64_decode($imgs);
        $paths   = 'images/event/' . uniqid() . '.png';
        $fnames  = dirname(dirname(__FILE__)) . '/' . $paths;
        file_put_contents($fnames, $datavbs);
        
        $table     = "tbl_event";
        $field     = array(
            'tags' => $tags,
            'vurls' => $vurls,
            'place_name' => $place_name,
            'facility_id' => $facility_id,
            'restict_id' => $restict_id,
            'status' => $status,
            'cover_img' => $paths,
            'title' => $title,
            'cid' => $cid,
            'sdate' => $sdate,
            'stime' => $stime,
            'etime' => $etime,
            'address' => $address,
            'description' => $description,
            'disclaimer' => $disclaimer,
            'latitude' => $latitude,
            'longtitude' => $longtitude
        );
        $where     = "where id=" . $record_id . " and sponsore_id=" . $orag_id . "";
        $h         = new Event();
        $check     = $h->evmultiupdateDatanull_Api($field, $table, $where);
        $returnArr = array(
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Event Update Successfully!!"
        );
    } else if ($data['img'] != '0' and $data['cover'] == '0') {
        $img    = $data['img'];
        $img    = str_replace('data:image/png;base64,', '', $img);
        $img    = str_replace(' ', '+', $img);
        $datavb = base64_decode($img);
        $path   = 'images/event/' . uniqid() . '.png';
        $fname  = dirname(dirname(__FILE__)) . '/' . $path;
       file_put_contents($fname, $datavb);
        
        $table     = "tbl_event";
        $field     = array(
            'tags' => $tags,
            'vurls' => $vurls,
            'place_name' => $place_name,
            'facility_id' => $facility_id,
            'restict_id' => $restict_id,
            'status' => $status,
            'img' => $path,
            'title' => $title,
            'cid' => $cid,
            'sdate' => $sdate,
            'stime' => $stime,
            'etime' => $etime,
            'address' => $address,
            'description' => $description,
            'disclaimer' => $disclaimer,
            'latitude' => $latitude,
            'longtitude' => $longtitude
        );
        $where     = "where id=" . $record_id . " and sponsore_id=" . $orag_id . "";
        $h         = new Event();
        $check     = $h->evmultiupdateDatanull_Api($field, $table, $where);
        $returnArr = array(
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Event Update Successfully!!"
        );
    } else if ($data['img'] != '0' and $data['cover'] != '0') {
        $img    = $data['img'];
        $img    = str_replace('data:image/png;base64,', '', $img);
        $img    = str_replace(' ', '+', $img);
        $datavb = base64_decode($img);
        $path   = 'images/event/' . uniqid() . '.png';
        $fname  = dirname(dirname(__FILE__)) . '/' . $path;
        file_put_contents($fname, $datavb);
        
        $imgs    = $data['cover'];
        $imgs    = str_replace('data:image/png;base64,', '', $imgs);
        $imgs    = str_replace(' ', '+', $imgs);
        $datavbs = base64_decode($imgs);
        $paths   = 'images/event/' . uniqid() . '.png';
        $fnames  = dirname(dirname(__FILE__)) . '/' . $paths;
        file_put_contents($fnames, $datavbs);
        
        
        $table     = "tbl_event";
        $field     = array(
            'tags' => $tags,
            'vurls' => $vurls,
            'place_name' => $place_name,
            'facility_id' => $facility_id,
            'restict_id' => $restict_id,
            'status' => $status,
            'cover_img' => $paths,
            'img' => $path,
            'title' => $title,
            'cid' => $cid,
            'sdate' => $sdate,
            'stime' => $stime,
            'etime' => $etime,
            'address' => $address,
            'description' => $description,
            'disclaimer' => $disclaimer,
            'latitude' => $latitude,
            'longtitude' => $longtitude
        );
        $where     = "where id=" . $record_id . " and sponsore_id=" . $orag_id . "";
        $h         = new Event();
        $check     = $h->evmultiupdateDatanull_Api($field, $table, $where);
        $returnArr = array(
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Event Update Successfully!!"
        );
    } else {
        $table     = "tbl_event";
        $field     = array(
            'tags' => $tags,
            'vurls' => $vurls,
            'place_name' => $place_name,
            'facility_id' => $facility_id,
            'restict_id' => $restict_id,
            'status' => $status,
            'title' => $title,
            'cid' => $cid,
            'sdate' => $sdate,
            'stime' => $stime,
            'etime' => $etime,
            'address' => $address,
            'description' => $description,
            'disclaimer' => $disclaimer,
            'latitude' => $latitude,
            'longtitude' => $longtitude
        );
        $where     = "where id=" . $record_id . " and sponsore_id=" . $orag_id . "";
        $h         = new Event();
        $check     = $h->evmultiupdateDatanull_Api($field, $table, $where);
        $returnArr = array(
            "ResponseCode" => "200",
            "Result" => "true",
            "ResponseMsg" => "Event Update Successfully!!"
        );
    }
}
echo json_encode($returnArr);
?>
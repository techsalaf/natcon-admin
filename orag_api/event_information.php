<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
if ($data['event_id'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
	
	$event_id = $data['event_id'];
	
		
			$pol = array();
            $s = array();
	$f = array();
	$r = array();
	$g = array();
	
			$gal = $evmulti->query("SELECT * FROM `tbl_event` where id=".$event_id."")->fetch_assoc();
			
				 
		$pol['event_id'] = $gal['id'];
		$pol['event_title'] = $gal['title'];
		$pol['event_cover_img'] = $gal['cover_img'];
		$pol['event_image'] = $gal['img'];
		$pol['event_status'] = $gal['status'];
		$pol['event_start_date'] = $gal['sdate'];
		$pol['event_start_time'] = $gal['stime'];
		$pol['event_end_time'] = $gal['etime'];
		$pol['event_address'] = $gal['address'];
		$pol['event_description'] = $gal['description'];
		$pol['event_disclaimer'] = $gal['disclaimer'];
		$pol['event_latitude'] = $gal['latitude'];
		$pol['event_longtitude'] = $gal['longtitude'];
		$pol['event_progress'] = $gal['event_status'];
		$pol['event_place_name'] = $gal['place_name'];
		$gettype = $evmulti->query("SELECT GROUP_CONCAT(`type`) as in_typelist FROM `tbl_type_price` where event_id=".$gal['id']."")->fetch_assoc();
		$pol['event_type_list'] = $gettype['in_typelist'];
	$total_earn = $evmulti->query("select sum((subtotal-cou_amt) - ((subtotal-cou_amt) * commission/100)) as total_amt from tbl_ticket where  eid=".$gal['id']." and ticket_type !='Cancelled'")->fetch_assoc();
	$earn =   empty($total_earn['total_amt']) ? 0 : number_format((float)($total_earn['total_amt']), 2, '.', '');
	$pol['event_revnue'] = $earn;
	
	$counter = $evmulti->query("select * from tbl_type_price where event_id=".$gal['id']." order by price")->num_rows;
	if($counter > 1)
	{
	$getprice = $evmulti->query("select min(price) as minprice from tbl_type_price where event_id=".$gal['id']."")->fetch_assoc();
	$getprices = $evmulti->query("select max(price) as  maxprice from tbl_type_price where event_id=".$gal['id']."")->fetch_assoc();
	$pol['ticket_price'] = $getprice['minprice'].$set['currency'].'-'.$getprices['maxprice'].$set['currency'];
	}
	else 
	{
	$getprice = $evmulti->query("select price from tbl_type_price where event_id=".$gal['id']."")->fetch_assoc();
	$pol['ticket_price'] = ($getprice['price'] == 0) ? 'Free' : $getprice['price'].$set['currency'];
	}
	
		$pol['event_tags'] = $gal['tags'];
		$pol['event_vurls'] = $gal['vurls'];
		$gettotal = $evmulti->query("select sum(tlimit) as totalticket from tbl_type_price where event_id=".$event_id."")->fetch_assoc();
	$pol['total_ticket'] = intval($gettotal['totalticket']);
	
	$bn = $evmulti->query("select sum(`total_ticket`) as book_ticket from tbl_ticket where eid=".$event_id."  and ticket_type!='Cancelled'")->fetch_assoc();
		$bookticket = empty($bn['book_ticket']) ? 0 : $bn['book_ticket'];
		
	$pol['total_book_ticket'] = intval($bookticket);
		
		$gallery = $evmulti->query("select * from tbl_gallery where eid=".$event_id." and status=1");
while($row = $gallery->fetch_assoc())
{
	$g[] = $row['img'];
}
$pol['gallerydata'] =$g;

	$spon = $evmulti->query("select * from tbl_artist where eid=".$event_id." and status=1");
$sponsore = array();
while($row = $spon->fetch_assoc())
{
	$sponsore['artist_img'] = $row['img'];
	$sponsore['artist_title'] = $row['title'];
	$sponsore['artist_role'] = $row['arole'];
	$s[] = $sponsore;
}
$pol['artistdata'] =$s;
if(empty($gal['facility_id']))
{
	
}
else 
{
$spon = $evmulti->query("select * from tbl_facility where id IN(".$gal['facility_id'].")");
$sponsore = array();
while($row = $spon->fetch_assoc())
{
	$sponsore['facility_img'] = $row['img'];
	$sponsore['facility_title'] = $row['title'];
	
	$f[] = $sponsore;
}
}
$pol['facilitydata'] =$f;

if(empty($gal['restict_id']))
{
	
}
else 
{
$spon = $evmulti->query("select * from tbl_restriction where id IN(".$gal['restict_id'].")");
$sponsore = array();
while($row = $spon->fetch_assoc())
{
	$sponsore['restriction_img'] = $row['img'];
	$sponsore['restriction_title'] = $row['title'];
	$r[] = $sponsore;
}
}
$pol['restrictiondata'] =$r;		
	
$user = $evmulti->query("SELECT uid,total_ticket,type FROM `tbl_ticket` where eid=".$event_id." and ticket_type!='Cancelled'");
$po = array();
$uo = array();
while($row = $user->fetch_assoc())
{
	$udata = $evmulti->query("SELECT pro_pic,name,ccode,mobile FROM `tbl_user` where id=".$row['uid']."")->fetch_assoc();
	$po['user_img'] = empty($udata['pro_pic']) ? 'images/user.png' : $udata['pro_pic'];
	$po['customername'] = $udata['name'];
	$po['customermobile'] = $udata['ccode'].$udata['mobile'];
	$po['Total_ticket_purchase'] = $row['total_ticket'];
	$po['Total_type'] = $row['type'];
	$uo[] = $po;
}
$pol['joined_user'] =$uo;


$user = $evmulti->query("SELECT uid,total_ticket,type FROM `tbl_ticket` where eid=".$event_id." and is_verify=1");
$po = array();
$uo = array();
while($row = $user->fetch_assoc())
{
	$udata = $evmulti->query("SELECT pro_pic,name,ccode,mobile FROM `tbl_user` where id=".$row['uid']."")->fetch_assoc();
	$po['user_img'] = empty($udata['pro_pic']) ? 'images/user.png' : $udata['pro_pic'];
	$po['customername'] = $udata['name'];
	$po['customermobile'] = $udata['ccode'].$udata['mobile'];
	$po['Total_ticket_purchase'] = $row['total_ticket'];
	$po['Total_type'] = $row['type'];
	$uo[] = $po;
}
$pol['attend_user'] =$uo;


$user = $evmulti->query("SELECT uid,total_ticket,type FROM `tbl_ticket` where eid=".$event_id." and is_verify=0 and ticket_type!='Cancelled'");
$po = array();
$uo = array();
while($row = $user->fetch_assoc())
{
	$udata = $evmulti->query("SELECT pro_pic,name,ccode,mobile FROM `tbl_user` where id=".$row['uid']."")->fetch_assoc();
	$po['user_img'] = empty($udata['pro_pic']) ? 'images/user.png' : $udata['pro_pic'];
	$po['customername'] = $udata['name'];
	$po['customermobile'] = $udata['ccode'].$udata['mobile'];
	$po['Total_ticket_purchase'] = $row['total_ticket'];
	$po['Total_type'] = $row['type'];
	$uo[] = $po;
}
$pol['notjoined_user'] =$uo;


$user = $evmulti->query("SELECT uid,total_star,review_comment FROM `tbl_ticket` where eid=".$event_id." and is_review=1");
$po = array();
$uo = array();
while($row = $user->fetch_assoc())
{
	$udata = $evmulti->query("SELECT pro_pic,name,ccode,mobile FROM `tbl_user` where id=".$row['uid']."")->fetch_assoc();
	$po['user_img'] = empty($udata['pro_pic']) ? 'images/user.png' : $udata['pro_pic'];
	$po['customername'] = $udata['name'];
	$po['rate_number'] = $row['total_star'];
	$po['rate_text'] = $row['review_comment'];
	$uo[] = $po;
}
$pol['total_review'] =$uo;

	
		$returnArr = array(
		"Eventdata"=>empty($pol) ? [] : $pol,
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Event Information Get Successfully!!!"
    );
}
echo json_encode($returnArr);
?>
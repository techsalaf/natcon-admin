<?php 
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require_once dirname( dirname(__FILE__) ).'/qr/qrlib.php';

header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);
$uid = $data['uid'];
$tid = $data['ticket_id'];
if($uid == ''  or $tid == '')
{
	$returnArr = array("ResponseCode"=>"401","Result"=>"false","ResponseMsg"=>"Something Went wrong  try again !");
}
else 
{
	$datav = array();
	
	$ticket = $evmulti->query("SELECT * FROM `tbl_ticket` where id=".$tid."")->fetch_assoc();
	$eid = $ticket['eid'];
	$sponsore_id = $ticket['sponsore_id'];
	$eve = $evmulti->query("SELECT * FROM `tbl_event` where id=".$ticket['eid']."")->fetch_assoc();
	$user = $evmulti->query("SELECT * FROM `tbl_user` where id=".$ticket['uid']."")->fetch_assoc();
	$pdata = $evmulti->query("select * from tbl_payment_list where id=".$ticket['p_method_id']."")->fetch_assoc();
	$datav['ticket_id'] = $tid;
	$datav['ticket_title'] =  $eve['title'];
	
	
	setlocale(LC_TIME, 'fr_FR.utf8', 'fra');
	$datav['start_time'] = strftime("%A", strtotime($eve['sdate'])).', '.strftime("%I:%M %p", strtotime($eve['stime'])).' à '.strftime("%I:%M %p", strtotime($eve['etime']));
	$datav['event_address'] = $eve['address'];
	$datav['event_address_title'] = $eve['place_name'];
	$datav['event_latitude'] = $eve['latitude'];
	$datav['event_longtitude'] = $eve['longtitude'];
	$spon = $evmulti->query("select * from tbl_sponsore where id=".$ticket['sponsore_id']."")->fetch_assoc();

	$datav['sponsore_id'] = $spon['id'];
	$datav['sponsore_img'] = $spon['img'];
	$datav['sponsore_title'] = $spon['title'];
	
	$data_print = json_encode(array(
    'ticket_id' => $tid,
    'uid' => $uid,
    'event_id' => $eid,
    'orgnizer_id' => $sponsore_id
));

$filename = $tid . '.png';
$filepath = dirname( dirname(__FILE__) ).'/images/qr/' . $filename;

// Generate QR code and save it to the server
QRcode::png($data_print, $filepath);
$server_url = 'server_url'; // Your server URL
$qrcode_url = $server_url.'images/qr/'.$filename;

	$datav['qrcode'] = $qrcode_url;
    $datav['unique_code'] = $ticket['uniq_id'];
$datav['ticket_username'] =  $user['name'];
$datav['ticket_mobile'] =  $user['ccode'].$user['mobile'];
$datav['ticket_email'] =  $user['email'];
$datav['ticket_rate'] = $ticket['is_review'];
$datav['ticket_type'] = $ticket['type'];
$datav['total_ticket'] = $ticket['total_ticket'];
$datav['ticket_subtotal'] = $ticket['subtotal'];
$datav['ticket_cou_amt'] = $ticket['cou_amt'];
$datav['ticket_wall_amt'] = $ticket['wall_amt'];
$datav['ticket_tax'] = $ticket['tax'];
$datav['ticket_total_amt'] = $ticket['total_amt'];

$datav['ticket_p_method'] = $pdata['title'];
$datav['ticket_transaction_id'] = $ticket['transaction_id'];
if($ticket['ticket_type'] == 'Cancelled')
{
	$datav['ticket_status'] = 'Cancelled';
}
else 
{
$datav['ticket_status'] = 'Paid';
}
	$returnArr = array("ResponseCode"=>"200","Result"=>"true","ResponseMsg"=>"Ticket Information Get Successfully!","TicketData"=>$datav);
}
echo json_encode($returnArr);
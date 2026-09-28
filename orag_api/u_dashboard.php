<?php
require dirname(dirname(__FILE__)) . '/filemanager/evconfing.php';
require dirname(dirname(__FILE__)) . '/filemanager/event.php';
header('Content-type: text/json');
$data = json_decode(file_get_contents('php://input'), true);

if ($data['orag_id'] == '') {
    $returnArr = array(
        "ResponseCode" => "401",
        "Result" => "false",
        "ResponseMsg" => "Something Went Wrong!"
    );
} else {
    $orag_id               = $data['orag_id'];
    $total_event           = $evmulti->query("select * from tbl_event where sponsore_id=" . $orag_id . " and event_status ='Pending'")->num_rows;
	$eventlist = $evmulti->query("SELECT GROUP_CONCAT(`id`) as event_id FROM `tbl_event` WHERE sponsore_id=".$orag_id." and (event_status='Completed' or event_status='Cancelled')")->fetch_assoc();
    $date = date("Y-m-d");
	$total_today = $evmulti->query("select * from tbl_event where sponsore_id=".$orag_id." and event_status ='Pending' and sdate='".$date."'")->num_rows;
	$upcoming_event = $evmulti->query("select * from tbl_event where sponsore_id=".$orag_id." and event_status ='Pending' and sdate >'".$date."'")->num_rows;
	$past_event = $evmulti->query("select * from tbl_event where sponsore_id=".$orag_id." and (event_status ='Completed' or event_status ='Cancelled')")->num_rows;
	$event_id = empty($eventlist['event_id']) ? 0 : $eventlist['event_id'];
    $total_cover_image     = $evmulti->query("select * from tbl_cover where sponsore_id=" . $orag_id . " and eid NOT IN (".$event_id.")")->num_rows;
	$total_type_price      = $evmulti->query("select * from tbl_type_price where sponsore_id=" . $orag_id . " and event_id NOT IN (".$event_id.")")->num_rows;
    $total_gallery         = $evmulti->query("select * from tbl_gallery where sponsore_id=" . $orag_id . " and eid NOT IN (".$event_id.")")->num_rows;
    $total_artist          = $evmulti->query("select * from tbl_artist where sponsore_id=" . $orag_id . " and eid NOT IN (".$event_id.")")->num_rows;
    $total_coupon          = $evmulti->query("select * from tbl_coupon where sponsore_id=" . $orag_id . "")->num_rows;
	$total_manager         = $evmulti->query("select * from tbl_omanager where orag_id=" . $orag_id . " and manager_type='MANAGER'")->num_rows;
	$total_scanner         = $evmulti->query("select * from tbl_omanager where orag_id=" . $orag_id . " and manager_type='SCANNER'")->num_rows;
    $t                     = $evmulti->query("select sum(`total_ticket`) as totaltic from tbl_ticket where sponsore_id=" . $orag_id . " and ticket_type!='Cancelled'")->fetch_assoc();
    $total_ticket_sale     = (empty($t['totaltic'])) ? "0" : $t['totaltic'];
    $total_earn            = $evmulti->query("select sum((subtotal-cou_amt) - ((subtotal-cou_amt) * commission/100)) as total_amt from tbl_ticket where sponsore_id=" . $orag_id . " and ticket_type ='Completed'")->fetch_assoc();
    $total_earns           = empty($total_earn['total_amt']) ? "0" : number_format((float) ($total_earn['total_amt']), 2, '.', '');
	
    $total_payout          = $evmulti->query("select sum(amt) as total_payout from payout_setting where owner_id=" . $orag_id . "")->fetch_assoc();
    $receive_payout        = empty($total_payout['total_payout']) ? "0" : number_format((float) ($total_payout['total_payout']), 2, '.', '');
    $final_earn            = number_format((float) ($total_earns) - $receive_payout, 2, '.', '');
    $papi                  = array(
        array(
            "title" => "Total Event",
            "report_data" => $total_event,
            "url" => 'images/dashboard/1total_event.png'
        ),
        array(
            "title" => "Today Events",
            "report_data" => $total_today,
            "url" => 'images/dashboard/2todayevent.png'
        ),
        array(
            "title" => "Upcoming Events",
            "report_data" => $upcoming_event,
            "url" => 'images/dashboard/3upcoming_event.png'
        ),
        array(
            "title" => "Past Events",
            "report_data" => $past_event,
            "url" => 'images/dashboard/4past_event.png'
        ),
		array(
            "title" => "Type & Price",
            "report_data" => $total_type_price,
            "url" => 'images/dashboard/5type_price.png'
        ),
        array(
            "title" => "Coupon",
            "report_data" => $total_coupon,
            "url" => 'images/dashboard/6coupon.png'
        ),
        array(
            "title" => "Cover Images",
            "report_data" => $total_cover_image,
            "url" => 'images/dashboard/7cover_image.png'
        ),
        array(
            "title" => "Artist",
            "report_data" => $total_artist,
            "url" => 'images/dashboard/8artist.png'
        ),
        array(
            "title" => "Gallery Images",
            "report_data" => $total_gallery,
            "url" => 'images/dashboard/9gallery.png'
        ),
        array(
            "title" => "Ticket Sales",
            "report_data" => $total_ticket_sale,
            "url" => 'images/dashboard/10ticketsales.png'
        ),
        array(
            "title" => "Earning",
            "report_data" => $total_earns,
            "url" => 'images/dashboard/11earning.png'
        ),
        array(
            "title" => "Payout",
            "report_data" => $receive_payout,
            "url" => 'images/dashboard/12payout.png'
        ),
        array(
            "title" => "Payout Earning",
            "report_data" => $final_earn,
            "url" => 'images/dashboard/13afterpayout.png'
        ),
		array(
            "title" => "Total Manager",
            "report_data" => $total_manager,
            "url" => 'images/dashboard/13afterpayout.png'
        ),
		array(
            "title" => "Total Scanner",
            "report_data" => $total_scanner,
            "url" => 'images/dashboard/13afterpayout.png'
        ),
		
    );
    
    $returnArr = array(
        "ResponseCode" => "200",
        "Result" => "true",
        "ResponseMsg" => "Report List Get Successfully!!!",
        "report_data" => $papi,
        "withdraw_limit" => $set['pstore']
    );
    
}
echo json_encode($returnArr);
?>
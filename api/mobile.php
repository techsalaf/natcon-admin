<?php
declare(strict_types=1);
require_once dirname(__DIR__).'/services/natcon/bootstrap.php';
use function Natcon\{config,database,query,clean,limit,createAccount,loginAccount,accountForToken,staffForToken,issueMobileToken,updateAccountProfile,updateAccountProfileImage,mobileTicketHistory,mobileTicketInfo,mobileEventCard,mobileEventDetails,mobileTicketType};

header('X-Content-Type-Options: nosniff');
header('Cache-Control: no-store');
header('Content-Type: application/json; charset=utf-8');

function mobileReply(array $data,int $status=200): never {http_response_code($status);echo json_encode($data,JSON_UNESCAPED_SLASHES|JSON_INVALID_UTF8_SUBSTITUTE);exit;}
function mobileAccountPayload(array $account): array {
    return ['id'=>(string)$account['id'],'name'=>$account['name'],'email'=>$account['email'],'ccode'=>$account['country_code'],'mobile'=>$account['phone'],'pro_pic'=>$account['profile_image']??'','wallet'=>(int)$account['wallet_balance_kobo'],'refercode'=>$account['referral_code']??''];
}
function mobileStaffType(string $role): string {return match($role){'admin'=>'Orgnizer','finance'=>'MANAGER','registrar'=>'SCANNER',default=>''};}

try {
    $client=clean($_GET['client']??'',20);$endpoint=clean($_GET['endpoint']??'',100);
    if(!in_array($client,['user_api','orag_api'],true)||!preg_match('#^[A-Za-z0-9_/-]+\.php$#',$endpoint))mobileReply(['Result'=>'false','ResponseMsg'=>'Unknown mobile endpoint.'],404);
    $endpoint=strtolower($endpoint);
    $c=config();$db=database($c);$raw=file_get_contents('php://input');$maxBody=$client==='orag_api'&&in_array($endpoint,['add_event.php','edit_event.php'],true)?7200000:(($client==='orag_api'&&in_array($endpoint,['add_artist.php','update_artist.php','add_gallery.php','update_gallery.php'],true))||($client==='user_api'&&$endpoint==='pro_image.php')?4000000:100000);if(strlen($raw)>$maxBody)throw new InvalidArgumentException('Request is too large.');
    $in=$raw!==''?json_decode($raw,true):[];if(!is_array($in))throw new InvalidArgumentException('Invalid request body.');
    if($client==='user_api'&&$endpoint==='u_reg_user.php'){
        limit($db,'mobile-account-register:'.($_SERVER['REMOTE_ADDR']??''),10);
        $account=createAccount($db,$in);
        mobileReply(['Result'=>'true','ResponseMsg'=>'Account created successfully.','UserLogin'=>mobileAccountPayload($account),'AccessToken'=>$account['access_token']]);
    }
    if($client==='user_api'&&$endpoint==='u_login_user.php'){
        limit($db,'mobile-account-login:'.($_SERVER['REMOTE_ADDR']??''),10);
        $account=loginAccount($db,$in);
        mobileReply(['Result'=>'true','ResponseMsg'=>'Signed in successfully.','UserLogin'=>mobileAccountPayload($account),'AccessToken'=>$account['access_token']]);
    }
    if($client==='user_api'&&$endpoint==='getdata.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Referral details loaded.']+\Natcon\referralSummary($db,(int)$account['id']));
    }
    if($client==='user_api'&&$endpoint==='mobile_check.php'){
        limit($db,'mobile-account-check:'.($_SERVER['REMOTE_ADDR']??''),20);
        $country=clean($in['ccode']??'',12);$phone=clean($in['mobile']??'',40);
        $exists=(bool)query($db,'SELECT id FROM natcon_accounts WHERE country_code=? AND phone=?',[$country,$phone])->fetchColumn();
        mobileReply(['Result'=>$exists?'false':'true','ResponseMsg'=>$exists?'Phone number already has an account.':'Phone number is available.']);
    }
    if($client==='user_api'&&$endpoint==='u_forget_password.php'){
        limit($db,'mobile-password-reset:'.($_SERVER['REMOTE_ADDR']??''),12,300);
        $stage=clean($in['stage']??'',20);$email=strtolower(clean($in['email']??'',190));
        if($stage==='request'){
            \Natcon\requestAccountPasswordReset($db,$email);
            mobileReply(['Result'=>'true','ResponseMsg'=>'If an active NATCON account uses that email, a reset code will be sent shortly.']);
        }
        if($stage==='confirm'){
            \Natcon\resetAccountPassword($db,$email,clean($in['code']??'',6),(string)($in['password']??''));
            mobileReply(['Result'=>'true','ResponseMsg'=>'Your password was reset. Sign in with your new password.']);
        }
        mobileReply(['Result'=>'false','ResponseMsg'=>'Choose a password reset step.'],400);
    }
    if($client==='user_api'&&$endpoint==='u_home_data.php'){
        $account=accountForToken($db);$cards=\Natcon\mobileEventCards($db);
        $wallet=$account?(int)$account['wallet_balance_kobo']/100:0;
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'NATCON events loaded.','HomeData'=>['Catlist'=>\Natcon\mobileEventCategories($db),'Main_Data'=>['id'=>'NATCON','currency'=>'₦','scredit'=>'0','rcredit'=>'0','tax'=>'0'],'latest_event'=>$cards,'wallet'=>(string)$wallet,'upcoming_event'=>$cards,'nearby_event'=>[],'this_month_event'=>$cards]]);
    }
    if($client==='user_api'&&$endpoint==='u_cat_event.php'){
        $categoryId=clean($in['cat_id']??'',32);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Category events loaded.','CatEventData'=>\Natcon\mobileEventsByCategory($db,$categoryId)]);
    }
    if($client==='user_api'&&$endpoint==='u_search_event.php'){
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Search results loaded.','SearchData'=>\Natcon\mobileEventSearch($db,clean($in['keyword']??'',100))]);
    }
    if($client==='user_api'&&$endpoint==='u_pagelist.php')mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Pages loaded.','pagelist'=>\Natcon\mobilePages($db)]);
    if($client==='user_api'&&$endpoint==='u_faq.php')mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'FAQs loaded.','FaqData'=>\Natcon\mobileFaqs($db)]);
    if($client==='user_api'&&$endpoint==='u_fav.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        $saved=\Natcon\toggleFavorite($db,(int)$account['id'],clean($in['eid']??'',64));mobileReply(['Result'=>'true','ResponseMsg'=>$saved?'Added to favorites.':'Removed from favorites.','is_favorite'=>$saved]);
    }
    if($client==='user_api'&&$endpoint==='u_favlist.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Favorites loaded.','FavEventData'=>\Natcon\favoriteEvents($db,(int)$account['id'])]);
    }
    if($client==='user_api'&&$endpoint==='rate_update.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        $rating=filter_var($in['total_star']??null,FILTER_VALIDATE_FLOAT);if($rating===false||$rating<1||$rating>5)mobileReply(['Result'=>'false','ResponseMsg'=>'Choose a rating from 1 to 5 stars.'],400);
        $result=\Natcon\submitReview($db,(int)$account['id'],clean($in['ticket_id']??'',128),(int)round($rating),clean($in['review_comment']??'',2000));
        mobileReply(['Result'=>'true','ResponseMsg'=>'Your review was saved.','reviewdata'=>$result['reviews']]);
    }
    if($client==='user_api'&&$endpoint==='u_couponlist.php'){
        if(!accountForToken($db))mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        mobileReply(['Result'=>'true','ResponseMsg'=>'Coupons loaded.','couponlist'=>\Natcon\availableCoupons($db,max(0,(int)($in['subtotal_kobo']??0)),clean($in['event_id']??'',32))]);
    }
    if($client==='user_api'&&$endpoint==='u_check_coupon.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        $coupon=query($db,'SELECT code,minimum_kobo,event_id FROM natcon_coupons WHERE id=?',[clean($in['cid']??'',64)])->fetch();
        if(!$coupon)mobileReply(['Result'=>'false','ResponseMsg'=>'Coupon not found.']);
        $eventId=clean($in['event_id']??($coupon['event_id']??''),32);if($eventId==='')$eventId=(string)\Natcon\primaryConference($db)['id'];
        try{\Natcon\applicableCoupon($db,(string)$coupon['code'],(int)$coupon['minimum_kobo'],$eventId);mobileReply(['Result'=>'true','ResponseMsg'=>'Coupon is valid. The final discount will be calculated by NATCON at checkout.']);}
        catch(InvalidArgumentException $e){mobileReply(['Result'=>'false','ResponseMsg'=>$e->getMessage()]);}
    }
    if($client==='user_api'&&$endpoint==='notification.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Notifications loaded.','NotificationData'=>\Natcon\mobileNotifications($db,(int)$account['id'])]);
    }
    if($client==='user_api'&&$endpoint==='notification_read.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        $updated=\Natcon\markMobileNotificationRead($db,(int)$account['id'],clean($in['id']??'',16));
        mobileReply(['Result'=>'true','ResponseMsg'=>$updated?'Notification marked as read.':'Notification already read or unavailable.','is_read'=>$updated]);
    }
    if($client==='user_api'&&$endpoint==='u_wallet_report.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Wallet history loaded.','wallet'=>number_format((int)$account['wallet_balance_kobo']/100,2,'.',''),'Walletitem'=>\Natcon\walletHistory($db,(int)$account['id'])]);
    }
    if($client==='user_api'&&$endpoint==='u_paymentgateway.php'){
        $methods=$c['secret']?[['id'=>'paystack','title'=>'Paystack','img'=>'','attributes'=>'','status'=>'1','subtitle'=>'Secure NATCON wallet top-up','p_show'=>'1']]:[];
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Available payment methods loaded.','paymentdata'=>$methods]);
    }
    if($client==='user_api'&&$endpoint==='u_wallet_up.php')mobileReply(['Result'=>'false','ResponseMsg'=>'Wallet credits are added only after NATCON verifies your payment.'],410);
    if($client==='user_api'&&$endpoint==='u_event_data.php'){
        $eventId=clean($in['event_id']??'',32);$primary=\Natcon\primaryConference($db);if(in_array($eventId,['NATCON-2026','2026'],true))$eventId=(string)$primary['id'];
        $event=\Natcon\publishedEvent($db,$eventId);$account=accountForToken($db);$detail=mobileEventDetails($db,$c,$account?(int)$account['id']:null,(string)$event['id']);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Event details loaded.','EventData'=>$detail,'Event_gallery'=>$detail['event_gallery']??[],'Event_Artist'=>$detail['event_artists']??[],'Event_Facility'=>$detail['event_facilities']??[],'Event_Restriction'=>$detail['event_restrictions']??[],'reviewdata'=>\Natcon\mobileReviews($db,(int)$event['id'])]);
    }
    if($client==='user_api'&&$endpoint==='u_event_type_price.php'){
        $eventId=clean($in['event_id']??'',32);$primary=\Natcon\primaryConference($db);if(in_array($eventId,['NATCON-2026','2026'],true))$eventId=(string)$primary['id'];
        \Natcon\publishedEvent($db,$eventId);mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Ticket prices loaded.','EventTypePrice'=>\Natcon\mobileTicketTypes($db,$c,$eventId)]);
    }
    if($client==='orag_api'&&$endpoint==='u_login_user.php'){
        limit($db,'mobile-staff-login:'.($_SERVER['REMOTE_ADDR']??''),10);
        $staff=query($db,'SELECT * FROM natcon_staff WHERE email=?',[strtolower(clean($in['email']??''))])->fetch();
        if(!$staff||!password_verify((string)($in['password']??''),$staff['password_hash']))mobileReply(['Result'=>'false','ResponseMsg'=>'Email or password is incorrect.'],401);
        $expected=mobileStaffType((string)$staff['role']);
        $requested=match((string)($in['type']??'')){'Admin'=>'Orgnizer','Finance'=>'MANAGER','Registrar'=>'SCANNER',default=>(string)($in['type']??'')};
        if(!$expected||$requested!==$expected)mobileReply(['Result'=>'false','ResponseMsg'=>'Choose the role assigned to this account.'],403);
        unset($staff['password_hash']);$token=issueMobileToken($db,'staff',(int)$staff['id'],$staff['role']);
        $org=['id'=>(string)$staff['id'],'name'=>$staff['name'],'title'=>$staff['name'],'email'=>$staff['email'],'mobile'=>'','img'=>''];
        mobileReply(['Result'=>'true','ResponseMsg'=>'Signed in successfully.','OragnizerLogin'=>$org,'Type'=>$expected,'currency'=>'NGN','AccessToken'=>$token]);
    }
    if($client==='orag_api'&&$endpoint==='u_dashboard.php'){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        if(!in_array($staff['role'],['admin','finance','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view this dashboard.'],403);
        $totals=[
            'delegates'=>(int)query($db,'SELECT COUNT(*) FROM natcon_delegates')->fetchColumn(),
            'paid'=>(int)query($db,"SELECT COUNT(*) FROM natcon_delegates d JOIN natcon_orders o ON o.reference=d.reference WHERE o.status='paid'")->fetchColumn(),
            'checked_in'=>(int)query($db,'SELECT COUNT(DISTINCT delegate_id) FROM natcon_checkins')->fetchColumn(),
            'revenue'=>(int)query($db,"SELECT COALESCE(SUM(amount_kobo+wallet_kobo),0) FROM natcon_orders WHERE status='paid'")->fetchColumn(),
            'pending_transfers'=>(int)query($db,"SELECT COUNT(*) FROM natcon_orders WHERE status='awaiting_review'")->fetchColumn(),
        ];
        $labels=['Total Delegates'=>$totals['delegates'],'Paid Delegates'=>$totals['paid'],'Checked In'=>$totals['checked_in'],'Earning'=>number_format($totals['revenue']/100,2),'Pending Transfers'=>$totals['pending_transfers']];
        $report=[];foreach($labels as $title=>$value)$report[]=['title'=>$title,'report_data'=>(string)$value,'url'=>''];
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Dashboard loaded.','report_data'=>$report,'withdraw_limit'=>'1','natcon_data'=>$totals]);
    }
    if($client==='orag_api'&&$endpoint==='payout_list.php'){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);if(!in_array($staff['role'],['admin','finance'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view payout records.'],403);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Payout history loaded.','Payoutlist'=>\Natcon\payoutHistory($db,(int)$staff['id'],$staff['role']),'balance'=>\Natcon\payoutBalance($db)]);
    }
    if($client==='orag_api'&&$endpoint==='request_withdraw.php'){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);if($staff['role']!=='admin')mobileReply(['Result'=>'false','ResponseMsg'=>'Only Admin can submit payout requests.'],403);
        $amount=\Natcon\payoutNairaToKobo($in['amt']??'');$result=\Natcon\requestPayout($db,(int)$staff['id'],$amount,$in);mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Payout request submitted for Finance review.','data'=>$result]);
    }
    if($client==='orag_api'&&$endpoint==='payout_review.php'){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);if($staff['role']!=='finance')mobileReply(['Result'=>'false','ResponseMsg'=>'Only Finance can review payout requests.'],403);
        $result=\Natcon\reviewPayout($db,(int)$staff['id'],(int)($in['payout_id']??0),clean($in['status']??'',20),clean($in['note']??'',1000));mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Payout request updated.','data'=>$result]);
    }
    if($client==='orag_api'&&in_array($endpoint,['coupon_list.php','add_coupon.php','update_coupon.php'],true)){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        if($endpoint==='coupon_list.php'){
            if(!in_array($staff['role'],['admin','finance','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view coupons.'],403);
            mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Coupons loaded.','coupondata'=>\Natcon\organizerCoupons($db,clean($in['event_id']??'',32))]);
        }
        if($staff['role']!=='admin')mobileReply(['Result'=>'false','ResponseMsg'=>'Only Admin can manage NATCON coupons.'],403);
        $in['_staff_id']=(int)$staff['id'];$id=$endpoint==='update_coupon.php'?filter_var($in['record_id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]):null;if($endpoint==='update_coupon.php'&&!$id)throw new InvalidArgumentException('Choose a valid coupon.');
        $saved=\Natcon\saveOrganizerCoupon($db,$in,$id?:null);mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>$endpoint==='add_coupon.php'?'Coupon added to the NATCON catalogue.':'Coupon updated.','data'=>$saved]);
    }
    if($client==='orag_api'&&in_array($endpoint,['list_facility.php','list_restriction.php','list_artist.php','view_gallery.php','add_artist.php','update_artist.php','add_gallery.php','update_gallery.php'],true)){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);$eventId=clean($in['event_id']??'',32);
        if(in_array($endpoint,['list_facility.php','list_restriction.php','list_artist.php','view_gallery.php'],true)){
            if(!in_array($staff['role'],['admin','finance','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view event content.'],403);
            $kind=match($endpoint){'list_facility.php'=>'facility','list_restriction.php'=>'restriction','list_artist.php'=>'artist',default=>'gallery'};$rows=\Natcon\organizerEventContentList($db,$kind,$eventId);
            $key=match($kind){'facility'=>'Facilitydata','restriction'=>'Restrictiondata','artist'=>'Artistdata',default=>'gallerydata'};mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Event content loaded.',$key=>$rows]);
        }
        if($staff['role']!=='admin')mobileReply(['Result'=>'false','ResponseMsg'=>'Only Admin can manage event content.'],403);
        $kind=str_contains($endpoint,'artist')?'artist':(str_contains($endpoint,'gallery')?'gallery':(str_contains($endpoint,'facility')?'facility':'restriction'));$id=str_starts_with($endpoint,'update_')?filter_var($in['record_id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]):null;if(str_starts_with($endpoint,'update_')&&!$id)throw new InvalidArgumentException('Choose a valid event content record.');$saved=\Natcon\saveOrganizerEventContent($db,$kind,$in,$id?:null,(int)$staff['id']);mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Event content saved.','data'=>$saved]);
    }
    if($client==='orag_api'&&in_array($endpoint,['list_category.php','list_type.php','add_event.php','edit_event.php','add_type.php','edit_type.php','complete_event.php','cancle_event.php'],true)){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        if($endpoint==='list_category.php'){
            if(!in_array($staff['role'],['admin','finance','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view event categories.'],403);
            mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Categories loaded.','Categorydata'=>\Natcon\organizerCategories($db)]);
        }
        if($endpoint==='list_type.php'){
            if(!in_array($staff['role'],['admin','finance','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view ticket types.'],403);
            mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Ticket types loaded.','TypePricedata'=>\Natcon\organizerTicketTypes($db,clean($in['event_id']??'',32))]);
        }
        if($staff['role']!=='admin')mobileReply(['Result'=>'false','ResponseMsg'=>'Only Admin can manage NATCON events and ticket types.'],403);
        if(in_array($endpoint,['complete_event.php','cancle_event.php'],true)){$action=$endpoint==='complete_event.php'?'complete':'cancel';$saved=\Natcon\setOrganizerEventStatus($db,clean($in['event_id']??'',32),$action,(int)$staff['id']);mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>$action==='cancel'?'Event marked cancelled. Paid orders remain for staff-managed refunds.':'Event marked completed.','Eventdata'=>$saved]);}
        $in['_staff_id']=(int)$staff['id'];
        if(in_array($endpoint,['add_event.php','edit_event.php'],true)){
            $id=$endpoint==='edit_event.php'?filter_var($in['record_id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]):null;
            if($endpoint==='edit_event.php'&&!$id)throw new InvalidArgumentException('Choose a valid NATCON event.');
            $saved=\Natcon\saveOrganizerEvent($db,$in,$id?:null);
            mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>$endpoint==='add_event.php'?'Event created in the NATCON catalogue.':'Event updated in the NATCON catalogue.','Eventdata'=>$saved]);
        }
        $id=$endpoint==='edit_type.php'?filter_var($in['record_id']??null,FILTER_VALIDATE_INT,['options'=>['min_range'=>1]]):null;
        if($endpoint==='edit_type.php'&&!$id)throw new InvalidArgumentException('Choose a valid ticket type.');
        \Natcon\saveOrganizerTicketType($db,$in,$id?:null);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>$endpoint==='add_type.php'?'Ticket type created.':'Ticket type updated.']);
    }
    if($client==='orag_api'&&in_array($endpoint,['list_event.php','event_status_wise.php'],true)){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        if(!in_array($staff['role'],['admin','finance','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view event records.'],403);
        $events=\Natcon\organizerEvents($db);
        if($endpoint==='event_status_wise.php'){$filter=strtolower(clean($in['status']??'',20));$events=array_values(array_filter($events,static fn($e)=>match($filter){'today','active'=>strtolower($e['event_progress'])==='today','past','completed'=>strtolower($e['event_progress'])==='past','upcoming'=>strtolower($e['event_progress'])==='upcoming',default=>false}));mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Events loaded.','order_data'=>array_map(static fn($e)=>['event_id'=>$e['event_id'],'event_title'=>$e['event_title'],'event_img'=>$e['event_image'],'event_sdate'=>$e['event_start_date'],'event_place_name'=>$e['event_place_name']],$events)]);}
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Events loaded.','Eventdata'=>$events]);
    }
    if($client==='orag_api'&&$endpoint==='event_information.php'){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        if(!in_array($staff['role'],['admin','finance','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Your role cannot view event records.'],403);
        $detail=\Natcon\organizerEventDetails($db,clean($in['event_id']??'',32));mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Event details loaded.','Eventdata'=>$detail]);
    }
    if($client==='orag_api'&&in_array($endpoint,['qr_ticket_verify.php','id_ticket_verify.php'],true)){
        $staff=staffForToken($db);if(!$staff)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        if(!in_array($staff['role'],['admin','registrar'],true))mobileReply(['Result'=>'false','ResponseMsg'=>'Only registrar staff can scan tickets.'],403);
        $token=clean($in['ticket_id']??'',64);
        if($endpoint==='id_ticket_verify.php'){
            $code=clean($in['ticket_code']??'',100);
            $matches=query($db,'SELECT ticket_token FROM natcon_delegates WHERE id=? OR reference=? ORDER BY id LIMIT 2',[$code,$code])->fetchAll();
            if(count($matches)!==1)mobileReply(['Result'=>'false','ResponseMsg'=>count($matches)>1?'This booking has multiple delegates. Scan each personal ticket QR code.':'Ticket code was not found.'],404);
            $token=$matches[0]['ticket_token'];
        }
        $result=\Natcon\checkin($db,$c,$token,'arrival',(int)$staff['id']);
        mobileReply(['Result'=>$result['result']==='accepted'?'true':'false','ResponseMsg'=>$result['result']==='accepted'?'Ticket accepted.':'This ticket has already been checked in.','ticket'=>$result['delegate']]);
    }
    if($client==='user_api'&&$endpoint==='u_profile_edit.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        if((string)($in['uid']??'')!==(string)$account['id'])mobileReply(['Result'=>'false','ResponseMsg'=>'Account does not match this session.'],403);
        $updated=updateAccountProfile($db,(int)$account['id'],$in);
        mobileReply(['Result'=>'true','ResponseMsg'=>'Profile updated.','UserLogin'=>mobileAccountPayload($updated)]);
    }
    if($client==='user_api'&&$endpoint==='pro_image.php'){$account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);if((string)($in['uid']??'')!==(string)$account['id'])mobileReply(['Result'=>'false','ResponseMsg'=>'Account does not match this session.'],403);limit($db,'profile-image:'.$account['id'],12,3600);$updated=updateAccountProfileImage($db,(int)$account['id'],$in);mobileReply(['Result'=>'true','ResponseMsg'=>'Profile photo updated.','UserLogin'=>mobileAccountPayload($updated)]);}
    if($client==='user_api'&&$endpoint==='ticket_status_wise.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Tickets loaded.','order_data'=>mobileTicketHistory($db,(int)$account['id'],$c)]);
    }
    if($client==='user_api'&&$endpoint==='ticket_information.php'){
        $account=accountForToken($db);if(!$account)mobileReply(['Result'=>'false','ResponseMsg'=>'Please sign in.'],401);
        $token=clean($in['ticket_id']??'',64);
        mobileReply(['ResponseCode'=>'200','Result'=>'true','ResponseMsg'=>'Ticket loaded.','TicketData'=>mobileTicketInfo($db,(int)$account['id'],$token,$c)]);
    }
    mobileReply(['Result'=>'false','ResponseMsg'=>'This feature is not connected to NATCON yet.'],404);
} catch(InvalidArgumentException $e) {
    if(http_response_code()<400)http_response_code(400);
    mobileReply(['Result'=>'false','ResponseMsg'=>$e->getMessage()],http_response_code());
} catch(Throwable $e) {
    error_log('NATCON mobile API: '.$e->getMessage());
    mobileReply(['Result'=>'false','ResponseMsg'=>'The conference service is temporarily unavailable.'],503);
}

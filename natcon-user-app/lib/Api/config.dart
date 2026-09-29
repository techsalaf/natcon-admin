class Config {

  static const String imageUrl = String.fromEnvironment('NATCON_BASE_URL', defaultValue: 'https://unconfigured.invalid/');

  static const paymentBaseUrl = imageUrl;

  static final String baseurl = '${imageUrl.replaceFirst(RegExp(r'/+$'), '')}/user_api/';

  static const String notificationUrl = 'https://fcm.googleapis.com/fcm/send';

  static  String? firebaseKey ;

  static String? projectID = "d***********";

  static const String oneSignel = "********************";

  static const String registerUser = 'u_reg_user.php';
  static const String mobileChack = 'mobile_check.php';
  static const String loginApi = 'u_login_user.php';
  static const String paymentgatewayApi = 'u_paymentgateway.php';
  static const String pageListApi = 'u_pagelist.php';
  static const String couponlist = 'u_couponlist.php';
  static const String couponCheck = 'u_check_coupon.php';
  static const String forgetPassword = 'u_forget_password.php';
  static const String updateProfilePic = 'pro_image.php';
  static const String faqApi = 'u_faq.php';
  static const String editProfileApi = 'u_profile_edit.php';
  static const String homeDataApi = 'u_home_data.php';

  static const String walletReportApi = "u_wallet_report.php";
  static const String walletUpdateApi = 'u_wallet_up.php';

  static const String eventDetails = 'u_event_data.php';
  static const String ticketApi = 'u_event_type_price.php';

  static const String favORUnFav = "u_fav.php";
  static const String favoriteList = "u_favlist.php";

  static const String bookEventApi = "book_ticket.php";

  static const String myOrderHistory = "ticket_status_wise.php";
  static const String ticketInformetion = "ticket_information.php";

  static const String searchEvent = "u_search_event.php";

  static const String ticketCancle = "ticket_cancle.php";
  static const String deletAccount = "acc_delete.php";

  static const String referAndEarn = "getdata.php";

  static const String notificationApi = "notification.php";

  static const String catWiseEvent = "u_cat_event.php";
  static const String orderReview = "rate_update.php";

  static const String eventStatusWise = "event_status_wise.php";
  static const String joinUserList = "joined_user.php";

  static const String smsType = "sms_type.php";
  static const String msgOtp = "msg_otp.php";
  static const String twilioOtp = "twilio_otp.php";
  static const String payStackApi = "paystack/index.php";


}

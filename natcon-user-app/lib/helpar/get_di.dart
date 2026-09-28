import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/bookevent_controller.dart';
import '../controller/coupon_controller.dart';
import '../controller/eventdetails_controller.dart';
import '../controller/faq_controller.dart';
import '../controller/favorites_controller.dart';
import '../controller/home_controller.dart';
import '../controller/login_controller.dart';
import '../controller/mybooking_controller.dart';
import '../controller/notification_controller.dart';
import '../controller/org_controller.dart';
import '../controller/pagelist_controller.dart';
import '../controller/search_controller.dart';
import '../controller/signup_controller.dart';
import '../controller/wallet_controller.dart';

init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => LoginController());
  Get.lazyPut(() => SignUpController());
  Get.lazyPut(() => HomePageController());
  Get.lazyPut(() => PageListController());
  Get.lazyPut(() => WalletController());
  Get.lazyPut(() => EventDetailsController());
  Get.lazyPut(() => FavoriteController());
  Get.lazyPut(() => CouponController());
  Get.lazyPut(() => BookEventController());
  Get.lazyPut(() => MyBookingController());
  Get.lazyPut(() => SearchController());
  Get.lazyPut(() => FaqController());
  Get.lazyPut(() => NotificationController());
  Get.lazyPut(() => OrgController());
}

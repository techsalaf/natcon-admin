// ignore_for_file: unused_field, library_private_types_in_public_api, camel_case_types, unused_import, prefer_const_constructors, file_names, duplicate_ignore, unused_local_variable

import 'dart:developer';
import 'dart:io';

// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:magicmate_organizer/Dashboard/Dashboard_screen.dart';
import 'package:magicmate_organizer/Dashboard/Qr%20View/qrview_screen.dart';
import 'package:magicmate_organizer/Dashboard/Today_event/Todayevent_screen.dart';
import 'package:magicmate_organizer/Dashboard/notificatin_screen.dart';
import 'package:magicmate_organizer/Dashboard/payout/payout_screen.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Dashboard_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Todayevent_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/eventdetails_controller.dart';
import 'package:magicmate_organizer/Profile_Screen/Profilescreen.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:magicmate_organizer/utils/dark_light_mode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Login_flow/Login_screen.dart';
import 'firebase/chat_page.dart';

int selectedIndex = 0;

class BottoBarScreen extends StatefulWidget {
  const BottoBarScreen({Key? key}) : super(key: key);

  @override
  _BottoBarScreenState createState() => _BottoBarScreenState();
}

class _BottoBarScreenState extends State<BottoBarScreen> with WidgetsBindingObserver, TickerProviderStateMixin  {

  StatuswiseeventController statuswiseeventController = Get.put(StatuswiseeventController());
  DashboardController dashboardController = Get.put(DashboardController());

  late int _lastTimeBackButtonWasTapped;
  static const exitTimeInMillis = 2000;

  late TabController tabController;

  @override
  void initState() {
    getDarkMode();
    WidgetsBinding.instance.addObserver(this);
    _updateUserStatus(true);
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }


  List<Widget> myChilders = [
    DashboardScreen(),
    Todayeventscreen(status: "Today event", hideStatus: "2"),
    MyPayoutScreen(status: "2"),
    ProfileScreen(),
  ];

  var qrText = "";
  Map qrCodeResult = {};
  String qCodeResult = "";
  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _updateUserStatus(true);
        break;
      case AppLifecycleState.inactive:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.paused:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.detached:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _updateUserStatus(bool isOnline) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserStatus(getData.read("UserLogin")["id"], isOnline);
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return PopScope(
      onPopInvoked: (didPop) {
        exit(0);
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: getData.read("AccountType") == "SCANNER" ? const EdgeInsets.only(bottom: 15) : const EdgeInsets.only(left: 4),
          child: FloatingActionButton(
            backgroundColor: appcolor,
            onPressed: () async {
              save("openCamera", true);
              Get.to(QrViewScreen(), duration: Duration(seconds: 1));
              // ScanResult codeScanner = await BarcodeScanner.scan();

              // setState(
              //   () {
              //     qCodeResult = codeScanner.rawContent;
              //   },
              // );
              // if (qCodeResult.isNotEmpty) {
              //   // print("Yagnik QRCode--->" + qCodeResult.toString());

              //   // Get.to(
              //   //   () => TicketDetailPage(tikitdata: qCodeResult),
              //   // );
              // } else {
              //   ApiWrapper.showToastMessage("Plese Scan Qr Code");
              // }
              // qCodeResult = "";
            },
            child: Container(
              margin: EdgeInsets.all(15.0),
              child: Image.asset(
                "assets/qrcode,scan.png",
              ),
            ),
            elevation: 4.0,
          ),
        ),
        bottomNavigationBar: getData.read("AccountType") == "SCANNER"
            ? SizedBox()
            : BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: greycolor,
          backgroundColor: notifier.background,
          elevation: 0,
          selectedLabelStyle:
              const TextStyle(fontFamily: 'Gilroy Bold', fontSize: 12),
          fixedColor: appcolor,
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Gilroy Medium',
          ),
          currentIndex: selectedIndex,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
                icon: Image.asset("assets/dashboard.png",
                    color: selectedIndex == 0 ? appcolor : greycolor,
                    height: MediaQuery.of(context).size.height / 40),
                label: 'Home'.tr),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(right: 35),
                  child: Image.asset("assets/Bookmark1.png",
                      color: selectedIndex == 1 ? appcolor : greycolor,
                      height: MediaQuery.of(context).size.height / 37),
                ),
                label: 'Booking            '.tr),
            BottomNavigationBarItem(
              backgroundColor: transparent,
              icon: Padding(
                padding: const EdgeInsets.only(left: 35),
                child: Image.asset("assets/Wallet.png",
                    color: selectedIndex == 2 ? appcolor : greycolor,
                    height: MediaQuery.of(context).size.height / 35),
              ),
              label: '           Payout'.tr,
            ),
            BottomNavigationBarItem(
              icon: Image.asset("assets/user.png",
                  color: selectedIndex == 3 ? appcolor : greycolor,
                  height: MediaQuery.of(context).size.height / 35),
              label: 'Profile'.tr,
            ),
          ],
          onTap: (index) {
            if (index == 1) {
              statuswiseeventController.statuswiseevent(status: "Today");
            } else if (index == 2) {
              dashboardController.dashboard();
            }
            setState(() {});
            selectedIndex = index;
          },
        ),
        body: getData.read("AccountType") == "SCANNER" ? PreferredSize(
          preferredSize: Size(double.infinity, 60),
          child: AppBar(
            // automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: WhiteColor,
            leading: Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 15, right: 5),
              child: Image.asset("assets/Logo1.png", height: 40, width: 40),
            ),
            title: Text(
              "Hello, ${getData.read("UserLogin")[getData.read("AccountType") == "SCANNER" || getData.read("AccountType") == "MANAGER" ? "${"name"}" : "${"title"}"]}",
              maxLines: 1,
              style: TextStyle(
                fontFamily: FontFamily.gilroyExtraBold,
                color: appcolor,
                fontSize: 18,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: [
              InkWell(
                onTap: () async {
                  logoutSheet();
                  },
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.only(top: 8),
                  decoration:
                  BoxDecoration(shape: BoxShape.circle, color: bgcolor),
                  child: Image.asset(
                    "assets/logout.png",
                    color: appcolor,
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        )  : myChilders[selectedIndex],
      ),
    );
  }
  Future logoutSheet() {
    return Get.bottomSheet(
      Container(
        height: 220,
        width: Get.size.width,
        decoration: BoxDecoration(
          color: notifier.containerColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Logout".tr,
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: FontFamily.gilroyBold,
                  color: RedColor),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: greycolor),
            ),
            SizedBox(height: 10),
            Text(
              "Are you sure you want to log out?".tr,
              style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 16,
                  color: notifier.textColor),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(
                            color:  appcolor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16),
                      ),
                      decoration: BoxDecoration(
                        color: appcolor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final base = AppUrl.imageurl.replaceFirst(RegExp(r'/+$'), '');
                      try {
                        await NatconHttp.post(Uri.parse('$base/api/natcon.php?action=logout'), body: '{}');
                      } catch (_) {
                        // Local sign-out must still finish if the device is offline.
                      }
                      setState(() {
                        getData.remove('Firstuser');
                        getData.remove('Remember');
                        getData.remove('UserLogin');
                        getData.remove('NATCON_ACCESS_TOKEN');
                        Get.offAll(LoginScreen());
                      });
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes, Logout".tr,
                        style: TextStyle(
                            color: WhiteColor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16),
                      ),
                      decoration: BoxDecoration(
                          gradient: gradient.btnGradient,
                          borderRadius: BorderRadius.circular(45)),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
// ignore_for_file: unused_field, library_private_types_in_public_api, camel_case_types, unused_import, prefer_const_constructors, file_names, sort_child_properties_last

// import 'dart:developer';

// import 'package:magicmate_organizer/Booking_Screen/Bookingscreen.dart';
// import 'package:magicmate_organizer/Dashboard/Dashboard_screen.dart';
// import 'package:magicmate_organizer/Login_flow/Login_screen.dart';
// import 'package:magicmate_organizer/Message_Screen/Massagescreen.dart';
// import 'package:magicmate_organizer/Profile_Screen/Profilescreen.dart';
// import 'package:magicmate_organizer/api_screens/data_store.dart';
// import 'package:magicmate_organizer/utils/Colors.dart';
// import 'package:magicmate_organizer/utils/Fontfamily.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// int selectedIndex = 0;

// class BottoBarScreen extends StatefulWidget {
//   const BottoBarScreen({super.key});

//   @override
//   State<BottoBarScreen> createState() => _BottoBarScreenState();
// }

// late TabController tabController;

// class _BottoBarScreenState extends State<BottoBarScreen>
//     with TickerProviderStateMixin {
//   // WalletController walletController = Get.find();
//   // DashBoardController dashBoardController = Get.find();
//   // ListOfPropertiController listOfPropertiController = Get.find();
//   // SelectCountryController selectCountryController = Get.find();

//   int _currentIndex = 0;
//   int _selectIndex = 0;

//   var isLogin;

//   List<Widget> myChilders = [
//     DashboardScreen(),
//     Bookingscreen(),
//     Massagescreen(),
//     Profilescreen(),
//   ];

//   // late ColorNotifire notifire;
//   // getdarkmodepreviousstate() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   bool? previusstate = prefs.getBool("setIsDark");
//   //   if (previusstate == null) {
//   //     notifire.setIsDark = false;
//   //   } else {
//   //     notifire.setIsDark = previusstate;
//   //   }
//   // }

//   @override
//   void initState() {
//     super.initState();
//     // dashBoardController.getDashBoardData();
//     // isLogin = getData.read("UserLogin");
//     tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // notifire = Provider.of<ColorNotifire>(context, listen: true);
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: TabBarView(
//         physics: const NeverScrollableScrollPhysics(),
//         controller: tabController,
//         children: myChilders,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: FloatingActionButton(
//           backgroundColor: appcolor,
//           onPressed: () {
//             // if (isLogin != null) {
//             //   if (dashBoardController.dashBoardInfo?.isSubscribe == 1) {
//             //     dashBoardController.getDashBoardData();
//             //     listOfPropertiController.getPropertiList();
//             //     selectCountryController.getCountryApi();
//             //     Get.to(MembershipScreen());
//             //   } else {
//             //     selectCountryController.getCountryApi();
//             //     Get.to(BoardingPage());
//             //   }
//             // } else {
//             //   Get.to(() => LoginScreen());
//             // }
//           },
//           child: Container(
//             margin: EdgeInsets.all(15.0),
//             child: Image.asset(
//               "assets/bolt.png",
//             ),
//           ),
//           elevation: 4.0,
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: bgcolor,
//         child: TabBar(
//           onTap: (index) {
//             // setState(() {});
//             // if (isLogin != null) {
//             //   _currentIndex = index;
//             // } else {
//             //   index != 0 ? Get.to(() => LoginScreen()) : const SizedBox();
//             // }
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//           indicator: UnderlineTabIndicator(
//             insets: EdgeInsets.only(bottom: 52),
//             borderSide: BorderSide(color: bgcolor, width: 2),
//           ),
//           labelColor: Colors.blueAccent,
//           indicatorSize: TabBarIndicatorSize.label,
//           unselectedLabelColor: Colors.grey,
//           controller: tabController,
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           tabs: [
//             Tab(
//               child: Column(
//                 children: [
//                   _currentIndex == 0
//                       ? Image.asset(
//                           "assets/dashboard.png",
//                           scale: 4.5,
//                           color: appcolor,
//                         )
//                       : Image.asset(
//                           "assets/dashboard.png",
//                           scale: 4.5,
//                           color: BlackColor,
//                         ),
//                   SizedBox(height: 3),
//                   Text(
//                     "Home",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: FontFamily.gilroyMedium,
//                       color: _currentIndex == 0 ? appcolor : Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 50,
//               width: 80,
//               alignment: Alignment.topLeft,
//               child: Tab(
//                 child: Column(
//                   children: [
//                     _currentIndex == 1
//                         ? Image.asset(
//                             "assets/Bookmark.png",
//                             scale: 3.5,
//                             color: appcolor,
//                           )
//                         : Image.asset(
//                             "assets/Bookmark.png",
//                             scale: 3.5,
//                             color: BlackColor,
//                           ),
//                     SizedBox(height: 3),
//                     Text(
//                       "Search",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: FontFamily.gilroyMedium,
//                         color: _currentIndex == 1 ? appcolor : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               height: 50,
//               width: 80,
//               alignment: Alignment.topRight,
//               child: Tab(
//                 child: Column(
//                   children: [
//                     _currentIndex == 2
//                         ? Image.asset(
//                             "assets/message.png",
//                             scale: 3.8,
//                             color: appcolor,
//                           )
//                         : Image.asset(
//                             "assets/message.png",
//                             scale: 3.8,
//                             color: BlackColor,
//                           ),
//                     SizedBox(height: 3),
//                     Text(
//                       "Favorite",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: FontFamily.gilroyMedium,
//                         color: _currentIndex == 2 ? appcolor : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Tab(
//               child: Column(
//                 children: [
//                   _currentIndex == 3
//                       ? Image.asset(
//                           "assets/user.png",
//                           scale: 4.5,
//                           color: appcolor,
//                         )
//                       : Image.asset(
//                           "assets/user.png",
//                           scale: 4.5,
//                           color: BlackColor,
//                         ),
//                   SizedBox(height: 3),
//                   Text(
//                     "Account",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontFamily: FontFamily.gilroyMedium,
//                       color: _currentIndex == 3 ? appcolor : Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

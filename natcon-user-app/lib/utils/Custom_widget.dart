// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, file_names, sort_child_properties_last, camel_case_types, avoid_print
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../Api/config.dart';
import '../controller/home_controller.dart';
import '../model/fontfamily_model.dart';
import '../screen/bottombar_screen.dart';
import 'Colors.dart';

Button(
    {String? buttontext,
    Function()? onclick,
    double? Width,
    Color? buttoncolor}) {
  return GestureDetector(
    onTap: onclick,
    child: Container(
      height: 50,
      width: Width,
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: buttoncolor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Image.asset(
              "assets/images/phone.png",
              color: WhiteColor,
            ),
          ),
          Text(
            buttontext!,
            style: TextStyle(
              fontFamily: "Gilroy Bold",
              color: WhiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

GestButton({
  String? buttontext,
  Function()? onclick,
  double? Width,
  double? height,
  Color? buttoncolor,
  EdgeInsets? margin,
  TextStyle? style,
}) {
  return GestureDetector(
    onTap: onclick,
    child: Container(
      height: height,
      width: Width,
      // margin: EdgeInsets.only(top: 15, left: 30, right: 30),
      margin: margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        // color: buttoncolor,
        gradient: gradient.btnGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(
              0.5,
              0.5,
            ),
            blurRadius: 1,
          ),
        ],
      ),
      child: Text(buttontext!, style: style),
    ),
  );
}

ContinueButton({
  String? buttontext,
  Function()? onclick,
  double? Width,
  double? height,
  Color? buttoncolor,
  EdgeInsets? margin,
  TextStyle? style,
}) {
  return GestureDetector(
    onTap: onclick,
    child: Container(
      height: height,
      width: Width,
      // margin: EdgeInsets.only(top: 15, left: 30, right: 30),
      margin: margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: buttoncolor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(
              0.5,
              0.5,
            ),
            blurRadius: 1,
          ),
        ],
      ),
      child: Text(buttontext!, style: style),
    ),
  );
}

showToastMessage(message) {
  Fluttertoast.showToast(
    msg: message,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: gradient.defoultColor.withOpacity(0.9),
    textColor: Colors.white,
    fontSize: 14.0,
  );
}


Future<void> initPlatformState() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(Config.oneSignel);
  OneSignal.Notifications.requestPermission(true).then(
        (value) {
      print("Signal value:- $value");
    },
  );
}

Future OrderPlacedSuccessfully() {
  HomePageController homePageController = Get.find();
  return Get.bottomSheet(
    enableDrag: false,
    PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Get.offAll(BottomBarScreen());
        Future.value(false);
      },
      child: Container(
        width: Get.size.width,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/SuccessfullyBooked.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Successfully Booked".tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 20,
                color: BlackColor,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "You’ve successfully book the ticket, for detailed \n information you can check on ticket page."
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                height: 1.4,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestButton(
              height: 50,
              Width: Get.size.width,
              margin: EdgeInsets.only(top: 10, left: 15, right: 15),
              buttontext: "Return to Homepage".tr,
              buttoncolor: gradient.defoultColor,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                color: WhiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              onclick: () {
                homePageController.getHomeDataApi();
                Get.offAll(BottomBarScreen());
              },
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          color: WhiteColor,
        ),
      ),
    ),
  );
}

class provider {
  static String discover = "Find your favorite events here".tr;
  static String healthy =
      "Connect, Discover, and Experience \n All with Join Event App!".tr;
  static String order = "Find your nearby event here".tr;
  static String orderthe =
      "Join the Fun - Your One \n Stop Destination for Events!".tr;
  static String lets = "Update your upcoming event here".tr;
  static String cooking =
      "Experience Life to the Fullest \n Join Event App has You Covered!".tr;
  static String getstart = "Get Started".tr;
  static String skip = "Skip".tr;
  static String next = "Next".tr;
}


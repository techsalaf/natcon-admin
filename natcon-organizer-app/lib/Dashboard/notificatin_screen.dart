// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, unnecessary_string_interpolations, unused_local_variable, must_be_immutable

import 'package:magicmate_organizer/Getx_controller.dart/notification_controller.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dark_light_mode.dart';

class NotificationScreen extends StatefulWidget {
  String? status;
  NotificationScreen({super.key, this.status});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationController notificationController = Get.find();

  @override
  void initState() {
    getDarkMode();
    super.initState();
  }

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
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.containerColor,
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        centerTitle: widget.status == "1" ? false : true,
        leading: widget.status == "1"
            ? IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: notifier.textColor,
                ),
              )
            : SizedBox(),
        title: Text(
          "Notification".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: notifier.textColor,
          ),
        ),
      ),
      body: GetBuilder<NotificationController>(builder: (context) {
        return Column(
          children: [
            Expanded(
              child: notificationController.isLoading
                  ? notificationController.notificationInfo!.notificationData.isNotEmpty
                      ? ListView.builder(
                          itemCount: notificationController
                              .notificationInfo?.notificationData.length,
                          itemBuilder: (context, index) {
                            String time =
                                "${DateFormat.jm().format(DateTime.parse("2023-03-20T${notificationController.notificationInfo?.notificationData[index].datetime.toString().split(" ").last}"))}";
                            return Container(
                              margin: EdgeInsets.all(10),
                              child: ListTile(
                                leading: Container(
                                  height: 60,
                                  width: 60,
                                  padding: EdgeInsets.all(15),
                                  child: Image.asset(
                                    "assets/Notification1.png",
                                    color: gradient.defoultColor,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFeef4ff),
                                  ),
                                ),
                                title: Text(
                                  notificationController.notificationInfo
                                          ?.notificationData[index].title ??
                                      "",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: FontFamily.gilroyBold,
                                    color: notifier.textColor,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      notificationController.notificationInfo
                                              ?.notificationData[index].datetime
                                              .toString()
                                              .split(" ")
                                              .first ??
                                          "",
                                      style: TextStyle(
                                        color: greycolor,
                                        fontFamily: FontFamily.gilroyMedium,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: greycolor,
                                        fontFamily: FontFamily.gilroyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: notifier.background,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Padding(
                              //   padding: const EdgeInsets.only(left: 30),
                              //   child: Image.asset(
                              //     "assets/images/bookingEmpty.png",
                              //     height: 120,
                              //     width: 120,
                              //   ),
                              // ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "We'll let you know when we\nget news for you".tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: greycolor,
                                  fontFamily: FontFamily.gilroyBold,
                                ),
                              )
                            ],
                          ),
                        )
                  : Center(
                      child: CircularProgressIndicator(
                        color: appcolor,
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}

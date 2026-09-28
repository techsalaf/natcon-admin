// ignore_for_file: file_names, unnecessary_brace_in_string_interps, avoid_print, must_be_immutable, prefer_const_constructors_in_immutables, non_constant_identifier_names

import 'package:magicmate_organizer/Login_flow/Login_screen.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dark_light_mode.dart';

class PasswordUpdate extends StatefulWidget {
  PasswordUpdate({super.key});

  @override
  State<PasswordUpdate> createState() => _PasswordUpdateState();
}

class _PasswordUpdateState extends State<PasswordUpdate> {
  String forgotpass = "";
  String Country = "";
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
      backgroundColor: notifier.background,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: AppButton(
          buttonColor: notifier.textColor,
          buttontext: "Back to Login".tr,
          onTap: () {
            Get.to(() => const LoginScreen());
          },
        ),
      ),
      appBar: appbar(title: "Password Update".tr),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Center(
                child: Padding(
              padding: EdgeInsets.only(left: 45, top: Get.height * 0.05),
              child: Image.asset("assets/update.png", height: 200, width: 250),
            )),
            Text(
              "Password updated!".tr,
              style: TextStyle(
                  fontFamily: "Gilroy Bold", color:  notifier.textColor, fontSize: 20),
            ),
            SizedBox(height: Get.height * 0.02),
            SizedBox(
              width: Get.width * 0.70,
              child: Text(
                "Your password has been setup successfully".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Gilroy Medium  ",
                    color: greycolor,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

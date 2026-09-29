// ignore_for_file: avoid_print, unused_local_variable, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../screen/choosefevorite_event.dart';
import '../utils/Custom_widget.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class SignUpController extends GetxController implements GetxService {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController number = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController referralCode = TextEditingController();
  bool showPassword = true;
  bool chack = false;
  int currentIndex = 0;
  String userMessage = "";
  String resultCheck = "";

  String signUpMsg = "";

  showOfPassword() {
    showPassword = !showPassword;
    update();
  }

  checkTermsAndCondition(bool? newbool) {
    chack = newbool ?? false;
    update();
  }

  cleanFild() {
    name.text = "";
    email.text = "";
    number.text = "";
    password.text = "";
    referralCode.text = "";
    chack = false;
    update();
  }

  changeIndex(int index) {
    currentIndex = index;
    update();
  }

  Future checkMobileNumber(String cuntryCode) async {
    try {
      Map map = {
        "mobile": number.text,
        "ccode": cuntryCode,
      };
      Uri uri = Uri.parse(Config.baseurl + Config.mobileChack);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        userMessage = result["ResponseMsg"];
        resultCheck = result["Result"];
        print("MMMMMMMMMMMMMMMMMM" + userMessage);
        if (resultCheck == "true") {

          // sendOTP(number.text, cuntryCode);
          // Get.toNamed(Routes.otpScreen, arguments: {
          //   "number": number.text,
          //   "cuntryCode": cuntryCode,
          //   "route": "signUpScreen",
          // });
          return response.body;
        }
        showToastMessage(userMessage);
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  Future checkMobileInResetPassword({String? number, String? cuntryCode}) async {
    try {
      Map map = {
        "mobile": number,
        "ccode": cuntryCode,
      };
      Uri uri = Uri.parse(Config.baseurl + Config.mobileChack);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );

      print("++++++++++ ${uri}");
      print("12345678890 ${map}");
      print("333333333333333 ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        userMessage = result["ResponseMsg"];
        resultCheck = result["Result"];
        if (resultCheck == "false") {
          // sendOTP(number ?? "", cuntryCode ?? "");
          // Get.toNamed(Routes.otpScreen, arguments: {
          //   "number": number,
          //   "cuntryCode": cuntryCode,
          //   "route": "resetScreen",
          // });
          return response.body;
        } else {
          showToastMessage('Invalid Mobile Number');
        }
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }


  setUserApiData(String cuntryCode) async {
    try {
      Map map = {
        "name": name.text,
        "email": email.text,
        "mobile": number.text,
        "ccode": cuntryCode,
        "password": password.text
      };
      Uri uri = Uri.parse(Config.baseurl + Config.registerUser);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        save('Firstuser', true);
        signUpMsg = result["ResponseMsg"];
        showToastMessage(signUpMsg);
        save("UserLogin", result["UserLogin"]);
        save('NATCON_ACCESS_TOKEN', result['AccessToken']);
        // OneSignal.shared.sendTag("user_id", getData.read("UserLogin")["id"]);
        OneSignal.User.addTagWithKey("user_id", getData.read("UserLogin")["id"]);
        Get.offAll(const ChooseFevoriteEvent());
        update();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  editProfileApi({String? name, String? password, String? email}) async {
    try {
      Map map = {
        "name": name,
        "uid": getData.read("UserLogin")["id"].toString(),
        "password": password,
        "email": email,
      };
      Uri uri = Uri.parse(Config.baseurl + Config.editProfileApi);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        save("UserLogin", result["UserLogin"]);
        showToastMessage(result["ResponseMsg"]);
      }
      Get.back();
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

class CustomTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final VoidCallback onTriggered;

  CustomTooltip({
    required this.child,
    required this.message,
    required this.onTriggered,
  });

  @override
  _CustomTooltipState createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  final GlobalKey _key = GlobalKey();

  void _showTooltip() {
    final dynamic tooltip = _key.currentState;
    tooltip.ensureTooltipVisible();
    widget.onTriggered();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showTooltip,
      child: Tooltip(
        key: _key,
        message: widget.message,
        child: widget.child,
      ),
    );
  }
}

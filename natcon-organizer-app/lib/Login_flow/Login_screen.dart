// ignore_for_file: file_names, unnecessary_brace_in_string_interps, avoid_print, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:magicmate_organizer/Bottombar_screen.dart';
import 'package:magicmate_organizer/Login_flow/Resend_Code.dart';
import 'package:magicmate_organizer/Login_flow/Sign_up.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dark_light_mode.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
List<String> status = ["Admin", "Finance", "Registrar"];

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool _obscureText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  @override
  void initState() {
   getDarkMode();
    super.initState();
  }

  String loginpage = "";
  bool isChecked = false;
  final _formKey = GlobalKey<FormState>();
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

  String slectStatus = status.first;
  String statusType = "Admin";

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return PopScope(
      onPopInvoked: (didPop) {
        exit(0);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: notifier.background,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: InkWell(
            onTap: () {
              Get.to(() => Singup());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don’t have an account?".tr,
                  style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      color: greycolor,
                      fontSize: 16),
                ),
                SizedBox(width: Get.width * 0.01),
                Text(
                  "Sign Up".tr,
                  style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: appcolor,
                      fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: Stack(
                children: [
                  Positioned(
                      right: 0,
                      child: Image.asset("assets/pattern.png",
                          height: 170, width: 170)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Get.height * 0.12),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            "assets/Logo1.png",
                            height: 50,
                            width: 50,
                          ),
                        ),
                        // SizedBox(height: Get.height * 0.015),
                        Text(
                          "Welcome Back! 👋".tr,
                          style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: notifier.textColor,
                              fontSize: 22),
                        ),
                        SizedBox(height: Get.height * 0.005),
                        Text(
                          "Sign in to your account".tr,
                          style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: greycolor,
                              fontSize: 16),
                        ),
                        SizedBox(height: Get.height * 0.03),
                        // Text(
                        //   "Enter Email",
                        //   style: TextStyle(
                        //       fontFamily: FontFamily.gilroyBold,
                        //       color: greycolor,
                        //       fontSize: 16),
                        // ),
                        // SizedBox(height: Get.height * 0.01),
                        passwordtextfield(
                          context: context,
                          controller: email,
                          lebaltext: "Email".tr,
                          prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset("assets/mail.png",
                                  height: 30, width: 30, color: greycolor)),
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Get.height * 0.03),
                        // Text(
                        //   "Enter Password",
                        //   style: TextStyle(
                        //       fontFamily: FontFamily.gilroyBold,
                        //       color: greycolor,
                        //       fontSize: 16),
                        // ),
                        // SizedBox(height: Get.height * 0.01),
                        passwordtextfield(
                          context: context,
                          lebaltext: "Password".tr,
                          controller: password,
                          obscureText: _obscureText,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Password'.tr;
                            }
                            return null;
                          },
                          prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Image.asset("assets/lock.png",
                                  height: 30, width: 30, color: greycolor)),
                          suffixIcon: InkWell(
                              onTap: () {
                                _toggle();
                              },
                              child: !_obscureText
                                  ? Icon(
                                      Icons.visibility,
                                      color: appcolor,
                                    )
                                  : Icon(
                                      Icons.visibility_off,
                                      color: greycolor,
                                    )),
                        ),
                        SizedBox(height: Get.height * 0.03),

                        Container(
                          height: 60,
                          width: Get.size.width,
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: DropdownButton(
                            dropdownColor: notifier.background,
                            value: slectStatus,
                            icon: Image.asset(
                              'assets/Arrowdown.png',
                              height: 20,
                              width: 20,
                            ),
                            isExpanded: true,
                            underline: SizedBox.shrink(),
                            items: status
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: notifier.textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              statusType = value ?? "Admin";
                              setState(() {
                                slectStatus = value ?? "";
                                // listOfUser.add(selectValue);
                              });
                            },
                          ),
                          decoration: BoxDecoration(
                            color: notifier.background,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),



                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: greycolor),
                                  child: Checkbox(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                    value: isChecked,
                                    activeColor: appcolor,
                                    checkColor: WhiteColor,
                                    onChanged: (value) {
                                      setState(() {
                                        isChecked = value!;
                                        save("Remember", value);
                                      });
                                    },
                                  ),
                                ),
                                Text(
                                  "Remember Me".tr,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Gilroy Bold",
                                      color: notifier.textColor),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => ResendCode());
                              },
                              child: Center(
                                child: Text(
                                  "Forgot password?".tr,
                                  style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      color: appcolor,
                                      fontSize: 17),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Get.height * 0.1),
                        AppButton(
                            buttontext: "Login".tr,
                            textcolor: WhiteColor,
                            onTap: () {
                              if ((_formKey.currentState?.validate() ?? false)) {
                                setState(() {
                                 isLoged = true;
                                });
                                login(email: email.text, password:  password.text, type: statusType);
                                // print("dfkdgjdfvfhvfu ${statusType}");
                              }
                            },
                            gradientcolor: gradient.btnGradient),
                        SizedBox(height: Get.height * 0.03),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isLoged ? Center(child: CircularProgressIndicator()) : SizedBox(),
          ],
        ),
      ),
    );
  }
  bool isLoged = false;
  login({required String email, required String password, required String type}) async {
    try {
      Map map = {
        "email": email,
        "password": password,
        "type": type
      };
      Uri uri = Uri.parse(AppUrl.login);
      var response = await NatconHttp.post(uri, body: jsonEncode(map));
      print("++++++++++++++++++++ ${response.body}");
      print("-------------------- ${map}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        loginpage = result["Result"];
        save("Firstuser", true);
        setState(() {
          save("UserLogin", result["OragnizerLogin"]);
          save("currency", result["currency"]);
          save("AccountType", result["Type"]);
          print("type:------------- ${result["Type"]}");
        });
        print("*********************${loginpage}");

        if (loginpage == "true") {
          save("NATCON_ACCESS_TOKEN", result["AccessToken"]);
          print("+++++++++++++++ ${statusType}");

          print("Id: ${getData.read("UserLogin")["id"]}");
          OneSignal.User.addTagWithKey("orag_id", getData.read("UserLogin")["id"]);

          print("Name: ${result["OragnizerLogin"]["name"]}");
          print("Email: ${result["OragnizerLogin"]["email"]}");
          print("Phone: ${result["OragnizerLogin"]["mobile"]}");
          print("Image: ${result["OragnizerLogin"]["img"]}");
          Get.to(() => BottoBarScreen());
          setState(() {
            isLoged = false;
          });
          // OneSignal.shared.sendTag("orag_id", getData.read("UserLogin")["id"]);
          // print("+++++++++++++++++++++++++++++++++++++++++++ ${data}");
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        } else {
          setState(() {
            isLoged = false;
          });
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
      } else {
        setState(() {
          isLoged = false;
        });
      }
      // update();
    } catch (e) {
      setState(() {
        isLoged = false;
      });
      print(e.toString());
    }
  }
}
// Future<void> initPlatformState() async {
//   OneSignal.shared.setAppId(AppUrl.oneSignel);
//   OneSignal.shared
//       .promptUserForPushNotificationPermission()
//       .then((accepted) {});
//   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//     print("Accepted OSPermissionStateChanges : $changes");
//   });
//   // print("--------------__uID : ${getData.read("UserLogin")["id"]}");
// }
Future<void> initPlatformState() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize(AppUrl.oneSignel);
  OneSignal.Notifications.requestPermission(true).then(
        (value) {
      print("Signal value:- $value");
    },
  );
}

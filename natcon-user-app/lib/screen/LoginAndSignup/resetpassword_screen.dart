// ignore_for_file: prefer_const_constructors, must_be_immutable, use_key_in_widget_constructors, unnecessary_string_interpolations, sort_child_properties_last

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../controller/login_controller.dart';
import '../../controller/msg_otp_controller.dart';
import '../../controller/signup_controller.dart';
import '../../controller/sms_type_controller.dart';
import '../../controller/twillio_otp_controller.dart';
import '../../helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  static String verifay = "";

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  SignUpController signUpController = Get.find();

  TextEditingController number = TextEditingController();

  String cuntryCode = "";

  final _formKey = GlobalKey<FormState>();
  SmsTypeController smsTypeController = Get.put(SmsTypeController());
  MsgOtpController msgOtpController = Get.put(MsgOtpController());
  TwilioOtpController twilioOtpController = Get.put(TwilioOtpController());
  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: transparent,
        height: Get.height,
        child: Stack(
          children: [
            Container(
              height: Get.height * 0.35,
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: Get.height * 0.05),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(13),
                          margin: EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/back.png',
                            color: WhiteColor,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF000000).withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Get.width * 0.25,
                      ),
                      Text(
                        "Reset Password".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 17,
                          color: WhiteColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.size.height * 0.025,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?".tr,
                        style: TextStyle(
                          color: WhiteColor,
                          fontFamily: FontFamily.gilroyMedium,
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(LoginScreen());
                        },
                        child: Text(
                          " Login Now".tr,
                          style: TextStyle(
                            color: Color(0xFFFBBC04),
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.size.height * 0.04,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Image.asset(
                      "assets/Rectangle326.png",
                      height: 25,
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                gradient: gradient.btnGradient,
              ),
            ),
            Positioned(
              top: Get.height * 0.22,
              child: Container(
                height: Get.size.height,
                width: Get.size.width,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    // SizedBox(
                    //   height: Get.height * 0.005,
                    // ),
                    Text(
                      "Please enter your phone number to request a\npassword reset"
                          .tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: BlackColor,
                        fontFamily: "Gilroy Medium",
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: IntlPhoneField(
                          keyboardType: TextInputType.number,
                          cursorColor: BlackColor,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          initialCountryCode: 'IN',
                          controller: number,
                          onChanged: (value) {
                            cuntryCode = value.countryCode;
                          },
                          onCountryChanged: (value) {
                            number.text = '';
                          },
                          dropdownIcon: Icon(
                            Icons.arrow_drop_down,
                            color: greycolor,
                          ),
                          dropdownTextStyle: TextStyle(
                            color: greycolor,
                          ),
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: BlackColor,
                          ),
                          decoration: InputDecoration(
                            helperText: null,
                            labelText: "Mobile Number".tr,
                            labelStyle: TextStyle(
                              color: greycolor,
                              fontFamily: FontFamily.gilroyMedium,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (p0) {
                            if (p0!.completeNumber.isEmpty) {
                              return 'Please enter your number'.tr;
                            } else {}
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestButton(
                      Width: Get.size.width,
                      height: 50,
                      buttoncolor: gradient.defoultColor,
                      margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                      buttontext: "Request OTP".tr,
                      style: TextStyle(
                        fontFamily: "Gilroy Bold",
                        color: WhiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      onclick: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if(number.text.isNotEmpty){
                            signUpController.checkMobileInResetPassword(number: number.text, cuntryCode: cuntryCode).then((value) {
                              print("++++++++ ${value}");
                              var decodeValue = jsonDecode(value);
                              print("----------- $decodeValue");
                              if(decodeValue["Result"] == "false"){
                                smsTypeController.smsTypeApi().then((smsType) {
                                  // print("********************** ${smsType}");
                                  if(smsType["Result"] == "true"){
                                    if(smsType["otp_auth"] == "No"){
                                      forgetPasswordBottomSheet();
                                      showToastMessage(signUpController.signUpMsg);
                                    } else{
                                      if(smsType["SMS_TYPE"] == "Firebase"){
                                        sendOTP(number.text, cuntryCode);
                                        Get.toNamed(Routes.otpScreen, arguments: {
                                          "number": number.text,
                                          "cuntryCode": cuntryCode,
                                          "route": "resetScreen",
                                          "msgType": smsType["SMS_TYPE"].toString,
                                        });
                                      }else if (smsType["SMS_TYPE"] == "Msg91"){
                                        //  msg_otp;
                                        msgOtpController.msgOtpApi(mobile: "$cuntryCode${number.text}").then((msgOtp) {
                                          if(msgOtp["Result"] == "true"){
                                            Get.toNamed(Routes.otpScreen, arguments: {
                                              "number": number.text,
                                              "cuntryCode": cuntryCode,
                                              "route": "resetScreen",
                                              "otpCode": msgOtp["otp"].toString(),
                                              "msgType": smsType["SMS_TYPE"].toString,
                                            });
                                            print("++++++++msgOtp+++++++++++ ${msgOtp["otp"]}");
                                          }else{
                                            showToastMessage("Invalid mobile number");
                                          }
                                        },);
                                      }else if(smsType["SMS_TYPE"] == "Twilio"){
                                        twilioOtpController.twilioOtpApi(mobile: "$cuntryCode${number.text}").then((twilioOtp) {
                                          print("---------- $twilioOtp");
                                          if(twilioOtp["Result"] == "true"){
                                            Get.toNamed(Routes.otpScreen, arguments: {
                                              "number": number.text,
                                              "cuntryCode": cuntryCode,
                                              "route": "resetScreen",
                                              "otpCode": twilioOtp["otp"].toString(),
                                              "msgType": smsType["SMS_TYPE"].toString,
                                            });
                                            print("++++++++twilioOtp+++++++++++ ${twilioOtp["otp"]}");
                                          }else{
                                            showToastMessage("Invalid mobile number");
                                          }
                                        },);
                                      }else{}
                                    }
                                  }
                                  else{
                                    showToastMessage("Invalid mobile number");
                                  }
                                },);

                              }else{
                                showToastMessage(decodeValue["ResponseMsg"]);
                              }
                            },);
                          }else{
                            showToastMessage("Please Enter Mobile Number");
                          }
                        }
                      },
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: WhiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Future forgetPasswordBottomSheet() {
    return Get.bottomSheet(
      GetBuilder<LoginController>(builder: (context) {
        return SingleChildScrollView(
          child: Container(
            height: 350,
            width: Get.size.width,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Forgot Password".tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: FontFamily.gilroyBold,
                    color: BlackColor,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Divider(
                    color: greycolor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 5, left: 15),
                  child: Text(
                    "Create Your New Password".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      color: BlackColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: loginController.newPassword,
                    obscureText: loginController.newShowPassword,
                    cursorColor: BlackColor,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: FontFamily.gilroyMedium,
                      color: BlackColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          loginController.newShowOfPassword();
                        },
                        child: !loginController.newShowPassword
                            ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/showpassowrd.png",
                            height: 10,
                            width: 10,
                            color: greycolor,
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/HidePassword.png",
                            height: 10,
                            width: 10,
                            color: greycolor,
                          ),
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          "assets/Unlock.png",
                          height: 10,
                          width: 10,
                          color: greycolor,
                        ),
                      ),
                      labelText: "Password".tr,
                      labelStyle: TextStyle(
                        color: greycolor,
                        fontFamily: FontFamily.gilroyMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: loginController.newConformPassword,
                    obscureText: loginController.conformPassword,
                    cursorColor: BlackColor,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      fontSize: 14,
                      color: BlackColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password'.tr;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: greycolor),
                      ),
                      suffixIcon: InkWell(
                        onTap: () {
                          loginController.newConformShowOfPassword();
                        },
                        child: !loginController.conformPassword
                            ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/showpassowrd.png",
                            height: 10,
                            width: 10,
                            color: greycolor,
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/HidePassword.png",
                            height: 10,
                            width: 10,
                            color: greycolor,
                          ),
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          "assets/Unlock.png",
                          height: 10,
                          width: 10,
                          color: greycolor,
                        ),
                      ),
                      labelText: "Conform Password".tr,
                      labelStyle: TextStyle(
                        color: greycolor,
                        fontFamily: FontFamily.gilroyMedium,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                GestButton(
                  Width: Get.size.width,
                  height: 50,
                  buttoncolor: gradient.defoultColor,
                  margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                  buttontext: "Continue".tr,
                  style: TextStyle(
                    fontFamily: "Gilroy Bold",
                    color: WhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: () {
                    if (loginController.newPassword.text ==
                        loginController.newConformPassword.text) {
                      loginController.setForgetPasswordApi(
                          ccode: cuntryCode, mobile: number.text);
                    } else {
                      showToastMessage("Please Enter Valid Password".tr);
                    }
                  },
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
        );
      }),
    );
  }
}

Future<void> sendOTP(String phonNumber, String cuntryCode,) async {
  print("andsjfcbdhv");
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: '${cuntryCode + phonNumber}',
    verificationCompleted: (PhoneAuthCredential credential) {},
    verificationFailed: (FirebaseAuthException e) {},
    timeout: Duration(seconds: 60),
    codeSent: (String verificationId, int? resendToken) {
      ResetPasswordScreen.verifay = verificationId;
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
}

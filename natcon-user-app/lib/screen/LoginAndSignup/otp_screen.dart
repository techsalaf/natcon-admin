// ignore_for_file: prefer_const_constructors, must_be_immutable, use_key_in_widget_constructors, unnecessary_brace_in_string_interps, avoid_print, sort_child_properties_last, unrelated_type_equality_checks

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_user/screen/LoginAndSignup/resetpassword_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../controller/login_controller.dart';
import '../../controller/msg_otp_controller.dart';
import '../../controller/signup_controller.dart';
import '../../controller/sms_type_controller.dart';
import '../../controller/twillio_otp_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import '../choosefevorite_event.dart';

class OtpScreen extends StatefulWidget {
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController pinPutController = TextEditingController();
  LoginController loginController = Get.find();
  SignUpController signUpController = Get.find();
  final _formKey = GlobalKey<FormState>();

  FirebaseAuth auth = FirebaseAuth.instance;

  String code = "";
  String phoneNumber = Get.arguments["number"];

  String countryCode = Get.arguments["cuntryCode"];
  String otpCode = Get.arguments["otpCode"].toString();

  String msgType = Get.arguments["msgType"].toString();

  String rout = Get.arguments["route"];

  int secondsRemaining = 30;
  bool enableResend = false;
  Timer? timer;

  @override
  initState() {
    smsTypeController.smsTypeApi();
    super.initState();
    startTimer();
    // timer = Timer.periodic(Duration(seconds: 1), (_) {
    //   if (secondsRemaining != 0) {
    //     setState(() {
    //       secondsRemaining--;
    //     });
    //   } else {
    //     setState(() {
    //       enableResend = true;
    //     });
    //   }
    // });
  }


  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  SmsTypeController smsTypeController = Get.put(SmsTypeController());
  MsgOtpController msgOtpController = Get.put(MsgOtpController());
  TwilioOtpController twilioOtpController = Get.put(TwilioOtpController());

  @override
  Widget build(BuildContext context)    {
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
                          height: 50,
                          width: 50,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.only(left: 10),
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
                        width: Get.width * 0.23,
                      ),
                      Text(
                        "Verification Code".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 17,
                          color: WhiteColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Get.size.height * 0.02,
                  ),
                  Text(
                    "${"We have sent the code verification to".tr}\n${countryCode} ${phoneNumber}",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontFamily: FontFamily.gilroyMedium,
                      color: WhiteColor,
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
                      height: 30,
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: PinCodeTextField(
                          appContext: context,
                          length: 6,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          cursorColor: gradient.defoultColor,
                          cursorHeight: 18,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 45,
                            fieldWidth: 45,
                            inactiveColor: gradient.defoultColor,
                            activeColor: gradient.defoultColor,
                            selectedColor: gradient.defoultColor,
                            activeFillColor: Colors.white,
                            inactiveFillColor: WhiteColor,
                            selectedFillColor: WhiteColor,
                            borderWidth: 1,
                          ),
                          animationDuration: Duration(milliseconds: 300),
                          backgroundColor: WhiteColor,
                          enableActiveFill: true,
                          controller: pinPutController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your otp'.tr;
                            }
                            return null;
                          },
                          onCompleted: (v) {
                            print("Completed");
                          },
                          onChanged: (value) {
                            code = value;
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");
                            return true;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive code?".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: greycolor,
                            ),
                          ),
                          enableResend ? InkWell(
                            onTap: () {
                              _resendCode();
                            },
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              child: Text(
                                " Resend New Code".tr,
                                style: TextStyle(
                                  color: gradient.defoultColor,
                                  fontFamily: FontFamily.gilroyBold,
                                ),
                              ),
                            ),
                          ) : Container(
                            height: 30,
                            alignment: Alignment.center,
                            child: Text(
                              " $secondsRemaining Seconds".tr,
                              style: TextStyle(
                                color: gradient.defoultColor,
                                fontFamily: FontFamily.gilroyBold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    GestButton(
                      Width: Get.size.width,
                      height: 50,
                      buttoncolor: gradient.defoultColor,
                      margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                      buttontext: "Verify".tr,
                      style: TextStyle(
                        fontFamily: "Gilroy Bold",
                        color: WhiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      onclick: () async {
                        try {
                          if(msgType == "Firebase"){
                            PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: ResetPasswordScreen.verifay, smsCode: code,);
                            // Sign the user in (or link) with the credential
                            await auth.signInWithCredential(credential);
                            pinPutController.text = "";
                            if (rout == "signUpScreen") {
                              signUpController.setUserApiData(countryCode);
                              showToastMessage(signUpController.signUpMsg);
                            }
                            if (rout == "resetScreen") {
                              forgetPasswordBottomSheet();
                            }
                          }else{
                           if(otpCode == code){
                             pinPutController.text = "";
                             if (rout == "signUpScreen") {
                               signUpController.setUserApiData(countryCode);
                               // Get.offAll(ChooseFevoriteEvent());
                               showToastMessage(signUpController.signUpMsg);
                             }
                             if (rout == "resetScreen") {
                               forgetPasswordBottomSheet();
                             }
                           }else{
                             showToastMessage("Please enter your valid OTP".tr);
                           }
                          }
                        } catch (e) {
                          showToastMessage("Please enter your valid OTP".tr);
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
                          ccode: countryCode, mobile: phoneNumber);
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

  void _resendCode() {
    smsTypeController.smsTypeApi().then((smsType) {
      // print("********************** ${smsType}");
      if(smsType["Result"] == "true"){
        if(smsType["otp_auth"] == "No"){
          signUpController.setUserApiData(countryCode);
          Get.offAll(ChooseFevoriteEvent());
          showToastMessage(signUpController.signUpMsg);
        } else{
          if(smsType["SMS_TYPE"] == "Firebase"){
            sendOTP(phoneNumber, countryCode);
          }else if (smsType["SMS_TYPE"] == "Msg91"){
            //  msg_otp;
            msgOtpController.msgOtpApi(mobile: "$countryCode${phoneNumber}").then((msgOtp) {
              if(msgOtp["Result"] == "true"){
                setState(() {
                  otpCode = msgOtp["otp"].toString();
                });

                print("++++++++msgOtp+++++++++++ ${msgOtp["otp"]}");
              }else{
                showToastMessage("Invalid mobile number");
              }
            },);
          }else if(smsType["SMS_TYPE"] == "Twilio"){
            twilioOtpController.twilioOtpApi(mobile: "$countryCode${phoneNumber}").then((twilioOtp) {
              print("---------- $twilioOtp");
              if(twilioOtp["Result"] == "true"){
                setState(() {
                  otpCode = twilioOtp["otp"].toString();
                });

                print("++++++++twilioOtp+++++++++++ ${twilioOtp["otp"]}");
              }else{
                showToastMessage("Invalid mobile number");
              }
            },);
          }else{
            showToastMessage("Invalid mobile number");
          }
        }
      }
      else{
        showToastMessage("Invalid mobile number");
      }
    },);
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
      startTimer();
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          enableResend = true;
          t.cancel();
        }
      });
    });
  }

}


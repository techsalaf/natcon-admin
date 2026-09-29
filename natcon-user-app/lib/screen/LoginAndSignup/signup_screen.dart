// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:magicmate_user/screen/LoginAndSignup/resetpassword_screen.dart';
import '../../Api/data_store.dart';
import '../../controller/msg_otp_controller.dart';
import '../../controller/signup_controller.dart';
import '../../controller/sms_type_controller.dart';
import '../../controller/twillio_otp_controller.dart';
import '../../helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import '../choosefevorite_event.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpController signUpController = Get.find();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String cuntryCode = "";

  SmsTypeController smsTypeController = Get.put(SmsTypeController());
  MsgOtpController msgOtpController = Get.put(MsgOtpController());
  TwilioOtpController twilioOtpController = Get.put(TwilioOtpController());

  Future<void> sendOTP(String phone, String countryCode) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$countryCode$phone',
        verificationCompleted: (_) {},
        verificationFailed: (error) => showToastMessage(error.message ?? 'Could not send the verification code.'),
        codeSent: (verificationId, _) {
          ResetPasswordScreen.verifay = verificationId;
          showToastMessage('A verification code was sent.');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          ResetPasswordScreen.verifay = verificationId;
        },
      );
    } catch (_) {
      showToastMessage('Could not send the verification code. Try again.');
    }
  }

  @override
  void initState() {
   smsTypeController.smsTypeApi();
    super.initState();
  }

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
                          getData.read('isLoginBack')
                              ? Get.toNamed(Routes.bottoBarScreen)
                              : Get.back();
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
                        "Signup".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.gilroyBold,
                          fontSize: 17,
                          color: WhiteColor,
                        ),
                      )
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
                          " Login Now",
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
                height: Get.height * 0.8,
                width: Get.size.width,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Get Started.".tr,
                          style: TextStyle(
                            color: BlackColor,
                            fontFamily: "Gilroy Bold",
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                          height: Get.height * 0.005,
                        ),
                        Text(
                          "Create your free account in seconds".tr,
                          style: TextStyle(
                            color: BlackColor,
                            fontFamily: "Gilroy Medium",
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            controller: signUpController.name,
                            cursorColor: BlackColor,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: BlackColor,
                            ),
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  "assets/Profile.png",
                                  height: 10,
                                  width: 10,
                                  color: greycolor,
                                ),
                              ),
                              labelText: "Full Name".tr,
                              labelStyle: TextStyle(
                                color: greycolor,
                                fontFamily: FontFamily.gilroyMedium,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            controller: signUpController.email,
                            cursorColor: BlackColor,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: BlackColor,
                            ),
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              border: OutlineInputBorder(
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
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  "assets/email.png",
                                  height: 10,
                                  width: 10,
                                  color: greycolor,
                                ),
                              ),
                              labelText: "Email Address".tr,
                              labelStyle: TextStyle(
                                color: greycolor,
                                fontFamily: FontFamily.gilroyMedium,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: IntlPhoneField(
                            keyboardType: TextInputType.number,
                            cursorColor: BlackColor,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: signUpController.number,
                            disableLengthCheck: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            dropdownIcon: Icon(
                              Icons.arrow_drop_down,
                              color: greycolor,
                            ),
                            dropdownTextStyle: TextStyle(
                              color: greycolor,
                            ),
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: BlackColor,
                            ),
                            onChanged: (value) {
                              cuntryCode = value.countryCode;
                            },
                            onCountryChanged: (value) {
                              signUpController.number.text = '';
                            },
                            decoration: InputDecoration(
                              helperText: null,
                              labelText: "Mobile Number".tr,
                              labelStyle: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                color: greycolor,
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
                        SizedBox(
                          height: 20,
                        ),
                        GetBuilder<SignUpController>(builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: signUpController.password,
                              obscureText: signUpController.showPassword,
                              cursorColor: BlackColor,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: BlackColor,
                              ),
                              onChanged: (value) {},
                              decoration: InputDecoration(
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
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    signUpController.showOfPassword();
                                  },
                                  child: !signUpController.showPassword
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password'.tr;
                                }
                                return null;
                              },
                            ),
                          );
                        }),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            controller: signUpController.referralCode,
                            cursorColor: BlackColor,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: BlackColor,
                            ),
                            decoration: InputDecoration(
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
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              labelText: "Referral code (optional)".tr,
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
                        GetBuilder<SignUpController>(builder: (context) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Transform.scale(
                                scale: 1,
                                child: Checkbox(
                                  value: signUpController.chack,
                                  side: const BorderSide(
                                      color: Color(0xffC5CAD4)),
                                  activeColor: gradient.defoultColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  onChanged: (newbool) async {
                                    signUpController
                                        .checkTermsAndCondition(newbool);

                                    save("Remember", true);
                                  },
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "By creating an account,you agree to our"
                                        .tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: greycolor,
                                      fontFamily: FontFamily.gilroyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    "Terms and Condition".tr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: gradient.defoultColor,
                                      fontFamily: FontFamily.gilroyBold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                        GestButton(
                          Width: Get.size.width,
                          height: 50,
                          buttoncolor: gradient.defoultColor,
                          margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                          buttontext: "Continue".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            color: WhiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          onclick: () {
                            if ((_formKey.currentState?.validate() ?? false) &&
                                (signUpController.chack == true)) {






                              signUpController.checkMobileNumber(cuntryCode).then((value) {
                                // print("+++++++++++++ $value");
                                var decodeValue = jsonDecode(value);
                                if(decodeValue["Result"] == "true"){
                                 smsTypeController.smsTypeApi().then((smsType) {
                                   // print("********************** ${smsType}");
                                   if(smsType["Result"] == "true"){
                                     if(smsType["otp_auth"] == "No"){
                                       signUpController.setUserApiData(cuntryCode);
                                       Get.offAll(ChooseFevoriteEvent());
                                       showToastMessage(signUpController.signUpMsg);
                                     } else{
                                       if(smsType["SMS_TYPE"] == "Firebase"){
                                         sendOTP(signUpController.number.text, cuntryCode);
                                         Get.toNamed(Routes.otpScreen, arguments: {
                                           "number": signUpController.number.text,
                                           "cuntryCode": cuntryCode,
                                           "route": "signUpScreen",
                                           "msgType": smsType["SMS_TYPE"].toString(),
                                         });
                                       }else if (smsType["SMS_TYPE"] == "Msg91"){
                                         //  msg_otp;
                                         msgOtpController.msgOtpApi(mobile: "$cuntryCode${signUpController.number.text}").then((msgOtp) {
                                           if(msgOtp["Result"] == "true"){
                                             Get.toNamed(Routes.otpScreen, arguments: {
                                               "number": signUpController.number.text,
                                               "cuntryCode": cuntryCode,
                                               "route": "signUpScreen",
                                               "otpCode": msgOtp["otp"].toString(),
                                               "msgType": smsType["SMS_TYPE"].toString(),
                                             });
                                             print("++++++++msgOtp+++++++++++ ${msgOtp["otp"]}");
                                           }else{
                                             showToastMessage("Invalid mobile number");
                                           }
                                         },);
                                       }else if(smsType["SMS_TYPE"] == "Twilio"){
                                         twilioOtpController.twilioOtpApi(mobile: "$cuntryCode${signUpController.number.text}").then((twilioOtp) {
                                           print("---------- $twilioOtp");
                                           if(twilioOtp["Result"] == "true"){
                                             Get.toNamed(Routes.otpScreen, arguments: {
                                               "number": signUpController.number.text,
                                               "cuntryCode": cuntryCode,
                                               "route": "signUpScreen",
                                               "otpCode": twilioOtp["otp"].toString(),
                                               "msgType": smsType["SMS_TYPE"].toString(),
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
                                }else{
                                  showToastMessage(decodeValue["ResponseMsg"]);
                                }
                              },);

                            } else {
                              if (signUpController.chack == false) {
                                showToastMessage(
                                    "Please select Terms and Condition".tr);
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
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
}

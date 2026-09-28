// ignore_for_file: file_names, non_constant_identifier_names, avoid_print, unused_field, unused_import, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings, prefer_const_constructors, prefer_final_fields

import 'dart:convert';

import 'package:magicmate_organizer/Login_flow/Sign_up.dart';
import 'package:magicmate_organizer/Login_flow/Verify_Account.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Getx_controller.dart/msg_otp_controller.dart';
import '../Getx_controller.dart/sms_type_controller.dart';
import '../Getx_controller.dart/twillio_otp_controller.dart';
import '../utils/dark_light_mode.dart';
import 'Forgot_Password.dart';

class ResendCode extends StatefulWidget {
  const ResendCode({super.key});

  @override
  State<ResendCode> createState() => _ResendCodeState();
}

class _ResendCodeState extends State<ResendCode> {
  final Email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final Mobile = TextEditingController();
  String mobilecheck = "";
  String Country = "";
  String _verificationId = "";
  int? _resendToken;
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
  SmsTypeController smsTypeController = Get.put(SmsTypeController());
  MsgOtpController msgOtpController = Get.put(MsgOtpController());
  TwilioOtpController twilioOtpController = Get.put(TwilioOtpController());

  bool isNavigate = false;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: AppButton(
          gradientcolor: gradient.btnGradient,
          buttontext: "Send OTP".tr,
          textcolor: WhiteColor,
          onTap: () {

            if(Mobile.text.isNotEmpty){
              setState(() {
                isNavigate = true;
              });
              checkMobileNumber(Mobile.text, Country).then((value) {
                print("+++++++++++ ${value}");
                var decodeValue = jsonDecode(value);
                if(decodeValue["Result"] == "false"){
                  smsTypeController.smsTypeApi().then((smsType) {
                    if(smsType["Result"] == "true"){
                      print("cscvdxvdcvfcbgbgn");
                      if(smsType["otp_auth"] == "No"){
                        Get.to(() => ForgotPassword(
                          ccode: Country,
                          mobileNo: Mobile.text,
                        ));
                      } else{
                        if(smsType["SMS_TYPE"] == "Firebase"){
                          sendOTP(Mobile.text, Country);
                          Get.to(() => VerifyAccount(
                            ccode: Country,
                            number: Mobile.text,
                            Email: Email.text,
                            Signup: "ResendCode",
                            msgType: smsType["SMS_TYPE"],
                          ));
                          setState(() {
                            isNavigate = false;
                          });
                        }else if (smsType["SMS_TYPE"] == "Msg91"){
                          //  msg_otp;
                          print("cscvdxvdcvfcbgbgn");
                          msgOtpController.msgOtpApi(mobile: "$Country${Mobile.text}").then((msgOtp) {
                            print("************* ${msgOtp}");
                            if(msgOtp["Result"] == "true"){
                              Get.to(() => VerifyAccount(
                                ccode: Country,
                                number: Mobile.text,
                                Email: Email.text,
                                Signup: "ResendCode",
                                otpCode: msgOtp["otp"].toString(),
                                msgType: smsType["SMS_TYPE"],

                              ));
                              setState(() {
                                isNavigate = false;
                              });
                              // Get.toNamed(Routes.otpScreen, arguments: {
                              //   "number": signUpController.number.text,
                              //   "cuntryCode": cuntryCode,
                              //   "route": "signUpScreen",
                              //   "otpCode": msgOtp["otp"].toString(),
                              //   "msgType": smsType["SMS_TYPE"].toString,
                              // });
                              print("++++++++msgOtp+++++++++++ ${msgOtp["otp"]}");
                            } else {
                              setState(() {
                                isNavigate = false;
                              });
                              ApiWrapper.showToastMessage("Invalid mobile number");
                            }
                          },);
                        }else if(smsType["SMS_TYPE"] == "Twilio"){
                          print("cscvdxvdcvfcbgbgn");
                          twilioOtpController.twilioOtpApi(mobile: "$Country${Mobile.text}").then((twilioOtp) {
                            print("---------- $twilioOtp");
                            if(twilioOtp["Result"] == "true"){
                              Get.to(() => VerifyAccount(
                                ccode: Country,
                                number: Mobile.text,
                                Email: Email.text,
                                Signup: "ResendCode",
                                otpCode: twilioOtp["otp"].toString(),
                                msgType: smsType["SMS_TYPE"],

                              ));
                              // Get.toNamed(Routes.otpScreen, arguments: {
                              //   "number": signUpController.number.text,
                              //   "cuntryCode": cuntryCode,
                              //   "route": "signUpScreen",
                              //   "otpCode": twilioOtp["otp"].toString(),
                              //   "msgType": smsType["SMS_TYPE"].toString,
                              // });
                              print("++++++++twilioOtp+++++++++++ ${twilioOtp["otp"]}");
                            }else{
                              ApiWrapper.showToastMessage("Invalid mobile number".tr);
                            }
                          },);
                        }else{
                          ApiWrapper.showToastMessage("Invalid mobile number".tr);
                        }

                      }
                    }else{
                      setState(() {
                        isNavigate = false;
                      });
                      ApiWrapper.showToastMessage("Invalid mobile number".tr);
                    }
                  },
                  );
                }else{
                  setState(() {
                    isNavigate = false;
                  });
                  ApiWrapper.showToastMessage(decodeValue["ResponseMsg"]);
                }
              },);
            }else{
              ApiWrapper.showToastMessage("Please Enter mobile number");
            }
            setState(() {
              // verifyotp = true;
            });
          },
        ),
      ),
      appBar: appbar(title: "Resend Code".tr),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.05),
                Text(
                  "Phone Number".tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Bold", color:  notifier.textColor, fontSize: 22),
                ),
                SizedBox(height: Get.height * 0.02),
                SizedBox(
                  width: Get.width * 0.80,
                  child: Text(
                    "We will call or send SMS to confirm your number.".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Medium",
                        color: greycolor,
                        fontSize: 16),
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                IntlPhoneField(
                  keyboardType: TextInputType.number,
                  controller: Mobile,
                  dropdownTextStyle: TextStyle(color: notifier.textColor, fontSize: 16),
                  style: TextStyle(fontFamily: "Gilroy Medium", color: notifier.textColor),
                  cursorColor: const Color(0xff4361EE),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    fillColor: transparent,
                    filled: true,
                    hintText: 'Enter your Phone'.tr,
                    hintStyle: const TextStyle(
                      fontFamily: 'Gilroy Medium',
                      // fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xffAAACAE),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xffF3F3FA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: orangeColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: notifier.border,
                        ),
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  initialCountryCode: 'IN',
                  invalidNumberMessage: 'please enter your phone number'.tr,
                  onChanged: (phone) {
                    setState(() {
                      Country = phone.countryCode;
                      print(phone.countryCode);
                    });
                  },
                ),
              ],
            ),
          ),
          isNavigate ? Center(child: CircularProgressIndicator(),) : SizedBox()
        ],
      ),
    );
  }

  Future<void> sendOTP(
    String phonNumber,
    String cuntryCode,
  ) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '${cuntryCode + phonNumber}',
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + e.toString());
      },
      timeout: Duration(seconds: 60),
      codeSent: (String verificationId, int? resendToken) {
        Singup.verify = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future checkMobileNumber(String mobile, String country) async {
    try {
      Map map = {
        "ccode": country,
        "mobile": mobile,
      };
      print("-----------------==============" + map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.mobilecheck);
      var response = await http.post(uri, body: jsonEncode(map),);
      print("-------------${response.body}----");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        mobilecheck = result["Result"];
        if (mobilecheck == "false") {
          return response.body;
        }
        ApiWrapper.showToastMessage(result["ResponseMsg"]);
      }
      setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }
}

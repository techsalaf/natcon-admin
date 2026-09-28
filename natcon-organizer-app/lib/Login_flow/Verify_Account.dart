// ignore_for_file: file_names, unused_catch_clause, non_constant_identifier_names, avoid_print, unused_import, unused_field, prefer_final_fields, prefer_const_constructors, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';

import 'package:magicmate_organizer/Bottombar_screen.dart';
import 'package:magicmate_organizer/Login_flow/Forgot_Password.dart';
import 'package:magicmate_organizer/Login_flow/Sign_up.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Getx_controller.dart/msg_otp_controller.dart';
import '../Getx_controller.dart/sign_up_controller.dart';
import '../Getx_controller.dart/sms_type_controller.dart';
import '../Getx_controller.dart/twillio_otp_controller.dart';
import '../utils/Fontfamily.dart';
import '../utils/dark_light_mode.dart';

// ignore: must_be_immutable
class VerifyAccount extends StatefulWidget {
  String? ccode;
  String? number;
  String? FullName;
  String? Email;
  String? Password;
  String? Signup;
  String? img;
  String? otpCode;
  String? msgType;

  VerifyAccount({this.msgType,this.otpCode,this.FullName, this.Email, this.Password, this.ccode, this.number, this.Signup, this.img, super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}
String pagerought = "";

class _VerifyAccountState extends State<VerifyAccount> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final pinController = TextEditingController();
  String code = "";

  String Country = "";

  String _verificationId = "";
  int? _resendToken;
  String verrification = "";
  // String otpCode = Get.arguments["otpCode"].toString();
  TextEditingController pinPutController = TextEditingController();
  SmsTypeController smsTypeController = Get.put(SmsTypeController());
  MsgOtpController msgOtpController = Get.put(MsgOtpController());
  TwilioOtpController twilioOtpController = Get.put(TwilioOtpController());
  SignUpController signUpController = Get.put(SignUpController());

  int secondsRemaining = 30;
  bool enableResend = false;
  Timer? timer;

  @override
  void initState() {
    startTimer();
    getDarkMode();
    super.initState();
    setState(() {
      verrification = widget.Signup ?? "";
    });
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
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool isNavigate = false;

  @override
  Widget build(BuildContext context)  {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: AppButton(
          gradientcolor: gradient.btnGradient,
          buttontext: "Verify Account".tr,
          textcolor: WhiteColor,
          onTap: () async {
            // try {
            //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
            //       verificationId: Singup.verify, smsCode: code);
            //   await auth.signInWithCredential(credential);
            //   print("&&&&&&&&&&&&&&&&&&&&&&&&&&&${verrification}");
            //   if (verrification == "Signup") {
            //     Register(
            //         widget.FullName ?? "",
            //         widget.Email ?? "",
            //         widget.number ?? "",
            //         widget.ccode ?? "",
            //         widget.img ?? "",
            //         widget.Password ?? "");
            //
            //     initPlatformState();
            //   } else {
            //     Get.to(() => ForgotPassword(
            //       ccode: widget.ccode,
            //       mobileNo: widget.number,
            //     ));
            //   }
            //
            //   ApiWrapper.showToastMessage("Verification successfull");
            // } catch (e) {
            //   ApiWrapper.showToastMessage("Please Enter Valid OTP");
            // }
            // Get.to(() => ForgotPassword(
            //       ccode: widget.ccode,
            //       mobileNo: widget.number,
            //     ));
            setState(() {
              isNavigate = true;
            });
            try {
              if(widget.msgType == "Firebase"){
                print("nccdvdvf");
                PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: Singup.verify, smsCode: code);await auth.signInWithCredential(credential);
                  //   print("&&&&&&&&&&&&&&&&&&&&&&&&&&&${verrification}");
                pinPutController.text = "";
                if (verrification == "Signup") {
                  signUpController.Register(widget.FullName ?? "", widget.Email ?? "", widget.number ?? "", widget.ccode ?? "", widget.img ?? "", widget.Password ?? "").then((value) {
                    setState(() {
                      isNavigate = false;
                    });
                  },);
                initPlatformState();
                }
                if(verrification == "resetScreen") {
                  Get.to(() => ForgotPassword(
                    ccode: widget.ccode,
                    mobileNo: widget.number,
                  ));
                  setState(() {
                    isNavigate = false;
                  });
                }
              } else {
                if(widget.otpCode == code){
                  pinPutController.text = "";
                  if (verrification == "Signup") {
                    print("35354656");
                    signUpController.Register(
                        widget.FullName ?? "",
                        widget.Email ?? "",
                        widget.number ?? "",
                        widget.ccode ?? "",
                        widget.img ?? "",
                        widget.Password ?? "").then((value) {
                           setState(() {
                             isNavigate = false;
                           });
                        },);
                    initPlatformState();
                  }
                  if(verrification == "resetScreen") {
                    Get.to(() => ForgotPassword(
                      ccode: widget.ccode,
                      mobileNo: widget.number,
                    ));
                    setState(() {
                      isNavigate = false;
                    });
                  }
                }else{
                  setState(() {
                    isNavigate = false;
                  });
                  ApiWrapper.showToastMessage("Please enter your valid OTP".tr);
                }
              }
            } catch (e) {
              setState(() {
                isNavigate = false;
              });
              ApiWrapper.showToastMessage("Please enter your valid OTP".tr);
            }
          },
        ),
      ),
      appBar: appbar(title: "Verify Otp".tr),
      backgroundColor: notifier.background,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.05),
                Text(
                  "Verify Account".tr,
                  style: TextStyle(
                      fontFamily: "Gilroy Bold", color:  notifier.textColor, fontSize: 22),
                ),
                SizedBox(height: Get.height * 0.02),
                SizedBox(
                  width: Get.width * 0.80,
                  child: RichText(
                    text: TextSpan(
                      text:
                      "Please, enter the verification code we send to your mobile".tr,
                      style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: greycolor,
                          fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                            text: "  ${widget.ccode} ${widget.number}",
                            style: TextStyle(
                                fontFamily: "Gilroy Bold",
                                fontSize: 16,
                                color: notifier.textColor)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Get.height * 0.02),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    cursorColor: appcolor,
                    cursorHeight: 18,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 45,
                      fieldWidth: 45,
                      inactiveColor: appcolor,
                      activeColor: appcolor,
                      selectedColor: appcolor,
                      activeFillColor: Colors.white,
                      inactiveFillColor: WhiteColor,
                      selectedFillColor: WhiteColor,
                      borderWidth: 1,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    backgroundColor: WhiteColor,
                    enableActiveFill: true,
                    controller: pinController,
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
                // Padding(
                //   padding: const EdgeInsets.only(left: 4),
                //   child: Pinput(
                //     length: 6,
                //     controller: pinController,
                //     submittedPinTheme: PinTheme(
                //         width: 56,
                //         height: 56,
                //         textStyle: TextStyle(
                //             fontSize: 20,
                //             color: BlackColor,
                //             fontFamily: "Gilroy Bold"),
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(10),
                //             border: Border.all(color: appcolor))),
                //     defaultPinTheme: PinTheme(
                //       width: 56,
                //       height: 56,
                //       textStyle: TextStyle(
                //           fontSize: 20,
                //           color: BlackColor,
                //           fontFamily: "Gilroy Bold"),
                //       decoration: BoxDecoration(
                //           color: WhiteColor,
                //           borderRadius: BorderRadius.circular(10),
                //           border: Border.all(color: greycolor.withOpacity(0.5))),
                //     ),
                //     errorText: 'Wrong otp',
                //     onChanged: (value) {
                //       code = value;
                //     },
                //   ),
                // ),
                SizedBox(height: Get.height * 0.02),
            enableResend
                ? InkWell(
                  onTap: () {
                   _resendCode();
                  },
                  child: Text(
                    "Resend code?".tr,
                    style: TextStyle(
                        fontFamily: "Gilroy Bold", color: notifier.textColor, fontSize: 16),
                  ),
                ) : Text(
                  " $secondsRemaining Seconds".tr,
                  style: TextStyle(
                    color: appcolor,
                    fontFamily: FontFamily.gilroyBold,
                  ),
                ),
              ],
            ),
          ),
          isNavigate ? Center(child: CircularProgressIndicator(),) : SizedBox()
        ],
      ),
    );
  }


  Future<bool> sendOTP({required String phone, Countrycode}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: Countrycode + phone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) async {
        _verificationId = verificationId;
        _resendToken = resendToken;
      },
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationId = _verificationId;
      },
    );
    debugPrint("_verificationId: $_verificationId");
    return true;
  }

  void _resendCode() {
    smsTypeController.smsTypeApi().then((smsType) {
      if(smsType["Result"] == "true"){
        print("cscvdxvdcvfcbgbgn");
        if(smsType["otp_auth"] == "No"){
          signUpController.Register(widget.FullName ?? "", widget.Email ?? "", widget.number ?? "", widget.ccode ?? "", widget.img ?? "", widget.Password ?? "");
        }else {
          if (smsType["SMS_TYPE"] == "Firebase") {
            print("cscvdxvdcvfcbgbgn");
            sendOTP(phone: widget.number!,Countrycode: widget.ccode);
          } else if (smsType["SMS_TYPE"] == "Msg91") {
            //  msg_otp;
            print("cscvdxvdcvfcbgbgn");
            msgOtpController.msgOtpApi(mobile: "${widget.ccode}${widget.number}").then((msgOtp) {
              print("************* ${msgOtp}");
              if (msgOtp["Result"] == "true") {
               setState(() {
                 widget.otpCode = msgOtp["otp"].toString();
               });
                print(
                    "++++++++msgOtp+++++++++++ ${msgOtp["otp"]}");
              } else {
                ApiWrapper.showToastMessage(
                    "Invalid mobile number");
              }
            },);
          } else if (smsType["SMS_TYPE"] == "Twilio") {
            print("cscvdxvdcvfcbgbgn");
            twilioOtpController.twilioOtpApi(mobile: "${widget.ccode}${widget.number}").then((twilioOtp) {
              print("---------- $twilioOtp");
              if (twilioOtp["Result"] == "true") {
                setState(() {
                  widget.otpCode = twilioOtp["otp"].toString();
                });
                print(
                    "++++++++twilioOtp+++++++++++ ${twilioOtp["otp"]}");
              } else {
                ApiWrapper.showToastMessage(
                    "Invalid mobile number".tr);
              }
            },);
          } else {
            ApiWrapper.showToastMessage(
                "Invalid mobile number".tr);
          }
        }
      }
    },);
    setState(() {
      secondsRemaining = 30;
      enableResend = false;
      startTimer();
    });
  }

  // Future<void> initPlatformState() async {
  //   OneSignal.shared.setAppId(AppUrl.oneSignel);
  //   OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {});
  //   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  //     print("Accepted OSPermissionStateChanges : $changes");
  //   });
  //   // print("--------------__uID : ${getData.read("UserLogin")["id"]}");
  //   await OneSignal.shared.sendTag("user_id", getData.read("UserLogin")["id"]);
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

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          enableResend = true;
          t.cancel(); // Cancel timer when done
        }
      });
    });
  }

}



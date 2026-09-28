// ignore_for_file: prefer_const_constructors, sort_child_properties_last, must_be_immutable, use_key_in_widget_constructors, unused_element, avoid_print, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../Api/data_store.dart';
import '../../controller/login_controller.dart';
import '../../helpar/routes_helpar.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import '../bottombar_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginController loginController = Get.find();
  String cuntryCode = "";

  @override
  void initState() {
    super.initState();
    loginController.number.text = "";
    loginController.password.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        getData.read('isLoginBack')
            ? Get.toNamed(Routes.bottoBarScreen)
            : Get.back();
      },

      child: Scaffold(
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
                          width: Get.width * 0.30,
                        ),
                        Text(
                          "Login".tr,
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
                          "Don’t have an account?".tr,
                          style: TextStyle(
                            color: WhiteColor,
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 15,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.toNamed(Routes.signUpScreen);
                          },
                          child: Text(
                            " Create Now".tr,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Sign in !".tr,
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
                          "Welcome back you’ve been missed! ".tr,
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
                          child: IntlPhoneField(
                            keyboardType: TextInputType.number,
                            cursorColor: BlackColor,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            disableLengthCheck: true,
                            controller: loginController.number,
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
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: BlackColor,
                            ),
                            onCountryChanged: (value) {
                              loginController.number.text = '';
                              loginController.password.text = '';
                            },
                            onChanged: (value) {
                              cuntryCode = value.countryCode;
                            },
                            decoration: InputDecoration(
                              helperText: null,
                              labelText: "Mobile Number".tr,
                              labelStyle: TextStyle(
                                color: greytext,
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
                                  color: greycolor,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            invalidNumberMessage:
                                "Please enter your mobile number".tr,
                            // validator: (p0) {
                            //   if (p0!.completeNumber.isEmpty) {
                            //     return 'Please enter your number';
                            //   } else {}
                            //   return null;
                            // },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GetBuilder<LoginController>(builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: loginController.password,
                              obscureText: loginController.showPassword,
                              cursorColor: BlackColor,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    loginController.showOfPassword();
                                  },
                                  child: !loginController.showPassword
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
                                    fontFamily: FontFamily.gilroyMedium),
                              ),
                            ),
                          );
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: GetBuilder<LoginController>(
                                  builder: (context) {
                                return Row(
                                  children: [
                                    Theme(
                                      data: ThemeData(
                                          unselectedWidgetColor: BlackColor),
                                      child: Checkbox(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        value: loginController.isChecked,
                                        activeColor: gradient.defoultColor,
                                        onChanged: (value) async {
                                          loginController.changeRememberMe(value);

                                          save("Remember", value);
                                        },
                                      ),
                                    ),
                                    Text(
                                      "Remember me".tr,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Gilroy Medium",
                                        color: BlackColor,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(Routes.resetPassword);
                              },
                              child: Container(
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  "Forgot Password?".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: gradient.defoultColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestButton(
                          Width: Get.size.width,
                          height: 50,
                          buttoncolor: gradient.defoultColor,
                          margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                          buttontext: "Login".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            color: WhiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          onclick: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              loginController.getLoginApiData(cuntryCode);
                            } else {}
                          },
                        ),
                        SizedBox(
                          height: 35,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            "OR".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: BlackColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ContinueButton(
                          Width: Get.size.width,
                          height: 50,
                          margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                          buttoncolor: bgcolor,
                          buttontext: "Continue as a Guest".tr,
                          onclick: () {

                            Get.to(BottomBarScreen());
                            save('isLoginBack', true);
                          },
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            color: BlackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
      ),
    );
  }
}

// ignore_for_file: file_names, prefer_const_constructors, sort_child_properties_last, non_constant_identifier_names, duplicate_ignore, deprecated_member_use, avoid_print, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:magicmate_organizer/Bottombar_screen.dart';
import 'package:magicmate_organizer/Dashboard/notificatin_screen.dart';
import 'package:magicmate_organizer/Getx_controller.dart/trems_condition_controller.dart';
import 'package:magicmate_organizer/Login_flow/Login_screen.dart';
import 'package:magicmate_organizer/Profile_Screen/terms_condition.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Getx_controller.dart/Dashboard_controller.dart';
import '../firebase/chat_page.dart';
import '../utils/dark_light_mode.dart';
import 'language_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? text;
  bool isLodding = false;
  PageListController pageListController = Get.find();
  final _formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();

  String? path;
  String? networkimage;
  String? base64Image;



  @override
  void initState() {
    getDarkMode();
    super.initState();
    getData.read("UserLogin") != null
        ? setState(() {
            name.text = getData.read("UserLogin")[getData.read("AccountType") == "MANAGER" ? "${"name"}" : "${"title"}"];
            email.text = getData.read("UserLogin")["email"];
            networkimage = getData.read("UserLogin")["img"] ?? "";
            getData.read("UserLogin")["img"] != "null"
                ? setState(() {
                    networkimageconvert();
                  })
                : const SizedBox();
          })
        : null;
  }

  networkimageconvert() {
    (() async {
      http.Response response =
          await http.get(Uri.parse(AppUrl.imageurl + networkimage.toString()));
      if (mounted) {
        print(response.bodyBytes);
        setState(() {
          base64Image = const Base64Encoder().convert(response.bodyBytes);
        });
      }
    })();
  }
  bool darkMode = false;

  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
      darkMode = previousState;
    }
  }

  void _updateUserStatus(bool isOnline) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserStatus(getData.read("UserLogin")["id"], isOnline);
  }

  DashboardController dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return WillPopScope(
      onWillPop: () {
        Get.to(() => const BottoBarScreen());
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: notifier.background,
        appBar: AppBar(
          leading: SizedBox(),
          centerTitle: false,
          elevation: 0,
          backgroundColor: notifier.background,
          titleSpacing: 0,
          leadingWidth: 20,
          title: Text(
            "Profile".tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              fontSize: 16,
              color: notifier.textColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                editProfileBottomSheet();
              },
              child: Text(
                'Edit Profile'.tr,
                style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  color: appcolor,
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        _openGallery();
                      },
                      child: SizedBox(
                        height: 130,
                        width: 130,
                        child: path == null
                            ? networkimage != ""
                                ? CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: notifier.background,
                                      backgroundImage: NetworkImage(
                                        "${AppUrl.imageurl}${networkimage}",
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundColor: notifier.background,
                                      backgroundImage: AssetImage(
                                        "assets/profile-default.png",
                                      ),
                                    ),
                                  )
                            : CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: notifier.background,
                                  backgroundImage: FileImage(
                                    File(path ?? ""),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          _openGallery();
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: gradient.btnGradient),
                            child: Image.asset(
                              "assets/Pen.png",
                              color: WhiteColor,
                              height: 18,
                              width: 18,
                            )),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Text(
                  name.text,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: notifier.textColor,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.005,
                ),
                Text(
                  email.text,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    color: greycolor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.03,
                ),
                setting(
                  SettingName: "Notification".tr,
                  image: "assets/message.png",
                  onTap: () {
                    Get.to(NotificationScreen(status: "1"));
                  },
                ),
                setting(
                    onTap: () {
                      Get.to(() => LanguageScreen());
                    },
                    image: "assets/globe-earth.png",
                  SettingName: "Language".tr,
                    ),
                Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12), color: notifier.containerColor),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              darkMode == false ? Image.asset("assets/sun.png", height: 25, color: appcolor) :  Image.asset("assets/moon.png", height: 25, color: appcolor),
                              SizedBox(width: Get.width * 0.03),
                              Text(
                                "Dark Mode".tr,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Gilroy Bold",
                                    color: notifier.textColor),
                              )
                            ],
                          ),
                          SizedBox(width: Get.width * 0.025),
                          Transform.scale(
                            scale: 0.7,
                            child: Transform.translate(
                              offset: const Offset(4, 0),
                              child: CupertinoSwitch(
                                trackColor: greycolor,
                                activeColor: appcolor,
                                thumbColor: Colors.white,
                                value: darkMode,
                                onChanged: (bool value) async{
                                  setState(() {
                                    darkMode = value;
                                  });
                                  final prefs = await SharedPreferences.getInstance();
                                  setState(() {
                                    notifier.setIsDark = value;
                                    prefs.setBool("setIsDark", value);
                                  },);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Get.height * 0.01),
                SizedBox(
                  height: Get.height * 0.01,
                ),
                GetBuilder<PageListController>(builder: (context) {
                  return pageListController.isLodding
                      ? ListView.builder(
                          itemCount: pageListController
                              .dynamicPageData?.pagelist.length,
                          shrinkWrap: true,
                          itemExtent: 70,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return InkWell(
                              child: Column(
                                children: [
                                  setting(
                                    SettingName: pageListController
                                        .dynamicPageData?.pagelist[index].title,
                                    image: "assets/file.png",
                                    onTap: () {
                                      Get.to(() => Loream(
                                          title: pageListController
                                              .dynamicPageData
                                              ?.pagelist[index]
                                              .title,
                                          discription: pageListController
                                              .dynamicPageData
                                              ?.pagelist[index]
                                              .description));
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(color: appcolor,),
                        );
                }),
                setting(
                  SettingName: "Delete Account".tr,
                  image: "assets/trash.png",
                  onTap: () {
                    deleteSheet();
                  },
                ),
                setting(
                  SettingName: "Logout".tr,
                  image: "assets/logout.png",
                  onTap: () {
                    logoutSheet();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  setting({String? image, SettingName, Function()? onTap, void Function(bool)? onHover}) {
    return InkWell(
      onTap: onTap,
      onHover: onHover,
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), color: notifier.containerColor),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(image!, height: 25, color: appcolor),
                    SizedBox(width: Get.width * 0.03),
                    Text(
                      SettingName,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Gilroy Bold",
                          color: notifier.textColor),
                    )
                  ],
                ),
                SizedBox(width: Get.width * 0.025),
                InkWell(
                  onTap: () {
                    // Get.to(() => const EditProfile());
                  },
                  child: Icon(Icons.keyboard_arrow_right_outlined,
                      color: notifier.textColor, size: 30),
                ),
              ],
            ),
          ),
          SizedBox(height: Get.height * 0.02),
        ],
      ),
    );
  }

  Future deleteSheet() {
    return Get.bottomSheet(
      Container(
        height: 220,
        width: Get.size.width,
        decoration: BoxDecoration(
          color: notifier.containerColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Delete Account".tr,
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Gilroy Bold",
                color: Colors.red,
              ),
            ),
            SizedBox(
              height: 20,
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
            Text(
              "Are you sure you want to delete account?".tr,
              style: TextStyle(
                fontFamily: "Gilroy Medium",
                fontSize: 16,
                color: notifier.textColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(
                          color: darkMode == false ? appcolor : WhiteColor,
                          fontFamily: "Gilroy Bold",
                          fontSize: 16,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: darkMode == false ? appcolor.withOpacity(0.1) : BlackColor,
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _updateUserStatus(false);
                      pageListController.deletAccount();
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes, Remove".tr,
                        style: TextStyle(
                          color: WhiteColor,
                          fontFamily: "Gilroy Bold",
                          fontSize: 16,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: gradient.btnGradient,
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Future logoutSheet() {
    return Get.bottomSheet(
      Container(
        height: 220,
        width: Get.size.width,
        decoration: BoxDecoration(
          color: notifier.containerColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Logout".tr,
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: FontFamily.gilroyBold,
                  color: RedColor),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: greycolor),
            ),
            SizedBox(height: 10),
            Text(
              "Are you sure you want to log out?".tr,
              style: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 16,
                  color: notifier.textColor),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(
                            color: darkMode == false ? appcolor : WhiteColor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16),
                      ),
                      decoration: BoxDecoration(
                        color: darkMode == false ? appcolor.withOpacity(0.1) : BlackColor,
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() async {
                        getData.remove('Firstuser');
                        getData.remove('Remember');
                        getData.remove("AccountType");
                        // await FirebaseMessaging.instance.deleteToken();
                        selectedIndex = 0;
                        dashboardController.isLoading = false;
                        _updateUserStatus(false);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      });
                    },
                    child: Container(
                      height: 60,
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text(
                        "Yes, Logout".tr,
                        style: TextStyle(
                            color: WhiteColor,
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16),
                      ),
                      decoration: BoxDecoration(
                          gradient: gradient.btnGradient,
                          borderRadius: BorderRadius.circular(45)),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _openGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      path = pickedFile.path;
      setState(() {});
      File imageFile = File(path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
      pageListController.updateProfileImage(base64Image);
      setState(() {});
    }
  }

  Future editProfileBottomSheet() {
    return Get.bottomSheet(
      GetBuilder<PageListController>(builder: (context) {
        return SingleChildScrollView(
          child: Container(
            // height: 350,
            width: Get.size.width,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Edit Profile".tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: FontFamily.gilroyBold,
                      color: notifier.textColor,
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
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: name,
                      cursorColor: notifier.textColor,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: FontFamily.gilroyMedium,
                        color: notifier.textColor,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full name'.tr;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: notifier.border),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: notifier.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: notifier.border),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/user.png",
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
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: email,
                      cursorColor: notifier.textColor,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        fontSize: 14,
                        color: notifier.textColor,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: notifier.border),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: notifier.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: notifier.border),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            "assets/mail.png",
                            height: 10,
                            width: 10,
                            color: greycolor,
                          ),
                        ),
                        labelText: "Email".tr,
                        labelStyle: TextStyle(
                          color: greycolor,
                          fontFamily: FontFamily.gilroyMedium,
                        ),
                      ),
                    ),
                  ),
                  GestButton(
                    Width: Get.size.width,
                    height: 50,
                    // buttoncolor: blueColor,
                    gradient: gradient.btnGradient,
                    margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                    buttontext: "Continue".tr,
                    style: TextStyle(
                      fontFamily: "Gilroy Bold",
                      color: WhiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        pageListController.editProfileApi(
                          name: name.text,
                          password: getData.read("UserLogin")["password"],
                          email: email.text,
                        ).then((value) {
                          setState(() {

                          });
                        },);
                      }
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: notifier.containerColor,
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

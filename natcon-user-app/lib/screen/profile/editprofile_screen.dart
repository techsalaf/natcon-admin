// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, avoid_print, unnecessary_brace_in_string_interps, sized_box_for_whitespace, deprecated_member_use, unused_element, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../Api/config.dart';
import '../../Api/data_store.dart';
import '../../controller/login_controller.dart';
import '../../controller/signup_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController number = TextEditingController();

  LoginController loginController = Get.find();
  SignUpController signUpController = Get.find();

  String? path;
  String? networkimage;
  String? base64Image;
  final ImagePicker imgpicker = ImagePicker();
  PickedFile? imageFile;
  @override
  void initState() {
    super.initState();
    fname.text;
    getData.read("UserLogin") != null
        ? setState(() {
            fname.text = getData.read("UserLogin")["name"] ?? "";
            number.text = getData.read("UserLogin")["mobile"] ?? "";
            email.text = getData.read("UserLogin")["email"] ?? "";
            networkimage = getData.read("UserLogin")["pro_pic"] ?? "";
            networkimage != "null"
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
          await http.get(Uri.parse(Config.imageUrl + networkimage.toString()));
      if (mounted) {
        print(response.bodyBytes);
        setState(() {
          base64Image = const Base64Encoder().convert(response.bodyBytes);
          print(base64Image);
        });
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: BlackColor,
          ),
        ),
        title: Text(
          "Profile".tr,
          style: TextStyle(
            fontSize: 17,
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
          ),
        ),
      ),
      body: GetBuilder<SignUpController>(builder: (context) {
        return SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                GetBuilder<LoginController>(builder: (context) {
                  return Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _openGallery(Get.context!);
                        },
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: path == null
                              ? networkimage != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(80),
                                      child: Image.network(
                                        "${Config.imageUrl}${networkimage ?? ""}",
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: Get.height / 17,
                                      child: Image.asset(
                                        "assets/profile-default.png",
                                        fit: BoxFit.cover,
                                      ),
                                    )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: Image.file(
                                    File(path.toString()),
                                    width: Get.width,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: -5,
                        child: InkWell(
                          onTap: () {
                            _openGallery(Get.context!);
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            padding: EdgeInsets.all(7),
                            child: Image.asset(
                              "assets/Edit.png",
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: WhiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: fname,
                      cursorColor: BlackColor,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14,
                        color: BlackColor,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                        hintText: "First Name".tr,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: WhiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      controller: email,
                      cursorColor: BlackColor,
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14,
                        color: BlackColor,
                      ),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                        // suffixIcon: Padding(
                        //   padding: const EdgeInsets.all(10),
                        //   child: Image.asset(
                        //     "assets/images/email.png",
                        //     height: 10,
                        //     width: 10,
                        //     color: BlackColor,
                        //   ),
                        // ),
                        hintText: "Email".tr,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email'.tr;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  width: Get.size.width,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${getData.read("UserLogin")["ccode"]}",
                        style: TextStyle(
                          color: BlackColor,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${number.text}",
                        style: TextStyle(
                          color: BlackColor,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: WhiteColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 20,
                ),
                GestButton(
                  Width: Get.size.width,
                  height: 50,
                  buttoncolor: gradient.defoultColor,
                  margin: EdgeInsets.only(top: 15, left: 30, right: 30),
                  buttontext: "Update".tr,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyBold,
                    color: WhiteColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  onclick: () {
                    signUpController.editProfileApi(
                      name: fname.text,
                      email: email.text,
                      password: getData.read("UserLogin")["password"],
                    );
                  },
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _openGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      path = pickedFile.path;
      setState(() {});
      File imageFile = File(path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
      loginController.updateProfileImage(base64Image);
      setState(() {});
    }
  }
}

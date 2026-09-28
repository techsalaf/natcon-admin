// ignore_for_file: unused_local_variable, avoid_print, prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../firebase/auth_firebase.dart';
import '../screen/LoginAndSignup/login_screen.dart';
import '../screen/bottombar_screen.dart';
import '../utils/Custom_widget.dart';

class LoginController extends GetxController implements GetxService {
  TextEditingController number = TextEditingController();
  TextEditingController password = TextEditingController();

  FirebaseAuthService firebaseAuthService = Get.put(FirebaseAuthService());

  TextEditingController newPassword = TextEditingController();
  TextEditingController newConformPassword = TextEditingController();

  ImagePicker picker = ImagePicker();
  File? pickedImage;

  bool showPassword = true;
  bool newShowPassword = true;
  bool conformPassword = true;
  bool isChecked = false;

  String userMessage = "";
  String resultCheck = "";

  String forgetPasswprdResult = "";
  String forgetMsg = "";

  changeIndex(int index) {
    selectedIndex = index;
    update();
  }

  showOfPassword() {
    showPassword = !showPassword;
    update();
  }

  newShowOfPassword() {
    newShowPassword = !newShowPassword;
    update();
  }

  newConformShowOfPassword() {
    conformPassword = !conformPassword;
    update();
  }

  changeRememberMe(bool? value) {
    isChecked = value ?? false;
    update();
  }

  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) return;
      final tempImage = File(photo.path);
      pickedImage = tempImage;
      update();
      Get.back();
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  getLoginApiData(String cuntryCode) async {
    try {
      Map map = {
        "mobile": number.text,
        "ccode": cuntryCode,
        "password": password.text,
      };
      Uri uri = Uri.parse(Config.baseurl + Config.loginApi);
      print("++++uri++++++++ ${uri}");

      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("++++++++++++ ${map}");
      print("-------------- ${response.body}");

      if (response.statusCode == 200) {
        save('Firstuser', true);
        var result = jsonDecode(response.body);
        print(result.toString());
        userMessage = result["ResponseMsg"];
        resultCheck = result["Result"];
        showToastMessage(userMessage);
        if (resultCheck == "true") {
        print("+++++++++++++++" + getData.read("Firstuser").toString());
        save("UserLogin", result["UserLogin"]);
        OneSignal.User.addTagWithKey("user_id", getData.read("UserLogin")["id"]);
          firebaseAuthService.singInAndStoreData(uid: result["UserLogin"]["id"], name: result["UserLogin"]["name"], email: result["UserLogin"]["email"], number: result["UserLogin"]["mobile"], proPicPath: result["UserLogin"]["pro_pic"] ?? "");
          print("Id: ${result["UserLogin"]["id"]}");
          print("Name: ${result["UserLogin"]["name"]}");
          print("Email: ${result["UserLogin"]["email"]}");
          print("Phone: ${result["UserLogin"]["mobile"]}");
          print("Image: ${result["UserLogin"]["pro_pic"]}");
          Get.offAll(BottomBarScreen());
          // Get.toNamed(Routes.selectCountryScreen);
          number.text = "";
          password.text = "";
          isChecked = false;
          update();
        }
        // OneSignal.shared.sendTag("user_id", getData.read("UserLogin")["id"]);
        update();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  setForgetPasswordApi({
    String? mobile,
    String? ccode,
  }) async {
    try {
      Map map = {
        "mobile": mobile,
        "ccode": ccode,
        "password": newPassword.text,
      };
      Uri uri = Uri.parse(Config.baseurl + Config.forgetPassword);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        forgetPasswprdResult = result["Result"];
        forgetMsg = result["ResponseMsg"];
        if (forgetPasswprdResult == "true") {
          save('isLoginBack', false);
          Get.to(LoginScreen());
          showToastMessage(forgetMsg);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  updateProfileImage(String? base64image) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
        "img": base64image,
      };
      Uri uri = Uri.parse(Config.baseurl + Config.updateProfilePic);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        save("UserLogin", result["UserLogin"]);
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../Bottombar_screen.dart';
import '../Login_flow/Verify_Account.dart';
import '../api_screens/Api_werper.dart';
import '../api_screens/confrigation.dart';
import '../api_screens/data_store.dart';
import '../firebase/auth_firebase.dart';
import '../utils/Custom_widget.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';

class SignUpController extends GetxController implements GetxService {

  FirebaseAuthService firebaseAuthService = Get.put(FirebaseAuthService());

  Future Register(String fullname, String email, String mobile, String Country, String img, String password) async {
    try {
      Map map = {
        "name": fullname,
        "email": email,
        "mobile": mobile,
        "ccode": Country,
        "password": password,
        "img": img
      };
      print("perametter${map.toString()}");
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.userregister);
      print("url====-----$uri");
      var response = await NatconHttp.post(uri, body: jsonEncode(map));
      print("************response*********${response.body.toString()}");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        save("Firstuser", true);
        print("************response200*********${result.toString()}");
        pagerought = result["Result"];
        save("UserLogin", result["OragnizerLogin"]);
        save("currency", result["currency"]);
        save("Remember", true);
        if (pagerought == "true") {
          currency = getData.read("currency");
          firebaseAuthService.singUpAndStore(uid: result["OragnizerLogin"]["id"], name: result["OragnizerLogin"]["title"], email: result["OragnizerLogin"]["email"], number: result["OragnizerLogin"]["mobile"], proPicPath: result["OragnizerLogin"]["img"]);
          Get.to(() => BottoBarScreen());
          // OneSignal.shared.sendTag("orag_id", getData.read("UserLogin")["id"]);
          OneSignal.User.addTagWithKey("orag_id", getData.read("UserLogin")["id"]);
          update();
        } else {
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}
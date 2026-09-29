// ignore_for_file: avoid_print, unused_local_variable, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:magicmate_organizer/Login_flow/Login_screen.dart';
import 'package:magicmate_organizer/Model%20class/Pagelist_model.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';

class PageListController extends GetxController implements GetxService {
  DynamicPageData? dynamicPageData;
  bool isLodding = false;

  PageListController() {
    getPageListData();
  }

  getPageListData() async {
    try {
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.pagelist);
      var response = await NatconHttp.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        dynamicPageData = DynamicPageData.fromJson(result);
        isLodding = true;
        update();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  updateProfileImage(String? base64image) async {
    try {
      Map map = {
        "orag_id": getData.read("UserLogin")["id"].toString(),
        "img": base64image,
      };
      print(".:.:.:.:.:.:.:.:.:..." + map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.profileUpdate);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      print(".:.:.:.:.:.:.:.:.:..." + response.body.toString());
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        save("UserLogin", result["OragnizerLogin"]);
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  deletAccount() async {
    try {
      Map map = {
        "orag_id": getData.read("UserLogin")["id"],
      };
      print(map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.deletAccount);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        getData.remove('Firstuser');
        getData.remove('Remember');
        getData.remove("UserLogin");
        Get.to(() => LoginScreen());

      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  Future editProfileApi({
    String? email,
    String? name,
    String? password,
  }) async {
    try {
      Map map = {
        "email": email,
        "password": password,
        "orag_id": getData.read("UserLogin")["id"].toString(),
        "name": name,
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.editProfile);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      print("+++++++map+++++++++${map}");
      print(":::::::::|||||||||||::::::::::" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        ApiWrapper.showToastMessage(result["ResponseMsg"]);
        print("zcsccsxcdf ${result}");
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("OragnizerLogin", jsonEncode(result["OragnizerLogin"]));
        // save("UserLogin", result["OragnizerLogin"]);
        update();
      }
      Get.back();
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../model/fav_info.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class FavoriteController extends GetxController implements GetxService {
  List<FevInfo> favList = [];
  bool isLoading = false;
  getFavoriteListApi() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.baseurl + Config.favoriteList);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        favList = [];
        for (var element in result["FavEventData"]) {
          favList.add(FevInfo.fromJson(element));
        }
      }
      isLoading = true;
      update();
    } catch (e) {
      isLoading = false;
      update();
      print(e.toString());
    }
  }
}

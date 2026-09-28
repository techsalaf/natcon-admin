// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../model/fav_info.dart';

class FavoriteController extends GetxController implements GetxService {
  List<FevInfo> favList = [];
  bool isLoading = false;
  getFavoriteListApi() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(Config.baseurl + Config.favoriteList);
      var response = await http.post(
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

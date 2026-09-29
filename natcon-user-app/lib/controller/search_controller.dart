// ignore_for_file: avoid_print, unused_local_variable

import 'dart:convert';

import 'package:get/get.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../model/search_info.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class SearchController extends GetxController implements GetxService {
  List<SearchInfo> searchInfo = [];
  bool isLoading = false;

  getSearchForEvent({String? keyWord}) async {
    try {
      Map map = {
        "uid": getData.read("UserLogin"),
        "keyword": keyWord,
      };
      Uri uri = Uri.parse(Config.baseurl + Config.searchEvent);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        searchInfo = [];
        for (var element in result["SearchData"]) {
          searchInfo.add(SearchInfo.fromJson(element));
        }
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../model/faq_info.dart';

class FaqController extends GetxController implements GetxService {
  FaqListInfo? faqListInfo;
  bool isLoading = false;

  getFaqDataApi() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      Uri uri = Uri.parse(Config.baseurl + Config.faqApi);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print(map);
      print(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result);
        faqListInfo = FaqListInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

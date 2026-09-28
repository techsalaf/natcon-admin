// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Api/config.dart';
import '../model/org_info.dart';
import '../model/user_info.dart';

class OrgController extends GetxController implements GetxService {
  OrgInfo? orgInfo;
  UserInfo? userInfo;
  bool isLoading = false;

  getStatusWiseEvent({String? orgId, status}) async {
    try {
      isLoading = false;
      Map map = {
        "orag_id": orgId,
        "status": status,
      };
      print("-----======-----" + map.toString());
      Uri uri = Uri.parse(Config.baseurl + Config.eventStatusWise);
      print(uri);
      print(map);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("-----======-----" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        orgInfo = OrgInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getJoinDataList({String? eventId}) async {
    try {
      isLoading = false;
      Map map = {
        "event_id": eventId,
      };
      print("-----======-----" + map.toString());
      Uri uri = Uri.parse(Config.baseurl + Config.joinUserList);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        userInfo = UserInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

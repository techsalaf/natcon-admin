// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:magicmate_organizer/Model%20class/notification_info.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationController extends GetxController implements GetxService {
  NotificationInfo? notificationInfo;
  bool isLoading = false;
  NotificationController() {
    getNotificationData();
  }
  getNotificationData() async {
    try {
      Map map = {
        "orag_id": getData.read("UserLogin")["id"],
      };

      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.notification);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        notificationInfo = NotificationInfo.fromJson(result);
      }

      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:get/get.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../model/notification_info.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class NotificationController extends GetxController implements GetxService {
  NotificationInfo? notificationInfo;
  bool isLoading = false;
  NotificationController() {
    getNotificationData();
  }
  getNotificationData() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin") != null
            ? getData.read("UserLogin")["id"]
            : "1",
      };
      Uri uri = Uri.parse(Config.baseurl + Config.notificationApi);
      var response = await NatconHttp.post(
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

  Future<void> markAsRead(String id) async {
    try {
      final response = await NatconHttp.post(
        Uri.parse(Config.baseurl + Config.notificationRead),
        body: jsonEncode({'id': id}),
      );
      if (response.statusCode == 200) {
        final item = notificationInfo?.notificationData.firstWhereOrNull((entry) => entry.id == id);
        if (item != null) {
          item.isRead = true;
          update();
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

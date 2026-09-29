// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';

import 'package:magicmate_organizer/Getx_controller.dart/Todayevent_controller.dart';
import 'package:magicmate_organizer/Model%20class/event_info.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';

class EventDetailsController extends GetxController implements GetxService {
  EventInfo? eventInfo;
  bool isLoading = false;

  StatuswiseeventController statuswiseeventController = Get.find();

  getEventDetailsApi({String? eventId}) async {
    try {
      Map map = {
        "event_id": eventId,
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.eventInformetion);
      print("------------- ${map}");

      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      log("**************** ${response.body}");
      print(uri);
      print(map);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        eventInfo = EventInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  eventCancleApi({String? eventId}) async {
    try {
      Map map = {
        "event_id": eventId,
        "orag_id": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.eventCancle);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        statuswiseeventController.statuswiseevent(status: "Today");
        Get.back();
        ApiWrapper.showToastMessage(result["ResponseMsg"].toString());

        print("-=-=-=-=-=-=-=-=-=-=-=--->" + result.toString());
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  eventCompletedApi({String? eventId}) async {
    try {
      Map map = {
        "event_id": eventId,
        "orag_id": getData.read("UserLogin")["id"],
      };
      print("^^^^^^^^^^^^^^^^^" + map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.eventComplete);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        ApiWrapper.showToastMessage(result["ResponseMsg"].toString());

        print("-=-=-=-=-=-=-=-=-=-=-=--->" + result.toString());
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  qrCheckApi({String? oragId, ticketId, uId, eventId,context}) async {
    try {
      Map map = {
        "orag_id": oragId,
        "ticket_id": ticketId,
        "uid": uId,
        "event_id": eventId,
      };
      print("*/*/*/*/*/*/*/*/*/*/*/*/*/*/**" + map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.qrCheckApi);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("${map}");
        print("*-*-*-*-*-*-*-*-*-*-*-*-*-" + result.toString());
        if (result["Result"] == "true") {
          ApiWrapper.showToastMessage(result["ResponseMsg"].toString());
          Navigator.pop(context);
          // Get.back();
        } else {

          // Get.back();
          Fluttertoast.showToast(
              msg: result["ResponseMsg"].toString(),
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xffE1495E),
              textColor: Colors.white,
              fontSize: 14.0);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  bookingIdVerifyApi({String? bookingID}) async {
    try {
      Map map = {
        "ticket_code": bookingID,
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.bookingIdVirify);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          Get.back();
          ApiWrapper.showToastMessage(result["ResponseMsg"].toString());
        } else {
          Get.back();
          Fluttertoast.showToast(
              msg: result["ResponseMsg"].toString(),
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Color(0xffE1495E),
              textColor: Colors.white,
              fontSize: 14.0);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names, unused_import, file_names, unnecessary_brace_in_string_interps, unused_local_variable

import 'dart:convert';

import 'package:magicmate_organizer/Getx_controller.dart/Eventtypeprice_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Listofevent_controller.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';

class AddeventtypepriceController extends GetxController
    implements GetxService {
  EventtypepriceController eventtypepriceController = Get.find();

  TextEditingController etype = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController tlimit = TextEditingController();

  bool isLoading = false;
  String pType = "";
  String status = "";
  String eventid = "";
  String eventtype = "";
  String eventdescription = "";
  String eventprice = "";
  String eventtlimit = "";
  String eventstatus = "";
  getEditDetails(
      {String? eventid, etype, edescription, eprice, etlimit, estatus}) {
    eventid = eventid ?? "";
    eventtype = etype ?? "";
    eventdescription = edescription ?? "";
    eventprice = eprice ?? "";
    eventtlimit = etlimit ?? "";
    eventstatus = estatus ?? "";
  }

  getCurrentLatAndLong(double latitude, double longitude) {}

  emptyAllDetails() {
    status = "";
    eventid = "";
    eventtype = "";
    eventdescription = "";
    eventprice = "";
    eventtlimit = "";
    eventstatus = "";
  }

  eventedittypeprice({String? recordid}) async {
    isLoading = true;
    update();
    try {
      Map data = {
        "event_id": pType,
        "etype": etype.text,
        "description": description.text,
        "price": price.text,
        "tlimit": tlimit.text,
        "orag_id": getData.read("UserLogin")["id"],
        "status": status != "" ? status : "1",
        "record_id": recordid
      };
      print(data.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.edittype);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(data),
      );
      print("-------------Response=========" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          eventtypepriceController.eventtypeprice();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
          Get.back();
          isLoading = false;
          update();
        } else {
          isLoading = false;
          update();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
        // print(result.toString());
      } else {
        isLoading = false;
        update();
      }

    } catch (e) {
      isLoading = false;
      update();
      print(e.toString());
    }
  }

  eventaddtypeprice({String? eventid}) async {
    isLoading = true;
    update();
    try {
      Map map = {
        "event_id": eventid,
        "etype": etype.text,
        "description": description.text,
        "price": price.text,
        "tlimit": tlimit.text,
        "orag_id": getData.read("UserLogin")["id"],
        "status": status != "" ? status : "1",
      };
      print(map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.addtype);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      print("-------------Response=========" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          eventtypepriceController.eventtypeprice();
          isLoading = false;
          update();
          Get.back();
        } else {
          isLoading = false;
          update();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
        // print(result.toString());
      } else {
        isLoading = false;
        update();
      }
    } catch (e) {
      isLoading = false;
      update();
      print(e.toString());
    }
  }
}

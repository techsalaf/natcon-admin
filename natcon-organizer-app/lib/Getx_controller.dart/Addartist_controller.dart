// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names, unused_import, file_names, unnecessary_brace_in_string_interps, unused_local_variable, prefer_if_null_operators

import 'dart:convert';

import 'package:magicmate_organizer/Getx_controller.dart/Artist_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Dashboard_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Listofevent_controller.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:textfield_tags/textfield_tags.dart';

class AddartistController extends GetxController implements GetxService {
  ArtistController artistController = Get.find();

  TextEditingController artistname = TextEditingController();
  TextEditingController artistrole = TextEditingController();

  String? path;
  String? base64Image;

  String countryId = "";

  String pType = "";
  String stype = "";
  String pbuySell = "";
  String status = "";

  var selectedIndexes = [];
  var restirectedindex = [];

  String artistName = "";
  String artistImage = "";
  String artistRole = "";

  var elat;
  var elong;
  bool isLoading = false;

  getEditDetails({
    String? artistName1,
    artistImage1,
    artistRole1,
  }) {
    artistName = artistName1 ?? "";
    artistImage = artistImage1 ?? "";
    artistRole = artistRole1 ?? "";
    update();
  }

  emptyAllDetails() {
    path = null;
    base64Image = "";
    status = "";
    artistname.text = "";
    artistrole.text = "";
    // medicineImage = "";
    update();
  }

  Future artistEdit({
    String? recordid,
  }) async {
    isLoading = true;
    update();
    if(isLoad){
      return;
    }else{
      isLoad = true;
    }
    try {
      Map data = {
        "status": status != "" ? status : "1",
        "orag_id": getData.read("UserLogin")["id"],
        "artist_name": artistname.text,
        "artist_role": artistrole.text,
        "event_id": pType,
        "img": path != null ? base64Image : "0",
        "record_id": recordid
      };
      print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$data");
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.editartist);
      var response = await http.post(
        uri,
        body: jsonEncode(data),
      );
      print("-------------Response=========" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          isLoad = false;
          isLoading = false;
          update();
          artistController.artistlist();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
          Get.back();
        } else {
          isLoading = false;
          update();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
      }
      isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
  bool isLoad = false;
  Future artisAdd() async {
    isLoading = true;
    update();
    if(isLoad){
      return;
    }else{
      isLoad = true;
    }
    try {
      Map map = {
        "status": status != "" ? status : "1",
        "orag_id": getData.read("UserLogin")["id"],
        "artist_name": artistname.text,
        "artist_role": artistrole.text,
        "event_id": pType,
        "img": base64Image,
      };
      print("+++++++++++=" + map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.addartist);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("-------------Response=========" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          isLoad = false;
          isLoading = false;
          update();
          artistController.artistlist();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
          Get.back();
        } else {
          isLoading = false;
          update();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
      }
      isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

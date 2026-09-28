// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names, unused_import, file_names, unnecessary_brace_in_string_interps, unused_local_variable, prefer_if_null_operators

import 'dart:convert';
import 'dart:developer';

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

class AddlistofeventController extends GetxController implements GetxService {
  ListofeventController listofeventController = Get.find();

  DashboardController dashboardController = Get.find();

  TextEditingController eventTitle = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController disclaimer = TextEditingController();
  TextEditingController placename = TextEditingController();
  TextEditingController starttime = TextEditingController();
  TextEditingController endtime = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController eventdate = TextEditingController();
  TextfieldTagsController youtubeurl = TextfieldTagsController();
  TextfieldTagsController tegs = TextfieldTagsController();

  String EndTimeFormatted = "";
  String StartTimeFormatted = "";

  String? path;
  String? base64Image;
  String? coverimagepath;
  String? coverimagebase64Image;

  String countryId = "";

  String pType = "";
  String stype = "";
  String pbuySell = "";
  String status = "";

  String medicineImage = "";

  var selectedIndexes = [];
  var restirectedindex = [];
  List<String> urltag = [];
  List<String> youtube = [];

  var lat;
  var long;

  String eventname = "";
  String eventimage = "";
  String eventcoverimage = "";
  String dateevent = "";
  String eventstarttime = "";
  String eventendtime = "";
  String latitude = "";
  String longitude = "";
  String eventaddress = "";
  String eventplace = "";
  String eventdescription = "";
  String eventdisclaimer = "";

  var elat;
  var elong;
  bool isLoading = false;


  getEditDetails({List? restrictionEdit,List? facilityEdit,String? ename, eimage, ecoverimage, edate, estarttime, eendtime, elatitude, elongitude, eaddress, eplacename, edescription, edisclaimer, estatus}) {
    eventname = ename ?? "";
    eventimage = eimage ?? "";
    eventcoverimage = ecoverimage ?? "";
    dateevent = edate ?? "";
    eventstarttime = estarttime ?? "";
    eventendtime = eendtime ?? "";
    latitude = elatitude ?? "";
    restirectedindex = restrictionEdit ?? [];
    selectedIndexes = facilityEdit ?? [];
    longitude = elongitude ?? "";
    eventaddress = eaddress ?? "";
    eventplace = eplacename ?? "";
    eventdescription = edescription ?? "";
    eventdisclaimer = edisclaimer ?? "";

    print("==========111======================${eventname}");
    print("==========222======================${eventimage}");
    print("==========333======================${eventcoverimage}");
    print("==========444======================${dateevent}");
    print("==========555======================${eventstarttime}");
    print("==========666======================${eventendtime}");
    print("==========777======================${longitude}");
    print("==========888======================${eventaddress}");
    print("==========999======================${eventplace}");
    print("==========101010======================${eventdescription}");
    print("==========111111======================${eventdisclaimer}");
    update();
  }

  getCurrentLatAndLong(double latitude, double longitude) {
    lat = latitude;
    long = longitude;
    update();
  }

  emptyAllDetails() {
    eventTitle.text = "";
    description.text = "";
    disclaimer.text = "";
    placename.text = "";
    starttime.text = "";
    endtime.text = "";
    address.text = "";
    // selectedIndexes = [];
    // restirectedindex = [];
    eventdate.text = "";
    path = null;
    base64Image = "";
    status = "";
    coverimagepath = null;
    // medicineImage = "";
  }

  String facelity = "";
  String restriction = "";
  Future eventedit({String? recordid}) async {
    String youtuburl = youtubeurl.getTags!.join(",");
    print("tag========>" + youtuburl);
    print("++++++++a+++++++++++ ${selectedIndexes.length}");
    facelity = selectedIndexes.join(",");
    print("--------b--------- ${selectedIndexes.length}");
    print("tag========>" + facelity);
    restriction = restirectedindex.join(",");
    print("tag========>" + restriction);
    String teg = tegs.getTags!.join(",");
    print("tag========>" + teg);
    try {
      if (facelity.startsWith(',')) {
          facelity = facelity.substring(1);
      }
      if (restriction.startsWith(',')) {
        restriction = restriction.substring(1);
      }

      print("restriction========>" + restriction);
      print("facelity========>" + facelity);

      Map data = {
        "status": status != "" ? status : "1",
        "title": eventTitle.text,
        "address": address.text,
        "tags": tegs.getTags!.isNotEmpty ? teg : "",
        "vurls": youtubeurl.getTags!.isNotEmpty ? youtuburl : "",
        "cdesc": description.text,
        "disclaimer": disclaimer.text,
        "orag_id": getData.read("UserLogin")["id"],
        "facility_id": selectedIndexes.isNotEmpty ? facelity : "",
        "restict_id": restirectedindex.isNotEmpty ? restriction : "",
        "pname": placename.text,
        "sdate": eventdate.text,
        "stime": StartTimeFormatted,
        "etime": EndTimeFormatted,
        "cat_id": pType,
        "latitude": lat.toString(),
        "longtitude": long.toString(),
        "img": path != null ? base64Image : "0",
        "cover": coverimagepath != null ? coverimagebase64Image : "0",
        "record_id": recordid
      };
      // print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$data");
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.eventedit);
      var response = await http.post(
        uri,
        body: jsonEncode(data),
      );
      // print("-------------Response=========" + response.body);
      log("--------data--------${data} ");
      print("++++++EVENT ADDED++++++++++++++ ${response.body}");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          selectedIndexes = [];
          restirectedindex = [];
          listofeventController.listofevent();
          Get.back();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        } else {
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
        // print(result.toString());
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
    // ApiWrapper.dataPost(AppUrl.eventedit, data).then((val) {
    //   if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
    //     listofeventController.listofevent();
    //   } else {
    //     ApiWrapper.showToastMessage(val["ResponseMsg"]);
    //   }
    //   Get.back();
    //   isLoading = true;
    //   update();
    // });
  }

  // ({String? recordid}) {
  //   var data = {
  //     "status": status != "" ? status : "1",
  //     "title": eventTitle.text,
  //     "address": address.text,
  //     "tags": "Business,Exhibitions",
  //     "vurls": "https://youtu.be/waAfg03TgOI",
  //     "cdesc": description.text,
  //     "disclaimer": disclaimer.text,
  //     "orag_id": getData.read("UserLogin")["id"],
  //     "facility_id": "1",
  //     "restict_id": "0",
  //     "pname": placename.text,
  //     "sdate": eventdate.text,
  //     "stime": starttime.text,
  //     "etime": endtime.text,
  //     "cat_id": "1",
  //     "latitude": lat.toString(),
  //     "longtitude": long.toString(),
  //     "img": base64Image,
  //   };
  //   print("!!!!!!!!!!!!!!!!!!!!!!${data.toString()}");
  //   ApiWrapper.dataPost(AppUrl.eventadd, data).then((val) {
  //     if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
  //       ApiWrapper.showToastMessage(val["ResponseMsg"]);
  //       listofeventController.listofevent();
  //       Get.back();
  //       update();
  //     } else {
  //       ApiWrapper.showToastMessage(val["ResponseMsg"]);
  //     }
  //     isLoading = true;
  //     update();
  //   });
  // }
  bool isLoad = false;
  eventadd() async {
    if(isLoad){
      return;
    }else{
      isLoad = true;
    }

    String youtuburl = youtubeurl.getTags!.join(",");
    print("tag========>" + youtuburl);
    String facelity = selectedIndexes.join(",");
    print("tag========>" + facelity);
    String restriction = restirectedindex.join(",");
    print("tag========>" + restriction);
    String teg = tegs.getTags!.join(",");
    print("tag========>" + teg);
    try {
      isLoading = false;
      // update();
      print("tag========>" + youtubeurl.getTags.toString());
      Map map = {
        "status": status != "" ? status : "1",
        "title": eventTitle.text,
        "address": address.text,
        "tags": tegs.getTags!.isNotEmpty ? teg : "",
        "vurls": youtubeurl.getTags!.isNotEmpty ? youtuburl : "",
        "cdesc": description.text,
        "disclaimer": disclaimer.text,
        "orag_id": getData.read("UserLogin")["id"],
        "facility_id": selectedIndexes.isNotEmpty ? facelity : "",
        "restict_id": restirectedindex.isNotEmpty ? restriction : "",
        "pname": placename.text,
        "sdate": eventdate.text,
        "stime": StartTimeFormatted,
        "etime": EndTimeFormatted,
        "cat_id": pType,
        "latitude": lat.toString(),
        "longtitude": long.toString(),
        "img": base64Image,
        "cover": coverimagebase64Image
      };
      print("............." + map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.eventadd);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      print("-------------Event Added Response-----------" + response.body);
      print("++++++++++++++++++ ${map}");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result["Result"] == "true") {
          isLoad = false;
          listofeventController.listofevent();
          Get.back();
        } else {
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
        // print(result.toString());
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

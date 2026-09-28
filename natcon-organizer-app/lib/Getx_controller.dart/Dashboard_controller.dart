// ignore_for_file: file_names, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps

import 'dart:convert';

import 'package:magicmate_organizer/Model%20class/Dashboardinfo_model.dart';
import 'package:magicmate_organizer/Model%20class/Facility_Model.dart';
import 'package:magicmate_organizer/Model%20class/Restriction_model.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/Custom_widget.dart';

class DashboardController extends GetxController {
  bool isLoading = false;

  Dashboardinfo? dashboardinfo;
  FacilityInfo? facilityInfo;
  Restrictioninfo? restrictioninfo;

  String payOut = "";

  DashboardController() {
    dashboard();
  }

  dashboard() {
    var data = {
      "orag_id": getData.read("UserLogin")["id"],
    };
    print("===============dashboard=================${data}");
    ApiWrapper.dataPost(AppUrl.dashboard, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          for (var element in val["report_data"]) {
            if (element["title"] == "Earning") {
              payOut = element["report_data"];
              currency = getData.read("currency");
            }
          }
          dashboardinfo = Dashboardinfo.fromJson(val);
        } else {
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
        isLoading = true;
        update();
      }
    });
  }

  getFacilityList() async {
    try {
      isLoading = false;
      var data = {
        "orag_id": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.facilitylist);
      var response = await http.post(uri, body: jsonEncode(data));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("Result-------" + result.toString());
        facilityInfo = FacilityInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getRestrictionList() async {
    try {
      isLoading = false;
      var data = {
        "orag_id": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.restrictionlist);
      var response = await http.post(uri, body: jsonEncode(data));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("Result-------" + result.toString());
        restrictioninfo = Restrictioninfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

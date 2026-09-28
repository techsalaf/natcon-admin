// ignore_for_file: avoid_print, unused_local_variable

import 'dart:convert';

import 'package:magicmate_organizer/Model%20class/payout_info.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

class PayOutController extends GetxController implements GetxService {
  PayoutInfo? payoutInfo;
  bool isLoading = false;

  TextEditingController amount = TextEditingController();
  TextEditingController upi = TextEditingController();
  TextEditingController accountNumber = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController accountHolderName = TextEditingController();
  TextEditingController ifscCode = TextEditingController();
  TextEditingController emailId = TextEditingController();

  PayOutController() {
    getPayOutList();
  }

  getPayOutList() async {
    try {
      Map map = {
        "orag_id": getData.read("UserLogin")["id"],
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.payoutlist);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        payoutInfo = PayoutInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  emptyDetails() {
    amount.text = "";
    accountNumber.text = "";
    bankName.text = "";
    accountHolderName.text = "";
    ifscCode.text = "";
    upi.text = "";
    emailId.text = "";
    update();
  }

  bool getWithdrawLoad = false;
  requestWithdraweApi({String? rType}) async {
    getWithdrawLoad = true;
    update();
    try {
      Map map = {
        "orag_id": getData.read("UserLogin")["id"],
        "amt": amount.text,
        "r_type": rType,
        "acc_number": accountNumber.text,
        "bank_name": bankName.text,
        "acc_name": accountHolderName.text,
        "ifsc_code": ifscCode.text,
        "upi_id": upi.text,
        "paypal_id": emailId.text,
      };
      print(map.toString());
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.requestwithdraw);
      var response = await http.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(result.toString());
        if (result["Result"] == "true") {
          getWithdrawLoad = false;
          update();
          emptyDetails();
          getPayOutList();
          Get.back();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        } else {
          getWithdrawLoad = false;
          update();
          ApiWrapper.showToastMessage(result["ResponseMsg"]);
        }
      }
      getWithdrawLoad = false;
      update();
    } catch (e) {
      getWithdrawLoad = false;
      update();
      print(e.toString());
    }
  }
}

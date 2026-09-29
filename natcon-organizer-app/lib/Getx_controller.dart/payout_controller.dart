// ignore_for_file: avoid_print, unused_local_variable

import 'dart:convert';

import 'package:magicmate_organizer/Model%20class/payout_info.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:magicmate_organizer/api_screens/natcon_http.dart';

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
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        payoutInfo = PayoutInfo.fromJson(result);
        availableKobo = (result['balance']?['available_kobo'] as num?)?.toInt() ?? 0;
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
  int availableKobo = 0;
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
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.requestwithdraw);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
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

  Future<bool> reviewPayout({required String payoutId, required String status, required String note}) async {
    try {
      final response = await NatconHttp.post(
        Uri.parse('${AppUrl.baseUrl}payout_review.php'),
        headers: ApiWrapper.headers,
        body: jsonEncode({'payout_id': payoutId, 'status': status, 'note': note}),
      );
      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result is Map && result['Result'] == 'true') {
        ApiWrapper.showToastMessage(result['ResponseMsg']);
        await getPayOutList();
        return true;
      }
      ApiWrapper.showToastMessage(result is Map ? (result['ResponseMsg'] ?? 'Payout review failed.') : 'Payout review failed.');
    } catch (e) {
      print(e.toString());
    }
    return false;
  }
}

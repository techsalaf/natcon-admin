// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../model/payment_info.dart';
import '../model/wallet_info.dart';
import 'home_controller.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class WalletController extends GetxController implements GetxService {
  TextEditingController amount = TextEditingController();
  HomePageController homePageController = Get.find();

  PaymentInfo? paymentInfo;

  bool isLoading = false;
  WalletInfo? walletInfo;

  String results = "";
  String walletMsg = "";

  String rCode = "";
  String signupcredit = "";
  String refercredit = "";
  int referralCount = 0;
  int convertedReferralCount = 0;

  Uri _natconUri(String action, [Map<String, String>? query]) {
    final base = Config.imageUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$base/api/natcon.php')
        .replace(queryParameters: {'action': action, ...?query});
  }

  Future<Map<String, dynamic>> _natconRequest(String action,
      {Map<String, dynamic>? body, Map<String, String>? query}) async {
    final response = body == null
        ? await NatconHttp.get(_natconUri(action, query))
        : await NatconHttp.post(_natconUri(action), body: jsonEncode(body));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['ok'] != true) {
      final message = decoded is Map ? decoded['error'] : null;
      throw HttpException(message?.toString() ?? 'NATCON wallet request failed.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('NATCON returned an invalid wallet response.');
    }
    return data;
  }

  getWalletReportData() async {
    try {
      isLoading = false;
      update();
      final result = await _natconRequest('account_wallet');
      walletInfo = WalletInfo.fromJson({
        'ResponseCode': '200',
        'Result': 'true',
        'ResponseMsg': 'Wallet history loaded.',
        'wallet': ((result['wallet_balance_kobo'] as num? ?? 0) / 100)
            .toStringAsFixed(2),
        'Walletitem': result['ledger'] ?? <dynamic>[],
      });
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  addAmount({String? price}) {
    amount.text = price ?? "";
    update();
  }

  getWalletUpdateData() async {
    // Legacy callers cannot award wallet funds by sending a claimed amount.
    await getWalletReportData();
    await homePageController.getHomeDataApi();
  }

  Future<Map<String, dynamic>> initializeNatconTopup() async {
    final naira = int.tryParse(amount.text.trim());
    if (naira == null) throw const FormatException('Enter a whole-number naira amount.');
    return _natconRequest('wallet_initialize',
        body: {'amount_kobo': naira * 100});
  }

  Future<bool> verifyNatconTopup(String reference) async {
    final result = await _natconRequest('wallet_verify',
        query: {'reference': reference});
    await getWalletReportData();
    await homePageController.getHomeDataApi();
    return result['credited'] == true || walletInfo?.result == 'true';
  }

  getReferData() async {
    try {
      Map map = {
        "uid": getData.read("UserLogin")["id"].toString(),
      };
      Uri uri = Uri.parse(Config.baseurl + Config.referAndEarn);
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
      print(response.body.toString());
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        rCode = result["code"];
        signupcredit = result["signupcredit"];
        refercredit = result["refercredit"];
        referralCount = (result['tracked'] as num?)?.toInt() ?? 0;
        convertedReferralCount = (result['converted'] as num?)?.toInt() ?? 0;
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }

  getpaymentgatewayList() async {
    try {
      isLoading = false;
      Uri uri = Uri.parse(Config.baseurl + Config.paymentgatewayApi);
      var response = await NatconHttp.post(uri);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        paymentInfo = PaymentInfo.fromJson(result);
      }
      isLoading = true;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

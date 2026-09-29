// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../utils/Custom_widget.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class BookEventController extends GetxController implements GetxService {
  double couponAmt = 0.0;

  Uri _natconUri(String action, [Map<String, String>? query]) {
    final base = Config.imageUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse(
      '$base/api/natcon.php',
    ).replace(queryParameters: {'action': action, ...?query});
  }

  Future<Map<String, dynamic>> _natconRequest(
    String action, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final response = body == null
        ? await NatconHttp.get(_natconUri(action, query))
        : await NatconHttp.post(_natconUri(action), body: jsonEncode(body));
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded['ok'] != true) {
      final message = decoded is Map ? decoded['error'] : null;
      throw HttpException(message?.toString() ?? 'NATCON request failed.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('NATCON returned an invalid response.');
    }
    return data;
  }

  Future<Map<String, dynamic>> createNatconOrder({
    required Map<String, dynamic> account,
    required List<Map<String, String>> delegates,
  }) => _natconRequest(
    'register',
    body: {
      'payer_name': account['name'],
      'payer_email': account['email'],
      'payer_phone': '${account['ccode'] ?? ''}${account['mobile'] ?? ''}',
      'consent': true,
      'delegates': delegates,
    },
  );

  Future<Map<String, dynamic>> initializeNatconPayment({
    required String reference,
    required String token,
  }) => _natconRequest(
    'payment_initialize',
    body: {'reference': reference, 'token': token},
  );

  Future<Map<String, dynamic>> verifyNatconPayment({
    required String reference,
    required String token,
  }) => _natconRequest(
    'payment_verify',
    query: {'reference': reference, 'token': token},
  );

  bookEventApi({
    String? eID,
    typeId,
    type,
    price,
    totalTicket,
    subTotal,
    tax,
    couAmt,
    totalAmt,
    wallAmt,
    pMethodId,
    otid,
    pLimit,
    sponsoreId,
  }) async {
    try {
      if (wallAmt == 0.0) {
        wallAmt = 0;
      }
      Map map = {
        "uid": getData.read("UserLogin")["id"],
        "eid": eID ?? "",
        "typeid": typeId,
        "type": type,
        "price": price,
        "total_ticket": totalTicket,
        "subtotal": subTotal,
        "tax": tax,
        "cou_amt": couAmt,
        "total_amt": totalAmt,
        "wall_amt": wallAmt,
        "p_method_id": pMethodId,
        "transaction_id": otid,
        "plimit": pLimit,
        "sponsore_id": sponsoreId,
      };
      print("::::::::::---------::::::::::" + map.toString());
      Uri uri = Uri.parse(Config.baseurl + Config.bookEventApi);
      var response = await NatconHttp.post(uri, body: jsonEncode(map));
      print("........=========........" + response.body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("........=========........" + result.toString());
        if (result["Result"] == "true") {
          showToastMessage(result["ResponseMsg"]);
          OrderPlacedSuccessfully();
        }
      }
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

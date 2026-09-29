// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:get/get.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../utils/Custom_widget.dart';
import 'package:magicmate_user/Api/natcon_http.dart';

class BookEventController extends GetxController implements GetxService {
  double couponAmt = 0.0;

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
      if(wallAmt==0.0){
        wallAmt=0;
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
      var response = await NatconHttp.post(
        uri,
        body: jsonEncode(map),
      );
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

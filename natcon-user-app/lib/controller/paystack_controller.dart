import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../Api/config.dart';
import '../model/paystack_model.dart';

class PayStackController extends GetxController implements GetxService {
  late PayStackApiApiModel payStackApiApiModel;
  String refrenceee = "";

  Future paystackApi({context,required String email,required String amount}) async{
    Map body = {
      "email" : email,
      "amount" : amount,
    };

    Map<String, String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};

    var response = await http.post(Uri.parse(Config.paymentBaseUrl + Config.payStackApi), body: jsonEncode(body), headers: userHeader);
    print("+++++:---  ${response.body}");
    try{
      if(response.statusCode == 200){
        payStackApiApiModel = payStackApiApiModelFromJson(response.body);
        update();
        refrenceee = payStackApiApiModel.data.reference;
        print("+++++:-  (${refrenceee})");
        return response.body;
      }
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../Model class/msg_otp_model.dart';
import '../api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';

class SmsTypeController extends GetxController implements GetxService {

  SmsTypeModel? smsTypeModel;
  Future smsTypeApi() async{
    Map<String,String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};
    var response = await NatconHttp.get(Uri.parse(AppUrl.baseUrl + AppUrl.smsType),headers: userHeader);

    print("++++++++++++++++ ${response.body}");

    var data = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(data["Result"] == "true"){
        smsTypeModel = smsTypeModelFromJson(response.body);
        if(smsTypeModel!.result == "true"){
          update();
          // print("***************** ${data}");
          return data;
        }else{
          // Fluttertoast.showToast(msg: "${data["message"]}");
        }
      }
      else{
        // Fluttertoast.showToast(msg: "${data["message"]}");
      }
    }
    else{
      Fluttertoast.showToast(msg: "Please update the content from the backend panel. It appears that the correct data was not uploaded, or there may be issues with the data that was added.");
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please update the content from the backend panel. It appears that the correct data was not uploaded, or there may be issues with the data that was added.")));
    }
  }
}
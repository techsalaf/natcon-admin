import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import '../Model class/msg_otp_model.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';


class MsgOtpController extends GetxController implements GetxService {

  SmsTypeModel? smsTypeModel;

  Future msgOtpApi({required String mobile}) async{
    Map body = {
      "mobile": mobile
    };
    Map<String, String> userHeader = {"Content-type": "application/json", "Accept": "application/json"};
    var response = await NatconHttp.post(Uri.parse(AppUrl.baseUrl + AppUrl.msgOtp),body: jsonEncode(body),headers: userHeader);

    print("+++++++ ${response.body}");
    print("----- ${body}");

    var data = jsonDecode(response.body);
    if(response.statusCode == 200){
      if(data["Result"] == "true"){
        smsTypeModel = smsTypeModelFromJson(response.body);
        if(smsTypeModel!.result == "true"){
          update();
          print("///////////////// ${data}");
          return data;
        }
        else{
          Fluttertoast.showToast(msg: smsTypeModel!.result.toString());
        }
      }
      else{
        Fluttertoast.showToast(msg: "${data["ResponseMsg"]}",);
      }
    }else{
      Fluttertoast.showToast(msg: "Please update the content from the backend panel. It appears that the correct data was not uploaded, or there may be issues with the data that was added.",);
    }
  }
}

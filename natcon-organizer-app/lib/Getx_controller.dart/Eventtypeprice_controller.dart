// ignore_for_file: file_names, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps

import 'package:magicmate_organizer/Model%20class/Eventtypeprice_model.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';

class EventtypepriceController extends GetxController {
  bool isLoading = false;
  Eventtypepriceinfo? eventtypepriceinfo;
  eventtypeprice() {
    var data = {
      "orag_id": getData.read("UserLogin")["id"],
    };
    print("===============eventtypeprice=================${data}");
    ApiWrapper.dataPost(AppUrl.listtypeprice, data).then((val) {
      if (val != null) {
        if (val.isNotEmpty) {
          if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
            eventtypepriceinfo = Eventtypepriceinfo.fromJson(val);
          } else {
            ApiWrapper.showToastMessage(val["ResponseMsg"]);
          }
        }
      }
      isLoading = true;
      update();
    });
  }
}

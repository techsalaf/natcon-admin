// ignore_for_file: file_names, avoid_print, unused_import

import 'package:magicmate_organizer/Model%20class/Coverimage_model.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';

class CoverimageController extends GetxController implements GetxService {
  bool isLoading = false;
  int currentindex = 0;

  Coverimageinfo? coverimageinfo;

  String storeid = "";
  String catName = "";
  String status = "";

  getIdAndName({String? recId, categoryName}) {
    storeid = recId ?? "";
    catName = categoryName ?? "";
  }

  Future coverimagelist() async {
    var data = {
      "orag_id": getData.read("UserLogin")["id"],
    };
    ApiWrapper.dataPost(AppUrl.coverimagelist, data).then((val) {
      print("OBLECC $val");
      if (val != null) {
        if ((val['ResponseCode'] == "200")) {
          coverimageinfo = Coverimageinfo.fromJson(val);
        } else {
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
      isLoading = true;
      update();
    });
  }
}

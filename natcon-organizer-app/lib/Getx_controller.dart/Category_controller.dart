// ignore_for_file: file_names, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps

import 'package:magicmate_organizer/Model%20class/Category_model.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  bool isLoading = false;
  List<String> categorytext = [];
  Categoryinfo? categoryinfo;
  categorylist() {
    var data = {
      "orag_id": getData.read("UserLogin")["id"],
    };
    print("===============listofevent=================${data}");
    ApiWrapper.dataPost(AppUrl.listcategory, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          categoryinfo = Categoryinfo.fromJson(val);
          categorytext = [];
          for (var element in val["Categorydata"]) {
            categorytext.add(element["title"]);
            print("EVENT DATA $categorytext");
          }
          update();
        } else {
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
        isLoading = true;
        update();
      }
    });
  }
}

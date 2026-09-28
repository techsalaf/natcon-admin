// ignore_for_file: file_names, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps

import 'package:magicmate_organizer/Model%20class/Todayevent_model.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';

class StatuswiseeventController extends GetxController {
  bool isLoading = false;
  Todayeventinfo? todayeventinfo;

  statuswiseevent({String? status}) {
    isLoading = false;
    var data = {
      "orag_id": getData.read("UserLogin")["id"],
      "status": status,
    };
    print("===============listofevent=================${data}");
    ApiWrapper.dataPost(AppUrl.statuswiseevent, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        print("<<<<<<<<<<<<<>>>>>>>>>>>>" + val.toString());
        todayeventinfo = Todayeventinfo.fromJson(val);
      } else {
        ApiWrapper.showToastMessage(val["ResponseMsg"]);
      }
      isLoading = true;
      update();
    });
  }
}

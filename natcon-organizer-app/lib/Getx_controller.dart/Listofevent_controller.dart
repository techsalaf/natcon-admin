// ignore_for_file: file_names, avoid_print, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps

import 'package:magicmate_organizer/Model%20class/Listofevent_model.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:get/get.dart';

class ListofeventController extends GetxController {
  bool isLoading = false;

  List<Listofeventinfo> listofeventinfo = [];
  List<String> selectevent = [];

  // Listofeventinfo? listModel;

  listofevent() {
    var data = {
      "orag_id": getData.read("UserLogin")["id"],
    };
    print("===============listofevent=================${data}");
    ApiWrapper.dataPost(AppUrl.listofevent, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          listofeventinfo = [];
          print("EVENT DATAT ${val["Eventdata"]}");
          // listModel = listofeventinfoFromJson(val);
          for (var element in val["Eventdata"]) {
            listofeventinfo.add(Listofeventinfo.fromJson(element),
            );
            selectevent = [];
            for (var element in val["Eventdata"]) {
              selectevent.add(element["event_title"]);
            }

          }
        } else {
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
        isLoading = true;
        update();
      }
    });
  }
}

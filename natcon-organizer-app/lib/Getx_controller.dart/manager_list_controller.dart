import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import '../Model class/manager_list_model.dart';

class ManagerListController extends GetxController implements GetxService {
  ManagerListModel? managerListModel;
  bool isLoading = false;

  managerListApi({context, required String orgID,required String accountType}) async {
    Map body = {
      "orag_id": orgID,
      "type": accountType
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await http.post(Uri.parse(AppUrl.baseUrl + AppUrl.addMangerList), body: jsonEncode(body), headers: userHeader);

    print(body);
    print(response.body);

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["Result"] == "true") {
        managerListModel = managerListModelFromJson(response.body);
        if (managerListModel!.result == "true") {
          isLoading = true;
          update();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("${managerListModel!.responseMsg}"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${data["ResponseMsg"]}"),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                "Please update the content from the backend panel. It appears that the correct data was not uploaded, or there may be issues with the data that was added."),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      );
    }
  }
}

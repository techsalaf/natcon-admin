import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import '../Model class/add_manager_model.dart';
import '../Model class/edit_manager_model.dart';
import 'package:magicmate_organizer/api_screens/natcon_http.dart';


class AddManagerController extends GetxController implements GetxService {
  AddManagerModel? addManagerModel;
  bool isLoading = false;
  bool buttonUpdate = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String id = "";
  String managerType = "";
  String accountType = "";

  getIdAndName({required String managerId,required String name, required String email, required String password, required String manager, required String status}) {
    id = managerId;
    nameController.text = name;
    emailController.text = email;
    passwordController.text = password;
    managerType = manager;
    accountType = status;
    update();
  }

  Future addManagerApi({context, required String orgID, required String name,required String email, required String password, required String managerType, required String status}) async {
    isLoading = true;
    update();
    Map body = {
      "orag_id": orgID,
      "name": name,
      "email": email,
      "password": password,
      "manager_type" : managerType,
      "status": status
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await NatconHttp.post(Uri.parse(AppUrl.baseUrl + AppUrl.addManger), body: jsonEncode(body), headers: userHeader);

    print("svcsvsv:--------- ${body}");
    print("++++:--------- ${response.body}");

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["Result"] == "true") {
        addManagerModel = addManagerModelFromJson(response.body);
        if (addManagerModel!.result == "true") {
          isLoading = false;
          update();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("${data["ResponseMsg"]}"),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
          update();
        } else {
          isLoading = false;
          update();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("${addManagerModel!.responseMsg}"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
        }
      } else {
        isLoading = false;
        update();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${data["ResponseMsg"]}"),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        );
      }
    } else {
      isLoading = false;
      update();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                "Please update the content from the backend panel. It appears that the correct data was not uploaded, or there may be issues with the data that was added."),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      );
    }
    isLoading = false;
    update();
  }



  EditManagerModel? editManagerModel;

  Future editManagerApi({context, required String orgID, required String name,required String email, required String recordId,required String password, required String managerType, required String status}) async {
    isLoading = true;
    update();
    Map body = {
      "orag_id": orgID,
      "name": name,
      "email": email,
      "password": password,
      "manager_type" : managerType,
      "record_id": recordId,
      "status": status
    };

    Map<String, String> userHeader = {
      "Content-type": "application/json",
      "Accept": "application/json"
    };
    var response = await NatconHttp.post(Uri.parse(AppUrl.baseUrl + AppUrl.editMangerList), body: jsonEncode(body), headers: userHeader);

    print("svcsvsv:--------- ${body}");
    print("++++:--------- ${response.body}");

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data["Result"] == "true") {
        editManagerModel = editManagerModelFromJson(response.body);
        if (editManagerModel!.result == "true") {
          isLoading = false;
          update();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("${data["ResponseMsg"]}"),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
          update();
        } else {
          isLoading = false;
          update();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("${editManagerModel!.responseMsg}"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
          );
        }
      } else {
        isLoading = false;
        update();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("${data["ResponseMsg"]}"),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        );
      }
    } else {
      isLoading = false;
      update();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text(
                "Please update the content from the backend panel. It appears that the correct data was not uploaded, or there may be issues with the data that was added."),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
      );
    }
    isLoading = false;
    update();
  }
}

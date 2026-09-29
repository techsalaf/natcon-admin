// ignore_for_file: file_names, duplicate_ignore, avoid_print, dead_code
// ignore_for_file: file_names
import 'dart:convert';
import 'dart:developer';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:magicmate_organizer/api_screens/natcon_http.dart';

//! Api Call
class ApiWrapper {
  static Map<String, String> get headers {
    final token = getData.read('NATCON_ACCESS_TOKEN')?.toString() ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
  static doImageUpload(
      String endpoint, Map<String, String> params, List imgs) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(AppUrl.baseUrl + endpoint));
    request.fields.addAll(params);
    for (int i = 0; i < imgs.length; i++) {
      log(imgs[i].toString(), name: "Image name $i");
      request.files.add(await http.MultipartFile.fromPath('image$i', imgs[i]));
    }
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    var model = await response.stream.bytesToString();
    return jsonDecode(model);
  }

  static showToastMessage(message) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: appcolor,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static dataPost(appUrl, method) async {
    // try {
      var url = Uri.parse(AppUrl.baseUrl + appUrl);
      print(url);
      print(method);

      var request = await NatconHttp.post(url, headers: headers, body: jsonEncode(method));
      print("response----- ${request.body}");
      if (request.statusCode == 200) {
      var response = jsonDecode(request.body);
        return response;
      }
    // } catch (e) {
    //   print("Exeption----- $e");
    // }
  }

  static dataGet(appUrl) async {
    try {
      var url = Uri.parse(AppUrl.baseUrl + appUrl);
      var request = await NatconHttp.get(url, headers: headers);
      var response = jsonDecode(request.body);
      if (request.statusCode == 200) {
        return response;
      } else {
        print(request.reasonPhrase);
      }
    } catch (e) {
      return e;
      print("Exeption----- $e");
    }
  }

  static dataGetLocation(appUrl) async {
    try {
      var request = await NatconHttp.get(appUrl, headers: headers);
      var response = jsonDecode(request.body);
      if (request.statusCode == 200) {
        return response;
      } else {
        print(request.reasonPhrase);
      }
    } catch (e) {
      print("Exeption----- $e");
    }
  }
}

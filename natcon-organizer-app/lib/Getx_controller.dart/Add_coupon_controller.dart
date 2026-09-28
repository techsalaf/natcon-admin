// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, non_constant_identifier_names, file_names

import 'dart:convert';

import 'package:magicmate_organizer/Getx_controller.dart/Coupon_controller.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AddCouponlistController extends GetxController implements GetxService {
  CouponController couponlistController = Get.find();

  TextEditingController Expiredate = TextEditingController();
  TextEditingController couponcode = TextEditingController();
  TextEditingController coupontitle = TextEditingController();
  TextEditingController couponsubtitle = TextEditingController();
  TextEditingController couponminorder = TextEditingController();
  TextEditingController couponvalue = TextEditingController();
  TextEditingController coupondiscription = TextEditingController();

  String? path;
  String? base64Image;

  String countryId = "";

  String pType = "";
  String pbuySell = "";
  String status = "";

  String couponImage = "";

  var selectedIndexes = [];

  var lat;
  var long;

  String Editimage = "";
  String Editexpiredate = "";
  String Editccode = "";
  String Edittitle = "";
  String Editsubtitle = "";
  String Editcminorder = "";
  String Editcvalue = "";
  String Editcdiscription = "";
  String Editstatus = "";

  var elat;
  var elong;
  bool isLoading = false;
  getEditDetails(
      {String? Editcouponimage,
      Editexpiredate1,
      Editcouponcode,
      Editcoupontitle,
      Editcouponsubtitle,
      Editcouponminorder,
      editcouponvalue,
      EditCoupondiscription,
      estatus}) {
    Editimage = Editcouponimage ?? "";
    Editexpiredate = Editexpiredate1 ?? "";
    Editccode = Editcouponcode ?? "";
    Edittitle = Editcoupontitle ?? "";
    Editsubtitle = Editcouponsubtitle ?? "";
    Editcminorder = Editcouponminorder ?? "";
    Editcvalue = editcouponvalue ?? "";
    Editcdiscription = EditCoupondiscription ?? "";
    Editstatus = estatus ?? "";

    update();
  }

  getCurrentLatAndLong(double latitude, double longitude) {
    lat = latitude;
    long = longitude;
    update();
  }

  emptyAllDetails() {
    Expiredate.text = "";
    couponcode.text = "";
    coupontitle.text = "";
    couponsubtitle.text = "";
    couponminorder.text = "";
    couponvalue.text = "";
    coupondiscription.text = "";
    path = null;
    base64Image = "";
    status = "";
    couponImage = "";
    update();
  }
  bool isLoad = false;
  addcoupon() {
    isLoading = true;
    update();
    if(isLoad){
      return;
    }else{
      isLoad = true;
    }
    var data = {
      "orag_id": getData.read("UserLogin")["id"],
      "status": status != "" ? status : "1",
      "description": coupondiscription.text,
      "subtitle": couponsubtitle.text,
      "title": coupontitle.text,
      "coupon_code": couponcode.text,
      "expire_date": Expiredate.text,
      "min_amt": couponminorder.text,
      "coupon_val": couponvalue.text,
      "img": base64Image
    };
    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$data");
    ApiWrapper.dataPost(AppUrl.addcoupon, data).then((val) {
      if ((val != null) && (val.isNotEmpty)) {
        if ((val['ResponseCode'] == "200") && (val['Result'] == "true")) {
          isLoad = false;
          isLoading = false;
          update();
          couponlistController.couponlist();
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
          Get.back();
        } else {
          isLoading = false;
          update();
          ApiWrapper.showToastMessage(val["ResponseMsg"]);
        }
      }
      isLoading = false;
      update();
    });
  }

  updatecoupon({String? recordid}) async {
    isLoading = true;
    update();
    if(isLoad){
      return;
    }else{
      isLoad = true;
    }
    try {
      var data = {
        "orag_id": getData.read("UserLogin")["id"],
        "status": status != "" ? status : "1",
        "description": coupondiscription.text,
        "subtitle": couponsubtitle.text,
        "title": coupontitle.text,
        "coupon_code": couponcode.text,
        "expire_date": Expiredate.text,
        "min_amt": couponminorder.text,
        "coupon_val": couponvalue.text,
        "img": path != null ? base64Image.toString() : "0",
        "record_id": recordid,
      };
      Uri uri = Uri.parse(AppUrl.baseUrl + AppUrl.updatecoupon);
      var response = await http.post(
        uri,
        body: jsonEncode(data),
      );
      print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&${response.toString()}");
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&${result.toString()}");
        ApiWrapper.showToastMessage(result["ResponseMsg"]);
        isLoad = false;
        isLoading = false;
        update();
        couponlistController.couponlist();
        Get.back();
      }
      isLoading = false;
      update();
    } catch (e) {
      print(e.toString());
    }
  }
}

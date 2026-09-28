// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field, must_be_immutable, file_names

import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Add_coupon_controller.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/dark_light_mode.dart';

class AddCouponscreen extends StatefulWidget {
  String? add;
  String? recordid;
  AddCouponscreen({this.add, this.recordid, super.key});

  @override
  State<AddCouponscreen> createState() => _AddCouponscreenState();
}

List<String> list = ["Yes", "No"];
List<String> propartyStatus = ["Publish", "UnPublish"];
List<String> category = ["fevar"];

class _AddCouponscreenState extends State<AddCouponscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddCouponlistController addCouponlistController = Get.find();
  // CategoryController categoryController = Get.put(CategoryController());

  String selectValue = list.first;
  String fevar = category.first;
  String? selectProperty;
  String? selectCountry;
  String slectStatus = propartyStatus.first;

  bool carCheck = false;
  bool sportCheck = false;
  bool laundaryCheck = false;

  @override
  void initState() {
    getDarkMode();
    super.initState();
    if (widget.add == "edit") {
      setState(() {
        addCouponlistController.emptyAllDetails();
        addCouponlistController.couponImage = addCouponlistController.Editimage;
        addCouponlistController.Expiredate.text =
            addCouponlistController.Editexpiredate.split(" ").first;
        addCouponlistController.couponcode.text =
            addCouponlistController.Editccode;
        addCouponlistController.coupontitle.text =
            addCouponlistController.Edittitle;
        addCouponlistController.couponsubtitle.text =
            addCouponlistController.Editsubtitle;
        addCouponlistController.couponminorder.text =
            addCouponlistController.Editcminorder;
        addCouponlistController.couponvalue.text =
            addCouponlistController.Editcvalue;
        addCouponlistController.coupondiscription.text =
            addCouponlistController.Editcdiscription;
      });
    } else {
      addCouponlistController.emptyAllDetails();
    }
  }
  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }


  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: appbar(title: "Add Coupons".tr),
      backgroundColor: notifier.background,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: GestButton(
            Width: Get.size.width,
            height: 55,
            gradient: gradient.btnGradient,
            buttontext: "Update".tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              color: WhiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            onclick: () {
              if (_formKey.currentState?.validate() ?? false) {
                if (addCouponlistController.path != null ||
                    addCouponlistController.couponImage != "") {
                  if (widget.add == "Add") {
                    addCouponlistController.addcoupon();
                  }
                  if (widget.add == "edit") {
                    addCouponlistController.updatecoupon(
                        recordid: widget.recordid);
                  }
                } else {
                  ApiWrapper.showToastMessage("Please Upload Image".tr);
                }
              }
            }),
      ),
      body: GetBuilder<AddCouponlistController>(
        builder: (addCouponlistController) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: Get.height * 0.02),
                                Text(
                                  "Coupon Image".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 16,
                                    color: notifier.textColor,
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.015),
                                DottedBorder(
                                  borderType: BorderType.RRect,
                                  color: appcolor,
                                  radius: Radius.circular(15),
                                  child: InkWell(
                                    onTap: _openGallery,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: widget.add == "Add"
                                          ? Container(
                                              height: 80,
                                              margin:
                                                  EdgeInsets.symmetric(horizontal: 20),
                                              width: Get.size.width,
                                              alignment: Alignment.center,
                                              child:
                                                  addCouponlistController.path == null
                                                      ? Image.asset(
                                                          "assets/uplodeimage.png",
                                                          height: 40,
                                                          width: 42,
                                                        )
                                                      : Image.file(
                                                          File(
                                                            addCouponlistController.path
                                                                .toString(),
                                                          ),
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.cover,
                                                        ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            )
                                          : Container(
                                              height: 80,
                                              margin:
                                                  EdgeInsets.symmetric(horizontal: 20),
                                              width: Get.size.width,
                                              alignment: Alignment.center,
                                              child: addCouponlistController
                                                          .couponImage ==
                                                      ""
                                                  ? Image.asset(
                                                      "assets/uplodeimage.png",
                                                      height: 40,
                                                      width: 42,
                                                    )
                                                  : addCouponlistController.path == null
                                                      ? Image.network(
                                                          "${AppUrl.imageurl}${addCouponlistController.couponImage}",
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.file(
                                                          File(
                                                            addCouponlistController.path
                                                                .toString(),
                                                          ),
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.cover,
                                                        ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.01),
                                textfield(
                                  type: "Coupon Expiry Date".tr,
                                  controller: addCouponlistController.Expiredate,
                                  textInputType: TextInputType.number,
                                  labelText: "yyyy-MM-dd".tr,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Coupon Expiry Date'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.height * 0.01),
                                textfield(
                                  type: "Coupon Code".tr,
                                  controller: addCouponlistController.couponcode,
                                  labelText: "Enter Coupon Code".tr,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Coupon Code'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.height * 0.01),
                                textfield(
                                  type: "Coupon title".tr,
                                  controller: addCouponlistController.coupontitle,
                                  labelText: "Enter Coupon title".tr,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Coupon title'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.height * 0.01),
                                textfield(
                                  type: "Coupon subtitle".tr,
                                  controller: addCouponlistController.couponsubtitle,
                                  labelText: "Enter Coupon subtitle".tr,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Coupon subtitle'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.height * 0.01),
                                textfield(
                                  type: "Coupon Min Order Amount".tr,
                                  controller: addCouponlistController.couponminorder,
                                  labelText: "Enter Min Order Amount".tr,
                                  textInputType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Min Order Amount'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.height * 0.01),
                                textfield(
                                  type: "Coupon Value".tr,
                                  controller: addCouponlistController.couponvalue,
                                  labelText: "Enter Coupon Value".tr,
                                  textInputType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Coupon Value'.tr;
                                    } else if (int.parse(value) >=
                                        int.parse(addCouponlistController
                                            .couponminorder.text)) {
                                      return 'Please Enter min amount getarthen coupon'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.height * 0.015),
                                Text(
                                  "Coupon Description".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 16,
                                    color: notifier.textColor,
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.01),
                                Container(
                                  child: TextFormField(
                                    controller:
                                        addCouponlistController.coupondiscription,
                                    minLines: 5,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    cursorColor: notifier.textColor,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: appcolor),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      contentPadding: EdgeInsets.all(10),
                                      border: InputBorder.none,
                                      hintText: "Description".tr,
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 15,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 16,
                                      color: notifier.textColor,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Medicine Description'.tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  decoration: BoxDecoration(
                                    color: notifier.background,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: notifier.border),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.02),
                                Text(
                                  "Coupon Status".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 16,
                                    color: notifier.textColor,
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.012),
                                Container(
                                  height: 60,
                                  width: Get.size.width,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: DropdownButton(
                                    dropdownColor: notifier.background,
                                    value: slectStatus,
                                    icon: Image.asset(
                                      'assets/Arrowdown.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    isExpanded: true,
                                    underline: SizedBox.shrink(),
                                    items: propartyStatus
                                        .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: notifier.textColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value == "Publish") {
                                        addCouponlistController.status = "1";
                                      } else if (value == "UnPublish") {
                                        addCouponlistController.status = "0";
                                      }
                                      setState(() {
                                        slectStatus = value ?? "";
                                        // listOfUser.add(selectValue);
                                      });
                                    },
                                  ),
                                  decoration: BoxDecoration(
                                    color: notifier.background,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: notifier.border),
                                  ),
                                ),
                                SizedBox(height: 25),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: notifier.containerColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              addCouponlistController.isLoading ? Center(child: CircularProgressIndicator()) : SizedBox()
            ],
          );
        }
      ),
    );
  }

  void _openGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addCouponlistController.path = pickedFile.path;
      setState(() {});
      File imageFile = File(addCouponlistController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addCouponlistController.base64Image = base64Encode(imageBytes);
      print("!!!!!!!!!++++++++++++${addCouponlistController.base64Image}");
      setState(() {});
    }
  }
}

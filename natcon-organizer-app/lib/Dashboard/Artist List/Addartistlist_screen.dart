// ignore_for_file: sort_child_properties_last, must_be_immutable, file_names, prefer_const_constructors, unused_local_variable, deprecated_member_use, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Addartist_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Listofevent_controller.dart';
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
import '../../Getx_controller.dart/Dashboard_controller.dart';
import '../../utils/dark_light_mode.dart';

class Addartistlistscreen extends StatefulWidget {
  String? add;
  String? eventName;
  String? eventId;
  String? recodeId;
  Addartistlistscreen(
      {this.add, this.eventName, this.eventId, this.recodeId, super.key});

  @override
  State<Addartistlistscreen> createState() => _AddartistlistscreenState();
}

List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddartistlistscreenState extends State<Addartistlistscreen> {
  ListofeventController listofeventController = Get.find();
  AddartistController addartistController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DashboardController dashboardController = Get.put(DashboardController());

  String? path;
  String? selectevent;
  String slectStatus = propartyStatus.first;

  @override
  void initState() {
    getDarkMode();
    super.initState();
    listofeventController.listofevent();
    if (widget.add == "edit") {
      setState(() {
        addartistController.artistname.text = addartistController.artistName;
        addartistController.artistrole.text = addartistController.artistRole;
        // selectevent = widget.eventName;
        addartistController.pType = widget.eventId ?? "";
      });
    } else if (widget.add == "Add") {
      setState(() {
        addartistController.artistname.text = "";
        addartistController.artistrole.text = "";
        addartistController.pType = "";
      });
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
      appBar: appbar(title: "Add Artist".tr),
      backgroundColor: notifier.containerColor,
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
            if (widget.add == "Add") {
              if (_formKey.currentState?.validate() ?? false) {
                if (addartistController.path != null) {
                  if (selectevent != null) {
                    addartistController.artisAdd().then((value) {
                      dashboardController.dashboard();
                      setState(() {});
                    },);
                    
                  } else {
                    ApiWrapper.showToastMessage("Please Select Event".tr);
                  }
                } else {
                  ApiWrapper.showToastMessage("Please Upload Artist Image".tr);
                }
              }
            } else if (widget.add == "edit") {
              addartistController.artistEdit(recordid: widget.recodeId).then((value) {
                dashboardController.dashboard();
                setState(() {

                });
              },);
            }
          },
        ),
      ),
      body: GetBuilder<AddartistController>(
        builder: (addartistController) {
          return Stack(
            children: [
              SizedBox(
                height: Get.size.height,
                width: Get.size.width,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Get.height * 0.02),
                          Text(
                            "Event Cover Image".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.015),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: notifier.background
                            ),
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              color: appcolor,
                              radius: Radius.circular(15),
                              // borderPadding: EdgeInsets.symmetric(horizontal: 20),
                              child: InkWell(
                                onTap: () {
                                  _openGallery();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: widget.add == "Add"
                                      ? Container(
                                          height: 80,
                                          margin: EdgeInsets.symmetric(horizontal: 20),
                                          width: Get.size.width,
                                          alignment: Alignment.center,
                                          child: addartistController.path == null
                                              ? Image.asset(
                                                  "assets/uplodeimage.png",
                                                  height: 40,
                                                  width: 42,
                                                )
                                              : Image.file(
                                                  File(
                                                    addartistController.path ?? "",
                                                  ),
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        )
                                      : addartistController.artistImage == ""
                                          ? Container(
                                              height: 80,
                                              margin:
                                                  EdgeInsets.symmetric(horizontal: 20),
                                              width: Get.size.width,
                                              alignment: Alignment.center,
                                              child: Image.asset(
                                                "assets/uplodeimage.png",
                                                height: 40,
                                                width: 42,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            )
                                          : addartistController.path == null
                                              ? Container(
                                                  height: 80,
                                                  width: Get.size.width,
                                                  alignment: Alignment.center,
                                                  child: Image.network(
                                                    "${AppUrl.imageurl}${addartistController.artistImage}",
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Container(
                                                  height: 80,
                                                  width: Get.size.width,
                                                  alignment: Alignment.center,
                                                  child: Image.file(
                                                    File(
                                                      addartistController.path.toString(),
                                                    ),
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Get.height * 0.02),
                          Text(
                            "Select Event".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 16,
                              color: notifier.textColor,
                            ),
                          ),
                          SizedBox(height: Get.height * 0.012),
                          // GetBuilder<MymedicineController>(builder: (context) {
                          //   return
                          Container(
                            height: 60,
                            width: Get.size.width,
                            alignment: Alignment.center,
                            // margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: DropdownButton(
                              dropdownColor: notifier.background,
                              hint: Text(
                                "Select Event".tr,
                                style: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    fontSize: 15,
                                    color: notifier.textColor),
                              ),
                              value: selectevent,
                              icon: Image.asset(
                                'assets/Arrowdown.png',
                                height: 20,
                                width: 20,
                              ),
                              isExpanded: true,
                              underline: SizedBox.shrink(),
                              items: listofeventController.selectevent
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
                                addartistController.pType = listofeventController.listofeventinfo[listofeventController.selectevent.indexOf(value ?? "")].eventId;
                                // addartistController.pType = listofeventController.listModel!.eventdata[listofeventController.selectevent.indexOf(value ?? "")].eventId;
                                print("+++++++++++++++++++++" + addartistController.pType);

                                setState(() {
                                  selectevent = value ?? "";
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
                          // }),
                          // SizedBox(height: Get.height * 0.02),
                          SizedBox(height: Get.height * 0.01),
                          textfield(
                            type: "Artist Name".tr,
                            controller: addartistController.artistname,
                            labelText: "Enter Artist Name".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Artist Name'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Get.height * 0.01),
                          textfield(
                            type: "Artist Role".tr,
                            controller: addartistController.artistrole,
                            labelText: "Enter Artist Role".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Artist Role'.tr;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Get.height * 0.02),
                          Text(
                            "Event Cover Image Status".tr,
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
                                  addartistController.status = "1";
                                } else if (value == "UnPublish") {
                                  addartistController.status = "0";
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
                  ),
                ),
              ),
              addartistController.isLoading ? Center(child: CircularProgressIndicator(),) : SizedBox()
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
      addartistController.path = pickedFile.path;
      setState(() {});
      File imageFile = File(addartistController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addartistController.base64Image = base64Encode(imageBytes);
      print("!!!!!!!!!++++++++++++${addartistController.base64Image}");
      setState(() {});
    }
  }
}

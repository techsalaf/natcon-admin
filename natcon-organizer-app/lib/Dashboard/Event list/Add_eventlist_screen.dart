// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print, deprecated_member_use, unused_field, file_names, must_be_immutable, unused_local_variable, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields, body_might_complete_normally_nullable, unnecessary_null_comparison, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Addeventlist_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Category_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Dashboard_controller.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/dark_light_mode.dart';

class Addeventlistscreen extends StatefulWidget {
  String? add;
  String? recordid;
  String? categoryname;
  String? categoryid;
  Addeventlistscreen({this.add, this.recordid, this.categoryid, this.categoryname, super.key});

  @override
  State<Addeventlistscreen> createState() => _AddeventlistscreenState();
}

CategoryController categoryController = Get.put(CategoryController());

List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddeventlistscreenState extends State<Addeventlistscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AddlistofeventController addlistofeventController = Get.put(AddlistofeventController());
  DashboardController dashboardController = Get.find();
  // CategoryController categoryController = Get.put(CategoryController());

  String? categorylist;

  String? selectProperty;
  String? selectCountry;
  String slectStatus = propartyStatus.first;

  bool carCheck = false;
  bool sportCheck = false;
  bool laundaryCheck = false;
  String? path;
  String? eventcover;
  String eventdescription = "";
  String eventdisclaimer = "";

  @override
  void initState() {
    getDarkMode();
    _selectedYear = DateTime.now().year;
    // dashboardController.getFacilityList();
    // dashboardController.getRestrictionList();
    addlistofeventController.eventTitle = TextEditingController();
    addlistofeventController.description = TextEditingController();
    addlistofeventController.disclaimer = TextEditingController();
    addlistofeventController.placename = TextEditingController();
    addlistofeventController.starttime = TextEditingController();
    addlistofeventController.endtime = TextEditingController();
    addlistofeventController.address = TextEditingController();
    addlistofeventController.eventdate = TextEditingController();
    addlistofeventController.youtubeurl = TextfieldTagsController();
    addlistofeventController.tegs = TextfieldTagsController();
    super.initState();
    if (widget.add == "edit") {
      print(
          "++++++++++++++++++++++++++++++${addlistofeventController.eventdescription}");

      var description = parse(addlistofeventController.eventdescription);
      if (description.documentElement != null) {
        eventdescription = description.documentElement!.text;
        print("333333333333333333333333" + eventdescription);
        //output without space: HelloThis is fluttercampus.com,Bye!
      }
      var disclaimer = parse(addlistofeventController.eventdisclaimer);
      if (disclaimer.documentElement != null) {
        eventdisclaimer = disclaimer.documentElement!.text;
        print("333333333333333333333333" + eventdisclaimer);
        //output without space: HelloThis is fluttercampus.com,Bye!
      }
      setState(() {
        addlistofeventController.emptyAllDetails();
        addlistofeventController.eventimage =
            addlistofeventController.eventimage;
        addlistofeventController.eventcoverimage =
            addlistofeventController.eventcoverimage;
        addlistofeventController.eventTitle.text =
            addlistofeventController.eventname;
        addlistofeventController.address.text =
            addlistofeventController.eventaddress;
        addlistofeventController.eventdate.text =
            addlistofeventController.dateevent;
        addlistofeventController.placename.text =
            addlistofeventController.eventplace;
        addlistofeventController.description.text = eventdescription;
        addlistofeventController.disclaimer.text = eventdisclaimer;
        addlistofeventController.starttime.text =
            addlistofeventController.eventstarttime;
        addlistofeventController.endtime.text =
            addlistofeventController.eventendtime;
        addlistofeventController.youtubeurl =
            addlistofeventController.youtubeurl;
        addlistofeventController.tegs = addlistofeventController.tegs;
        addlistofeventController.long = addlistofeventController.longitude;
        addlistofeventController.lat = addlistofeventController.latitude;
        addlistofeventController.pType = widget.categoryid!;
        categorylist = widget.categoryname;
      });
    } else {
      addlistofeventController.lat = "";
      addlistofeventController.long = "";
      addlistofeventController.emptyAllDetails();
    }
    // addlistofeventController.youtubeurl = TextfieldTagsController();
  }

  // TextfieldTagsController _controller = TextfieldTagsController();
  double _distanceToField = 0.0;
  late int _selectedYear;

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
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


  _launchURL() async {
    final Uri url = Uri.parse('https://ibb.co/W6pJM4m');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  String formatTimeOfDayTo24Hour(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat('HH:mm');  // Use 'hh:mm a' for 12-hour format
    return format.format(dt);
  }

  bool isAdded = false;
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      appBar: appbar(title: "Add Event".tr),
      backgroundColor: notifier.background,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: GestButton(
            Width: Get.size.width,
            height: 55,
            gradient: gradient.btnGradient,
            buttontext: widget.add == "Add" ? "Add".tr : "Update".tr,
            style: TextStyle(
              fontFamily: FontFamily.gilroyBold,
              color: WhiteColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            onclick: () {
              print("************************* ${addlistofeventController.restriction}");
              print("------------------- ${addlistofeventController.restirectedindex}");
              print("123444444444444444444444444444444");
              print("************************* ${addlistofeventController.facelity}");
              print("------------------- ${addlistofeventController.selectedIndexes}");

              if (widget.add == "Add") {
                if (_formKey.currentState?.validate() ?? false) {

                  if (addlistofeventController.base64Image != null) {
                    if (addlistofeventController.coverimagebase64Image != null) {
                      if (addlistofeventController.lat != "" && addlistofeventController.long != "") {
                        setState(() {
                          isAdded = true;
                        });
                        if (categorylist != null) {
                          if (widget.add == "Add") {
                            addlistofeventController.eventadd().then((value) {
                              setState(() {
                               isAdded = false;
                              });
                              // addlistofeventController.bdatePicker.toString().split(" ").first == "";
                            },);
                          }else {
                            setState(() {
                              isAdded = false;
                            });
                          }
                        } else {
                          setState(() {
                            isAdded = false;
                          });
                          ApiWrapper.showToastMessage("Please Select Category".tr);
                        }
                      } else {
                        setState(() {
                          isAdded = false;
                        });
                        ApiWrapper.showToastMessage(
                            "Please Add Your Current Location".tr);
                      }
                    } else {
                      ApiWrapper.showToastMessage(
                          "Please Upload Event Cover Image".tr);
                    }
                  } else {
                    ApiWrapper.showToastMessage("Please Upload Event Image".tr);
                  }
                } else {
                  isAdded = false;
                  setState(() {});
                }
              } else if (widget.add == "edit") {
                setState(() {
                  isAdded = true;
                });
                addlistofeventController.eventedit(recordid: widget.recordid).then((value) {
                  isAdded = false;
                  setState(() {});
                },);
              }
            }),
      ),
      body: Stack(
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
                            SizedBox(height: Get.height * 0.01),
                            textfield(
                              type: "Event Name".tr,
                              controller: addlistofeventController.eventTitle,
                              labelText: "Enter Event Name".tr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Event Name'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Event Image".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.015),
                            Container(
                              decoration: BoxDecoration(
                              color: notifier.background,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                color: appcolor,
                                radius: Radius.circular(15),
                                // borderPadding: EdgeInsets.symmetric(horizontal: 20),
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
                                            child: addlistofeventController.path ==
                                                    null
                                                ? Image.asset(
                                                    "assets/uplodeimage.png",
                                                    height: 40,
                                                    width: 42,
                                                  )
                                                : Image.file(
                                                    File(
                                                      addlistofeventController.path
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
                                            child:
                                                addlistofeventController.eventimage ==
                                                        ""
                                                    ? Image.asset(
                                                        "assets/uplodeimage.png",
                                                        height: 40,
                                                        width: 42,
                                                      )
                                                    : addlistofeventController.path ==
                                                            null
                                                        ? Image.network(
                                                            "${AppUrl.imageurl}${addlistofeventController.eventimage}",
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Image.file(
                                                            File(
                                                              addlistofeventController
                                                                  .path
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
                            ),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Event Cover".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.015),
                            Container(
                              decoration: BoxDecoration(
                                color: notifier.background,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                color: appcolor,
                                radius: Radius.circular(15),
                                // borderPadding: EdgeInsets.symmetric(horizontal: 20),
                                child: InkWell(
                                  onTap: Eventcover,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: widget.add == "Add"
                                        ? Container(
                                            height: 80,
                                            margin:
                                                EdgeInsets.symmetric(horizontal: 20),
                                            width: Get.size.width,
                                            alignment: Alignment.center,
                                            child: addlistofeventController
                                                        .coverimagepath ==
                                                    null
                                                ? Image.asset(
                                                    "assets/uplodeimage.png",
                                                    height: 40,
                                                    width: 42,
                                                  )
                                                : Image.file(
                                                    File(
                                                      addlistofeventController
                                                          .coverimagepath
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
                                            child: addlistofeventController
                                                        .eventcoverimage ==
                                                    ""
                                                ? Image.asset(
                                                    "assets/uplodeimage.png",
                                                    height: 40,
                                                    width: 42,
                                                  )
                                                : addlistofeventController
                                                            .coverimagepath ==
                                                        null
                                                    ? Image.network(
                                                        "${AppUrl.imageurl}${addlistofeventController.eventcoverimage}",
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(
                                                          addlistofeventController
                                                              .coverimagepath
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
                            ),
                            SizedBox(height: Get.height * 0.01),





                            textfield(
                              type: "Event Date".tr,
                              // onTap: (){
                              //   showModalBottomSheet(
                              //       context: context,
                              //       builder: (c) {
                              //         return Padding(
                              //           padding: const EdgeInsets.all(10.0),
                              //           child: SizedBox(
                              //             height: 200,
                              //             child: CupertinoDatePicker(
                              //               mode: CupertinoDatePickerMode.date,
                              //               initialDateTime: DateTime(2000, 1, 1),
                              //               onDateTimeChanged: (DateTime newDateTime) {
                              //                 addlistofeventController.updatebdate(newDateTime);
                              //               },
                              //             ),
                              //           ),
                              //         );
                              //       },
                              //   );
                              // },
                              controller: addlistofeventController.eventdate,
                              labelText: "yyyy-mm-dd".tr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Event Date'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Event Start time".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.01),
                            TextFormField(
                              // controller: addTimeSlotController.mintime,
                              controller: addlistofeventController.starttime,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(
                                  color: notifier.textColor,
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 18),
                              decoration: InputDecoration(
                                hintText: "Event Start time".tr,
                                fillColor: notifier.background,
                                filled: true,
                                hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "Gilroy Medium",
                                    fontSize: 16),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: appcolor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide:
                                      BorderSide(color: notifier.border),
                                ),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: notifier.border),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              readOnly: true,
                              onTap: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  // initialTime: TimeOfDay.fromDateTime(DateTime),
                                  initialTime: TimeOfDay.now(),

                                  context: context,
                                );
                                print("-----======" + pickedTime.toString());
                                if (pickedTime != null) {
                                  print(pickedTime.format(context));
                                  addlistofeventController.StartTimeFormatted = formatTimeOfDayTo24Hour(pickedTime);
                                  addlistofeventController.starttime.text = pickedTime.format(context);
                                } else {
                                  print("Time is not selected".tr);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Event Start time'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Get.height * 0.025),
                            Text(
                              "Event End time".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.015),
                            TextFormField(
                              // controller: addTimeSlotController.maxtime,
                              controller: addlistofeventController.endtime,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: TextStyle(
                                  color: notifier.textColor,
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 18),
                              decoration: InputDecoration(
                                fillColor: notifier.background,
                                filled: true,
                                hintText: "Event End time".tr,
                                hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: "Gilroy Medium",
                                    fontSize: 16),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: appcolor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide:
                                      BorderSide(color: notifier.border),
                                ),
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: notifier.border),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              readOnly: true,
                              onTap: () async {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                );

                                if (pickedTime != null) {
                                  print("+++++++cdsf++++ ${pickedTime.format(context)}");

                                  addlistofeventController.EndTimeFormatted = formatTimeOfDayTo24Hour(pickedTime);
                                  addlistofeventController.endtime.text = pickedTime.format(context);

                                } else {
                                  print("Time is not selected".tr);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Event End time'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Get.height * 0.02),
                            GetBuilder<AddlistofeventController>(
                                builder: (context) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          "Latitude".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 16,
                                            color: notifier.textColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 60,
                                        width: Get.width * 0.43,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        alignment: Alignment.center,
                                        child: Text(
                                          // addlistofeventController.latitude,
                                          addlistofeventController.lat != null
                                              ? addlistofeventController.lat
                                                  .toString()
                                              : "",
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: notifier.textColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: notifier.background,
                                          border: Border.all(color: notifier.border),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          "Longitude".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            fontSize: 16,
                                            color: notifier.textColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 60,
                                        width: Get.width * 0.43,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        alignment: Alignment.center,
                                        child: Text(
                                          // addlistofeventController.longitude,
                                          addlistofeventController.long != null ? addlistofeventController.long.toString() : "",
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: notifier.textColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: notifier.background,
                                          border: Border.all(color: notifier.border),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            }),
                            SizedBox(height: Get.height * 0.02),
                            InkWell(
                              onTap: () async {
                                LocationPermission permission;
                                permission = await Geolocator.checkPermission();
                                permission = await Geolocator.requestPermission();
                                if (permission == LocationPermission.denied) {}
                                var currentLocation = await locateUser();
                                debugPrint('location: ${currentLocation.latitude}');
                                addlistofeventController.getCurrentLatAndLong(
                                  currentLocation.latitude,
                                  currentLocation.longitude,
                                );
                                print("????????????" +
                                    currentLocation.latitude.toString());
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/Navigation.png",
                                    height: 25,
                                    width: 25,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Click for Current Location".tr,
                                    style: TextStyle(
                                      color: notifier.textColor,
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Event Address".tr,
                              style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 16,
                                  color: notifier.textColor),
                            ),
                            SizedBox(height: Get.height * 0.012),
                            Container(
                              child: TextFormField(
                                controller: addlistofeventController.address,
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
                                  hintText: "Enter Event Address".tr,
                                  hintStyle: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: Colors.grey,
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
                                    return 'Please Enter Event Address'.tr;
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
                            SizedBox(height: Get.height * 0.01),
                            textfield(
                              type: "Event Place Name".tr,
                              controller: addlistofeventController.placename,
                              labelText: "Enter Event Place Name".tr,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Event Place Name'.tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Event Category".tr,
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
                                hint: Text(
                                  "Select Category".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 16,
                                    color: notifier.textColor,
                                  ),
                                ),
                                value: categorylist,
                                icon: Image.asset(
                                  'assets/Arrowdown.png',
                                  height: 20,
                                  width: 20,
                                ),
                                isExpanded: true,
                                underline: SizedBox.shrink(),
                                items: categoryController.categorytext.map<DropdownMenuItem<String>>((String value) {
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
                                  for (var i = 0; i < categoryController.categoryinfo!.categorydata.length; i++) {
                                    if (value == categoryController.categoryinfo!.categorydata[i].title) {
                                      addlistofeventController.pType = categoryController.categoryinfo!.categorydata[i].id;
                                    }
                                  }
                                  setState(() {
                                    categorylist = value ?? "";
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
                            SizedBox(height: Get.height * 0.02),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Multiple Youtube URL".tr,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    fontSize: 16,
                                    color: notifier.textColor,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Tooltip(
                                  height: 110,
                                  triggerMode: TooltipTriggerMode.tap,
                                  showDuration: Duration(seconds: 5),
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  textStyle: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                    color: WhiteColor,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appcolor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  message: "Here is a sample URL for a YouTube link [ https://ibb.co/W6pJM4m ]. The same format must be used. You can add multiple YouTube links, but each link must be followed by pressing Enter.",
                                  child: Transform.translate(
                                      offset: Offset(0,1),
                                      child: Icon(CupertinoIcons.info_circle_fill,color: appcolor,size: 22,
                                      ),
                                  ), //Text
                                ),
                              ],
                            ),
                            SizedBox(height: Get.height * 0.01),
                            youtubeurl(),
                            SizedBox(height: Get.height * 0.02),
                            tegs(),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Select Facility".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.02),
                            GetBuilder<AddlistofeventController>(
                                builder: (context) {
                              return GetBuilder<DashboardController>(
                                  builder: (context) {
                                return dashboardController.isLoading
                                    ? ListView.builder(
                                        itemCount: dashboardController.facilityInfo?.facilitydata.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  // SizedBox(
                                                  //   width: 10,
                                                  // ),
                                                  Transform.scale(
                                                    scale: 1,
                                                    child: Checkbox(
                                                      value: addlistofeventController.selectedIndexes.contains(dashboardController.facilityInfo?.facilitydata[index].id),
                                                      side: const BorderSide(
                                                          color: Color(0xffC5CAD4)),
                                                      activeColor: appcolor,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(5),
                                                      ),
                                                      onChanged: (_) {
                                                        if (addlistofeventController.selectedIndexes.contains(dashboardController.facilityInfo?.facilitydata[index].id)) {
                                                          addlistofeventController.selectedIndexes.remove(dashboardController.facilityInfo?.facilitydata[index].id); // unselect
                                                          print("nvjdvddy ${dashboardController.facilityInfo?.facilitydata[index].id}");
                                                          print("----------------- ${addlistofeventController.selectedIndexes}");
                                                          print("tag========>" + addlistofeventController.facelity);
                                                          setState(() {});
                                                        } else {
                                                          addlistofeventController.selectedIndexes.add(dashboardController.facilityInfo?.facilitydata[index].id);
                                                          print("djvdhvdv ${dashboardController.facilityInfo?.facilitydata[index].id}");
                                                          print("+++++++++++++++  ${addlistofeventController.selectedIndexes}");
                                                          setState(() {});
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Text(
                                                    dashboardController.facilityInfo?.facilitydata[index].title ?? "",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FontFamily.gilroyMedium,
                                                      fontSize: 17,
                                                      color: notifier.textColor,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    child: Image.network(
                                                      "${AppUrl.imageurl}${dashboardController.facilityInfo?.facilitydata[index].img ?? ""}",
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFeef4ff),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Divider(thickness: 1),
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      );
                              });
                            }),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Select Restriction".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.01),
                            GetBuilder<AddlistofeventController>(
                                builder: (context) {
                              return GetBuilder<DashboardController>(
                                  builder: (context) {
                                return dashboardController.isLoading
                                    ? ListView.builder(
                                        itemCount: dashboardController.restrictioninfo?.restrictiondata.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Transform.scale(
                                                    scale: 1,
                                                    child: Checkbox(
                                                      value: addlistofeventController.restirectedindex
                                                          .contains(
                                                              dashboardController
                                                                  .restrictioninfo
                                                                  ?.restrictiondata[
                                                                      index]
                                                                  .id),
                                                      side: const BorderSide(
                                                          color: Color(0xffC5CAD4)),
                                                      activeColor: appcolor,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                5),
                                                      ),
                                                      onChanged: (_) {
                                                        if (addlistofeventController
                                                            .restirectedindex
                                                            .contains(
                                                                dashboardController
                                                                    .restrictioninfo
                                                                    ?.restrictiondata[
                                                                        index]
                                                                    .id)) {
                                                          addlistofeventController
                                                              .restirectedindex
                                                              .remove(dashboardController
                                                                  .restrictioninfo
                                                                  ?.restrictiondata[
                                                                      index]
                                                                  .id); // unselect
                                                          setState(() {});
                                                        } else {
                                                          addlistofeventController
                                                              .restirectedindex
                                                              .add(dashboardController
                                                                  .restrictioninfo
                                                                  ?.restrictiondata[
                                                                      index]
                                                                  .id);
                                                          setState(() {}); // select
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Text(
                                                    dashboardController
                                                            .restrictioninfo
                                                            ?.restrictiondata[index]
                                                            .title ??
                                                        "",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FontFamily.gilroyMedium,
                                                      fontSize: 17,
                                                      color: notifier.textColor,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    child: Image.network(
                                                      "${AppUrl.imageurl}${dashboardController.restrictioninfo?.restrictiondata[index].img ?? ""}",
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFeef4ff),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Divider(thickness: 1),
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      );
                              });
                            }),
                            SizedBox(height: Get.height * 0.02),
                            Text(
                              "Event Description".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.012),
                            Container(
                              child: TextFormField(
                                controller: addlistofeventController.description,
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
                                  hintStyle: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                  hintText: 'Enter Event Description'.tr,
                                  contentPadding: EdgeInsets.all(10),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 16,
                                  color: notifier.textColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Event Description'.tr;
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
                              "Event Disclaimer".tr,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                fontSize: 16,
                                color: notifier.textColor,
                              ),
                            ),
                            SizedBox(height: Get.height * 0.012),
                            Container(
                              child: TextFormField(
                                controller: addlistofeventController.disclaimer,
                                minLines: 5,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                cursorColor: notifier.textColor,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontFamily: FontFamily.gilroyMedium,
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                  hintText: 'Enter Event Disclaimer'.tr,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: appcolor),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 16,
                                  color: notifier.textColor,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Event Disclaimer'.tr;
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
                            SizedBox(height: Get.height * 0.012),
                            Text(
                              "Event Status".tr,
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
                                    addlistofeventController.status = "1";
                                  } else if (value == "UnPublish") {
                                    addlistofeventController.status = "0";
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
          isAdded ? Center(child: CircularProgressIndicator()) : SizedBox()
        ],
      ),
    );
  }

  void _openGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addlistofeventController.path = pickedFile.path;
      setState(() {});
      File imageFile = File(addlistofeventController.path.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addlistofeventController.base64Image = base64Encode(imageBytes);
      setState(() {});
    }
  }

  void Eventcover() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      addlistofeventController.coverimagepath = pickedFile.path;
      setState(() {});
      File imageFile = File(addlistofeventController.coverimagepath.toString());
      List<int> imageBytes = imageFile.readAsBytesSync();
      addlistofeventController.coverimagebase64Image = base64Encode(imageBytes);
      setState(() {});
    }
  }

  youtubeurl() {
    return TextFieldTags(
      textfieldTagsController: addlistofeventController.youtubeurl,
      initialTags: addlistofeventController.youtube,
      textSeparators: const [' ', ','],
      letterCase: LetterCase.normal,
      inputFieldBuilder:(context, textFieldTagValues) {
        return TextField(
          controller: textFieldTagValues.textEditingController,
          focusNode: textFieldTagValues.focusNode,
          style: TextStyle(
              color: notifier.textColor,
              fontFamily: FontFamily.gilroyMedium,
              fontSize: 18),
          decoration: InputDecoration(
            fillColor: notifier.background,
            filled: true,
            // isDense: true,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: appcolor),
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: notifier.border),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: notifier.border),
              borderRadius: BorderRadius.circular(15),
            ),
            hintStyle: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 15,
                color: Colors.grey
            ),
            hintText: addlistofeventController.youtubeurl.getTags!.isEmpty
                ? ''
                : "Enter https://youtu.be/1s62eem-24A",
            errorText: textFieldTagValues.error,
            prefixIconConstraints:
            BoxConstraints(maxWidth: _distanceToField * 0.8),
            prefixIcon: textFieldTagValues.tags.isNotEmpty
                ? SingleChildScrollView(
              controller: textFieldTagValues.tagScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: textFieldTagValues.tags.map((tag) {
                  return InkWell(
                    onTap: () {
                      textFieldTagValues.onTagRemoved(tag);
                    },
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        gradient: gradient.btnGradient,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            child: Text(
                              '$tag',
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              //print("$tag selected");
                            },
                          ),
                          const SizedBox(width: 4.0),
                          InkWell(
                            child: const Icon(
                              Icons.cancel,
                              size: 14.0,
                              color: Color.fromARGB(255, 233, 233, 233),
                            ),
                            onTap: () {
                              textFieldTagValues.onTagRemoved(tag);
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },).toList(),
              ),
            )
                : null,
          ),
          onChanged: textFieldTagValues.onTagChanged,
          onSubmitted: textFieldTagValues.onTagSubmitted,
        );
      },
    );
  }

  tegs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Add Tag".tr,
              style: TextStyle(
                fontFamily: FontFamily.gilroyBold,
                fontSize: 16,
                color: notifier.textColor,
              ),
            ),
            SizedBox(width: 5),
            Tooltip(
              height: 50,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 5),
              margin: EdgeInsets.symmetric(horizontal: 10),
              textStyle: TextStyle(
                fontFamily: FontFamily.gilroyMedium,
                fontSize: 14,
                letterSpacing: 0.5,
                color: WhiteColor,
              ),
              decoration: BoxDecoration(
                color: appcolor,
                borderRadius: BorderRadius.circular(8),
              ),
              message: 'You can add multiple Tags, but each tags must be followed by pressing Enter. ',
              child: Transform.translate(
                  offset: Offset(0,3),
                  child: Icon(CupertinoIcons.info_circle_fill,color: appcolor,size: 22,)), //Text
            ),
          ],
        ),
        SizedBox(height: Get.height * 0.02),
        TextFieldTags(
          textfieldTagsController: addlistofeventController.tegs,
          initialTags: addlistofeventController.urltag,
          textSeparators: const [' ', ','],
          letterCase: LetterCase.normal,
          inputFieldBuilder: (context, textFieldTagValues) {
            return TextField(
              controller: textFieldTagValues.textEditingController,
              focusNode: textFieldTagValues.focusNode,
              style: TextStyle(
                  color: notifier.textColor,
                  fontFamily: FontFamily.gilroyMedium,
                  fontSize: 18),
              decoration: InputDecoration(
                fillColor: notifier.background,
                filled: true,
                // isDense: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appcolor),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: notifier.border),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: notifier.border),
                  borderRadius: BorderRadius.circular(15),
                ),
                hintStyle: TextStyle(
                  fontFamily: FontFamily.gilroyMedium,
                  color: Colors.grey,
                  fontSize: 15,
                ),
                hintText: addlistofeventController.tegs.getTags == null
                    ? ''
                    : "Enter tag..".tr,
                errorText: textFieldTagValues.error,
                prefixIconConstraints:
                BoxConstraints(maxWidth: _distanceToField * 0.8),
                prefixIcon: textFieldTagValues.tags.isNotEmpty
                    ? SingleChildScrollView(
                  controller: textFieldTagValues.tagScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      children: textFieldTagValues.tags.map((tag) {
                        return InkWell(
                          onTap: () {
                            textFieldTagValues.onTagRemoved(tag);
                          },
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              gradient: gradient.btnGradient,
                            ),
                            margin:
                            const EdgeInsets.symmetric(horizontal: 5.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  child: Text(
                                    '$tag',
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                  onTap: () {
                                    //print("$tag selected");
                                  },
                                ),
                                const SizedBox(width: 4.0),
                                InkWell(
                                  child: const Icon(
                                    Icons.cancel,
                                    size: 14.0,
                                    color:
                                    Color.fromARGB(255, 233, 233, 233),
                                  ),
                                  onTap: () {
                                    textFieldTagValues.onTagRemoved(tag);
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList()),
                )
                    : null,
              ),
              onChanged: textFieldTagValues.onTagChanged,
              onSubmitted: textFieldTagValues.onTagSubmitted,
            );
          },
        ),
      ],
    );
  }

  // youtubeurl() {
  //   return TextFieldTags(
  //     textfieldTagsController: addlistofeventController.youtubeurl,
  //     initialTags: addlistofeventController.youtube,
  //     textSeparators: const [' ', ','],
  //     letterCase: LetterCase.normal,
  //     validator: (String tag) {
  //       // if (tag == 'php') {
  //       //   return 'No, please just no';
  //       // } else if (_controller.getTags?.contains(tag)) {
  //       //   return 'you already entered that';
  //       // }
  //       // return null;
  //     },
  //     inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
  //       return ((context, sc, tags, onTagDelete) {
  //         return TextField(
  //           controller: tec,
  //           focusNode: fn,
  //           style: TextStyle(
  //               color: notifier.textColor,
  //               fontFamily: FontFamily.gilroyMedium,
  //               fontSize: 18),
  //           decoration: InputDecoration(
  //             fillColor: notifier.background,
  //             filled: true,
  //             // isDense: true,
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: BorderSide(color: appcolor),
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(15),
  //               borderSide: BorderSide(color: notifier.border),
  //             ),
  //             border: OutlineInputBorder(
  //               borderSide: BorderSide(color: notifier.border),
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             hintStyle: TextStyle(
  //               fontFamily: FontFamily.gilroyMedium,
  //               fontSize: 15,
  //               color: Colors.grey
  //             ),
  //             hintText: addlistofeventController.youtubeurl.hasTags
  //                 ? ''
  //                 : "Enter https://youtu.be/1s62eem-24A",
  //             errorText: error,
  //             prefixIconConstraints:
  //                 BoxConstraints(maxWidth: _distanceToField * 0.8),
  //             prefixIcon: tags.isNotEmpty
  //                 ? SingleChildScrollView(
  //                     controller: sc,
  //                     scrollDirection: Axis.horizontal,
  //                     child: Row(
  //                         children: tags.map((String tag) {
  //                       return InkWell(
  //                         onTap: () {
  //                           onTagDelete(tag);
  //                         },
  //                         child: Container(
  //                           height: 30,
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.all(
  //                               Radius.circular(10.0),
  //                             ),
  //                             gradient: gradient.btnGradient,
  //                           ),
  //                           margin: const EdgeInsets.symmetric(horizontal: 5.0),
  //                           padding: const EdgeInsets.symmetric(
  //                               horizontal: 10.0, vertical: 5.0),
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               InkWell(
  //                                 child: Text(
  //                                   '$tag',
  //                                   style: const TextStyle(color: Colors.white),
  //                                 ),
  //                                 onTap: () {
  //                                   //print("$tag selected");
  //                                 },
  //                               ),
  //                               const SizedBox(width: 4.0),
  //                               InkWell(
  //                                 child: const Icon(
  //                                   Icons.cancel,
  //                                   size: 14.0,
  //                                   color: Color.fromARGB(255, 233, 233, 233),
  //                                 ),
  //                                 onTap: () {
  //                                   onTagDelete(tag);
  //                                 },
  //                               )
  //                             ],
  //                           ),
  //                         ),
  //                       );
  //                     }).toList()),
  //                   )
  //                 : null,
  //           ),
  //           onChanged: onChanged,
  //           onSubmitted: onSubmitted,
  //         );
  //       });
  //     },
  //   );
  // }
  //
  // tegs() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Text(
  //             "Add Tag".tr,
  //             style: TextStyle(
  //               fontFamily: FontFamily.gilroyBold,
  //               fontSize: 16,
  //               color: notifier.textColor,
  //             ),
  //           ),
  //           SizedBox(width: 5),
  //           Tooltip(
  //             height: 50,
  //             triggerMode: TooltipTriggerMode.tap,
  //             showDuration: Duration(seconds: 5),
  //             margin: EdgeInsets.symmetric(horizontal: 10),
  //             textStyle: TextStyle(
  //               fontFamily: FontFamily.gilroyMedium,
  //               fontSize: 14,
  //               letterSpacing: 0.5,
  //               color: WhiteColor,
  //             ),
  //             decoration: BoxDecoration(
  //               color: appcolor,
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             message: 'You can add multiple Tags, but each tags must be followed by pressing Enter. ',
  //             child: Transform.translate(
  //               offset: Offset(0,3),
  //                 child: Icon(CupertinoIcons.info_circle_fill,color: appcolor,size: 22,)), //Text
  //           ),
  //         ],
  //       ),
  //       SizedBox(height: Get.height * 0.02),
  //       TextFieldTags(
  //         textfieldTagsController: addlistofeventController.tegs,
  //         initialTags: addlistofeventController.urltag,
  //         textSeparators: const [' ', ','],
  //         letterCase: LetterCase.normal,
  //         validator: (String tag) {
  //           // if (tag == 'php') {
  //           //   return 'No, please just no';
  //           // } else if (_controller.getTags?.contains(tag)) {
  //           //   return 'you already entered that';
  //           // }
  //           // return null;
  //         },
  //         inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
  //           return ((context, sc, tags, onTagDelete) {
  //             return TextField(
  //               controller: tec,
  //               focusNode: fn,
  //               style: TextStyle(
  //                   color: notifier.textColor,
  //                   fontFamily: FontFamily.gilroyMedium,
  //                   fontSize: 18),
  //               decoration: InputDecoration(
  //                 fillColor: notifier.background,
  //                 filled: true,
  //                 // isDense: true,
  //                 focusedBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(color: appcolor),
  //                   borderRadius: BorderRadius.circular(15),
  //                 ),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(15),
  //                   borderSide: BorderSide(color: notifier.border),
  //                 ),
  //                 border: OutlineInputBorder(
  //                   borderSide: BorderSide(color: notifier.border),
  //                   borderRadius: BorderRadius.circular(15),
  //                 ),
  //                 hintStyle: TextStyle(
  //                   fontFamily: FontFamily.gilroyMedium,
  //                   color: Colors.grey,
  //                   fontSize: 15,
  //                 ),
  //                 hintText: addlistofeventController.tegs.hasTags
  //                     ? ''
  //                     : "Enter tag..".tr,
  //                 errorText: error,
  //                 prefixIconConstraints:
  //                     BoxConstraints(maxWidth: _distanceToField * 0.8),
  //                 prefixIcon: tags.isNotEmpty
  //                     ? SingleChildScrollView(
  //                         controller: sc,
  //                         scrollDirection: Axis.horizontal,
  //                         child: Row(
  //                             children: tags.map((String tag) {
  //                           return InkWell(
  //                             onTap: () {
  //                               onTagDelete(tag);
  //                             },
  //                             child: Container(
  //                               height: 30,
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.all(
  //                                   Radius.circular(10.0),
  //                                 ),
  //                                 gradient: gradient.btnGradient,
  //                               ),
  //                               margin:
  //                                   const EdgeInsets.symmetric(horizontal: 5.0),
  //                               padding: const EdgeInsets.symmetric(
  //                                   horizontal: 10.0, vertical: 5.0),
  //                               child: Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   InkWell(
  //                                     child: Text(
  //                                       '$tag',
  //                                       style: const TextStyle(
  //                                           color: Colors.white),
  //                                     ),
  //                                     onTap: () {
  //                                       //print("$tag selected");
  //                                     },
  //                                   ),
  //                                   const SizedBox(width: 4.0),
  //                                   InkWell(
  //                                     child: const Icon(
  //                                       Icons.cancel,
  //                                       size: 14.0,
  //                                       color:
  //                                           Color.fromARGB(255, 233, 233, 233),
  //                                     ),
  //                                     onTap: () {
  //                                       onTagDelete(tag);
  //                                     },
  //                                   )
  //                                 ],
  //                               ),
  //                             ),
  //                           );
  //                         }).toList()),
  //                       )
  //                     : null,
  //               ),
  //               onChanged: onChanged,
  //               onSubmitted: onSubmitted,
  //             );
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }
}



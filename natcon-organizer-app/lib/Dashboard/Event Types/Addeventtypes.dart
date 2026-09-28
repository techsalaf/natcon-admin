// ignore_for_file: prefer_const_constructors, sort_child_properties_last, file_names, must_be_immutable, prefer_interpolation_to_compose_strings, avoid_print

import 'package:magicmate_organizer/Getx_controller.dart/Addeventtypeprice_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Listofevent_controller.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/dark_light_mode.dart';

class Addeventtypes extends StatefulWidget {
  String? edit;
  String? recordid;
  String? eventname;
  String? evevtid;
  Addeventtypes({this.edit, this.recordid, this.evevtid, this.eventname, super.key});

  @override
  State<Addeventtypes> createState() => _AddeventtypesState();
}

List<String> propartyStatus = ["Publish", "UnPublish"];

class _AddeventtypesState extends State<Addeventtypes> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ListofeventController listofeventController = Get.find();
  AddeventtypepriceController addeventtypepriceController = Get.find();
  String slectStatus = propartyStatus.first;
  String? selectevent;
  @override
  void initState() {
    getDarkMode();
    listofeventController.listofevent();
    if (widget.edit == "edit") {
      setState(() {
        addeventtypepriceController.etype.text =
            addeventtypepriceController.eventtype;
        addeventtypepriceController.price.text =
            addeventtypepriceController.eventprice;
        addeventtypepriceController.tlimit.text =
            addeventtypepriceController.eventtlimit;
        addeventtypepriceController.description.text =
            addeventtypepriceController.eventdescription;
        selectevent = widget.eventname;
        print("-------*******------" + selectevent.toString());
        print("-------*******------" + widget.eventname.toString());
        addeventtypepriceController.pType = widget.evevtid!;
      });
    } else {
      setState(() {
        addeventtypepriceController.etype.text = "";
        addeventtypepriceController.price.text = "";
        addeventtypepriceController.tlimit.text = "";
        addeventtypepriceController.description.text = "";
      });
    }
    super.initState();
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
      appBar: appbar(title: "Add Event Type & Price".tr),
      backgroundColor: notifier.containerColor,
      bottomNavigationBar: Container(
        color: notifier.background,
        child: Padding(
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
                  if (widget.edit == "Add") {
                    addeventtypepriceController.eventaddtypeprice(
                        eventid: addeventtypepriceController.pType);
                  } else {
                    addeventtypepriceController.eventedittypeprice(
                        recordid: widget.recordid);
                  }
                }
              }),
        ),
      ),
      body: GetBuilder<AddeventtypepriceController>(
        builder: (addeventtypepriceController) {
          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Container(
                          height: 60,
                          width: Get.size.width,
                          alignment: Alignment.center,
                          // margin: EdgeInsets.symmetric(horizontal: 10),
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: DropdownButton(
                            dropdownColor: notifier.background,
                            hint: Text(
                              "Select Event",
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
                              addeventtypepriceController.pType = listofeventController
                                  .listofeventinfo[listofeventController.selectevent
                                      .indexOf(value ?? "")]
                                  .eventId;
                              print("+++++++++++++++++++++" +
                                  addeventtypepriceController.pType);

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
                        SizedBox(height: Get.height * 0.01),
                        textfield(
                          type: "Event Type".tr,
                          controller: addeventtypepriceController.etype,
                          labelText: "Enter Event Type".tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Event Type'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Get.height * 0.01),
                        textfield(
                          type: "Event Ticket Price".tr,
                          controller: addeventtypepriceController.price,
                          labelText: "Enter Event Ticket Price".tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Event Ticket Price'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Get.height * 0.01),
                        textfield(
                          type: "Event Ticket Limit".tr,
                          controller: addeventtypepriceController.tlimit,
                          labelText: "Enter Event Ticket Limit".tr,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Event Ticket Limit'.tr;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Get.height * 0.02),
                        Text(
                          "Event Type Description".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16,
                            color: notifier.textColor,
                          ),
                        ),
                        SizedBox(height: Get.height * 0.012),
                        Container(
                          child: TextFormField(
                            controller: addeventtypepriceController.description,
                            minLines: 5,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            cursorColor: notifier.textColor,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
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
                                return 'Please Enter Medicine Disclaimer'.tr;
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
                          "Ticket Status".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 16,
                            color: notifier.textColor,
                          ),
                        ),
                        SizedBox(height: Get.height * 0.01),
                        Container(
                          height: 60,
                          width: Get.size.width,
                          alignment: Alignment.center,
                          // margin: EdgeInsets.symmetric(horizontal: 10),
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
                                addeventtypepriceController.status = "1";
                              } else if (value == "UnPublish") {
                                addeventtypepriceController.status = "0";
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
                        SizedBox(height: Get.height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
              addeventtypepriceController.isLoading ? Center(child: CircularProgressIndicator()) : SizedBox()
            ],
          );
        }
      ),
    );
  }
}

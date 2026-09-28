// ignore_for_file: sort_child_properties_last, prefer_const_constructors, file_names

import 'package:magicmate_organizer/Getx_controller.dart/Addeventtypeprice_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Eventtypeprice_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Listofevent_controller.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/dark_light_mode.dart';
import 'Addeventtypes.dart';

class Eventtypescreen extends StatefulWidget {
  const Eventtypescreen({super.key});

  @override
  State<Eventtypescreen> createState() => _EventtypescreenState();
}

class _EventtypescreenState extends State<Eventtypescreen> {
  EventtypepriceController eventtypepriceController = Get.find();
  AddeventtypepriceController addeventtypepriceController = Get.find();
  ListofeventController listofeventController = Get.find();

  @override
  void initState() {
    getDarkMode();
    super.initState();
    eventtypepriceController.eventtypeprice();
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
      appBar: CustomAppbar(
        title: "Event Type & Price".tr,
        context: context,
        onTap: () {
          Get.to(() => Addeventtypes(
                edit: "Add",
              ));
        },
      ),
      backgroundColor: notifier.containerColor,
      body: RefreshIndicator(
        color: notifier.textColor,
        backgroundColor: notifier.containerColor,
        onRefresh: () {
          return Future.delayed(
            Duration(seconds: 2),
            () {
              setState(() {
                eventtypepriceController.eventtypeprice();
              });
            },
          );
        },
        child: GetBuilder<EventtypepriceController>(builder: (eventtypepriceController) {
          return !eventtypepriceController.isLoading
          ? Center(child: CircularProgressIndicator(),)
              : eventtypepriceController.eventtypepriceinfo == null ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/emptyOrder.png")),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "No Event Type placed!",
                  style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: notifier.textColor,
                      fontSize: 15),
                ),
                SizedBox(height: 5),
                Text(
                  "Currently you don’t have any Event Type.",
                  style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      color: greycolor),
                ),
              ],
            ),
          ) :  eventtypepriceController.eventtypepriceinfo!.typePricedata.isNotEmpty
              ? SingleChildScrollView(
            physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      SizedBox(height: Get.height * 0.02),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: eventtypepriceController
                              .eventtypepriceinfo?.typePricedata.length,
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  // height: 70,
                                  width: Get.size.width,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                  margin: EdgeInsets.all(10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        padding: EdgeInsets.all(13),
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                            "assets/documentlist.png"),
                                        decoration: BoxDecoration(
                                            gradient: gradient.btnGradient,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: Get.width * 0.6,
                                              child: Text(
                                                eventtypepriceController
                                                        .eventtypepriceinfo
                                                        ?.typePricedata[index]
                                                        .eventTitle ??
                                                    "",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                // faqsController
                                                //         .faqinfo?.faQdata[index].question ??
                                                //     "",
                                                style: TextStyle(
                                                  color: notifier.textColor,
                                                  fontFamily:
                                                      FontFamily.gilroyBold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: Get.height * 0.005),
                                            Row(
                                              children: [
                                                Text(
                                                  "Type:",
                                                  // faqsController
                                                  //         .faqinfo?.faQdata[index].answer ??
                                                  //     "",
                                                  style: TextStyle(
                                                      color: notifier.textColor,
                                                      fontFamily:
                                                          FontFamily.gilroyBold,
                                                      fontSize: 15),
                                                ),
                                                SizedBox(
                                                    width: Get.width * 0.02),
                                                Text(
                                                  eventtypepriceController
                                                          .eventtypepriceinfo
                                                          ?.typePricedata[index]
                                                          .type ??
                                                      "",
                                                  style: TextStyle(
                                                      color: notifier.textColor,
                                                      fontFamily: FontFamily
                                                          .gilroyMedium,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: Get.height * 0.007),
                                            Row(
                                              // mainAxisAlignment:
                                              //     MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        "Price:",
                                                        // faqsController
                                                        //         .faqinfo?.faQdata[index].answer ??
                                                        //     "",
                                                        style: TextStyle(
                                                            color: notifier.textColor,
                                                            fontFamily:
                                                                FontFamily
                                                                    .gilroyBold,
                                                            fontSize: 15),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              Get.width * 0.02),
                                                      Text(
                                                        eventtypepriceController
                                                                .eventtypepriceinfo
                                                                ?.typePricedata[
                                                                    index]
                                                                .price ??
                                                            "",
                                                        style: TextStyle(
                                                            color: notifier.textColor,
                                                            fontFamily: FontFamily
                                                                .gilroyMedium,
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // SizedBox(width: Get.width * 0.25),
                                                SizedBox(
                                                  width: 70,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      eventtypepriceController
                                                                  .eventtypepriceinfo
                                                                  ?.typePricedata[
                                                                      index]
                                                                  .status ==
                                                              "1"
                                                          ? Text(
                                                              "Publish",
                                                              // faqsController
                                                              //         .faqinfo?.faQdata[index].answer ??
                                                              //     "",
                                                              style: TextStyle(
                                                                  color:
                                                                      appcolor,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .gilroyMedium,
                                                                  fontSize: 15),
                                                            )
                                                          : Text(
                                                              "UnPublish",
                                                              // faqsController
                                                              //         .faqinfo?.faQdata[index].answer ??
                                                              //     "",
                                                              style: TextStyle(
                                                                  color:
                                                                      appcolor,
                                                                  fontFamily:
                                                                      FontFamily
                                                                          .gilroyMedium,
                                                                  fontSize: 15),
                                                            ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: notifier.border),
                                      borderRadius: BorderRadius.circular(15),
                                      color: notifier.background),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      addeventtypepriceController
                                          .getEditDetails(
                                        edescription: eventtypepriceController
                                            .eventtypepriceinfo
                                            ?.typePricedata[index]
                                            .description,
                                        eprice: eventtypepriceController
                                            .eventtypepriceinfo
                                            ?.typePricedata[index]
                                            .price,
                                        estatus: eventtypepriceController
                                            .eventtypepriceinfo
                                            ?.typePricedata[index]
                                            .status,
                                        etlimit: eventtypepriceController
                                            .eventtypepriceinfo
                                            ?.typePricedata[index]
                                            .tlimit,
                                        etype: eventtypepriceController
                                            .eventtypepriceinfo
                                            ?.typePricedata[index]
                                            .type,
                                        eventid: eventtypepriceController
                                            .eventtypepriceinfo
                                            ?.typePricedata[index]
                                            .id,
                                      );
                                      Get.to(
                                        () => Addeventtypes(
                                          edit: "edit",
                                          recordid: eventtypepriceController
                                              .eventtypepriceinfo
                                              ?.typePricedata[index]
                                              .id,
                                          eventname: eventtypepriceController
                                              .eventtypepriceinfo
                                              ?.typePricedata[index]
                                              .eventTitle,
                                          evevtid: eventtypepriceController
                                              .eventtypepriceinfo
                                              ?.typePricedata[index]
                                              .eventId,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      padding: EdgeInsets.all(9),
                                      alignment: Alignment.center,
                                      child: Image.asset("assets/Pen.png"),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: gradient.btnGradient,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/emptyOrder.png")),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "No Event Type placed!",
                  style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: notifier.textColor,
                      fontSize: 15),
                ),
                SizedBox(height: 5),
                Text(
                  "Currently you don’t have any Event Type.",
                  style: TextStyle(
                      fontFamily: FontFamily.gilroyMedium,
                      color: greycolor),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

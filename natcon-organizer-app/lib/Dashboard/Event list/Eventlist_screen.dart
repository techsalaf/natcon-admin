// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, file_names, avoid_print, unused_import, unused_local_variable, prefer_interpolation_to_compose_strings

import 'package:magicmate_organizer/Dashboard/Event%20list/Add_eventlist_screen.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Addeventlist_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Category_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Dashboard_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Listofevent_controller.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/dark_light_mode.dart';

class Eventlistscreen extends StatefulWidget {
  const Eventlistscreen({super.key});

  @override
  State<Eventlistscreen> createState() => _EventlistscreenState();
}

class _EventlistscreenState extends State<Eventlistscreen> {
  ListofeventController listofeventController = Get.find();
  AddlistofeventController addlistofeventController = Get.find();
  CategoryController categoryController = Get.find();
  DashboardController dashboardController = Get.find();
  @override
  void initState() {
    getDarkMode();
    super.initState();
    dashboardController.getFacilityList();
    dashboardController.getRestrictionList();
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
      backgroundColor: notifier.containerColor,
      appBar: CustomAppbar(
        context: context,
        title: "List of Events".tr,
        onTap: () {
          categoryController.categorylist();
          addlistofeventController.restirectedindex = [];
          addlistofeventController.selectedIndexes = [];
          // addlistofeventController.coverimagebase64Image = "";
          addlistofeventController.eventdate.text = "";
          addlistofeventController.youtube = [];
          addlistofeventController.urltag = [];
          Get.to((() => Addeventlistscreen(add: "Add",)));
        },
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: GetBuilder<ListofeventController>(builder: (context) {
            return listofeventController.isLoading
            ? listofeventController.listofeventinfo.isNotEmpty
                ? SingleChildScrollView(
              physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                          itemCount: listofeventController.listofeventinfo.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                // print(
                                //     "!!!!!!!!!!!!!!recordid!!!!!!!!!!!!!!!!!${mymedicine.medicinedata?.medicinedata[index].id ?? ""}");
                                // Get.to(() => AddMedicine(
                                //       recordid: mymedicine.medicinedata
                                //               ?.medicinedata[index].id ??
                                //           "",
                                //       add: "",
                                //     ));
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    // height: 125,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    width: Get.size.width,
                                    margin: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 100,
                                              width: 100,
                                              // margin: EdgeInsets.all(10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: listofeventController.listofeventinfo[index].eventImage.isEmpty
                                                    ? const ColoredBox(color: Color(0xFFEAF0F6), child: Center(child: Icon(Icons.event, color: Color(0xFF52677D))))
                                                    : Image.network(
                                                        "${AppUrl.imageurl}${listofeventController.listofeventinfo[index].eventImage}",
                                                        height: 140,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFEAF0F6), child: Center(child: Icon(Icons.event, color: Color(0xFF52677D)))),
                                                      ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 6),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            listofeventController
                                                                .listofeventinfo[
                                                                    index]
                                                                .eventCatName,
                                                            // mymedicine
                                                            //         .medicinedata
                                                            //         ?.medicinedata[index]
                                                            //         .title ??
                                                            //     "",
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontFamily: FontFamily
                                                                  .gilroyMedium,
                                                              color: greycolor.withOpacity(
                                                                  0.7),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          listofeventController
                                                                      .listofeventinfo[
                                                                          index]
                                                                      .eventStatus ==
                                                                  "1"
                                                              ? Text(
                                                                  "Publish",
                                                                  // mymedicine
                                                                  //         .medicinedata
                                                                  //         ?.medicinedata[index]
                                                                  //         .title ??
                                                                  //     "",
                                                                  maxLines: 2,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        FontFamily
                                                                            .gilroyMedium,
                                                                    color:
                                                                        appcolor,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  "UnPublish",
                                                                  // mymedicine
                                                                  //         .medicinedata
                                                                  //         ?.medicinedata[index]
                                                                  //         .title ??
                                                                  //     "",
                                                                  maxLines: 2,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        FontFamily
                                                                            .gilroyMedium,
                                                                    color:
                                                                        appcolor,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height: Get.height * 0.007),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      listofeventController.listofeventinfo[index].eventTitle,
                                                      // mymedicine
                                                      //         .medicinedata
                                                      //         ?.medicinedata[index]
                                                      //         .catName ??
                                                      //     "",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          color: notifier.textColor,
                                                          fontFamily: FontFamily
                                                              .gilroyBold,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  // Padding(
                                                  //   padding: EdgeInsets.only(top: 8),
                                                  //   child: Column(
                                                  //     children: [
                                                  //       Text(
                                                  //         "Event Name",
                                                  //         // "${currency}${mymedicine.medicinedata?.medicinedata[index].sprice ?? ""}",
                                                  //         style: TextStyle(
                                                  //           fontSize: 17,
                                                  //           fontFamily:
                                                  //               FontFamily.gilroyBold,
                                                  //           color: blueColor,
                                                  //         ),
                                                  //       ),
                                                  //       // Text(
                                                  //       //   "",
                                                  //       //   // "${currency}${mymedicine.medicinedata?.medicinedata[index].aprice ?? ""}",
                                                  //       //   style: TextStyle(
                                                  //       //     color: greycolor,
                                                  //       //     fontFamily:
                                                  //       //         FontFamily.gilroyMedium,
                                                  //       //   ),
                                                  //       // ),
                                                  //     ],
                                                  //   ),
                                                  // ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              GetBuilder<ListofeventController>(
                                                  builder: (context) {
                                                String starttime =
                                                    "2023-03-20T${listofeventController.listofeventinfo[index].eventStartTime}";
                                                String endtime =
                                                    "2023-03-20T${listofeventController.listofeventinfo[index].eventEndTime}";
                                                return Text(
                                                  "${DateFormat.jm().format(DateTime.parse(starttime))} To ${DateFormat.jm().format(DateTime.parse(endtime))}",
                                                  // "${currency}${mymedicine.medicinedata?.medicinedata[index].sprice ?? ""}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        FontFamily.gilroyMedium,
                                                    color: notifier.textColor,
                                                  ),
                                                );
                                              }),
                                              // CircleAvatar(
                                              //     radius: 4,
                                              //     backgroundColor:
                                              //         greyColor.withOpacity(0.3)),
                                              SizedBox(
                                                  height: Get.height * 0.005),
                                              Text(
                                                "${listofeventController.listofeventinfo[index].eventStartDate}"
                                                    .split(" ")
                                                    .first,
                                                // "${currency}${mymedicine.medicinedata?.medicinedata[index].sprice ?? ""}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  color: greycolor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: notifier.border),
                                      color: notifier.background,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: InkWell(
                                        onTap: () {
                                          print(":::::::::::::::::");
                                          addlistofeventController.getEditDetails(
                                              // facilityEdit: listofeventController.listofeventinfo[index].eventFacilityId,
                                              ename: listofeventController.listofeventinfo[index].eventTitle,
                                              ecoverimage: listofeventController.listofeventinfo[index].eventCoverImg,
                                              edescription: listofeventController.listofeventinfo[index].eventDescription,
                                              edisclaimer: listofeventController.listofeventinfo[index].eventDisclaimer,
                                              edate: listofeventController.listofeventinfo[index].eventStartDate.toString().split(" ").first,
                                              eimage: listofeventController.listofeventinfo[index].eventImage,
                                              eplacename: listofeventController.listofeventinfo[index].eventPlaceName,
                                              elongitude: listofeventController.listofeventinfo[index].eventLongtitude,
                                              eaddress: listofeventController.listofeventinfo[index].eventAddress,
                                              eendtime: listofeventController.listofeventinfo[index].eventEndTime,
                                              elatitude: listofeventController.listofeventinfo[index].eventLatitude,
                                              estarttime: listofeventController.listofeventinfo[index].eventStartTime);
                                          Get.to(() => Addeventlistscreen(
                                                add: "edit",
                                                recordid: listofeventController.listofeventinfo[index].eventId,
                                                categoryname: listofeventController.listofeventinfo[index].eventCatName,
                                                categoryid: listofeventController.listofeventinfo[index].eventCatId,
                                              ));
                                          // List<String> facilityid =
                                          //     listofeventController
                                          //         .listofeventinfo[index]
                                          //         .eventFacilityId
                                          //         .split(",");
                                          // print("--------------->" +
                                          //     facilityid.toString());
                                          addlistofeventController.selectedIndexes = [];
                                          addlistofeventController.selectedIndexes.addAll(listofeventController.listofeventinfo[index].eventFacilityId.split(","));
                                          addlistofeventController.restirectedindex = [];
                                          addlistofeventController.restirectedindex.addAll(listofeventController.listofeventinfo[index].eventRestictId!.split(","));
                                          addlistofeventController.urltag = [];

                                          addlistofeventController.urltag = listofeventController.listofeventinfo[index].eventTags.split(",");
                                          addlistofeventController.youtube = [];
                                          addlistofeventController.youtube = listofeventController.listofeventinfo[index].eventVurls != "null"
                                              ? listofeventController.listofeventinfo[index].eventVurls.split(",")
                                              : [];
                                          print(">>>>>>>>>>>>>>>>>>>>>>>>>" +
                                              listofeventController.listofeventinfo[index].eventVurls.split(",").toString());
                                          setState(() {});
                                          categoryController.categorylist();
                                          print(":::::::::::111111::::::");
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
                                        )),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      SizedBox(height: Get.height * 0.03),
                    ],
                  ),
                )
                :  Center(
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
                    "No Event placed!",
                    style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        color: notifier.textColor,
                        fontSize: 15),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Currently you don’t have any Event.",
                    style: TextStyle(
                        fontFamily: FontFamily.gilroyMedium,
                        color: greycolor),
                  ),
                ],
              ),
            )
                : Center(child: CircularProgressIndicator());
          }),
          decoration: BoxDecoration(
            color: notifier.containerColor,
          ),
        ),
      ),
    );
  }
}

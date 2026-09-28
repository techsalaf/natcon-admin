// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, unnecessary_new, unnecessary_null_comparison, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Api/config.dart';
import '../../controller/mybooking_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';
import 'myticket_details.dart';

class MyTicketScreen extends StatefulWidget {
  const MyTicketScreen({super.key});

  @override
  State<MyTicketScreen> createState() => _MyTicketScreenState();
}

class _MyTicketScreenState extends State<MyTicketScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  MyBookingController myBookingController = Get.find();
  final note = TextEditingController();
  var selectedRadioTile;
  String? rejectmsg = '';

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _tabController?.index == 0;
    if (_tabController?.index == 0) {
      myBookingController.myOrderHistory(statusWise: "Active");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        centerTitle: true,
        leading: SizedBox(),
        elevation: 0,
        title: Text(
          "My Ticket".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            color: BlackColor,
            fontSize: 16,
          ),
        ),
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: Column(
          children: [
            Container(
              color: WhiteColor,
              height: 50,
              child: TabBar(
                indicatorColor: gradient.defoultColor,
                controller: _tabController,
                unselectedLabelColor: greyColor,
                // indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 16,
                  color: gradient.defoultColor,
                ),
                indicator: MD2Indicator(
                  indicatorSize: MD2IndicatorSize.full,
                  indicatorHeight: 3,
                  indicatorColor: gradient.defoultColor,
                ),
                labelColor: gradient.defoultColor,
                onTap: (value) {
                  if (value == 0) {
                    myBookingController.myOrderHistory(statusWise: "Active");
                  } else {
                    myBookingController.myOrderHistory(statusWise: "Past");
                  }
                },
                tabs: [
                  Tab(
                    text: "Active".tr,
                  ),
                  Tab(
                    text: "Completed".tr,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  activeWidget(),
                  completeWidget(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ticketCancell(orderId) {
    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        backgroundColor: WhiteColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: Get.height * 0.02),
                    Container(
                        height: 6,
                        width: 80,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(25))),
                    SizedBox(height: Get.height * 0.02),
                    Text(
                      "Select Reason".tr,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Gilroy Bold',
                          color: BlackColor),
                    ),
                    SizedBox(height: Get.height * 0.02),
                    Text(
                      "Please select the reason for cancellation:".tr,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Gilroy Medium',
                          color: BlackColor),
                    ),
                    SizedBox(height: Get.height * 0.02),
                    ListView.builder(
                      itemCount: cancelList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (ctx, i) {
                        return RadioListTile(
                          dense: true,
                          value: i,
                          activeColor: gradient.defoultColor,
                          tileColor: BlackColor,
                          selected: true,
                          groupValue: selectedRadioTile,
                          title: Text(
                            cancelList[i]["title"],
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Gilroy Medium',
                                color: BlackColor),
                          ),
                          onChanged: (val) {
                            setState(() {});
                            selectedRadioTile = val;
                            rejectmsg = cancelList[i]["title"];
                          },
                        );
                      },
                    ),
                    rejectmsg == "Others".tr
                        ? SizedBox(
                            height: 50,
                            width: Get.width * 0.85,
                            child: TextField(
                              controller: note,
                              decoration: InputDecoration(
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: gradient.defoultColor, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    borderSide: BorderSide(
                                        color: gradient.defoultColor, width: 1),
                                  ),
                                  hintText: 'Enter reason'.tr,
                                  hintStyle: TextStyle(
                                      fontFamily: 'Gilroy Medium',
                                      fontSize: Get.size.height / 55,
                                      color: Colors.grey)),
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(height: Get.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: Get.width * 0.35,
                          height: Get.height * 0.05,
                          child: ticketbutton(
                            title: "Cancel".tr,
                            bgColor: RedColor,
                            titleColor: Colors.white,
                            ontap: () {
                              Get.back();
                            },
                          ),
                        ),
                        SizedBox(
                          width: Get.width * 0.35,
                          height: Get.height * 0.05,
                          child: ticketbutton(
                            title: "Confirm".tr,
                            bgColor: gradient.defoultColor,
                            titleColor: Colors.white,
                            ontap: () {
                              myBookingController.cancleOrder(
                                orderId1: orderId,
                                reason: rejectmsg == "Others".tr
                                    ? note.text
                                    : rejectmsg,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Get.height * 0.04),
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget activeWidget() {
    return GetBuilder<MyBookingController>(builder: (context) {
      return SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: myBookingController.isLoading
            ? myBookingController.orderInfo!.orderData.isNotEmpty
                ? ListView.builder(
                    itemCount: myBookingController.orderInfo?.orderData.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          myBookingController.ticketInformetionApi(
                            ticketId: myBookingController
                                .orderInfo?.orderData[index].ticketId,
                          );
                          Get.to(MyTicketDetailsScreen());
                        },
                        child: Container(
                          width: Get.size.width,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 90,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 90,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              "assets/ezgif.com-crop.gif",
                                          image:
                                              "${Config.imageUrl}${myBookingController.orderInfo?.orderData[index].eventImg}",
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            myBookingController
                                                    .orderInfo
                                                    ?.orderData[index]
                                                    .ticketType ??
                                                "",
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              fontSize: 13,
                                              color: greytext,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            myBookingController
                                                    .orderInfo
                                                    ?.orderData[index]
                                                    .eventTitle ??
                                                "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              fontSize: 16,
                                              color: BlackColor,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    // Container(
                                    //   height: 90,
                                    //   width: 70,
                                    //   alignment: Alignment.center,
                                    //   child: Container(
                                    //     height: 25,
                                    //     width: 60,
                                    //     alignment: Alignment.center,
                                    //     child: Text(
                                    //       "\$483",
                                    //       style: TextStyle(
                                    //         color: gradient.defoultColor,
                                    //         fontFamily: FontFamily.gilroyMedium,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Divider(
                                color: greyColor,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Location".tr,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: greytext,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          myBookingController
                                                  .orderInfo
                                                  ?.orderData[index]
                                                  .eventPlaceName ??
                                              "",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: BlackColor,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Date".tr,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: greytext,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          myBookingController
                                                  .orderInfo
                                                  ?.orderData[index]
                                                  .eventSdate ??
                                              "",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: BlackColor,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Seats".tr,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: greytext,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          myBookingController
                                                  .orderInfo
                                                  ?.orderData[index]
                                                  .totalTicket ??
                                              "",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: BlackColor,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  myBookingController.orderInfo!
                                              .orderData[index].bookMintues <=
                                          10.0
                                      ? Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              ticketCancell(myBookingController
                                                      .orderInfo
                                                      ?.orderData[index]
                                                      .ticketId ??
                                                  "");
                                            },
                                            child: Container(
                                              height: 35,
                                              alignment: Alignment.center,
                                              margin: EdgeInsets.only(right: 8),
                                              child: Text(
                                                "Cancle Booking".tr,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FontFamily.gilroyMedium,
                                                  fontSize: 14,
                                                  color: gradient.defoultColor,
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                border: Border.all(
                                                    color:
                                                        gradient.defoultColor),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        myBookingController
                                            .ticketInformetionApi(
                                          ticketId: myBookingController
                                              .orderInfo
                                              ?.orderData[index]
                                              .ticketId,
                                        );
                                        Get.to(MyTicketDetailsScreen());
                                      },
                                      child: Container(
                                        height: 35,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(left: 8),
                                        child: Text(
                                          "View E-Ticket".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            fontSize: 14,
                                            color: WhiteColor,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            gradient: gradient.btnGradient),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: WhiteColor,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Go & Book your favorite Event".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 15,
                      ),
                    ),
                  )
            : Center(
                child: CircularProgressIndicator(
                  color: gradient.defoultColor,
                ),
              ),
      );
    });
  }

  Widget completeWidget() {
    return SizedBox(
      height: Get.size.height,
      width: Get.size.width,
      child: GetBuilder<MyBookingController>(builder: (context) {
        return myBookingController.isLoading
            ? myBookingController.orderInfo!.orderData.isNotEmpty
                ? ListView.builder(
                    itemCount: myBookingController.orderInfo?.orderData.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          myBookingController.ticketInformetionApi(
                            ticketId: myBookingController
                                .orderInfo?.orderData[index].ticketId,
                          );
                          Get.to(MyTicketDetailsScreen());
                        },
                        child: Container(
                          width: Get.size.width,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 90,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 90,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              "assets/ezgif.com-crop.gif",
                                          image:
                                              "${Config.imageUrl}${myBookingController.orderInfo?.orderData[index].eventImg}",
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            myBookingController
                                                    .orderInfo
                                                    ?.orderData[index]
                                                    .ticketType ??
                                                "",
                                            style: TextStyle(
                                              fontFamily:
                                                  FontFamily.gilroyMedium,
                                              fontSize: 13,
                                              color: greytext,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            myBookingController
                                                    .orderInfo
                                                    ?.orderData[index]
                                                    .eventTitle ??
                                                "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontFamily: FontFamily.gilroyBold,
                                              fontSize: 16,
                                              color: BlackColor,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Divider(
                                color: greyColor,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Location".tr,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: greytext,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          myBookingController
                                                  .orderInfo
                                                  ?.orderData[index]
                                                  .eventPlaceName ??
                                              "",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: BlackColor,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Date".tr,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: greytext,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          myBookingController
                                                  .orderInfo
                                                  ?.orderData[index]
                                                  .eventSdate ??
                                              "",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: BlackColor,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Seats".tr,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: greytext,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          myBookingController
                                                  .orderInfo
                                                  ?.orderData[index]
                                                  .totalTicket ??
                                              "",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            color: BlackColor,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        myBookingController
                                            .ticketInformetionApi(
                                          ticketId: myBookingController
                                              .orderInfo
                                              ?.orderData[index]
                                              .ticketId,
                                        );
                                        Get.to(MyTicketDetailsScreen());
                                      },
                                      child: Container(
                                        height: 35,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(left: 8),
                                        child: Text(
                                          "View E-Ticket".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyMedium,
                                            fontSize: 14,
                                            color: WhiteColor,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            gradient: gradient.btnGradient),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: WhiteColor,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Go & Book your favorite Event".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        fontSize: 15,
                      ),
                    ),
                  )
            : Center(
                child: CircularProgressIndicator(
                  color: gradient.defoultColor,
                ),
              );
      }),
    );
  }

  List cancelList = [
    {"id": 1, "title": "Financing fell through".tr},
    {"id": 2, "title": "Inspection issues".tr},
    {"id": 3, "title": "Change in financial situation".tr},
    {"id": 4, "title": "Title issues".tr},
    {"id": 5, "title": "Seller changes their mind".tr},
    {"id": 6, "title": "Competing offer".tr},
    {"id": 7, "title": "Personal reasons".tr},
    {"id": 8, "title": "Others".tr},
  ];

  ticketbutton(
      {Function()? ontap,
      String? title,
      Color? bgColor,
      titleColor,
      Gradient? gradient1}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: Get.height * 0.04,
        width: Get.width * 0.40,
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient1,
          borderRadius: (BorderRadius.circular(18)),
        ),
        child: Center(
          child: Text(title!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: titleColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  fontFamily: 'Gilroy Medium')),
        ),
      ),
    );
  }
}

class MD2Indicator extends Decoration {
  final double indicatorHeight;
  final Color indicatorColor;
  final MD2IndicatorSize indicatorSize;

  const MD2Indicator({
    required this.indicatorHeight,
    required this.indicatorColor,
    required this.indicatorSize,
  });

  @override
  _MD2Painter createBoxPainter([VoidCallback? onChanged]) {
    return new _MD2Painter(this, onChanged!);
  }
}

enum MD2IndicatorSize {
  tiny,
  normal,
  full,
}

class _MD2Painter extends BoxPainter {
  final MD2Indicator decoration;

  _MD2Painter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);

    Rect? rect;
    if (decoration.indicatorSize == MD2IndicatorSize.full) {
      rect = Offset(offset.dx,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(configuration.size!.width, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MD2IndicatorSize.normal) {
      rect = Offset(offset.dx + 6,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(configuration.size!.width - 12, decoration.indicatorHeight);
    } else if (decoration.indicatorSize == MD2IndicatorSize.tiny) {
      rect = Offset(offset.dx + configuration.size!.width / 2 - 8,
              (configuration.size!.height - decoration.indicatorHeight)) &
          Size(16, decoration.indicatorHeight);
    }

    final Paint paint = Paint();
    paint.color = decoration.indicatorColor;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect!,
            topRight: Radius.circular(8), topLeft: Radius.circular(8)),
        paint);
  }
}

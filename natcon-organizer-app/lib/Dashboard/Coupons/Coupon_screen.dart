// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, file_names, avoid_print

import 'package:magicmate_organizer/Dashboard/Coupons/Addcoupon_screen.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Add_coupon_controller.dart';
import 'package:magicmate_organizer/Getx_controller.dart/Coupon_controller.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Couponscreen extends StatefulWidget {
  const Couponscreen({super.key});

  @override
  State<Couponscreen> createState() => _CouponscreenState();
}

class _CouponscreenState extends State<Couponscreen> {
  CouponController couponlistController = Get.find();
  AddCouponlistController addCouponlistController = Get.find();
  @override
  void initState() {
    super.initState();
    couponlistController.couponlist();
  }

  String expiredate = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifier.containerColor,
      appBar: CustomAppbar(
        context: context,
          onTap: () {
            Get.to((() => AddCouponscreen(
                  add: "Add",
                )));
          },
          title: "My Coupon".tr),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: GetBuilder<CouponController>(builder: (context) {
                  return couponlistController.isLoading
                  ? couponlistController.couponinfo!.coupondata.isNotEmpty
                      ? ListView.builder(
                          itemCount: couponlistController
                              .couponinfo?.coupondata.length,
                          physics: BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                print(
                                    "!!!!!!!!!!!!!!recordid!!!!!!!!!!!!!!!!!${couponlistController.couponinfo?.coupondata[index].id ?? ""}");
                                Get.to(() => AddCouponscreen(
                                      recordid: couponlistController.couponinfo
                                              ?.coupondata[index].id ??
                                          "",
                                      add: "Add",
                                    ));
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    height: 125,
                                    width: Get.size.width,
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 80,
                                              width: 80,
                                              padding: EdgeInsets.all(5),
                                              // decoration: BoxDecoration(
                                              //   shape: BoxShape.circle,
                                              //   color: bgcolor,
                                              // ),
                                              child: Image.network(
                                                  "${AppUrl.imageurl}${couponlistController.couponinfo?.coupondata[index].couponImg ?? ""}"),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: Get.width * 0.02),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 28),
                                                      child: Text(
                                                        couponlistController
                                                                .couponinfo
                                                                ?.coupondata[
                                                                    index]
                                                                .title ??
                                                            "",
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: FontFamily
                                                              .gilroyBold,
                                                          color: notifier.textColor,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              GetBuilder<CouponController>(
                                                  builder: (context) {
                                                expiredate =
                                                    "${couponlistController.couponinfo?.coupondata[index].expireDate}"
                                                        .split(" ")
                                                        .first
                                                        .toString();

                                                return Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Exp: $expiredate",
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          color: greycolor,
                                                          fontFamily: FontFamily
                                                              .gilroyMedium,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 8),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "${currency}${couponlistController.couponinfo?.coupondata[index].couponVal ?? ""}",
                                                            style: TextStyle(
                                                              fontSize: 17,
                                                              fontFamily:
                                                                  FontFamily
                                                                      .gilroyBold,
                                                              color: blueColor,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                );
                                              }),
                                              SizedBox(
                                                height: 5,
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
                                          print(
                                              "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${couponlistController.couponinfo?.coupondata[index].id ?? ""}");
                                          Get.to(() => AddCouponscreen(
                                                add: "edit",
                                                recordid: couponlistController
                                                        .couponinfo
                                                        ?.coupondata[index]
                                                        .id ??
                                                    "",
                                              ));
                                          addCouponlistController.getEditDetails(
                                              Editcouponimage: couponlistController
                                                  .couponinfo
                                                  ?.coupondata[index]
                                                  .couponImg,
                                              Editcoupontitle: couponlistController
                                                  .couponinfo
                                                  ?.coupondata[index]
                                                  .title,
                                              Editcouponcode: couponlistController
                                                  .couponinfo
                                                  ?.coupondata[index]
                                                  .couponCode,
                                              Editcouponsubtitle: couponlistController
                                                  .couponinfo
                                                  ?.coupondata[index]
                                                  .subtitle,
                                              Editexpiredate1: couponlistController
                                                  .couponinfo
                                                  ?.coupondata[index]
                                                  .expireDate
                                                  .toString(),
                                              Editcouponminorder:
                                                  couponlistController
                                                      .couponinfo
                                                      ?.coupondata[index]
                                                      .minAmt,
                                              editcouponvalue: couponlistController
                                                  .couponinfo
                                                  ?.coupondata[index]
                                                  .couponVal,
                                              EditCoupondiscription:
                                                  couponlistController
                                                      .couponinfo
                                                      ?.coupondata[index]
                                                      .description,
                                              estatus: couponlistController.couponinfo?.coupondata[index].status);
                                        },
                                        child: Container(
                                          height: 35,
                                          width: 35,
                                          padding: EdgeInsets.all(9),
                                          alignment: Alignment.center,
                                          child: Image.asset("assets/Pen.png"),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: appcolor,
                                          ),
                                        )),
                                  )
                                  // : SizedBox(),
                                ],
                              ),
                            );
                          },
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
                          "No Coupon placed!",
                          style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              color: notifier.textColor,
                              fontSize: 15),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Currently you don’t have any Coupon.",
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
            )
          ],
        ),
      ),
    );
  }
}

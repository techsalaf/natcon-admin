// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Api/config.dart';
import '../controller/home_controller.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
import 'bottombar_screen.dart';

class ChooseFevoriteEvent extends StatefulWidget {
  const ChooseFevoriteEvent({super.key});

  @override
  State<ChooseFevoriteEvent> createState() => _ChooseFevoriteEventState();
}

class _ChooseFevoriteEventState extends State<ChooseFevoriteEvent> {
  HomePageController homePageController = Get.find();
  List<int> selectedIndexes = [];

  int? currentIndex;
  @override
  void initState() {
    super.initState();
    homePageController.getHomeDataApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      bottomNavigationBar: GestButton(
        height: 50,
        Width: Get.size.width,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        buttoncolor: gradient.defoultColor,
        buttontext: "Finish".tr,
        style: TextStyle(
          color: WhiteColor,
          fontFamily: FontFamily.gilroyBold,
          fontSize: 15,
        ),
        onclick: () {
          Get.to(BottomBarScreen());
        },
      ),
      body: GetBuilder<HomePageController>(builder: (context) {
        return homePageController.isLoading
            ? SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Choose your Favorite event".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 20,
                              color: BlackColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Get Persanalized event recomendation".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 15,
                              color: greytext,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children: List<Widget>.generate(
                              homePageController.homeInfo!.homeData.catlist
                                  .length, (int index) {
                            return InkWell(
                              onTap: () {
                                if (selectedIndexes.contains(index)) {
                                  selectedIndexes.remove(index); // unselect
                                  setState(() {});
                                } else {
                                  selectedIndexes.add(index);
                                  setState(() {}); // select
                                }
                              },
                              child: Chip(
                                backgroundColor: selectedIndexes.contains(index)
                                    ? gradient.defoultColor
                                    : WhiteColor,
                                label: Text(
                                  homePageController
                                      .homeInfo!.homeData.catlist[index].title,
                                  style: TextStyle(
                                    fontFamily: FontFamily.gilroyBold,
                                    color: selectedIndexes.contains(index) ? WhiteColor : BlackColor,
                                  ),
                                ),
                                avatar: Image.network(
                                  "${Config.imageUrl}${homePageController.homeInfo!.homeData.catlist[index].catImg}",
                                  color: selectedIndexes.contains(index) ? WhiteColor : BlackColor,
                                  height: 18,
                                  width: 18,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
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
}

// ignore_for_file: unused_field, avoid_print, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../controller/faq_controller.dart';
import '../../model/fontfamily_model.dart';
import '../../utils/Colors.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});
  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> with TickerProviderStateMixin {
  FaqController faqController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  final _contentStyle = const TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: BlackColor,
          ),
        ),
        title: Text(
          "Helps & FAQs".tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Gilroy Medium',
            color: BlackColor,
          ),
        ),
      ),
      body: GetBuilder<FaqController>(builder: (context) {
        return faqController.isLoading
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    Accordion(
                      disableScrolling: true,
                      flipRightIconIfOpen: true,
                      contentVerticalPadding: 0,
                      scrollIntoViewOfItems: ScrollIntoViewOfItems.fast,
                      contentBorderColor: Colors.transparent,
                      maxOpenSections: 1,
                      headerBackgroundColorOpened: WhiteColor,
                      headerPadding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 15),
                      children: [
                        for (var j = 0;
                            j < faqController.faqListInfo!.faqData.length;
                            j++)
                          AccordionSection(
                            rightIcon: Image.asset(
                              "assets/Arrow - Down.png",
                              height: 20,
                              width: 20,
                              color: blueColor,
                            ),
                            headerPadding: const EdgeInsets.all(15),
                            // flipRightIconIfOpen: true,
                            headerBackgroundColor: WhiteColor,
                            contentBackgroundColor: WhiteColor,
                            header: Text(
                                faqController
                                        .faqListInfo?.faqData[j].question ??
                                    "",
                                style: TextStyle(
                                    color: BlackColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                            content: Text(
                                faqController.faqListInfo?.faqData[j].answer ??
                                    "",
                                style: _contentStyle),
                            contentHorizontalPadding: 20,
                            contentBorderWidth: 1,
                          ),
                      ],
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(height: 250),
                  Center(
                    child: CircularProgressIndicator(
                      color: gradient.defoultColor,
                    ),
                  ),
                ],
              );
      }),
    );
  }
}

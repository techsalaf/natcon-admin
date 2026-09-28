// ignore_for_file: camel_case_types, use_key_in_widget_constructors, annotate_overrides, prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'dart:async';

import 'package:magicmate_organizer/Bottombar_screen.dart';
import 'package:magicmate_organizer/Login_flow/Login_screen.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dark_light_mode.dart';

class onbording extends StatefulWidget {
  const onbording({Key? key}) : super(key: key);

  @override
  State<onbording> createState() => _onbordingState();
}

class _onbordingState extends State<onbording> {
  @override
  void initState() {
    getDarkMode();
    super.initState();
print("+++++++Rember++++++++++++ ${getData.read("Remember")}");
print("++++++++++First+++++++++ ${getData.read("Firstuser")}");

    Timer(
      const Duration(seconds: 3),
          () => getData.read('Firstuser') != true
          ? Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BoardingPage(),
        ),
      )
          : getData.read('Remember') != true
          ? Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      )
          : Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BottoBarScreen(),
        ),
      ),
    );
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
        backgroundColor: notifier.background,
        body: Container(
          decoration: BoxDecoration(
              // image: DecorationImage(
              //     image: AssetImage("assets/Splash.png"), fit: BoxFit.fill),
              color: notifier.background),
          child: Center(
            child: Image.asset("assets/Logo1.png", height: 80, width: 80),
          ),
        ));
  }
}

class BoardingPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _BoardingPageState createState() => _BoardingPageState();
}

class _BoardingPageState extends State<BoardingPage> {
  // creating all the widget before making our home screeen
  // SubscribeController subscribeController = Get.find();
  // ListOfPropertiController listOfPropertiController = Get.find();
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

  void initState() {
    getDarkMode();
    // getdarkmodepreviousstate();
    super.initState();

    _currentPage = 0;

    _slides = [
      Slide("assets/introimg.png", "Creating unforgettable experiences",
          "Organizers can manage events through the app, including adding or managing attendees"),
      Slide("assets/introimg1.png", "We make magic happen",
          "The app can send push notifications to attendees to remind them about upcoming events"),
      Slide("assets/introimg2.png", "Leave the details to us.",
          "The app can include ticketing functionality so that organizers can sell tickets to their events through the app"),
    ];
    _pageController = PageController(initialPage: _currentPage);
    super.initState();
  }

  int _currentPage = 0;
  List<Slide> _slides = [];
  PageController _pageController = PageController();

  // the list which contain the build slides
  List<Widget> _buildSlides() {
    return _slides.map(_buildSlide).toList();
  }

  // late ColorNotifire notifire;

  Widget _buildSlide(Slide slide) {
    // notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      body: Column(
        children: <Widget>[
          SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.09), //upar thi jagiya mukeli che
          // ignore: sized_box_for_whitespace
          Container(
            height: MediaQuery.of(context).size.height * 0.5, //imagee size
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Image.asset(
              slide.image,
              fit: BoxFit.cover,
            ),
            // color: BlackColor,
          ),
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.02,
          // ),
          SizedBox(
            width: Get.width * 0.75,
            child: Text(
              slide.heading,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontFamily: "Gilroy Bold",
                  color: notifier.textColor), //heding Text
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          SizedBox(
            width: Get.width * 0.79,
            child: Text(
              slide.subtext,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: greycolor,
                  fontFamily: "Gilroy Medium"), //subtext
            ),
          ),
        ],
      ),
    );
  }

  // handling the on page changed
  void _handlingOnPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  // building page indicator
  Widget _buildPageIndicator() {
    Row row = Row(mainAxisAlignment: MainAxisAlignment.center, children: []);
    for (int i = 0; i < _slides.length; i++) {
      row.children.add(_buildPageIndicatorItem(i));
      if (i != _slides.length - 1)
        // ignore: curly_braces_in_flow_control_structures
        row.children.add(
          const SizedBox(
            width: 10,
          ),
        );
    }
    return row;
  }

  Widget _buildPageIndicatorItem(int index) {
    return Container(
      width: index == _currentPage ? 25 : 25,
      height: index == _currentPage ? 6 : 6,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: index == _currentPage ? appcolor : greycolor.withOpacity(0.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      backgroundColor: notifier.background,
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            onPageChanged: _handlingOnPageChanged,
            physics: const BouncingScrollPhysics(),
            children: _buildSlides(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.28, //indicator set screen
                ),
                _currentPage == 2
                    ? GestureDetector(
                        onTap: () {
                          Get.to(() => const LoginScreen());
                          // listOfPropertiController.getPropertiList();
                          // subscribeController.getSubscribeDetailsList();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              gradient: gradient.btnGradient,
                              borderRadius: BorderRadius.circular(15)),
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Get Started".tr,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: WhiteColor,
                                  fontFamily: "Gilroy Bold"),
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _pageController.nextPage(
                              duration: const Duration(microseconds: 300),
                              curve: Curves.easeIn);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                              gradient: gradient.btnGradient,
                              borderRadius: BorderRadius.circular(15)),
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              "Next".tr,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: WhiteColor,
                                  fontFamily: "Gilroy Bold"),
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.03, //indicator set screen
                ),
                // GestureDetector(
                //   onTap: () {},
                //   child: Text(
                //     "Skip",
                //     style: TextStyle(
                //       fontSize: 18,
                //       color: Darkblue,
                //       fontFamily: "Gilroy Bold",
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 20)
                _buildPageIndicator(),
              ],
            ),
          )
        ],
      ),
    );
  }

//   getdarkmodepreviousstate() async {
//     final prefs = await SharedPreferences.getInstance();
//     bool? previusstate = prefs.getBool("setIsDark");
//     if (previusstate == null) {
//       notifire.setIsDark = false;
//     } else {
//       notifire.setIsDark = previusstate;
//     }
//   }
}

class Slide {
  String image;
  String heading;
  String subtext;

  Slide(this.image, this.heading, this.subtext);
}

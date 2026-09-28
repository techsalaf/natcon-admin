// ignore_for_file: prefer_const_constructors, sort_child_properties_last, sized_box_for_whitespace, unused_element, prefer_typing_uninitialized_variables, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_user/screen/profile/profile_screen.dart';
import 'package:provider/provider.dart';

import '../Api/data_store.dart';
import '../controller/login_controller.dart';
import '../firebase/chat_page.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import 'LoginAndSignup/login_screen.dart';
import 'favorites/favorites_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'myTicket/myticket_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

int selectedIndex = 0;

class _BottomBarScreenState extends State<BottomBarScreen> with WidgetsBindingObserver {
  List<Widget> myChilders = [
    HomeScreen(),
    FavoritesScreen(),
    MyTicketScreen(),
    ProfileScreen(),
  ];

  int currenIndex = 0;

  var isLogin;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _updateUserStatus(true);
    if (getData.read("currentIndex") == true) {
      save("currentIndex", false);
    } else {
      selectedIndex = 0;
    }
    super.initState();
    isLogin = getData.read("UserLogin");
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _updateUserStatus(true);
        break;
      case AppLifecycleState.inactive:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.paused:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.detached:
        _updateUserStatus(false);
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  void _updateUserStatus(bool isOnline) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateUserStatus(isLogin != null ? getData.read("UserLogin")["id"] : "0", isOnline);
  }

  @override
  Widget build(BuildContext context) {
    currenIndex = 0;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        exit(0);
      },

      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: FloatingActionButton(
        //     backgroundColor: Color(0xff3D5BF6),
        //     onPressed: () {},
        //     child: Container(
        //       alignment: Alignment.center,
        //       margin: EdgeInsets.all(15.0),
        //       child: Icon(
        //         Icons.add,
        //         color: WhiteColor,
        //       ),
        //     ),
        //     elevation: 4.0,
        //   ),
        // ),
        floatingActionButton: GetBuilder<LoginController>(builder: (context) {
          return selectedIndex == 0
              ? Container(
                  height: 40,
                  width: 150,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            currenIndex = 0;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 70,
                          margin: EdgeInsets.only(top: 4, bottom: 4, left: 4),
                          alignment: Alignment.center,
                          child: Text(
                            "List".tr,
                            style: TextStyle(
                              color: WhiteColor,
                              fontFamily: FontFamily.gilroyMedium,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: currenIndex == 0
                                ? Color.fromARGB(255, 43, 71, 255)
                                : transparent,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(Get.context!).push(_createRoute());
                          setState(() {
                            currenIndex = 1;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 70,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 4, bottom: 4, right: 4),
                          child: Text(
                            "Map".tr,
                            style: TextStyle(
                              color: WhiteColor,
                              fontFamily: FontFamily.gilroyMedium,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: currenIndex == 1
                                ? Color.fromARGB(255, 43, 71, 255)
                                : transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: gradient.defoultColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                )
              : SizedBox();
        }),
        bottomNavigationBar: GetBuilder<LoginController>(builder: (context) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            unselectedItemColor: greyColor,
            // backgroundColor: BlackColor,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
                fontFamily: 'Gilroy Bold',
                // fontWeight: FontWeight.bold,
                fontSize: 12),
            fixedColor: gradient.defoultColor,
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Gilroy Medium',
            ),
            currentIndex: selectedIndex,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/home-dash.png",
                  color: selectedIndex == 0 ? gradient.defoultColor : greytext,
                  height: Get.size.height / 35,
                ),
                label: 'Home'.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/Love.png",
                  color: selectedIndex == 1 ? gradient.defoultColor : greytext,
                  height: Get.size.height / 35,
                ),
                label: 'Favorite'.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/Ticket.png",
                  color: selectedIndex == 2 ? gradient.defoultColor : greytext,
                  height: Get.size.height / 35,
                ),
                label: 'Ticket'.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/Profile.png",
                  color: selectedIndex == 3 ? gradient.defoultColor : greytext,
                  height: Get.size.height / 35,
                ),
                label: 'Profile'.tr,
              ),
            ],
            onTap: (index) {
              setState(() {});
              if (isLogin != null) {
                selectedIndex = index;
              } else {
                index != 0 ? Get.to(() => LoginScreen()) : const SizedBox();
              }
            },
          );
        }),
        body: GetBuilder<LoginController>(builder: (context) {
          return myChilders[selectedIndex];
        }),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => MapScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

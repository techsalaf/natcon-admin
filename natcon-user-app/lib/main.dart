// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:magicmate_user/screen/language/local_string.dart';
import 'package:magicmate_user/utils/Custom_widget.dart';
import 'package:provider/provider.dart';
import 'Api/data_store.dart';
import 'firebase/chat_page.dart';
import 'firebase/firebase_provider.dart';
import 'firebase/notification_service.dart';
import 'firebase_accesstoken.dart';
import 'firebase_options.dart';
import 'helpar/get_di.dart' as di;
import 'helpar/routes_helpar.dart';

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  await di.init();
  await GetStorage.init();
  final notificationsService = NotificationsService();
  notificationsService.requestPermission();
  notificationsService.listenFCM();
  notificationsService.initLocalNotification();
  notificationsService.loadFCM();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  initPlatformState();
  FirebaseAccesstoken accesstoken=new FirebaseAccesstoken();
  accesstoken.getAccessToken();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FirebaseProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.blue,
          fontFamily: "Gilroy",
        ),
        translations: LocaleString(),
        locale: getData.read("lan2") != null
            ? Locale(getData.read("lan2"), getData.read("lan1"))
            : Locale('en_US', 'en_US'),
        initialRoute: Routes.initial,
        getPages: getPages,
      ),
    ),
  );
}

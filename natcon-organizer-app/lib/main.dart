// ignore_for_file: prefer_const_constructors, duplicate_ignore


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:magicmate_organizer/intro_Screen/addintro_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_organizer/utils/dark_light_mode.dart';
import 'package:magicmate_organizer/utils/language_translate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'Login_flow/Login_screen.dart';
import 'api_screens/data_store.dart';
import 'firebase/chat_page.dart';
import 'firebase/firebase_provider.dart';
import 'firebase/notification_service.dart';
import 'firebase_accesstoken.dart';
import 'firebase_options.dart';
import 'helpar/get_di.dart' as di;
import 'package:get_storage/get_storage.dart';

Future<void> _backgroundMessageHandler(RemoteMessage message) async {await Firebase.initializeApp();}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  await di.init();
  await requestPermission();
  Permission.camera;
  final notificationsService = NotificationsService();
  FirebaseAccesstoken accesstoken = new FirebaseAccesstoken();
  accesstoken.getAccessToken();
  await notificationsService.getToken();
  notificationsService.loadFCM();
  notificationsService.listenFCM();
  notificationsService.initLocalNotification();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  initPlatformState();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ColorNotifier()),
        ChangeNotifierProvider(create: (context) => FirebaseProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: GetMaterialApp(
        translations: LocaleString(),
        locale: getData.read("lan2") != null
            ? Locale(getData.read("lan2"), getData.read("lan1"))
            : const Locale('en_US', 'en_US'),
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          dividerColor: Colors.transparent,
          useMaterial3: false,
        ),
        debugShowCheckedModeBanner: false,
        home: onbording(),
      ),
    ),
  );
}

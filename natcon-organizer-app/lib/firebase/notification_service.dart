import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

import '../api_screens/confrigation.dart';
import '../api_screens/data_store.dart';
import 'chats.dart';


const channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Hign Importance Notifications',
    description:
    'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true);

class NotificationsService {

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      WebNotification? web = message.notification?.web;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && (web != null || android != null)) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentSound: true,
                presentBadge: true,
              ),
            ),
            payload: jsonEncode({
              "name": message.data["name"],
              "id": message.data["id"],
            }));
      }
    });
  }

  void initLocalNotification() {
    const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
        android: androidSettings, iOS: iosSettings);
    flutterLocalNotificationsPlugin
        .initialize(initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint(response.payload.toString());
        });
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    if(payload != null){
      Map data = jsonDecode(payload);
      Get.to(ChatScreen());
    }
  }

  Future<void> onDidReceiveNotificationResponse(NotificationResponse response) async {

    String? payload = response.payload;
    if(payload != null){
      Map data = jsonDecode(payload);
      Get.to(ChatScreen());
    }
  }

  late AndroidNotificationChannel channel;

  Future<void> loadFCM() async {

    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      enableVibration: true,
    );

    print(" rne t bjn  j  hjnb jn");
    final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);


    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

  }

  Future<void> _showLocalNotification(
      RemoteMessage message) async {
    final styleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title,
      htmlFormatTitle: true,
    );
    final androidDetails = AndroidNotificationDetails(
      'com.evently.organizer',
      'mychannelid',
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.max,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['body']);
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint(
          'User declined or has not accepted permission');
    }
  }

  Future<void> getToken() async {
    final token =
    await FirebaseMessaging.instance.getToken();
    _saveToken(token!);
  }

  Future<void> _saveToken(String token) async =>
      await FirebaseFirestore.instance.collection('MagicOrganizer').doc(getData.read("UserLogin")["id"]).set({'token': token}, SetOptions(merge: true));

  String receiverToken = '';

  Future<void> getReceiverToken(String? receiverId) async {
    final getToken = await FirebaseFirestore.instance.collection('MagicUser').doc(receiverId).get();


    if (getToken.exists && getToken.data() != null) {
      receiverToken = getToken.data()!['token'];
    } else {
      print('No data found for receiverId: $receiverId');
    }
  }

  void firebaseNotification(context) {
    initLocalNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(),
        ),
      );
    });

    FirebaseMessaging.onMessage
        .listen((RemoteMessage message) async {
      await _showLocalNotification(message);
    });
  }

  Future<void> sendNotification({required String body, required String senderId}) async {
    final dio = Dio();

    print("++++send meshj++++:--  ${AppUrl.firebaseKey}");
    try {
      final response = await dio.post(
        'https://fcm.googleapis.com/v1/projects/${AppUrl.projectID}/messages:send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppUrl.firebaseKey}',
          },
        ),
        data: jsonEncode({
          'message': {
            'token': receiverToken,
            'notification': {
              'title': 'New Message !',
              'body': body,
            },
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'senderId': senderId,
              'status': 'done'
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        print('done');
      } else {
        print('Failed to send push notification: ${response.data}');
      }
    } catch (e) {
      print("Error push notificatioDDn: $e");
    }
  }
}

requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {

  }
}

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import 'chats.dart';


const channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Hign Importance Notifications',
    description:
    'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true);

class NotificationsService {

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

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
              "propic": message.data["propic"]
            }));
      }
    });
  }

  void initLocalNotification() async {

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIos = DarwinInitializationSettings();


    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIos);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    if(payload != null){
      Map data = jsonDecode(payload);
      Get.to(
          ChatScreen(
            eventUid: data["id"],
          ));
    }
  }

  Future<void> onDidReceiveNotificationResponse(NotificationResponse response) async {
    String? payload = response.payload;
    if(payload != null){
      Map data = jsonDecode(payload);
      Get.to(
          ChatScreen(
            eventUid: data["id"],
          ));
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

  Future<void> showLocalNotification(RemoteMessage message) async {
    final styleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title,
      htmlFormatTitle: true,
    );
    final androidDetails = AndroidNotificationDetails(
      'com.eventlycustomerapp',
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
      await FirebaseFirestore.instance.collection('MagicUser').doc(getData.read("UserLogin")["id"]).set({'token': token}, SetOptions(merge: true));

  String receiverToken = '';

  Future<void> getReceiverToken(String? receiverId) async {
    final getToken = await FirebaseFirestore.instance.collection('MagicOrganizer').doc(receiverId).get();

    if (getToken.exists && getToken.data() != null) {
      receiverToken = getToken.data()!['token'];
    } else {
      print('No data found for receiverId: $receiverId');
    }
  }

  void firebaseNotification(context,Widget chatScreen) {
    initLocalNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen(),),
      );
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showLocalNotification(message);
    });
  }

  // Future<void> sendNotification(
  //     {required String body,
  //       required String senderId}) async {
  //   try {
  //     await http.post(
  //       Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //         'Authorization': 'key=$key',
  //       },
  //       body: jsonEncode(<String, dynamic>{
  //         "to": receiverToken,
  //         'priority': 'high',
  //         'notification': <String, dynamic>{
  //           'body': body,
  //           'title': 'New Message !',
  //         },
  //         'data': <String, String>{
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'status': 'done',
  //           'senderId': senderId,
  //         }
  //       }),
  //     );
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }


  Future<void> sendNotification({required String body, required String senderId}) async {
    final dio = Dio();

    print("++++send meshj++++:--  ${Config.firebaseKey}");
    try {
      final response = await dio.post(
        'https://fcm.googleapis.com/v1/projects/${Config.projectID}/messages:send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Config.firebaseKey}',
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

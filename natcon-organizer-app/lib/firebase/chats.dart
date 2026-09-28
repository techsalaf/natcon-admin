// ignore_for_file: unused_import

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:magicmate_organizer/api_screens/confrigation.dart';
import 'package:magicmate_organizer/firebase/chat_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../firebase/chat_page.dart';
import '../api_screens/data_store.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
import '../utils/Fontfamily.dart';
import '../utils/dark_light_mode.dart';
import '../utils/simmer_effect.dart';
import 'firebase_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'firestore_service.dart';

class ChatScreen extends StatefulWidget {
  static const chatScreenRoute = "/chatScreen";

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final controller = TextEditingController();

  @override
  void initState() {
    getDarkMode();
    Provider.of<FirebaseProvider>(context, listen: false)
      ..getUserById(getData.read("UserLogin")["id"]);
    print("+++++++++++++++++++++++++++++ ${FirebaseProvider.conID}");
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      appBar: AppBar(
        backgroundColor: notifier.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back, color: notifier.textColor)),
        title: Text(
          "Chats".tr,
          style: TextStyle(
            color: notifier.textColor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: notifier.containerColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("MagicUser").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: appcolor));
          } else {
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: snapshot.data!.docs.map<Widget>((doc) {
                return _chatUserList(doc, snapshot.data!.docs.length);
              }).toList(),
            );
          }
        });
  }

  FirebaseFirestoreService firestoreService = FirebaseFirestoreService();
  Widget _chatUserList(DocumentSnapshot document, int length){
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (getData.read("UserLogin")["name"] != data["name"]) {
      print("USERNAME OR ORGANIZER ${getData.read("UserLogin")["id"]} - ${data["uid"]}");
      return StreamBuilder(
        stream: firestoreService.getMessage(userId: data["uid"], otherUserId: getData.read("UserLogin")["id"]),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return const Text("Error");
          } else {

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox();
            }

            // final ids = snapshot.data!.docs.map((doc) => doc.id).toList();
            // print("All Chat IDs: $ids");
            print("IDS ${snapshot.data!.docs[0]["senderId"]} = ${getData.read("UserLogin")["id"]} - ${data["uid"]}");
            // if (!ids.contains(data["uid"])) {
            //   return const SizedBox();
            // }
            return _buildUserListItem(document, data["uid"], length);
          }
        },
      );
    } else {
      return Container();
    }
  }


  Widget _buildMessageItem(DocumentSnapshot doc, String email, String name, String uid, String proPic, int length, AsyncSnapshot<QuerySnapshot> snapshot, bool isOnline, String lastTime, String Time) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ChattingPage(
            resiverUsername: name,
            resiverUserId: uid,
            proPic: proPic,
            status: isOnline,
            lastTime: Time,
          ),
        ));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: notifier.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifier.border)),
        child: Row(
          children: [
            // proPic != ""
            //       ? CircleAvatar(
            //     radius: 30,
            //     backgroundColor: appcolor,
            //     foregroundImage: NetworkImage("${AppUrl.baseUrl+proPic}"),
            //     )
            //       :
            CircleAvatar(
              radius: 30,
              backgroundColor: appcolor,
              child: Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    color: WhiteColor,
                    fontFamily: FontFamily.gilroyBold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: notifier.textColor,
                    fontSize: 17,
                    fontFamily: FontFamily.gilroyBold,
                  ),
                ),
                SizedBox(height: 2),
                isOnline == true
                    ? Text(
                        "Active",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 13,
                          fontFamily: FontFamily.gilroyBold,
                        ),
                      )
                    : Text(
                        'Last Active: ${lastTime}',
                        style: TextStyle(
                          color: notifier.textColor,
                          fontSize: 13,
                          fontFamily: FontFamily.gilroyBold,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  FirebaseProvider firebaseProvider = FirebaseProvider();

  Widget _buildUserListItem(DocumentSnapshot document, String doc, int legth) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String receiverId = doc;
    // print("<<<<<<<<<Data>>>>>>>>>>>> ${data}");

    // if (getData.read("UserLogin")["uid"] != data["uid"]) {
      return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("MagicUser").where('uid', isEqualTo: receiverId).snapshots(),
        // stream: firebaseProvider.getMessageData(receiverId: data["uid"]),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Shimmer.fromColors(
              baseColor: Colors.black45,
              highlightColor: Colors.grey.shade100,
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3))),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                    SizedBox(width: 13),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 25,
                          width: 130,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 25,
                          width: 85,
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No Data"));
          }
          Timestamp timestamp;
          if (data['lastActive'] != null && data['lastActive'] is Timestamp) {
            timestamp = data['lastActive'];
          } else if (data['lastActive'] != null &&
              data['lastActive'] is String) {
            DateTime dateTime = DateTime.parse(data['lastActive']);
            timestamp = Timestamp.fromDate(dateTime);
          } else {
            timestamp = Timestamp.now();
          }
          // Timestamp timestamp = data['lastActive'];
          DateTime dateTime = timestamp.toDate();
          String formattedDate = DateFormat('d MMMM yyyy').format(dateTime);
          String relativeTime = timeago.format(dateTime);

          print("+++++++++++++++++++ ${snapshot.data}");
          print("+++++++++++++++++++ ${data}");

          var lastDoc = snapshot.data!.docs.last;
          var name = lastDoc['name'] ?? 'No Name';
          var uid = lastDoc['uid'] ?? 'No UID';
          var proPic = lastDoc['pro_pic']?.toString() ?? '';
          var length = snapshot.data!.docs.length;
          var email = lastDoc['email'] ?? "No Email";
          var isOnline = lastDoc['isOnline'] ?? "No Email";
          var lastActive = formattedDate;
          var chatsTime = relativeTime;

          return _buildMessageItem(lastDoc, email, name, uid, proPic, length,
              snapshot, isOnline, lastActive, chatsTime);
        },
      );
    // }
    // else {
      return const SizedBox();
    // }
  }


}

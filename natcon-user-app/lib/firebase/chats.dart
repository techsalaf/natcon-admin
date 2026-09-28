// ignore_for_file: unused_import, avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../firebase/chat_page.dart';
import '../Api/config.dart';
import '../Api/data_store.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
import '../utils/simmer_effect.dart';
import 'firestore_service.dart';
import 'notification_service.dart';

class ChatScreen extends StatefulWidget {
  static const chatScreenRoute = "/chatScreen";
  final String? eventUid;
  const ChatScreen({super.key, this.eventUid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  void initState() {
    fetchEventDetails();
    super.initState();
  }

  String formattedDate = "";
  String relativeTime = "";
  Map<String, dynamic>? eventData;
  bool isLoading = true;

  Future<void> fetchEventDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('MagicOrganizer').doc(widget.eventUid).get();

      setState(() {
        eventData = documentSnapshot.data() as Map<String, dynamic>?;
        print("================ $eventData");
        Timestamp timestamp;
        if (eventData!['lastActive'] != null &&
            eventData!['lastActive'] is Timestamp) {
          timestamp = eventData!['lastActive'];
        } else if (eventData!['lastActive'] != null &&
            eventData!['lastActive'] is String) {
          DateTime dateTime = DateTime.parse(eventData!['lastActive']);
          timestamp = Timestamp.fromDate(dateTime);
        } else {
          timestamp = Timestamp.now(); // or handle null case appropriately
        }
        DateTime dateTime = timestamp.toDate();
        formattedDate = DateFormat('d MMMM yyyy').format(dateTime);
        relativeTime = timeago.format(dateTime);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching event details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        // centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.arrow_back, color: Colors.black,)),
        title: Text(
          "Chats".tr,
          style: TextStyle(
            color: BlackColor,
            fontFamily: FontFamily.gilroyBold,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: bgcolor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.eventUid != FirebaseFirestore.instance.collection("MagicOrganizer").doc(widget.eventUid).id
                ? Expanded(child: _buildUserList())
                : singleData(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("MagicOrganizer").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: gradient.defoultColor,));
          } else {
            return ListView(
              physics: const BouncingScrollPhysics(),
              key: const PageStorageKey('chat_list'),
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
    print("USERNAME OR ORGANIZER ${getData.read("UserLogin")["name"]} - ${data["name"]}");
      return StreamBuilder(
        stream: firestoreService.getMessage(userId: getData.read("UserLogin")["id"], otherUserId: data["uid"]),
        builder: (context, snapshot) {
          print("IDS Step 0");
          if(snapshot.hasError){
            return const Text("Error");
          } else {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox();
            }
            // final ids = snapshot.data!.docs.map((doc) => doc.id).toList();
            // print("All Chat IDs: $ids");
            // print("IDS ${snapshot.data!.docs.last.id} = ${getData.read("UserLogin")["id"]} - ${data["uid"]}");
            // if (!ids.contains(data["uid"])) {
            //   return const SizedBox();
            // }
            print("IDS Step 1");
            return _buildUserListItem(document, data["uid"], length);
          }
        },
      );
    } else {
      return Container();
    }
  }

  Widget _buildMessageItem(DocumentSnapshot doc, String email, String name, String uid, String proPic, int length, bool isOnline, String lastTime, String Time) {
    return GestureDetector(
      onTap: () {
        print("---------------- ${Config.baseurl + proPic}");
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            ChattingPage(resiverUsername: name, resiverUserId: uid, proPic: proPic, status: isOnline, lastTime: Time),));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: WhiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // proPic == ""
            //     ? CircleAvatar(
            //   radius: 30,
            //   backgroundColor: gradient.defoultColor,
            //   foregroundImage: NetworkImage(Config.baseurl+proPic),
            // )
            //     :
            CircleAvatar(
              radius: 30,
              backgroundColor: gradient.defoultColor,
              child: Center(
                child: Text(name[0].toUpperCase(), style: TextStyle(
                  color: WhiteColor,
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 18,
                ),),
              ),),
            const SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(
                  color: BlackColor,
                  fontSize: 17,
                  fontFamily: FontFamily.gilroyBold,
                ),),
                const SizedBox(height: 2),
                isOnline == true
                    ? const Text("Active", style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontFamily: FontFamily.gilroyBold,
                ),)
                    : Text('Last Active: $lastTime', style: TextStyle(
                  color: BlackColor,
                  fontSize: 13,
                  fontFamily: FontFamily.gilroyBold,
                ),),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document, String doc, int legth) {
    print("IDS Step 2");
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String chatData = doc;
    print("IDS $chatData");
    Timestamp timestamp;
    if (data['lastActive'] != null && data['lastActive'] is Timestamp) {
      timestamp = data['lastActive'];
    } else if (data['lastActive'] != null && data['lastActive'] is String) {
      DateTime dateTime = DateTime.parse(data['lastActive']);
      timestamp = Timestamp.fromDate(dateTime);
    } else {
      timestamp = Timestamp.now();
    }
    // Timestamp timestamp = data['lastActive'] ?? "";
    print("IDS Step 3");
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('d MMMM yyyy').format(dateTime);
    String relativeTime = timeago.format(dateTime);
    print("IDS Step 4");
    var lastDoc = document;
    var name = data['name'] ?? 'No Name';
    var uid = data['uid'] ?? 'No UID';
    var proPic = data['pro_pic']?.toString() ?? '';
    var length = legth;
    var email = data['email'] ?? "No Email";
    var isOnline = data['isOnline'] ?? "No Email";
    var lastActive = formattedDate;
    var chatsTime = relativeTime;
    print("IDS Step 5");
    return _buildMessageItem(lastDoc, email, name, uid, proPic, length, isOnline, lastActive, chatsTime);
  }

  Widget singleData() {
    return isLoading
        ? const Column(
      children: [
        SizedBox(height: 350),
        Center(child: CircularProgressIndicator(color: gradient.defoultColor,)),
      ],
    )
        : eventData == null
        ? Column(
      children: [
        const SizedBox(height: 350),
        Center(
            child: Text('Chat not Found',
              style: TextStyle(
                color: BlackColor,
                fontSize: 25,
                fontFamily: FontFamily.gilroyBold,
              ),)),
      ],
    )
        : GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
            ChattingPage(resiverUsername: eventData!['name'],
                resiverUserId: eventData!['uid'],
                proPic: eventData!['pro_pic'],
                status: eventData!['isOnline'],
                lastTime: relativeTime),));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: WhiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            // eventData!['proPic'] == ""
            //     ? CircleAvatar(
            //   radius: 30,
            //   backgroundColor: gradient.defoultColor,
            //   foregroundImage: NetworkImage(Config.baseurl+eventData!['pro_pic']),
            // )
            //     :
            CircleAvatar(
              radius: 30,
              backgroundColor: gradient.defoultColor,
              child: Center(
                child: Text(
                  eventData!['name'][0].toUpperCase(), style: TextStyle(
                  color: WhiteColor,
                  fontFamily: FontFamily.gilroyBold,
                  fontSize: 18,
                ),),
              ),),
            const SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(eventData!['name'], style: TextStyle(
                  color: BlackColor,
                  fontSize: 17,
                  fontFamily: FontFamily.gilroyBold,
                ),),
                const SizedBox(height: 2),
                eventData!['isOnline'] == true
                    ? const Text("Active", style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontFamily: FontFamily.gilroyBold,
                ),)
                    : Text('Last Active: $formattedDate', style: TextStyle(
                  color: BlackColor,
                  fontSize: 13,
                  fontFamily: FontFamily.gilroyBold,
                ),),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
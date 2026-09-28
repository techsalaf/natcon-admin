import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_screens/data_store.dart';
import '../utils/Fontfamily.dart';
import '../utils/dark_light_mode.dart';

import 'chat_bubble.dart';
import 'chat_model.dart';
import 'chat_textfield.dart';
import 'firebase_provider.dart';


class ChattingPage extends StatefulWidget {
  final String resiverUserId;
  final String resiverUsername;
  final String proPic;
  final bool status;
  final String lastTime;
  const ChattingPage({super.key, required this.resiverUserId, required this.resiverUsername, required this.proPic, required this.status, required this.lastTime});

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

bool isLoading = true;

class _ChattingPageState extends State<ChattingPage> with WidgetsBindingObserver {



  @override
  void initState() {
    getDarkMode();
    Provider.of<FirebaseProvider>(context, listen: false)
      ..getUserById(getData.read("UserLogin")["id"])
      ..getMessages(widget.resiverUserId);
    print("${FirebaseProvider.conID}");
    idSeparation();
    super.initState();
  }


  String customerId = "";
  String organizerId = "";

  idSeparation(){
    RegExp regExp = RegExp(r'U(\d+)_O(\d+)');
    Match? match = regExp.firstMatch(FirebaseProvider.conID);

    if (match != null) {
      customerId = match.group(1)!; // "6"
      organizerId = match.group(2)!; // "78"

      print("First Number customerId: $customerId");
      print("Second Number organizerId: $organizerId");
    }
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


  TextEditingController controller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: notifier.containerColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: notifier.background,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back, color: notifier.textColor, size: 20,)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: appcolor,
              child: Text(
                "${widget.resiverUsername[0].toUpperCase()}", style: TextStyle(
                color: WhiteColor,
                fontSize: 15,
                fontFamily: FontFamily.gilroyBold,
              ),),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.resiverUsername}", style: TextStyle(
                  color: notifier.textColor,
                  fontSize: 15,
                  fontFamily: FontFamily.gilroyBold,
                ),
                ),
                Text(
                  widget.status == true
                      ? 'Online'
                      : widget.lastTime,
                  style: TextStyle(
                    color: widget.status == true
                        ? Colors.green
                        : Colors.grey,
                    fontFamily:FontFamily.gilroyBold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ChatMessages(receiverId: getData.read("UserLogin")["id"]),
            ChatTextField(receiverId: widget.resiverUserId),
          ],
        ),
      ),
    );
  }
}

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('MagicOrganizer').doc(userId).update({
        'isOnline': isOnline,
        'lastActive': Timestamp.now(),
      });
      notifyListeners();
    } catch (e) {
      print('Error updating user status: $e');
    }
  }
}



class ChatMessages extends StatelessWidget {
  ChatMessages({super.key, required this.receiverId});
  final String receiverId;

  @override
  Widget build(BuildContext context) =>
      Consumer<FirebaseProvider>(
        builder: (context, value, child) =>
        value.loading
            ? Expanded(
              child: Center(child: CircularProgressIndicator(color: appcolor)),
            )
            : value.messages.isEmpty
            ? const Expanded(
          child: EmptyWidget(
            icon: Icons.waving_hand,
            text: 'Say Hello!',
          ),
        )
            : Expanded(
          child: ListView.builder(
            controller: Provider.of<FirebaseProvider>(context, listen: false).scrollController,
            itemCount: value.messages.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final isTextMessage = value.messages[index].messageType == MessageType.text;
              final isMe = receiverId != value.messages[index].senderId;
              return Column(
                children: [
                  MessageBubble(
                    isMe: isMe,
                    message: value.messages[index],
                    isImage: !isTextMessage,
                  ),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      );

}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget(
      {super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 150),
        SizedBox(height: 20),
        Text(
          'Say Hello...!!!',
          style: const TextStyle(fontSize: 25),
        ),
      ],
    ),
  );
}


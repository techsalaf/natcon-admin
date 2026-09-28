import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Api/data_store.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
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

class _ChattingPageState extends State<ChattingPage> with WidgetsBindingObserver {

  @override
  void initState() {
    Provider.of<FirebaseProvider>(context, listen: false).getMessages(widget.resiverUserId);
      // ..getUserById(getData.read("UserLogin")["id"])

    super.initState();
  }

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bgcolor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WhiteColor,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(
              Icons.arrow_back, color: BlackColor, size: 20,)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: gradient.defoultColor,
              child: Text(
                widget.resiverUsername[0].toUpperCase(), style: TextStyle(
                color: WhiteColor,
                fontSize: 15,
                fontFamily: FontFamily.gilroyBold,
              ),),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.resiverUsername, style: TextStyle(
                  color: BlackColor,
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
            ChatTextField(receiverId: widget.resiverUserId)
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
      await _firestore.collection('MagicUser').doc(userId).update({'isOnline': isOnline, 'lastActive': Timestamp.now(),
      });
      notifyListeners();
    } catch (e) {
      print('Error updating user status: $e');
    }
  }
}

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key, required this.receiverId});
  final String receiverId;

  @override
  Widget build(BuildContext context) =>
      Consumer<FirebaseProvider>(
        builder: (context, value, child) =>
        value.loading
            ? const Expanded(
          child: Center(
            child: CircularProgressIndicator(color: gradient.defoultColor,),
          ),
        )
            : value.messages.isEmpty
            ? const Expanded(
          child: EmptyWidget(
              icon: Icons.waving_hand,
              text: 'Say Hello!'),
        )
            : Expanded(
          child: ListView.builder(
            controller: Provider.of<FirebaseProvider>(context, listen: false).scrollController,
            itemCount: value.messages.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final isTextMessage =
                  value.messages[index].messageType == MessageType.text;
              final isMe = receiverId != value.messages[index].senderId;

              return Column(
                children: [
                  isTextMessage
                      ? MessageBubble(
                    isMe: isMe,
                    message: value.messages[index],
                    isImage: false,
                  )
                      : MessageBubble(
                    isMe: isMe,
                    message: value.messages[index],
                    isImage: true,
                  ),
                  const SizedBox(height: 10),
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
        const SizedBox(height: 20),
        Text(
          text,
          style: const TextStyle(fontSize: 25),
        ),
      ],
    ),
  );
}

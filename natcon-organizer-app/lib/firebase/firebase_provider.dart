import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../api_screens/data_store.dart';
import 'chat_model.dart';
import 'package:flutter/material.dart';

import 'firestore_service.dart';

class FirebaseProvider extends ChangeNotifier {

  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  List<UserModel> users = [];
  UserModel? user;
  List<Message> messages = [];
  List<UserModel> search = [];

  static String conID = "";




  bool _loading = true;
  bool get loading => _loading;

  FirebaseProvider() {
    focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      scrollDown();
    }
  }





  List<UserModel> getAllUsers() {
    FirebaseFirestore.instance.collection('Magic_Organization_rooms').orderBy('lastActive', descending: true).snapshots(includeMetadataChanges: true).listen((users) {
      this.users = users.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      notifyListeners();
    });
    return users;
  }

  // Stream<List<UserModel>> getAllUsers() {
  //   return FirebaseFirestore.instance.collection('Magic_Organization_rooms').orderBy('lastActive', descending: true).snapshots(includeMetadataChanges: true).map((snapshot) {
  //     users = snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  //     notifyListeners();
  //     print("++++++++++++++++ ${users}");
  //     return users;
  //   });
  // }

  UserModel? getUserById(String userId) {
    List ids = [userId, getData.read("UserLogin")["id"]];
    ids.sort();
    String chatRoomId = ids.join("_");

    FirebaseFirestore.instance.collection('Magic_Organization_rooms').doc(chatRoomId).snapshots(includeMetadataChanges: true).listen((user) {
      final data = user.data();
      if (data != null) {
        print('User data: $data');
        this.user = UserModel.fromJson(data);
        notifyListeners();
      } else {
        print('No user data found for userId: $userId');
      }
    });
    return user;
  }

  // Stream<QuerySnapshot> getMessageData({required String receiverId}) {
  //   conID = "U${receiverId}_O${getData.read("UserLogin")["id"]}";
  //
  //   return FirebaseFirestore.instance.collection("Magic_Organization_rooms").doc(conID).collection("messages").orderBy("sentTime", descending: false).snapshots();
  // }

  List<Message> getMessages(String receiverId) {
     conID = "${receiverId}_${getData.read("UserLogin")["id"]}";
    _loading = true;
    notifyListeners();

    FirebaseFirestore.instance.collection('Magic_Organization_rooms').doc(conID).collection('messages').orderBy('sentTime', descending: false).snapshots(includeMetadataChanges: true).listen((messages) {
      this.messages = messages.docs.map((doc) => Message.fromJson(doc.data())).toList();
      _loading = false;
      notifyListeners();

      scrollDown();
    });
    return messages;
  }




  void scrollDown() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(
              scrollController.position.maxScrollExtent);
        }
      });

  Future<void> searchUser(String name) async {
    search =
    await FirebaseFirestoreService.searchUser(name);
    notifyListeners();
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    super.dispose();
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Api/data_store.dart';
import 'chat_model.dart';
import 'firestore_service.dart';


class FirebaseProvider extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  List<UserModel> users = [];
  UserModel? user;
  List<Message> messages = [];
  List<UserModel> search = [];

  bool _loading = true;
  bool get loading => _loading;

  List<UserModel> getAllUsers() {
    FirebaseFirestore.instance.collection('Magic_Organization_rooms').orderBy('lastActive', descending: true).snapshots(includeMetadataChanges: true).listen((users) {
      this.users = users.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
      notifyListeners();
    });
    return users;
  }

  UserModel? getUserById(String userId) {
    FirebaseFirestore.instance.collection('Magic_Organization_rooms').doc(userId).snapshots(includeMetadataChanges: true).listen((user) {
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

  List<Message> getMessages(String receiverId) {
    String conID = "${getData.read("UserLogin")["id"]}_$receiverId";
    _loading = true;
    notifyListeners();
    FirebaseFirestore.instance.collection('Magic_Organization_rooms').doc(conID).collection('messages').orderBy('sentTime', descending: false).snapshots(includeMetadataChanges: true).listen((messages) {
      this.messages = messages.docs.map((doc) => Message.fromJson(doc.data())).toList();
      _loading = false;
      notifyListeners();
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
    search = await FirebaseFirestoreService.searchUser(name);
    notifyListeners();
  }

}


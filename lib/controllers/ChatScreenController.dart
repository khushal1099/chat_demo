import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../Firebase/FirebaseHelper.dart';

class ChatScreenController extends GetxController {
  RxBool isSend = false.obs;
  RxMap<String, List<ChatModel>> messageList = <String, List<ChatModel>>{}.obs;
  RxList<ChatModel>? list = <ChatModel>[].obs;
  RxList<UserModel> friendsList = <UserModel>[].obs;
  RxList<String> friendsIdList = <String>[].obs;

  void getMessages(String chatroomId, var fTime) async {
    if (fTime == null) list?.value = messageList[chatroomId] ?? [];

    var data = fTime == null
        ? await FBHelper().getMessages(chatroomId)
        : await FBHelper().getMoreMessages(chatroomId, fTime);

    var msg = data.docs.map((e) => ChatModel.fromJson(e.data())).toList();

    if (fTime == null) {
      list?.value = msg;
    } else {
      for (var newMsg in msg) {
        if (!list!.any((oldMsg) => oldMsg.time == newMsg.time)) {
          list?.add(newMsg);
        }
      }
    }

    list?.sort((a, b) => b.time!.compareTo(a.time!));
    messageList[chatroomId] = list?.value ?? [];
  }

  void getfriendList() async {
    var frd = await FirebaseFirestore.instance
        .collection(FBHelper.users)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(FBHelper.friends)
        .get();

    var frdId = frd.docs.map((e) => e.id).toList();

    friendsIdList.value = frdId;

    if (frdId.isNotEmpty) {
      var data = await FirebaseFirestore.instance
          .collection(FBHelper.users)
          .where('uid', whereIn: frdId)
          .get();

      friendsList.value =
          data.docs.map((e) {
            print(e.data());
            return UserModel.fromJson(e.data());
          }).toList();
      friendsList.refresh();
    }
  }
}

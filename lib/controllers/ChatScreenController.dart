import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:get/get.dart';

import '../Firebase/FirebaseHelper.dart';

class ChatScreenController extends GetxController {
  RxBool isSend = false.obs;
  RxMap<String, List<ChatModel>> messageList = <String, List<ChatModel>>{}.obs;
  RxList<ChatModel>? list = <ChatModel>[].obs;

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
}

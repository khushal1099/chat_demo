import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:get/get.dart';

class ChatScreenController extends GetxController {
  RxBool isSend = false.obs;
  RxMap<String,List<ChatModel>> messageList = <String,List<ChatModel>>{}.obs;
  RxList<ChatModel>? list = <ChatModel>[].obs;
}

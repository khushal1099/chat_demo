import 'dart:developer';
import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/Utils/SizeUtils.dart';
import 'package:chat_demo/Utils/Utils.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:chat_demo/screens/CameraScreen.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Utils/AppAssets.dart';

class ChatScreen extends StatefulWidget {
  final UserModel userModel;

  const ChatScreen({super.key, required this.userModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatScreenController cc = Get.put(ChatScreenController());
  TextEditingController chat = TextEditingController();
  var cu = FirebaseAuth.instance.currentUser;
  String chatroomId = '';
  ScrollController scrollController = ScrollController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;

  @override
  void initState() {
    if (cu?.uid.compareTo(widget.userModel.uid!) == 1) {
      chatroomId = "${cu?.uid}-${widget.userModel.uid}";
    } else {
      chatroomId = "${widget.userModel.uid}-${cu?.uid}";
    }
    getMoreMessages();
    super.initState();
  }

  bool isLoading = false;

  void getMoreMessages() async {
    cc.messageList.putIfAbsent(chatroomId, () => []);
    cc.getMessages(chatroomId, null);
    scrollController.addListener(
      () async {
        if (scrollController.offset <=
                scrollController.position.minScrollExtent + 10 &&
            !isLoading) {
          isLoading = true;
          cc.getMessages(chatroomId, cc.list?.value.last.time);
          log('${cc.list?.value.map((data) => data.message)}');
          isLoading = false;
        }
      },
    );
    stream = await FBHelper().getNewMsg(chatroomId.toString());
    stream?.listen(
      (event) {
        if (event.docs.isNotEmpty) {
          var v = event.docs.map((e) => ChatModel.fromJson(e.data())).last;
          print(v.message);
          cc.list?.value.removeWhere((element) => element.time == v.time);
          cc.list?.value.add(v);
          cc.list?.value.sort((a, b) => b.time!.compareTo(a.time!));
        }
      },
    );
  }

  void sendMessage(var value, var message) async {
    chat.clear();
    String? v;
    if (value != null && message == null) {
      v = value;
    } else if (value == null && message != null) {
      v = message;
    } else {
      v = message;
    }

    if (v != null) {
      String date = DateTime.now().toString();
      cc.list?.value.insert(
        0,
        ChatModel(
          message: v,
          senderEmail: cu?.email ?? "",
          senderId: cu?.uid,
          time: date,
          slug: "Text"
        ),
      );
      cc.list?.refresh();

      await FBHelper().sendMessage(
          cu?.uid ?? '', cu?.email ?? '', v, chatroomId, date, 'Text');

      if (!cc.friendsIdList.contains(widget.userModel.uid)) {
        await FBHelper().addFriend(widget.userModel.uid.toString());
        await cc.getfriendList();
      }
      print(cc.friendsList.length);
      print(cc.friendsList.map((e) => e.fullname));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff101010),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              maxRadius: 15,
              backgroundImage: widget.userModel.profilePic != null
                  ? NetworkImage(widget.userModel.profilePic.toString())
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.userModel.fullname.toString()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                image: DecorationImage(
                  image: AssetImage(AppAssets.bg),
                  fit: BoxFit.cover,
                ),
              ),
              child: Obx(
                () {
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: cc.list?.value.length,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var msg = cc.list?.value[index];
                      var isMyMsg = cu?.uid == msg?.senderId;
                      return Row(
                        mainAxisAlignment: isMyMsg
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMyMsg)
                            CircleAvatar(
                              maxRadius: 10,
                              backgroundImage: widget.userModel.profilePic !=
                                      null
                                  ? NetworkImage(
                                      widget.userModel.profilePic.toString())
                                  : null,
                            ),
                          if (msg?.slug == "Text")
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                msg?.message ?? '',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          if (msg?.slug == "Image")
                            Container(
                              padding: const EdgeInsets.all(6),
                              margin: const EdgeInsets.only(bottom: 4),
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                color: const Color(0xff101010),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.network(
                                msg?.message ?? '',
                                fit: BoxFit.cover,
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  if (frame != null) {
                                    const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  return child;
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            height: 80,
            width: SizeUtils.width,
            color: const Color(0xff101010),
            child: Center(
              child: TFF(
                controller: chat,
                onFieldSubmitted: (value) async {
                  sendMessage(value, null);
                },
                suffixIcon: Obx(
                  () => cc.isSend.value
                      ? IconButton(
                          onPressed: () async {
                            sendMessage(null, chat.text);
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            Utils.pageChange(
                                CameraScreen(
                                  chatroomId: chatroomId,
                                  userModel: widget.userModel,
                                ), onBackScreen: () async {
                              stream = await FBHelper()
                                  .getNewMsg(chatroomId.toString());
                              stream?.listen(
                                (event) {
                                  if (event.docs.isNotEmpty) {
                                    var v = event.docs
                                        .map(
                                            (e) => ChatModel.fromJson(e.data()))
                                        .last;
                                    print(v.message);
                                    cc.list?.value.removeWhere(
                                        (element) => element.time == v.time);
                                    cc.list?.value.add(v);
                                    cc.list?.value.sort(
                                        (a, b) => b.time!.compareTo(a.time!));
                                  }
                                },
                              );
                            });
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                ),
                onChanged: (value) {
                  cc.isSend.value = value.isNotEmpty;
                },
                hintText: 'Enter Message',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    FBHelper().removeNewMSgCol(chatroomId);
    super.dispose();
  }
}

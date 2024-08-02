import 'dart:ui';

import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/Utils/SizeUtils.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final UserModel userModel;

  const ChatScreen({super.key, required this.userModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatScreenController cc = Get.put(ChatScreenController());
  TextEditingController chat = TextEditingController();
  var senderId = FirebaseAuth.instance.currentUser?.uid;
  String? chatroomId;
  ScrollController scrollController = ScrollController();
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;

  @override
  void initState() {
    if (senderId?.compareTo(widget.userModel.uid!) == 1) {
      chatroomId = "$senderId-${widget.userModel.uid}";
    } else {
      chatroomId = "${widget.userModel.uid}-$senderId";
    }
    cc.messageList.putIfAbsent(widget.userModel.email.toString(), () => []);
    getMoreMessages();
    super.initState();
  }

  bool isLoading = false;

  void getMoreMessages() async {
    var data = await FBHelper().getMessages(chatroomId.toString());
    var msg = data.docs.map((e) => ChatModel.fromJson(e.data())).toList();
    cc.list?.value = cc.messageList[widget.userModel.email]!;
    for (var newMsg in msg) {
      if (!cc.list!.any((oldMsg) => oldMsg.time == newMsg.time)) {
        cc.list?.add(newMsg);
      }
    }
    scrollController.addListener(
      () async {
        if (scrollController.offset <=
                scrollController.position.minScrollExtent + 10 &&
            !isLoading) {
          isLoading = true;
          var data = await FBHelper().getMoreMessages(
              chatroomId.toString(), cc.list!.first.time.toString());
          var moreMsg =
              data.docs.map((e) => ChatModel.fromJson(e.data())).toList();
          for (var newMsg in moreMsg) {
            if (!cc.list!.any((oldMsg) => oldMsg.time == newMsg.time)) {
              cc.list?.insert(0, newMsg);
            }
          }
          cc.list?.sort((a, b) => a.time!.compareTo(b.time!));
          isLoading = false;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      },
    );
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
                image: const DecorationImage(
                  image: AssetImage('assets/chat bg.jpg'),

                  fit: BoxFit.cover,
                ),
              ),
              child: Obx(() {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: cc.list?.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var msg = cc.list?[index];
                    var isMyMsg = senderId == msg?.senderId;
                    return Row(
                      mainAxisAlignment: isMyMsg
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMyMsg)
                          CircleAvatar(
                            maxRadius: 10,
                            backgroundImage: widget.userModel.profilePic != null
                                ? NetworkImage(
                                    widget.userModel.profilePic.toString())
                                : null,
                          ),
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
                      ],
                    );
                  },
                );
              }),
            ),
          ),
          Container(
            height: 80,
            width: SizeUtils.width,
            color: Colors.blue,
            child: Center(
              child: TFF(
                controller: chat,
                onFieldSubmitted: (value) async {
                  var cu = FirebaseAuth.instance.currentUser;
                  var sn = await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(cu?.uid ?? "")
                      .get();
                  var userData =
                      UserModel.fromJson(sn.data() as Map<String, dynamic>);
                  if (value.isNotEmpty) {
                    FBHelper().sendMessage(
                      cu!.uid,
                      widget.userModel.uid ?? '',
                      cu.email ?? '',
                      widget.userModel.email ?? '',
                      value,
                      widget.userModel.fullname ?? '',
                      userData.fullname ?? '',
                      userData.profilePic ?? '',
                      widget.userModel.profilePic ?? '',
                    );

                    scrollController
                        .jumpTo(scrollController.position.maxScrollExtent);
                    chat.clear();
                  }
                },
                suffixIcon: Obx(
                  () => cc.isSend.value
                      ? IconButton(
                          onPressed: () async {
                            var cu = FirebaseAuth.instance.currentUser;
                            var sn = await FirebaseFirestore.instance
                                .collection("Users")
                                .doc(cu?.uid ?? "")
                                .get();
                            var userData = UserModel.fromJson(
                                sn.data() as Map<String, dynamic>);
                            if (chat.text.isNotEmpty) {
                              FBHelper().sendMessage(
                                cu!.uid,
                                widget.userModel.uid ?? '',
                                cu.email ?? '',
                                widget.userModel.email ?? '',
                                chat.text,
                                widget.userModel.fullname ?? '',
                                userData.fullname ?? '',
                                userData.profilePic ?? '',
                                widget.userModel.profilePic ?? '',
                              );
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent);
                              chat.clear();
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        )
                      : IconButton(
                          onPressed: () {},
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
}

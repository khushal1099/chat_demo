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

    getMessages();
    super.initState();
  }

  void getMessages() {
    stream = FBHelper().getMessages(chatroomId.toString());
    scrollController.addListener(
          () {
        if (scrollController.offset <=
            scrollController.position.minScrollExtent + 10) {
          stream = FirebaseFirestore.instance
              .collection(FBHelper.chats)
              .doc(chatroomId)
              .collection(FBHelper.messages)
              .where('time',isGreaterThan: widget.userModel.time)
              .snapshots();
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
                color: Colors.blue.withOpacity(0.2),
                child: StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    var data = snapshot.data?.docs ?? [];
                    var msgList = data
                        .map((item) => ChatModel.fromJson(item.data()))
                        .toList();

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: msgList.length,
                      itemBuilder: (context, index) {
                        var msg = msgList[index];
                        var isMyMsg = senderId == msg.senderId;
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                msg.message ?? '',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )),
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
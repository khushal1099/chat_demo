import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/Utils/SizeUtils.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
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

          cc.getMessages(chatroomId, cc.list!.first.time.toString());
          isLoading = false;
        }
      },
    );

    stream = await FBHelper().getNewMsg(chatroomId.toString());
    stream?.listen(
      (event) {
        if (event.docs.isNotEmpty) {
          var v = event.docs.map((e) => ChatModel.fromJson(e.data())).last;
          cc.list?.removeWhere((element) => element.time == v.time);
          cc.list?.add(v);
          cc.list?.sort((a, b) => b.time!.compareTo(a.time!));
        }
      },
    );
  }

  void sendMessage(var value, var message) async {
    String? v;
    if (value != null && message == null) {
      v = value;
    } else if (value == null && message != null) {
      v = message;
    } else {
      v = message;
    }

    var sn =
        await FirebaseFirestore.instance.collection("Users").doc(cu?.uid).get();
    var userData = UserModel.fromJson(sn.data() as Map<String, dynamic>);
    if (v != null) {
      String date = DateTime.now().toString();
      cc.list?.insert(
          0,
          ChatModel(
            message: v,
            senderEmail: userData.email ?? "",
            senderId: cu?.uid,
            time: date,
          ));

      var fMsg = await FBHelper().getMessages(chatroomId);
      var fMsgdata =
          fMsg.docs.map((e) => ChatModel.fromJson(e.data())).toList();

      FBHelper().sendMessage(
          cu?.uid ?? '',
          cu?.email ?? '',
          v,
          chatroomId,
          date,
          fMsgdata.first.message.toString(),
          widget.userModel.uid.toString());

      chat.clear();

      if (!cc.friendsIdList.contains(widget.userModel.uid)) {
        await FBHelper().addFriend(widget.userModel.uid.toString());
        cc.getfriendList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xff101010),
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            FBHelper().removeNewMSgCol(chatroomId);
            Get.back();
          },
          icon: const Icon(CupertinoIcons.back),
        ),
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
                // print(cc.list?.map(
                //   (element) => element.toJson(),
                // ));
                return ListView.builder(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                  itemCount: cc.list?.length,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var msg = cc.list?[index];
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
            color: const Color(0xff101010),
            child: Center(
              child: TFF(
                outSideTap: true,
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

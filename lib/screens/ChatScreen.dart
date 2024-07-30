import 'package:chat_demo/Utils/SizeUtils.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatScreenController chatScreenController = Get.put(ChatScreenController());
  TextEditingController chat = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              backgroundImage: chatScreenController.profilePic != null
                  ? NetworkImage(chatScreenController.profilePic.toString())
                  : null,
            ),
            const SizedBox(width: 10),
            Text(chatScreenController.fullname.toString()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            color: Colors.blue.withOpacity(0.2),
          )),
          Container(
            height: 80,
            width: SizeUtils.width,
            color: Colors.blue,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TFF(
                    controller: chat,
                    suffixIcon: Obx(
                      () => chatScreenController.isSend.value
                          ? IconButton(
                              onPressed: () {},
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
                      chatScreenController.isSend.value = value.isNotEmpty;
                    },
                    hintText: 'Enter Message',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

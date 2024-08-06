import 'dart:io';
import 'package:camera/camera.dart';
import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/Utils/AppAssets.dart';
import 'package:chat_demo/Utils/SizeUtils.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CameraScreen extends StatefulWidget {
  final String chatroomId;
  final UserModel userModel;

  const CameraScreen(
      {super.key, required this.chatroomId, required this.userModel});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  ChatScreenController cc = Get.put(ChatScreenController());

  void sendMessage() async {
    var cu = FirebaseAuth.instance.currentUser;
    if (cc.picture.value.isNotEmpty) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Chat_Image')
          .child('${widget.userModel.uid}');
      await storageRef.putFile(File(cc.picture.value));
      final imageUrl = await storageRef.getDownloadURL();
      String date = DateTime.now().toString();
      cc.list?.value.insert(
        0,
        ChatModel(
            message: imageUrl.toString(),
            senderEmail: cu?.email ?? "",
            senderId: cu?.uid,
            time: date,
            slug: "Image"),
      );
      cc.list?.refresh();

      await FBHelper().sendMessage(
        cu?.uid ?? '',
        cu?.email ?? '',
        imageUrl.toString(),
        widget.chatroomId,
        date,
        'Image',
      );

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
      resizeToAvoidBottomInset: false,
      body: Container(
        height: SizeUtils.height,
        width: SizeUtils.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppAssets.bg), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Obx(
              () => Container(
                color: Colors.transparent,
                child: cc.picture.value.isNotEmpty
                    ? Image.file(
                        File(cc.picture.value),
                        fit: BoxFit.cover,
                      )
                    : cc.cameraController != null &&
                            cc.cameraController!.value.isInitialized
                        ? Obx(() {
                            cc.loadCamera.value;
                            return CameraPreview(cc.cameraController!);
                          })
                        : const Center(child: CircularProgressIndicator()),
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  cc.picture.value;
                  if (cc.picture.value.isEmpty) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.photo,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            cc.captureImage();
                          },
                          child: SvgPicture.asset(AppAssets.union),
                        ),
                        IconButton(
                          onPressed: () {
                            cc.toggleCamera();
                          },
                          icon: const Icon(
                            Icons.cameraswitch_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            cc.picture.value = '';
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.back();
                            sendMessage();
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

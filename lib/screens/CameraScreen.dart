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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

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
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_image${DateTime.now()}.jpg';
      var compressedImage = await FlutterImageCompress.compressAndGetFile(
        cc.picture.value,
        targetPath,
        quality: 90,
        rotate: 0,
        format: CompressFormat.jpeg,
      );

      print('compressedImage=========> ${compressedImage?.path}');

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Chat_Image')
          .child(targetPath.replaceAll(dir.path, ''));
      await storageRef.putFile(File(compressedImage!.path));
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
    cc.picture.value = '';
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
                        ? Obx(
                            () {
                              cc.loadCamera.value;
                              return CameraPreview(cc.cameraController!);
                            },
                          )
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              cc.picture.value = '';
                            },
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.white),
                            ),
                            onPressed: () {
                              Get.back();
                              sendMessage();
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.send_rounded,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

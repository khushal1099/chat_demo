import 'dart:io';
import 'package:camera/camera.dart';
import 'package:chat_demo/Utils/AppAssets.dart';
import 'package:chat_demo/Utils/SizeUtils.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  ChatScreenController cc = Get.put(ChatScreenController());

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

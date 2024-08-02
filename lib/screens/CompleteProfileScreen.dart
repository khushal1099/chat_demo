import 'dart:io';
import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/controllers/CompleteProfileScreenController.dart';
import 'package:chat_demo/screens/HomePage.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    CompleteProfileScreenController completeProfileScreenController =
        CompleteProfileScreenController();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Obx(
                  () => CircleAvatar(
                    maxRadius: 70,
                    backgroundColor: Colors.pinkAccent.withOpacity(0.2),
                    backgroundImage: completeProfileScreenController
                            .image.value.isNotEmpty
                        ? FileImage(File(
                            completeProfileScreenController.image.toString()))
                        : null,
                    child: completeProfileScreenController
                                .image.value.isEmpty ||
                            completeProfileScreenController.image.value.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 80,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: IconButton(
                    onPressed: () {
                      completeProfileScreenController
                          .pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () {
                      completeProfileScreenController
                          .pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Enter FullName:-"),
              ),
            ),
            const SizedBox(height: 5),
            TFF(
              controller: name,
              hintText: 'Enter Your Full Name',
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: Colors.blue,
              onPressed: () async {
                try {
                  completeProfileScreenController.isLoading.value = true;
                  var cu = FirebaseAuth.instance.currentUser;
                  if (name.text.isNotEmpty) {
                    await FBHelper().completeUserProfile(
                      completeProfileScreenController.image.value,
                      name.text,
                      cu!.uid,
                      cu.email!,
                    );
                    name.clear();
                    completeProfileScreenController.image.value = '';
                    Get.offAll(const HomePage());
                  }
                } catch (e) {
                  print(e);
                } finally {
                  completeProfileScreenController.isLoading.value = false;
                }
              },
              child: Obx(
                () => completeProfileScreenController.isLoading.value
                    ? Transform.scale(
                        scaleX: 0.7,
                        scaleY: 0.7,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

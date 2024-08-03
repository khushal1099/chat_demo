import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:chat_demo/screens/SearchUserScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'LoginScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChatScreenController cc = ChatScreenController();

  @override
  Widget build(BuildContext context) {
    cc.getfriendList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(const LoginScreen());
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Obx(() {
        var list = cc.friendsList.value;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            var data = list[index];
            return ListTile(
              title: Text(data.fullname ?? ''),
              subtitle: Text(data.email ?? ''),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SearchUserScreen()));
          // Get.to(() => const SearchUserScreen());
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}

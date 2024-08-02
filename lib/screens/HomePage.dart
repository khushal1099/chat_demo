import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/models/ChatRoomModel.dart';
import 'package:chat_demo/screens/SearchUserScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'LoginScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection(FBHelper.chats).snapshots(),
        builder: (context, snapshot) {
          var data = snapshot.data?.docs;
          var chatUsers =
              data?.map((e) => ChatModel.fromJson(e.data())).toList();
          if (chatUsers != null) {
            return ListView.builder(
              itemCount: chatUsers.length,
              itemBuilder: (context, index) {
                var cUsers = chatUsers[index];
                return const Text('-');
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const SearchUserScreen());
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

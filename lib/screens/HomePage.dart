import 'package:chat_demo/Utils/Utils.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/screens/CartPage.dart';
import 'package:chat_demo/screens/ChatScreen.dart';
import 'package:chat_demo/screens/SearchUserScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'LoginScreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ChatScreenController cc = Get.put(ChatScreenController());
    cc.getfriendList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        actions: [
          Row(
            children: [
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
              IconButton(
                onPressed: () {
                  Utils.pageChange(const CartPage());
                },
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(
        () {
          return ListView.builder(
            itemCount: cc.friendsList.length,
            itemBuilder: (context, index) {
              var data = cc.friendsList[index];
              return ListTile(
                onTap: () {
                  Utils.pageChange(ChatScreen(userModel: data));
                },
                title: Text(data.fullname ?? ''),
                subtitle: Text(data.email ?? ''),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Utils.pageChange(const SearchUserScreen());
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

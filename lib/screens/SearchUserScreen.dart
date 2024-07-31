import 'package:chat_demo/controllers/SearchUserScreenController.dart';
import 'package:chat_demo/models/UserModel.dart';
import 'package:chat_demo/screens/ChatScreen.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../Firebase/FirebaseHelper.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  TextEditingController search = TextEditingController();
  SearchUserScreenController searchUserScreenController =
      SearchUserScreenController();

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser?.email);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => TFF(
                controller: search,
                icon: const Icon(CupertinoIcons.search),
                hintText: 'Search User',
                onChanged: (value) {
                  searchUserScreenController.isSuffix.value = value.isNotEmpty;
                  searchUserScreenController.stream.value =
                      FBHelper().getSearchedUser(value);
                },
                suffixIcon: searchUserScreenController.isSuffix.value
                    ? IconButton(
                        onPressed: () {
                          search.clear();
                          searchUserScreenController.isSuffix.value = false;
                          searchUserScreenController.stream.value = FBHelper()
                              .getUserList(
                                  FirebaseAuth.instance.currentUser!.email!);
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Obx(
                  () => StreamBuilder(
                    stream: searchUserScreenController.stream.value,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data as QuerySnapshot;
                        var sData = data.docs
                            .map((item) => UserModel.fromJson(
                                item.data() as Map<String, dynamic>))
                            .toList();
                        return ListView.builder(
                          itemCount: sData.length,
                          itemBuilder: (context, index) {
                            if (sData.isNotEmpty) {
                              var user = sData[index];
                              return ListTile(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return ChatScreen(userModel: user);
                                    },
                                  ));
                                },
                                title: Text(user.fullname ?? ''),
                                subtitle: Text(user.email ?? ''),
                              );
                            } else {
                              return const Center(
                                  child: Text("No result found!"));
                            }
                          },
                        );
                      } else {
                        return StreamBuilder(
                          stream: FBHelper().getUserList(
                              FirebaseAuth.instance.currentUser!.email!),
                          builder: (context, snapshot) {
                            var allData = snapshot.data?.docs ?? [];
                            var uData = allData.map((item) {
                              return UserModel.fromJson(item.data());
                            }).toList();

                            return ListView.builder(
                              itemCount: uData.length,
                              itemBuilder: (BuildContext context, int index) {
                                var d = uData[index];
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ChatScreen(userModel: d);
                                      },
                                    ));
                                  },
                                  title: Text(d.fullname.toString()),
                                  subtitle: Text(d.email.toString()),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

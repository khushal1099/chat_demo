import 'package:chat_demo/Api/ApiProvider.dart';
import 'package:chat_demo/controllers/ChatScreenController.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  ChatScreenController cc = Get.put(ChatScreenController());
  TextEditingController title = TextEditingController();
  TextEditingController category = TextEditingController();

  @override
  void initState() {
    super.initState();
    ApiProvider.getProducts(
      (list) {
        cc.productList.value = list ?? [];
        cc.productList.refresh();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Products'),
        centerTitle: true,
      ),
      body: Obx(
        () {
          if ((cc.productList.value ?? []).isEmpty) {
            return const SizedBox();
          }
          return ListView.builder(
            itemCount: cc.productList.value?.length,
            primary: true,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var data = cc.productList.value?[index];
              return ListTile(
                title: Text(data?.title ?? ''),
                subtitle: Text(data!.category.toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            title.text = data.title ?? '';
                            return AlertDialog(
                              title: const Center(child: Text('Edit Title')),
                              content: TFF(
                                controller: title,
                                hintText: 'Edit Title',
                              ),
                              actions: [
                                Center(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          WidgetStateProperty.all(Colors.blue),
                                    ),
                                    onPressed: () {
                                      ApiProvider.editProducts((list) {
                                        cc.productList.value?[index] = list;
                                        cc.productList.refresh();
                                      }, data.id.toString(), title.text);
                                      title.clear();
                                      Get.back();
                                    },
                                    child: const Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        ApiProvider.deleteProducts((list) {
                          cc.productList.value
                              ?.removeWhere((e) => e.id == list.id);
                          cc.productList.refresh();
                        }, data.id.toString());
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Center(child: Text('Add Product')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TFF(
                      controller: title,
                      hintText: 'Add Title',
                    ),
                    const SizedBox(height: 10),
                    TFF(
                      controller: category,
                      hintText: 'Add Category',
                    ),
                  ],
                ),
                actions: [
                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                      ),
                      onPressed: () {
                        ApiProvider.addProducts((list) {
                          cc.productList.value?.insert(0, list);
                          cc.productList.refresh();
                        }, title.text, category.text);
                        title.clear();
                        category.clear();
                        Get.back();
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

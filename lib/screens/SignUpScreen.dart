import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/controllers/AuthenticationController.dart';
import 'package:chat_demo/screens/CompleteProfileScreen.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();
  AuthenticationController controller = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Chat App',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TFF(
                    controller: email,
                    hintText: 'Enter Your Email',
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {},
                    icon: const Icon(Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (!value!.contains('@')) {
                        return 'Enter Valid Email';
                      } else if (value!.isEmpty) {
                        return 'Please Enter Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TFF(
                    controller: password,
                    hintText: 'Enter Your Password',
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {},
                    icon: const Icon(Icons.lock),
                    validator: (value) {
                      if (value!.length < 4) {
                        return 'Enter Password must be 4 character';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TFF(
                    controller: confirmPassword,
                    hintText: 'Confirm Your Password',
                    onFieldSubmitted: (value) {},
                    onChanged: (value) {},
                    icon: const Icon(Icons.lock),
                    validator: (value) {
                      if (value!.length < 4) {
                        return 'Enter Password must be 4 character';
                      } else if (password.text != confirmPassword.text) {
                        return 'Don\'t match confirm password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => CupertinoButton(
                      color: Colors.blue,
                      onPressed: () async {
                        try {
                          controller.isLoading.value = true;
                          if (formKey.currentState!.validate()) {
                            await FBHelper()
                                .signUpUser(email.text, password.text);
                            Get.offAll(const CompleteProfileScreen());
                            email.clear();
                            password.clear();
                            confirmPassword.clear();
                          }
                        } on FirebaseAuthException catch (e) {
                          print('error-------${e.message}');
                          print(e.code);
                        } finally {
                          controller.isLoading.value = false;
                        }
                      },
                      child: controller.isLoading.value
                          ? Transform.scale(
                              scaleX: 0.7,
                              scaleY: 0.7,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SignUp',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Already have an account?',
              style: TextStyle(fontSize: 15)),
          CupertinoButton(
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.blue, fontSize: 15),
            ),
            onPressed: () {
              Get.to(() => const LoginScreen());
            },
          )
        ],
      ),
    );
  }
}

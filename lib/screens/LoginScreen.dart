import 'package:chat_demo/Firebase/FirebaseHelper.dart';
import 'package:chat_demo/screens/HomePage.dart';
import 'package:chat_demo/screens/SignUpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/AuthenticationController.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
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
                      } else if (value.isEmpty) {
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
                  const SizedBox(height: 20),
                  CupertinoButton(
                    color: Colors.blue,
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          controller.isLoading.value = true;
                          await FBHelper().loginUser(email.text, password.text);
                          Get.offAll(const HomePage());
                          email.clear();
                          password.clear();
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            print('No user found for that email.');
                          } else if (e.code == 'wrong-password') {
                            print('Wrong password provided for that user.');
                          } else {
                            print('Error: ${e.message}');
                          }
                        } catch (e) {
                          print('General error: $e');
                        } finally {
                          controller.isLoading.value = false;
                        }
                      }
                    },
                    child: Obx(
                      () => controller.isLoading.value
                          ? Transform.scale(
                              scaleX: 0.7,
                              scaleY: 0.7,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text('Login'),
                    ),
                  )
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
          const Text('Don\'t have an account?', style: TextStyle(fontSize: 15)),
          CupertinoButton(
            child: const Text(
              'Sign Up',
              style: TextStyle(color: Colors.blue, fontSize: 15),
            ),
            onPressed: () {
              Get.to(() => const SignUpScreen());
            },
          )
        ],
      ),
    );
  }
}

class TFF extends StatelessWidget {
  String? hintText;
  Icon? icon;
  ValueChanged<String>? onChanged;
  ValueChanged<String>? onFieldSubmitted;
  TextEditingController? controller = TextEditingController();
  bool obsecureText;
  FormFieldValidator<String>? validator;
  TextInputType? keyboardType;
  Widget? suffixIcon;
  TextStyle? hintStyle;
  TextStyle? style;
  Color? cursorColor;
  bool outSideTap;

  TFF({
    super.key,
    this.hintText,
    this.icon,
    this.onChanged,
    this.onFieldSubmitted,
    this.controller,
    this.obsecureText = false,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.hintStyle,
    this.style,
    this.cursorColor,
    this.outSideTap = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        onTapOutside: (event) {
          if (outSideTap) {
            FocusScope.of(context).unfocus();
          }
        },
        style: style,
        textInputAction: TextInputAction.next,
        keyboardType: keyboardType,
        obscureText: obsecureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.1),
          prefixIcon: icon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.all(12),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        cursorColor: cursorColor,
        validator: validator,
        autofocus: true,
      ),
    );
  }
}

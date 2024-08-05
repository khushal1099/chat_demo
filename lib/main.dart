import 'package:chat_demo/Utils/SizeUtils.dart';
import 'package:chat_demo/firebase_options.dart';
import 'package:chat_demo/screens/HomePage.dart';
import 'package:chat_demo/screens/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeUtils.config(context);
    var cu = FirebaseAuth.instance.currentUser;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      home: cu != null ? const HomePage() : const LoginScreen(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:petverse/frontend/login.dart';

// Import Login Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetVerse',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFE58A),
      ),
      home: const LoginPage(), // Loads the Login Page
    );
  }
}

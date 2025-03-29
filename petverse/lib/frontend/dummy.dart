import 'package:flutter/material.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to PetVerse"),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text("You are now logged in! 🎉"),
      ),
    );
  }
}

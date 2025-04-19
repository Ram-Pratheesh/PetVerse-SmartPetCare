import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petverse/frontend/chatscreen.dart';

class MyChatsPage extends StatefulWidget {
  const MyChatsPage({super.key});

  @override
  State<MyChatsPage> createState() => _MyChatsPageState();
}

class _MyChatsPageState extends State<MyChatsPage> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Chats",
          style: TextStyle(
            fontFamily: 'Rubik Bubbles',
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFCC00),
      ),
      backgroundColor: const Color(0xFFFFE58A),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chatsMetadata')
            .where('participants', arrayContains: currentUserId)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                "No chats yet.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final data = chats[index];
              final chatId = data.id;
              final participants = List<String>.from(data['participants']);
              final otherUserId =
                  participants.firstWhere((id) => id != currentUserId);

              return ListTile(
                leading:
                    const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                title: Text(
                  "Chat with $otherUserId",
                  style: const TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  data['lastMessage'] ?? '',
                  style: const TextStyle(color: Colors.black87),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chatId,
                        petOwnerId: otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

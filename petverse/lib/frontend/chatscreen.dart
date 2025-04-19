import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String petOwnerId;

  const ChatScreen({super.key, required this.chatId, required this.petOwnerId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  String? currentUserId;
  bool isSelfChat = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId == widget.petOwnerId) {
      setState(() {
        isSelfChat = true;
      });

      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ You cannot chat with yourself."),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pop(context);
      });
    } else {
      setState(() {
        currentUserId = userId;
      });
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || currentUserId == null) return;

    final text = messageController.text.trim();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': currentUserId,
      'timestamp': Timestamp.now(),
    });

    await FirebaseFirestore.instance
        .collection('chatsMetadata')
        .doc(widget.chatId)
        .set({
      'participants': [currentUserId, widget.petOwnerId],
      'lastMessage': text,
      'lastTimestamp': Timestamp.now(),
    }, SetOptions(merge: true));

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE58A),
      appBar: AppBar(
        title: Text("Chat with Owner",
            style: GoogleFonts.rubikBubbles(color: Colors.black)),
        backgroundColor: const Color(0xFFFFCC00),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: isSelfChat
          ? const SizedBox()
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(widget.chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg =
                              messages[index].data() as Map<String, dynamic>;
                          final isMe = msg['senderId'] == currentUserId;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.orange[300]
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(msg['text'] ?? ''),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: "Type your message...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: sendMessage,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent),
                        child: const Icon(Icons.send, color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/frontend/chatscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailsScreen({super.key, required this.pet});

  Future<void> navigateToChat(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserId = prefs.getString('userId');
    String petOwnerId = pet['reportedBy'] ?? '';

    if (currentUserId == null || petOwnerId.isEmpty) return;

    if (currentUserId == petOwnerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ You cannot chat with yourself."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String chatId = currentUserId.compareTo(petOwnerId) < 0
        ? '${currentUserId}_$petOwnerId'
        : '${petOwnerId}_$currentUserId';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          petOwnerId: petOwnerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE58A),
      appBar: AppBar(
        title: Text("Pet Details",
            style: GoogleFonts.rubikBubbles(fontSize: 24, color: Colors.black)),
        backgroundColor: const Color(0xFFFFCC00),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pet['imageUrl'] != null && pet['imageUrl'].isNotEmpty)
              Image.network(
                pet['imageUrl'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  detailRow("Pet Name", pet['petName']),
                  detailRow("Type", pet['petType']),
                  detailRow("Breed", pet['breed']),
                  detailRow("Color", pet['color']),
                  detailRow("Date Lost", pet['dateLost']),
                  detailRow(
                      "Location",
                      pet['location'] != null
                          ? "Lat: ${pet['location']['lat']}, Lng: ${pet['location']['lng']}"
                          : "Not provided"),
                  detailRow("Identification Mark", pet['identificationMark']),
                  detailRow("Contact Info", pet['contactInfo']),
                  detailRow("Description", pet['description']),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Chat with Owner"),
                      onPressed: () => navigateToChat(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? "Not provided")),
        ],
      ),
    );
  }
}

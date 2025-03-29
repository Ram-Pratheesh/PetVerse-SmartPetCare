import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

import 'package:petverse/frontend/petdetailsscreen.dart';
import 'package:petverse/frontend/reportlostpet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class LostFoundDashboard extends StatefulWidget {
  const LostFoundDashboard({super.key});

  @override
  _LostFoundDashboardState createState() => _LostFoundDashboardState();
}

class _LostFoundDashboardState extends State<LostFoundDashboard> {
  List<dynamic> lostPets = [];
  List<DocumentSnapshot> userPets = [];
  bool isLoading = true;
  Position? userPosition;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    getUserIdAndLocation();
  }

  Future<void> getUserIdAndLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId');
    await getUserLocation();
  }

  Future<void> getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        userPosition = position;
      });

      fetchLostPetsFromFirestore();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> fetchLostPetsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('lostPets')
          .where('status', isEqualTo: 'lost')
          .where('isResolved', isEqualTo: false)
          .get();

      final List<dynamic> filteredPets = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final location = data['location'];
            if (location == null || userPosition == null) return false;

            final petLat = location['lat'];
            final petLng = location['lng'];
            final distance = calculateDistance(
              userPosition!.latitude,
              userPosition!.longitude,
              petLat,
              petLng,
            );

            return distance <= 10.0;
          })
          .map((doc) => doc.data())
          .toList();

      userPets = snapshot.docs
          .where((doc) => doc['reportedBy'] == currentUserId)
          .toList();

      setState(() {
        lostPets = filteredPets;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching pets from Firestore: $e");
    }
  }

  Future<void> markPetAsFound(DocumentSnapshot petDoc) async {
    try {
      await FirebaseFirestore.instance
          .collection('lostPets')
          .doc(petDoc.id)
          .update({'isResolved': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("✅ Pet marked as found and removed from list.")),
      );

      fetchLostPetsFromFirestore();
    } catch (e) {
      print("Error updating pet status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE58A),
      appBar: AppBar(
        title: Text("Lost & Found",
            style: GoogleFonts.rubikBubbles(color: Colors.black, fontSize: 24)),
        backgroundColor: const Color(0xFFFFCC00),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          "Report Lost Pet",
                          Icons.pets,
                          Colors.red,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ReportLostPetScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          "My Lost Pets",
                          Icons.assignment_ind,
                          Colors.blue,
                          () => _showMyLostPetsDialog(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: lostPets.isEmpty
                      ? const Center(
                          child: Text("No lost pets found nearby 🐶❌"))
                      : ListView.builder(
                          itemCount: lostPets.length,
                          itemBuilder: (context, index) =>
                              _buildLostPetCard(lostPets[index]),
                        ),
                ),
              ],
            ),
    );
  }

  void _showMyLostPetsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: userPets.isEmpty
            ? [const Text("You haven't reported any lost pets.")]
            : userPets.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        data["imageUrl"] != null && data["imageUrl"].isNotEmpty
                            ? NetworkImage(data["imageUrl"])
                            : const AssetImage("assets/default_pet.png")
                                as ImageProvider,
                  ),
                  title: Text(data["petName"] ?? "Unknown"),
                  subtitle: Text("Lost on: ${data["dateLost"]}"),
                  trailing: ElevatedButton(
                    onPressed: () => markPetAsFound(doc),
                    child: const Text("Mark Found"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildLostPetCard(dynamic pet) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: pet["imageUrl"] != null && pet["imageUrl"].isNotEmpty
              ? NetworkImage(pet["imageUrl"])
              : const AssetImage("assets/default_pet.png") as ImageProvider,
          radius: 30,
        ),
        title: Text(pet["petName"] ?? "Unknown",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            "Last seen: ${pet["location"] != null ? "(${pet["location"]["lat"]}, ${pet["location"]["lng"]})" : "Location not provided"}\n"
            "Lost on: ${pet["dateLost"] ?? "Unknown date"}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetDetailsScreen(pet: pet),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:petverse/frontend/lostandfound1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class ReportLostPetScreen extends StatefulWidget {
  const ReportLostPetScreen({super.key});

  @override
  _ReportLostPetScreenState createState() => _ReportLostPetScreenState();
}

class _ReportLostPetScreenState extends State<ReportLostPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController dateLostController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController identificationMarkController =
      TextEditingController();

  String? selectedPetType;
  String? selectedBreed;
  File? _image;
  final picker = ImagePicker();

  final Map<String, List<String>> petBreeds = {
    'Dog': ['Labrador', 'Golden Retriever', 'Pug', 'Bulldog'],
    'Cat': ['Persian', 'Siamese', 'Bengal', 'Sphynx'],
    'Bird': ['Parrot', 'Canary', 'Cockatoo', 'Macaw'],
  };

  LatLng? pickedLocation;
  GoogleMapController? _mapController;
  final geo = GeoFlutterFire();

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dateLostController.text = pickedDate.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    final cloudName = 'dclwdshhz';
    final uploadPreset = 'ml_default';

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['cloud_name'] = cloudName
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonResp = json.decode(respStr);
      return jsonResp['secure_url'];
    } else {
      print("❌ Cloudinary Upload Error [\${response.statusCode}]: \$respStr");
      throw Exception('Cloudinary upload failed: \$respStr');
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate() ||
        _image == null ||
        pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please fill all fields, pick a location, and upload an image!")),
      );
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      GeoFirePoint geoPoint = geo.point(
          latitude: pickedLocation!.latitude,
          longitude: pickedLocation!.longitude);

      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "location": {
          "lat": geoPoint.latitude,
          "lng": geoPoint.longitude,
          "geohash": geoPoint.hash
        },
        "fcmToken": fcmToken,
      }, SetOptions(merge: true));

      String imageUrl = await uploadToCloudinary(_image!);

      final petData = {
        "petType": selectedPetType,
        "petName": petNameController.text,
        "breed": selectedBreed,
        "description": descriptionController.text,
        "color": colorController.text,
        "dateLost": dateLostController.text,
        "contactInfo": contactInfoController.text,
        "identificationMark": identificationMarkController.text,
        "imageUrl": imageUrl,
        "location": {
          "lat": pickedLocation!.latitude,
          "lng": pickedLocation!.longitude,
        },
        "status": "lost",
        "isResolved": false,
        "createdAt": Timestamp.now(),
        "reportedBy": userId,
      };

      await FirebaseFirestore.instance.collection("lostPets").add(petData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("📢 Nearby users would have received a notification."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LostFoundDashboard()),
      );

      _formKey.currentState!.reset();
      setState(() {
        _image = null;
        selectedPetType = null;
        selectedBreed = null;
        pickedLocation = null;
      });
    } catch (e) {
      print("Error: \$e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: \$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Lost Pet",
            style: GoogleFonts.rubikBubbles(fontSize: 22, color: Colors.black)),
        backgroundColor: const Color(0xFFFFCC00),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFFFE58A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                    "Pet Type", petBreeds.keys.toList(), selectedPetType,
                    (value) {
                  setState(() {
                    selectedPetType = value;
                    selectedBreed = null;
                  });
                }),
                if (selectedPetType != null)
                  _buildDropdown(
                      "Breed", petBreeds[selectedPetType] ?? [], selectedBreed,
                      (value) {
                    setState(() {
                      selectedBreed = value;
                    });
                  }),
                _buildTextField("Pet Name", petNameController),
                _buildTextField("Description", descriptionController,
                    maxLines: 3),
                _buildTextField("Color", colorController),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                      child: _buildTextField("Date Lost", dateLostController)),
                ),
                _buildTextField("Contact Info", contactInfoController),
                _buildTextField(
                    "Identification Mark", identificationMarkController),
                const SizedBox(height: 10),
                const Text("Mark Lost Location on Map",
                    style: TextStyle(fontSize: 16)),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(13.0827, 80.2707),
                      zoom: 14,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    onTap: (LatLng position) =>
                        setState(() => pickedLocation = position),
                    markers: pickedLocation != null
                        ? {
                            Marker(
                              markerId: const MarkerId("picked-location"),
                              position: pickedLocation!,
                            )
                          }
                        : {},
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Upload Pet Image", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                _image == null
                    ? const Text("No image selected.",
                        style: TextStyle(color: Colors.grey))
                    : Image.file(_image!, height: 150),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent),
                  child: const Text("Pick Image"),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Submit Report",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        hint: Text("Select $label"),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select a $label" : null,
      ),
    );
  }
}

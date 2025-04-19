import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/frontend/clinicdetails.dart';

class PetClinicScreen extends StatefulWidget {
  const PetClinicScreen({super.key});

  @override
  _PetClinicScreenState createState() => _PetClinicScreenState();
}

class _PetClinicScreenState extends State<PetClinicScreen> {
  GoogleMapController? mapController;
  LatLng? userLocation;
  LatLng? selectedLocation;
  Set<Marker> markers = {};
  List<Map<String, dynamic>> clinics = [];
  bool isLoading = false;
  bool hasError = false;
  bool isMapVisible = true;
  String selectedSortOption = "rating"; // Default sorting by rating

  String apiKey = "";
  String locationTitle = "Select Your Location";
  double selectedRating = 0.0;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    setState(() => isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError("Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError("Location permissions permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        userLocation = newLocation;
        selectedLocation = newLocation;
        _updateMarker(newLocation);
        isLoading = false;
      });
    } catch (e) {
      _showError("Failed to get location: $e");
    }
  }

  void _showError(String message) {
    setState(() {
      hasError = true;
      isLoading = false;
    });
    print("❌ Error: $message");
  }

  void _updateMarker(LatLng newLocation) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId("selected"),
          position: newLocation,
          infoWindow: const InfoWindow(title: "Selected Location"),
          draggable: true,
          onDragEnd: (newPos) {
            selectedLocation = newPos;
          },
        ),
      );
    });
  }

  void _confirmLocation() {
    if (selectedLocation == null) return;
    setState(() {
      userLocation = selectedLocation;
      locationTitle = "Pet Clinic";
      isMapVisible = false;
    });
    _fetchNearbyClinics();
  }

  Future<void> _fetchNearbyClinics() async {
    try {
      // Replace with your Google Places API key
      const String apiKey = "";
      String url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${userLocation!.latitude},${userLocation!.longitude}&radius=5000&type=veterinary_care&key=$apiKey";

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        setState(() {
          clinics = data["results"].map<Map<String, dynamic>>((clinic) {
            return {
              "name": clinic["name"],
              "address": clinic["vicinity"],
              "rating": clinic["rating"]?.toString() ?? "N/A",
              "placeId":
                  clinic["place_id"], // Store place ID for further details
              "photoReference": clinic["photos"] != null
                  ? clinic["photos"][0]["photo_reference"]
                  : null,
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching clinics: $e");
    }
  }

  void _sortClinics() {
    if (selectedSortOption == "rating") {
      clinics.sort((a, b) {
        double ratingA = double.tryParse(a["rating"] ?? "0") ?? 0;
        double ratingB = double.tryParse(b["rating"] ?? "0") ?? 0;
        return ratingB.compareTo(ratingA); // Highest to lowest
      });
    } else if (selectedSortOption == "distance") {
      clinics.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          a["lat"],
          a["lng"],
        );
        double distanceB = Geolocator.distanceBetween(
          userLocation!.latitude,
          userLocation!.longitude,
          b["lat"],
          b["lng"],
        );
        return distanceA.compareTo(distanceB); // Nearest to farthest
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locationTitle,
          style: GoogleFonts.rubikBubbles(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFFCC00),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFFFE58A),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? _errorScreen()
                : isMapVisible
                    ? _buildMapScreen()
                    : _buildClinicList(),
      ),
    );
  }

  Widget _buildMapScreen() {
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLocation ?? const LatLng(0, 0),
              zoom: 15,
            ),
            markers: markers,
            onMapCreated: (controller) {
              setState(() => mapController = controller);
            },
            onTap: (newLocation) {
              setState(() {
                selectedLocation = newLocation;
                _updateMarker(newLocation);
              });
            },
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: _confirmLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0088CC),
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Confirm Location",
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildClinicList() {
    return Column(
      children: [
        Expanded(
          child: clinics.isEmpty
              ? const Center(child: Text("No clinics found nearby."))
              : ListView.builder(
                  itemCount: clinics.length,
                  itemBuilder: (context, index) {
                    var clinic = clinics[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ClinicDetailsScreen(clinic: clinic),
                          ),
                        );
                      },
                      child: ClinicCard(clinic: clinic),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _errorScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 40),
          SizedBox(height: 10),
          Text("Failed to load location."),
        ],
      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final Map<String, dynamic> clinic;
  const ClinicCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        title: Text(clinic["name"],
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(clinic["address"]),
        trailing: Text("⭐ ${clinic["rating"]}"),
      ),
    );
  }
}

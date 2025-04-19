import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher package
import 'dart:convert';

class ClinicDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? clinic;

  const ClinicDetailsScreen({super.key, required this.clinic});

  @override
  _ClinicDetailsScreenState createState() => _ClinicDetailsScreenState();
}

class _ClinicDetailsScreenState extends State<ClinicDetailsScreen> {
  String? phoneNumber;
  String? openingHours;
  List<Map<String, String>> reviews = [];
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();

    if (widget.clinic?["place_id"] != null) {
      fetchAdditionalDetails(widget.clinic?["place_id"]);
    }

    // If latitude & longitude are missing, fetch from address
    if (latitude == null || longitude == null) {
      String? clinicAddress = widget.clinic?["address"];
      if (clinicAddress != null && clinicAddress.isNotEmpty) {
        getCoordinatesFromAddress(clinicAddress);
      }
    }
  }

  Future<void> fetchAdditionalDetails(String placeId) async {
    const String apiKey =
        ""; // Replace with your API key
    final String detailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number,opening_hours,reviews&key=$apiKey";

    final response = await http.get(Uri.parse(detailsUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data["result"];

      setState(() {
        phoneNumber = result["formatted_phone_number"];
        openingHours = result["opening_hours"]?["weekday_text"]?.join("\n");

        if (result["reviews"] != null) {
          reviews = List<Map<String, String>>.from(result["reviews"].map(
            (review) => {
              "author": review["author_name"],
              "text": review["text"],
              "rating": review["rating"].toString(),
            },
          ));
        }
      });
    }
  }

  // Fetch latitude & longitude from address if missing
  Future<void> getCoordinatesFromAddress(String address) async {
    const String apiKey =
        ""; // Replace with your API key
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["results"].isNotEmpty) {
        final location = data["results"][0]["geometry"]["location"];
        setState(() {
          latitude = location["lat"];
          longitude = location["lng"];
        });
      }
    }
  }

  void _openGoogleMaps(double lat, double lng) async {
    final Uri mapsUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng");

    if (await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clinic == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Clinic Details"),
          backgroundColor: const Color(0xFFFFCC00),
        ),
        body: const Center(
          child: Text("Clinic details not available."),
        ),
      );
    }

    String clinicName = (widget.clinic?["name"] ?? "Unknown Clinic").toString();
    String clinicAddress =
        (widget.clinic?["address"] ?? "Address not available").toString();
    double clinicRating =
        double.tryParse(widget.clinic?["rating"]?.toString() ?? "0.0") ?? 0.0;
    String? photoReference = widget.clinic?["photoReference"] as String?;

    if (widget.clinic?["geometry"]?["location"] != null) {
      latitude = double.tryParse(
          widget.clinic?["geometry"]?["location"]?["lat"]?.toString() ?? "0.0");
      longitude = double.tryParse(
          widget.clinic?["geometry"]?["location"]?["lng"]?.toString() ?? "0.0");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detailed Information",
          style: GoogleFonts.rubikBubbles(
            fontSize:
                MediaQuery.of(context).size.width * 0.05, // Adjustable size
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFCC00),
        toolbarHeight:
            MediaQuery.of(context).size.height * 0.08, // Adjustable height
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clinicName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text("📍 $clinicAddress"),
              const SizedBox(height: 10),
              Text(
                  "Rating: ${clinicRating > 0.0 ? clinicRating.toString() : "N/A"} ⭐"),
              const SizedBox(height: 10),
              if (phoneNumber != null) ...[
                const SizedBox(height: 10),
                Text("📞 Contact: $phoneNumber"),
              ],
              if (openingHours != null) ...[
                const SizedBox(height: 10),
                Text("🕒 Open Hours:\n$openingHours"),
              ],
              const SizedBox(height: 10),
              if (photoReference != null && photoReference.isNotEmpty)
                Image.network(
                  "https://maps.googleapis.com/maps/api/place/photo"
                  "?maxwidth=400&photoreference=$photoReference"
                  "&key=", // Replace with your API key
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              else
                Image.asset(
                  "assets/images/no_image_available.png",
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),

              // "Get Directions" Button
              if (latitude != null && longitude != null) ...[
                ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(latitude!, longitude!),
                  icon: const Icon(Icons.directions),
                  label: const Text("Get Directions"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 10),

                // Prevent overflow by wrapping GoogleMap inside a fixed height container
                SizedBox(
                  height: 300, // Fixed height to avoid overflow
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(latitude!, longitude!),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("clinic"),
                        position: LatLng(latitude!, longitude!),
                        infoWindow: InfoWindow(title: clinicName),
                      ),
                    },
                  ),
                ),
              ] else if (clinicAddress.isNotEmpty) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    final Uri mapsUrl = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(clinicAddress)}");
                    launchUrl(mapsUrl);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text("Get Directions"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

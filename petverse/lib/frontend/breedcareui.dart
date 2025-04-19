// lib/screens/breed_care_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/frontend/breedcare.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BreedCareScreen(),
  ));
}

class BreedCareScreen extends StatefulWidget {
  const BreedCareScreen({super.key});

  @override
  State<BreedCareScreen> createState() => _BreedCareScreenState();
}

class _BreedCareScreenState extends State<BreedCareScreen> {
  final BreedCareModel _model = BreedCareModel();
  String? _selectedBreed;
  Map<String, String>? _tips;
  bool _loading = false;
  bool _modelReady = false;
  List<String> _breedOptions = [];

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  void _initModel() async {
    await _model.loadModel();
    setState(() {
      _breedOptions = _model.breedVectors.keys.toList();
      _modelReady = true;
    });
  }

  void _getTips() async {
    if (_selectedBreed == null) return;
    setState(() => _loading = true);
    final tips = await _model.predict(_selectedBreed!);
    setState(() {
      _tips = tips;
      _loading = false;
    });
  }

  Widget _buildTipCard(String title, String content, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE58A),
      appBar: AppBar(
        title: Text(
          "Breed Care Tips",
          style: GoogleFonts.rubikBubbles(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFFFCC00),
        elevation: 1,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedBreed,
              items: _breedOptions.map((breed) {
                return DropdownMenuItem(
                  value: breed,
                  child:
                      Text(breed, style: const TextStyle(color: Colors.black)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedBreed = value),
              decoration: const InputDecoration(
                labelText: 'Select Breed',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              dropdownColor: Color(0xFFFFE58A),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _modelReady ? _getTips : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFCC00),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Get Tips',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_tips != null)
            Expanded(
              child: ListView(
                children: [
                  _buildTipCard(
                      'Health Tip', _tips!['Health']!, Icons.local_hospital),
                  _buildTipCard('Grooming Tip', _tips!['Grooming']!, Icons.cut),
                  _buildTipCard(
                      'Feeding Tip', _tips!['Feeding']!, Icons.restaurant),
                  _buildTipCard(
                      'Reminder Tip', _tips!['Reminder']!, Icons.alarm),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

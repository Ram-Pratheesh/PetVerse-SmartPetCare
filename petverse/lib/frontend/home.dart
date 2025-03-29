import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/frontend/lostandfound1.dart';
import 'package:petverse/frontend/petclinic.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(username: "User"), // Pass default username
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen(
      {super.key, required this.username}); // Receive username dynamically

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE58A), // Background color
      drawer: Drawer(
        child: Center(child: Text("Sidebar Content (To be added)")),
      ),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFE58A),
        elevation: 0, // Removes shadow to blend with background
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.grid_view, size: 30), // Grid View Icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // ✅ Now works properly
            },
          ),
        ),
        title: Text(
          "Home",
          style: GoogleFonts.rubikBubbles(fontSize: 25),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30), // Increased size
            onPressed: () {
              // Add Profile Navigation if needed
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi $username!",
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),

              // Welcome Box
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome!",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Let us know your pet’s info\nfor more personalized experience",
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Color.fromARGB(255, 19, 19, 19),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFCC00),
                        foregroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DummyPage("Pet Info"),
                          ),
                        );
                      },
                      child: Text(
                        "Fill details",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Lost & Found Section
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LostFoundDashboard(),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "assets/lostandfound.png",
                              width: 45,
                              height: 45,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Pets Lost and Found",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.search, size: 30),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Featured Categories
              Text(
                "Featured categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // GridView inside SizedBox to prevent overflow
              SizedBox(
                height: 400, // Set an appropriate height for the grid
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  shrinkWrap: true, // Makes GridView take only necessary space
                  physics:
                      NeverScrollableScrollPhysics(), // Prevents nested scrolling
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetClinicScreen(),
                          ),
                        );
                      },
                      child: _buildCategoryCard(
                        context,
                        "Pet Clinic",
                        "assets/petclinic.png",
                        "Pet Clinic",
                      ),
                    ),
                    _buildCategoryCard(
                      context,
                      "Essentials",
                      "assets/essentials.png",
                      "Essentials",
                    ),
                    _buildCategoryCard(
                      context,
                      "Mating",
                      "assets/mating.png",
                      "Mating",
                    ),
                    _buildCategoryCard(
                      context,
                      "Adoption",
                      "assets/adoption.png",
                      "Adoption",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: Colors.black, width: 1.5), // Thin black border on top
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Color(0xFFFFCC00), // Yellow background
          selectedItemColor: Colors.black, // Selected item color
          unselectedItemColor: Colors.black54, // Unselected item color
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false, // Hide selected labels
          showUnselectedLabels: false, // Hide unselected labels
          onTap: (index) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DummyPage(index == 0
                    ? "Certifications"
                    : index == 1
                        ? "SOS Alert"
                        : "Settings"),
              ),
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.description,
                  size: 28), // Bigger Certification Icon
              label: "", // Empty label to prevent error
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning,
                  color: Colors.red, size: 28), // Bigger SOS Icon
              label: "", // Empty label to prevent error
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 28), // Bigger Settings Icon
              label: "", // Empty label to prevent error
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String title, String img, String pageName) {
    return SizedBox(
      height: 180, // ✅ Fixed height to avoid overflow
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (title == "Pet Clinic") {
                // ✅ Navigate to PetClinicPage separately
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetClinicScreen()),
                );
              } else if (title == "Pets Lost and Found") {
                // ✅ Navigate to PetClinicPage separately
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LostFoundDashboard()),
                );
              } else {
                // ✅ Other categories use DummyPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DummyPage(pageName)),
                );
              }
            },
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: 220, // Adjust width here
                height: 132, // ✅ Reduced height to prevent overflow
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(img),
                    fit:
                        BoxFit.cover, // Ensures the image fully covers the card
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("This is $title page")),
    );
  }
}

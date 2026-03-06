import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'reports.dart';
import 'profile.dart';
import 'home.dart';

class HazardDetailsPage extends StatefulWidget {
  const HazardDetailsPage({super.key});

  @override
  State<HazardDetailsPage> createState() => _HazardDetailsPageState();
}

class _HazardDetailsPageState extends State<HazardDetailsPage> {
  final int _selectedIndex = 3;

  final LatLng hazardLocation = const LatLng(10.3157, 123.8854); // Example Cebu City coordinates

  void _onNavTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeWidget()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ReportsWidget()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 3:
        // Maps tab - already here
        break;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    // You can add additional map configuration here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Hazard Details",
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.share, color: Colors.black),
          )
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Stack(
              children: [
                Image.network(
                  "https://images.unsplash.com/photo-1590272456521-1bbe160a18ce",
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "UNDER INVESTIGATION",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Downed Utility Wires",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            /// LOCATION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.red,
                      size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "Corner of Rizal and Mabini St.",
                    style: GoogleFonts.outfit(
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "2H AGO",
                    style: GoogleFonts.outfit(
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// MAP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 180,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: hazardLocation,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("hazard"),
                        position: hazardLocation,
                        infoWindow: const InfoWindow(
                          title: "Hazard Location",
                          snippet: "Downed Utility Wires",
                        ),
                      )
                    },
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "DESCRIPTION",
                style: GoogleFonts.outfit(
                  letterSpacing: 1,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// DESCRIPTION CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Strong winds from the recent thunderstorm caused an electric pole to lean significantly. Several wires are hanging low across the intersection, obstructing traffic and posing a severe shock hazard to pedestrians.",
                  style: GoogleFonts.outfit(
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// REPORTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Text("JD"),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reported by",
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Juan Dela Cruz",
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          color: Colors.blue,
                          size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Verified User",
                        style: GoogleFonts.outfit(),
                      )
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.notifications),
                      label: const Text("Get Updates"),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.warning),
                      label: const Text("Request Help"),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      /// BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1976D2), // Blue color for selected items
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
        ],
      ),
    );
  }
}
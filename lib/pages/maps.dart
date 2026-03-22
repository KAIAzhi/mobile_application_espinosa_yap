import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_theme.dart';
import 'home.dart';
import 'profile.dart';
import 'reports.dart';

class HazardDetailsPage extends StatefulWidget {
  const HazardDetailsPage({super.key});

  @override
  State<HazardDetailsPage> createState() => _HazardDetailsPageState();
}

class _HazardDetailsPageState extends State<HazardDetailsPage> {
  final int _selectedIndex = 2;

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
        // Maps tab - already here
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    // You can add additional map configuration here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.cardWhite,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Hazard Details",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.share_rounded, size: 20, color: AppTheme.primaryBlue),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
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
                  bottom: 12,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "UNDER INVESTIGATION",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                  Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.dangerRed,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Corner of Rizal and Mabini St.",
                      style: GoogleFonts.outfit(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      "JD",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          color: AppTheme.successGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Verified User",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
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
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.notifications_outlined, size: 20),
                      label: const Text("Get Updates"),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerRed,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.emergency_rounded, size: 20),
                      label: const Text("Request Help"),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      /// BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1
                    ? Icons.assessment_rounded
                    : Icons.assessment_outlined,
              ),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 2 ? Icons.map_rounded : Icons.map_outlined,
              ),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 3
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../models/hazard_report.dart';
import '../models/users.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home.dart';
import 'notifications.dart';
import 'profile.dart';
import 'reports.dart';

class HazardDetailsPage extends StatefulWidget {
  final Users user;
  const HazardDetailsPage({super.key, required this.user});

  @override
  State<HazardDetailsPage> createState() => _HazardDetailsPageState();
}

class _HazardDetailsPageState extends State<HazardDetailsPage> {
  final int _selectedIndex = 3;
  final MapController _mapController = MapController();

  List<HazardReport> _hazards = [];
  bool _isLoading = true;
  HazardReport? _selectedHazard;

  // Default center — Bacolod City
  final LatLng _defaultCenter = const LatLng(10.6713, 122.9511);

  @override
  void initState() {
    super.initState();
    _loadHazards();
  }

  Future<void> _loadHazards() async {
    try {
      final hazards = await ApiService.fetchAllHazards();
      setState(() {
        _hazards = hazards;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onNavTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeWidget(user: widget.user)));
        break;
      case 1:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ReportsWidget(user: widget.user)));
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => NotificationsPage(user: widget.user)));
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)));
        break;
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return Colors.red;
      case 'high': return Colors.orange;
      case 'medium': return Colors.amber;
      case 'low': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  String _timeAgo(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Hazard Map',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: AppTheme.primaryBlue, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_hazards.length} Active',
                          style: GoogleFonts.outfit(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Map
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _isLoading
                      ? Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: CircularProgressIndicator()),
                        )
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _defaultCenter,
                            initialZoom: 13,
                            onTap: (_, __) => setState(() => _selectedHazard = null),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.rescuehub.app',
                            ),
                            MarkerLayer(
                              markers: _hazards.map((hazard) {
                                final color = _severityColor(hazard.severity);
                                return Marker(
                                  point: LatLng(hazard.latitude, hazard.longitude),
                                  width: 40,
                                  height: 40,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedHazard = hazard);
                                      _mapController.move(
                                        LatLng(hazard.latitude, hazard.longitude),
                                        15,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
                                      ),
                                      child: const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem('Critical', Colors.red),
                  const SizedBox(width: 12),
                  _legendItem('High', Colors.orange),
                  const SizedBox(width: 12),
                  _legendItem('Medium', Colors.amber),
                  const SizedBox(width: 12),
                  _legendItem('Low', Colors.green),
                ],
              ),
            ),

            // Selected hazard card or hazard list
            Expanded(
              flex: 2,
              child: _selectedHazard != null
                  ? _buildHazardDetailCard(_selectedHazard!)
                  : _buildHazardList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildHazardList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hazards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade300),
            const SizedBox(height: 8),
            Text('No active hazards!', style: GoogleFonts.outfit(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _hazards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final h = _hazards[index];
        final color = _severityColor(h.severity);
        return GestureDetector(
          onTap: () {
            setState(() => _selectedHazard = h);
            _mapController.move(LatLng(h.latitude, h.longitude), 15);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.warning_amber_rounded, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(h.barangayName, style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text(h.severity.toUpperCase(), style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(_timeAgo(h.createdAt), style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHazardDetailCard(HazardReport h) {
    final color = _severityColor(h.severity);
    final statusColor = _hexColor(h.statusColor);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title + close
            Row(
              children: [
                Expanded(
                  child: Text(h.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedHazard = null),
                  child: const Icon(Icons.close, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Image if available
            if (h.imageUrl != null && h.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  h.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            if (h.imageUrl != null && h.imageUrl!.isNotEmpty) const SizedBox(height: 8),

            // Badges
            Row(
              children: [
                _badge(h.severity.toUpperCase(), color),
                const SizedBox(width: 8),
                _badge(h.currentStatus.toUpperCase(), statusColor),
                const SizedBox(width: 8),
                _badge(h.hazardType, Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    h.locationText.isNotEmpty ? h.locationText : h.barangayName,
                    style: GoogleFonts.outfit(color: Colors.grey.shade700, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(_timeAgo(h.createdAt), style: GoogleFonts.outfit(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),

            // Reporter
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.primaryBlue,
                  child: Text(
                    h.reporterName.isNotEmpty ? h.reporterName[0].toUpperCase() : '?',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Text('Reported by ${h.reporterName}', style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),

            if (h.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(h.description, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.outfit(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
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
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 1 ? Icons.assessment_rounded : Icons.assessment_outlined), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 2 ? Icons.notifications_rounded : Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 3 ? Icons.map_rounded : Icons.map_outlined), label: 'Maps'),
          BottomNavigationBarItem(icon: Icon(_selectedIndex == 4 ? Icons.person_rounded : Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
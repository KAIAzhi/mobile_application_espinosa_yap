import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/hazard_report.dart';
import '../models/hazard_type.dart';
import '../models/users.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'home.dart';
import 'maps.dart';
import 'notifications.dart';
import 'profile.dart';

class ReportsWidget extends StatefulWidget {
  final Users user;
  const ReportsWidget({super.key, required this.user});

  @override
  State<ReportsWidget> createState() => _ReportsWidgetState();
}

class _ReportsWidgetState extends State<ReportsWidget> {
  int _selectedIndex = 1;
  int _tabIndex = 0; // 0 = Submit, 1 = My Reports

  // Form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<HazardType> _hazardTypes = [];
  int? _selectedHazardTypeId;
  String _selectedSeverity = 'medium';
  bool _isSubmitting = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // GPS
  double _latitude = 10.6713;
  double _longitude = 122.9511;
  bool _locationLoading = false;
  String _locationText = '';

  // My Reports
  List<HazardReport> _myReports = [];
  bool _isLoadingReports = true;

  @override
  void initState() {
    super.initState();
    _loadHazardTypes();
    _loadMyReports();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _locationLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationText =
            '${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E';
        _locationLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _locationLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _loadHazardTypes() async {
    try {
      final types = await ApiService.fetchHazardTypes();
      setState(() => _hazardTypes = types);
    } catch (_) {}
  }

  Future<void> _loadMyReports() async {
    try {
      final reports = await ApiService.fetchHazardReports(widget.user.id);
      setState(() {
        _myReports = reports;
        _isLoadingReports = false;
      });
    } catch (_) {
      setState(() => _isLoadingReports = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );
      if (image != null) setState(() => _selectedImage = File(image.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Hazard Photo',
                  style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                color: AppTheme.primaryBlue, size: 36),
                            const SizedBox(height: 8),
                            Text('Camera',
                                style: GoogleFonts.outfit(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.photo_library_rounded,
                                color: AppTheme.primaryBlue, size: 36),
                            const SizedBox(height: 8),
                            Text('Gallery',
                                style: GoogleFonts.outfit(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a photo as evidence')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (_selectedHazardTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a hazard type')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService.submitReport(
        userId: widget.user.id,
        barangayId: widget.user.barangayId ?? 1,
        hazardTypeId: _selectedHazardTypeId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        locationText: _locationController.text.trim(),
        severity: _selectedSeverity,
        imageFile: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully! ✅')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
      setState(() {
        _selectedHazardTypeId = null;
        _selectedSeverity = 'medium';
        _selectedImage = null;
        _isSubmitting = false;
        _tabIndex = 1;
      });
      _loadMyReports();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() => _isSubmitting = false);
    }
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => HomeWidget(user: widget.user)));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) =>
                    NotificationsPage(user: widget.user)));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) =>
                    HazardDetailsPage(user: widget.user)));
        break;
      case 4:
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) => ProfilePage(user: widget.user)));
        break;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.warning_amber_rounded,
                        color: AppTheme.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Text('Reports',
                      style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8)
                  ],
                ),
                child: Row(
                  children: [
                    _tabButton('Submit Report', 0),
                    _tabButton('My Reports', 1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child:
                  _tabIndex == 0 ? _buildSubmitForm() : _buildMyReports(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Photo picker
          _label('HAZARD EVIDENCE'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppTheme.successGreen
                      : AppTheme.primaryBlue.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ],
              ),
              child: _selectedImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(_selectedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.edit,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded,
                            size: 48,
                            color:
                                AppTheme.primaryBlue.withOpacity(0.6)),
                        const SizedBox(height: 8),
                        Text('Tap to add photo',
                            style: GoogleFonts.outfit(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Camera or Gallery',
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Required for validation',
              style: GoogleFonts.outfit(
                  fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),

          // Title
          _label('TITLE'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            style: GoogleFonts.outfit(),
            decoration: InputDecoration(
              hintText: 'e.g. Flooded road near barangay hall',
              filled: true,
              fillColor: AppTheme.cardWhite,
              hintStyle:
                  GoogleFonts.outfit(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Hazard Type
          _label('TYPE OF HAZARD'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedHazardTypeId,
                isExpanded: true,
                hint: Text('Select category...',
                    style: GoogleFonts.outfit(
                        color: Colors.grey.shade600)),
                items: _hazardTypes.map((type) {
                  return DropdownMenuItem<int>(
                    value: type.hazardTypeId,
                    child:
                        Text(type.name, style: GoogleFonts.outfit()),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedHazardTypeId = val),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Severity
          _label('SEVERITY'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSeverity,
                isExpanded: true,
                items: ['low', 'medium', 'high', 'critical'].map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(
                        s[0].toUpperCase() + s.substring(1),
                        style: GoogleFonts.outfit()),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedSeverity = val!),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Location
          _label('LOCATION'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _locationController,
            style: GoogleFonts.outfit(),
            decoration: InputDecoration(
              hintText: 'e.g. Corner Rizal St., Barangay 22',
              filled: true,
              fillColor: AppTheme.cardWhite,
              hintStyle:
                  GoogleFonts.outfit(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 20),

          // Description
          _label('DESCRIPTION (OPTIONAL)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            minLines: 3,
            style: GoogleFonts.outfit(),
            decoration: InputDecoration(
              hintText: 'Provide more details about the hazard...',
              filled: true,
              fillColor: AppTheme.cardWhite,
              hintStyle:
                  GoogleFonts.outfit(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // GPS card
          GestureDetector(
            onTap: _locationLoading ? null : _getLocation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.4),
                    width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _locationLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryBlue),
                          )
                        : Icon(Icons.gps_fixed_rounded,
                            color: AppTheme.primaryBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automatic GPS Tagging',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _locationText.isNotEmpty
                              ? 'Location: $_locationText'
                              : 'Tap to get your current location',
                          style: GoogleFonts.outfit(
                              color:
                                  AppTheme.primaryBlue.withOpacity(0.9),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _locationText.isNotEmpty
                        ? Icons.check_circle_rounded
                        : Icons.refresh_rounded,
                    color: _locationText.isNotEmpty
                        ? AppTheme.successGreen
                        : AppTheme.primaryBlue,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Offline notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_outlined,
                    size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Offline reports are saved locally and synced when connected.',
                    style: GoogleFonts.outfit(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReport,
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 22),
              label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMyReports() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_myReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No reports submitted yet.',
                style:
                    GoogleFonts.outfit(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _myReports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = _myReports[index];
        final color = _statusColor(report.statusColor);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: report.imageUrl != null
                    ? Image.network(
                        report.imageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _reportIcon(color),
                      )
                    : _reportIcon(color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.title,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(report.locationText,
                        style: GoogleFonts.outfit(
                            color: Colors.grey.shade600, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                          report.currentStatus.toUpperCase(),
                          style: GoogleFonts.outfit(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reportIcon(Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10)),
      child:
          Icon(Icons.warning_amber_rounded, color: color, size: 26),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.grey.shade600,
          letterSpacing: 0.5),
    );
  }

  Color _statusColor(String hex) {
    try {
      return Color(
          int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        backgroundColor: Colors.transparent,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: Colors.grey.shade500,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 0
                  ? Icons.home_rounded
                  : Icons.home_outlined),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 1
                  ? Icons.assessment_rounded
                  : Icons.assessment_outlined),
              label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 2
                  ? Icons.notifications_rounded
                  : Icons.notifications_outlined),
              label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 3
                  ? Icons.map_rounded
                  : Icons.map_outlined),
              label: 'Maps'),
          BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 4
                  ? Icons.person_rounded
                  : Icons.person_outline_rounded),
              label: 'Profile'),
        ],
      ),
    );
  }
}
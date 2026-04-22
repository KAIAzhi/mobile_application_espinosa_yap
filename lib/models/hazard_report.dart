class HazardReport {
  final int reportId;
  final String title;
  final String description;
  final String hazardType;
  final String currentStatus;
  final String statusColor;
  final String severity;
  final double latitude;
  final double longitude;
  final String locationText;
  final String barangayName;
  final String reporterName;
  final String createdAt;
  final String? imageUrl;  // ADD THIS

  HazardReport({
    required this.reportId,
    required this.title,
    required this.description,
    required this.hazardType,
    required this.currentStatus,
    required this.statusColor,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.locationText,
    required this.barangayName,
    required this.reporterName,
    required this.createdAt,
    this.imageUrl,  // ADD THIS
  });

  factory HazardReport.fromJson(Map<String, dynamic> json) {
    return HazardReport(
      reportId: int.tryParse(json['report_id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      hazardType: json['hazard_type']?.toString() ?? '',
      currentStatus: json['current_status']?.toString() ?? '',
      statusColor: json['status_color']?.toString() ?? '#808080',
      severity: json['severity']?.toString() ?? 'medium',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      locationText: json['location_text']?.toString() ?? '',
      barangayName: json['barangay_name']?.toString() ?? '',
      reporterName: json['reporter_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),  // ADD THIS
    );
  }
}
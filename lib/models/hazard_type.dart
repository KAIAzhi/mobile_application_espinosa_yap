class HazardType {
  final int hazardTypeId;
  final String name;
  final String? description;
  final String? iconName;
  final String colorCode;
  final bool isActive;

  HazardType({
    required this.hazardTypeId,
    required this.name,
    this.description,
    this.iconName,
    required this.colorCode,
    required this.isActive,
  });

  factory HazardType.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      return value.toString() == '1' || value.toString().toLowerCase() == 'true';
    }

    return HazardType(
      hazardTypeId: parseInt(json['hazard_type_id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      iconName: json['icon_name']?.toString(),
      colorCode: json['color_code']?.toString() ?? '#FF0000',
      isActive: parseBool(json['is_active']),
    );
  }
}
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
    return HazardType(
      hazardTypeId: json['hazard_type_id'],
      name: json['name'],
      description: json['description'],
      iconName: json['icon_name'],
      colorCode: json['color_code'] ?? '#FF0000',
      isActive: json['is_active'].toString() == '1',
    );
  }
}
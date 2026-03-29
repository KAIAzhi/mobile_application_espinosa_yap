class Users {
  final int id;
  final int? roleId;
  final int? barangayId;
  final String fullName;
  final String? email;
  final String? mobileNumber;
  final String? barangayName;
  final String? roleName;
  final String status;

  Users({
    required this.id,
    this.roleId,
    this.barangayId,
    required this.fullName,
    this.email,
    this.mobileNumber,
    this.barangayName,
    this.roleName,
    this.status = 'inactive',
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return Users(
      id: parseInt(json['user_id'] ?? json['id']),
      roleId: json['role_id'] != null ? parseInt(json['role_id']) : null,
      barangayId: json['barangay_id'] != null ? parseInt(json['barangay_id']) : null,
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobile_number']?.toString() ?? json['mobile']?.toString(),
      barangayName: json['barangay_name']?.toString(),
      roleName: json['role_name']?.toString(),
      status: json['status']?.toString() ?? 'inactive',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'role_id': roleId,
      'barangay_id': barangayId,
      'full_name': fullName,
      'email': email,
      'mobile_number': mobileNumber,
      'barangay_name': barangayName,
      'role_name': roleName,
      'status': status,
    };
  }
}

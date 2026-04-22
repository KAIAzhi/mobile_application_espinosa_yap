import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/users.dart';
import '../models/hazard_report.dart';
import '../models/hazard_type.dart';

class ApiService {
  /// Hostinger redirects HTTP → HTTPS (301). POST must use HTTPS or the client gets 301 with no JSON body.
  static const String baseUrl = 'https://webhoster3b.com/rescuehub/apis/users.php';

  static Future<List<Users>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl?action=list'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load users (HTTP ${response.statusCode})');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Invalid response from server.');
    }
    if (decoded == null || decoded['status'] != 'success') {
      final message = decoded != null ? decoded['message'] ?? 'Unknown error' : 'Empty response';
      throw Exception('API error: $message');
    }

    final List<dynamic> usersJson = decoded['data'] ?? [];
    return usersJson.map((e) {
      if (e is! Map) {
        throw Exception('Invalid user row from server.');
      }
      return Users.fromJson(Map<String, dynamic>.from(e));
    }).toList();
  }

  static Future<Users> login(String identifier, String password) async {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email/mobile and password are required.');
    }

    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse(baseUrl),
        // Your PHP login logic uses $_POST (like the example you shared).
        // Sending form-encoded data ensures $_REQUEST['action'] and $_POST fields are populated.
        headers: {
          'Accept': 'application/json',
        },
        body: {
          'action': 'login',
          'identifier': identifier.trim(),
          'password': password,
        },
      );
    } on SocketException {
      throw Exception(
        'No internet connection. Check your network and try again.',
      );
    } on http.ClientException {
      throw Exception('Could not reach the server. Try again later.');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Invalid response from server.');
    }

    if (response.statusCode != 200) {
      var message = 'Login failed (HTTP ${response.statusCode})';
      if (decoded is Map) {
        final m = Map<String, dynamic>.from(decoded);
        message = m['message']?.toString() ?? message;
      }
      throw Exception(message);
    }

    if (decoded == null || decoded['status'] != 'success') {
      final message = decoded != null
          ? decoded['message'] ?? 'Invalid login credentials'
          : 'Empty response';
      throw Exception(message);
    }

    final userJson = decoded['data'];
    // Login must return a single user object, not a list (list was wrongly used when PHP ignored JSON action).
    if (userJson is Map) {
      return Users.fromJson(Map<String, dynamic>.from(userJson));
    }
    throw Exception('Invalid user data from server.');
  }

  //start1 reports
  static const String reportsUrl = 'https://webhoster3b.com/rescuehub/apis/reports.php';

      static Future<List<HazardReport>> fetchHazardReports(int userId) async {
      late final http.Response response;
      try {
        response = await http.get(
          Uri.parse('$reportsUrl?action=list&user_id=$userId'),
        );
      } on SocketException {
        throw Exception('No internet connection.');
      } on http.ClientException {
        throw Exception('Could not reach the server.');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to load reports (HTTP ${response.statusCode})');
      }

      final dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Invalid response from server.');
      }

      if (decoded == null || decoded['status'] != 'success') {
        final message = decoded != null ? decoded['message'] ?? 'Unknown error' : 'Empty response';
        throw Exception('API error: $message');
      }

      final List<dynamic> reportsJson = decoded['data'] ?? [];
      return reportsJson.map((e) {
        return HazardReport.fromJson(Map<String, dynamic>.from(e));
      }).toList();
    }
  //end1 reports
  //start2 profile reports
  static Future<Map<String, int>> fetchUserStats(int userId) async {
    late final http.Response response;
    try {
      response = await http.get(
        Uri.parse('$reportsUrl?action=stats&user_id=$userId'),
      );
    } on SocketException {
      throw Exception('No internet connection.');
    } on http.ClientException {
      throw Exception('Could not reach the server.');
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('Invalid response from server.');
    }

    if (decoded == null || decoded['status'] != 'success') {
      final message = decoded != null ? decoded['message'] ?? 'Unknown error' : 'Empty response';
      throw Exception('API error: $message');
    }

    final data = decoded['data'];
    return {
      'total_reports': int.tryParse(data['total_reports'].toString()) ?? 0,
      'verified': int.tryParse(data['verified'].toString()) ?? 0,
    };
  }//end2 profile reports

  //start3 submit report
static Future<void> submitReport({
  required int userId,
  required int barangayId,
  required int hazardTypeId,
  required String title,
  required String description,
  required double latitude,
  required double longitude,
  required String locationText,
  required String severity,
  File? imageFile,
}) async {
  var uri = Uri.parse(reportsUrl);

  var request = http.MultipartRequest('POST', uri);

  request.fields.addAll({
    'action': 'submit',
    'user_id': userId.toString(),
    'barangay_id': barangayId.toString(),
    'hazard_type_id': hazardTypeId.toString(),
    'title': title,
    'description': description,
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
    'location_text': locationText,
    'severity': severity,
  });

  if (imageFile != null) {
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );
  }

  late http.StreamedResponse response;

  try {
    response = await request.send();
  } on SocketException {
    throw Exception('No internet connection.');
  }

  final respStr = await response.stream.bytesToString();

  final decoded = jsonDecode(respStr);

  if (response.statusCode != 200 || decoded['status'] != 'success') {
    throw Exception(decoded['message'] ?? 'Failed to submit report.');
  }
}
  //end3 submit report
static Future<List<HazardType>> fetchHazardTypes() async {
  final response = await http.get(
    Uri.parse('$reportsUrl?action=list_hazardtype'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load hazard types');
  }

  final decoded = jsonDecode(response.body);

  if (decoded is! Map || decoded['status'] != 'success') {
    throw Exception(decoded['message'] ?? 'Invalid API response');
  }

  final List data = decoded['data'] ?? [];

  return data.map((e) => HazardType.fromJson(e)).toList();
}

}

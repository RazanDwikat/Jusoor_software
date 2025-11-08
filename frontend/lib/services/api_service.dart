import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/child_model.dart';
import '../models/session.dart';

class ApiService {
  // 🔥 تحديد الـ baseUrl بناءً على المنصة
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/auth'; // للويب
    } else {
      return 'http://10.0.2.2:5000/api/auth'; // للموبايل
    }
  }

  // 🔥 دالة مساعدة لبناء URLs متكاملة
  static String _buildUrl(String endpoint) {
    if (kIsWeb) {
      return 'http://localhost:5000/api/$endpoint';
    } else {
      return 'http://10.0.2.2:5000/api/$endpoint';
    }
  }

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    print('🔵 Signup Response: ${response.statusCode} - ${response.body}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    print('🔵 Login Response: ${response.statusCode} - ${response.body}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendResetCode(String email) async {
    final response = await http.post(
      Uri.parse(_buildUrl('password/send-reset-code')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    print('🔵 Send Reset Code Response: ${response.statusCode} - ${response.body}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    final response = await http.post(
      Uri.parse(_buildUrl('password/verify-code')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    print('🔵 Verify Code Response: ${response.statusCode} - ${response.body}');
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String code, String newPassword) async {
    final response = await http.post(
      Uri.parse(_buildUrl('password/reset-password')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );
    print('🔵 Reset Password Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Server returned status code ${response.statusCode}'
      };
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) return data;
      return {'success': false, 'message': 'Server returned invalid response'};
    } catch (e) {
      print('JSON decode error: $e');
      return {'success': false, 'message': 'Server returned invalid response'};
    }
  }

  // ================= Parent Dashboard =================
  static Future<Map<String, dynamic>> getParentDashboard(String token) async {
    final response = await http.get(
      Uri.parse(_buildUrl('parent/dashboard')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    print('🔵 Dashboard Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard data: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getUpcomingSessions(String token) async {
    final response = await http.get(
      Uri.parse(_buildUrl('parent/upcoming-sessions')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    print('🔵 Upcoming Sessions Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<dynamic>.from(data['sessions'] ?? []);
    } else {
      throw Exception('Failed to load upcoming sessions: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getChildren({
    required String token,
    String? search,
    String? gender,
    String? diagnosis,
    String? sort,
    String? order,
    int? page,
    int? limit,
  }) async {
    final uri = Uri.parse(_buildUrl('children')).replace(
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (gender != null && gender.isNotEmpty && gender != 'All') 'gender': gender,
        if (diagnosis != null && diagnosis.isNotEmpty && diagnosis != 'All') 'diagnosis': diagnosis,
        if (sort != null) 'sort': sort,
        if (order != null) 'order': order,
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('🔵 Get Children Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch children: ${response.statusCode} - ${response.body}');
    }
  }

  static Future<Child> addChild(String token, Child child) async {
    final response = await http.post(
      Uri.parse(_buildUrl('children')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(child.toJson()),
    );
    print('🔵 Add Child Response: ${response.statusCode}');
    if (response.statusCode == 201) {
      return Child.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add child: ${response.body}');
    }
  }

  static Future<Child> updateChild(String token, int id, Child child) async {
    final response = await http.put(
      Uri.parse(_buildUrl('children/$id')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(child.toJson()),
    );
    print('🔵 Update Child Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      return Child.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update child: ${response.body}');
    }
  }

  static Future<void> deleteChild(String token, int id) async {
    final response = await http.delete(
      Uri.parse(_buildUrl('children/$id')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('🔵 Delete Child Response: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete child: ${response.body}');
    }
  }

  // ================= Get Diagnoses =================
  static Future<List<Map<String, dynamic>>> getDiagnoses(String token) async {
    final response = await http.get(
      Uri.parse(_buildUrl('diagnoses')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('🔵 Get Diagnoses Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch diagnoses: ${response.statusCode}');
    }
  }

  // ================= Get Child Statistics =================
  static Future<Map<String, dynamic>> getChildStatistics(String token) async {
    final response = await http.get(
      Uri.parse(_buildUrl('children/stats')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('🔵 Child Statistics Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch child statistics: ${response.statusCode}');
    }
  }

  // ================= Get Single Child =================
  static Future<Child> getChild(String token, int childId) async {
    final response = await http.get(
      Uri.parse(_buildUrl('children/$childId')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('🔵 Get Child Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      return Child.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch child: ${response.statusCode}');
    }
  }

  static Future<void> confirmSession(String token, int sessionId) async {
    final response = await http.patch(
      Uri.parse(_buildUrl('parent/sessions/$sessionId/confirm')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    print('🔵 Confirm Session Response: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to confirm session');
    }
  }

  static Future<void> cancelSession(String token, int sessionId) async {
    final response = await http.patch(
      Uri.parse(_buildUrl('parent/sessions/$sessionId/cancel')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    print('🔵 Cancel Session Response: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel session');
    }
  }

  static Future<List<SessionModel>> getChildSessions(String token, int childId) async {
    final response = await http.get(
      Uri.parse(_buildUrl('parent/child-sessions/$childId')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('🔵 Child Sessions Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final sessions = data['sessions'] as List;
      return sessions.map((json) => SessionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load child sessions: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getParentResources(String token) async {
    final response = await http.get(
      Uri.parse(_buildUrl('parent/resources')),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('🔵 Parent Resources Response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch resources');
    }
  }

  static Future<List<Map<String, dynamic>>> getInstitutions(String token) async {
    final response = await http.get(
      Uri.parse(_buildUrl('institutions')),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('🔵 Institutions Response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to fetch institutions: ${response.statusCode}');
    }
  }
}
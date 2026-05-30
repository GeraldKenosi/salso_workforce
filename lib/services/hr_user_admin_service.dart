import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'api_config.dart';

class HrUserAdminService {
  final FirebaseAuth _auth;

  HrUserAdminService(this._auth);

  Future<void> createUserAndSendResetEmail({
    required String fullName,
    required String email,
    required String roleTemplateId,
    String programmeId = '',
    String teamId = '',
  }) async {
    final res = await http.post(
      Uri.parse(ApiConfig.hrCreateUser),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'roleTemplateId': roleTemplateId,
        'programmeId': programmeId,
        'teamId': teamId,
      }),
    );

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Failed to create user');
    }

    await _auth.sendPasswordResetEmail(email: email);
  }
}

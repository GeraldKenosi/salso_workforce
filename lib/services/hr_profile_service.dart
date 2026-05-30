import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HrProfileService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  HrProfileService(this._db, this._auth);

  Future<void> createProfileOnly({
    required String fullName,
    required String email,
    required String roleTemplateId,
    String programmeId = '',
    String teamId = '',
  }) async {
    final me = _auth.currentUser;
    if (me == null) {
      throw Exception('You must be signed in.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await _db.collection('users').add({
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'roleTemplateId': roleTemplateId.trim(),
      'programmeId': programmeId.trim(),
      'teamId': teamId.trim(),
      'authProvisioned': false,
      'createdAtMs': now,
      'createdByUid': me.uid,
    });
  }
}
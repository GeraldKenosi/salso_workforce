import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/attendance_correction.dart';

class AttendanceCorrectionAdminService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  AttendanceCorrectionAdminService(this._db, this._auth);

  static const String correctionsCol = 'attendanceCorrections';
  static const String usersCol = 'users';

  /// Stream pending corrections, scoped by role
  Stream<List<AttendanceCorrection>> streamPendingCorrections({
    required String role,
    String? teamId,
    String? programmeId,
  }) {
    Query base = _db
        .collection(correctionsCol)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAtMs', descending: true);

    // ED sees everything
    if (role == 'executiveDirector') {
      return base.snapshots().map(
        (s) => s.docs
            .map((d) => AttendanceCorrection.fromMap(
                  d.data() as Map<String, dynamic>,
                ))
            .toList(),
      );
    }

    // Manager / Team Leader: filter by user's team or programme
    return base.snapshots().asyncMap((snap) async {
      final List<AttendanceCorrection> allowed = [];

      for (final d in snap.docs) {
        final correction = AttendanceCorrection.fromMap(
          d.data() as Map<String, dynamic>,
        );

        final userDoc =
            await _db.collection(usersCol).doc(correction.userId).get();

        if (!userDoc.exists) continue;

        final userData = userDoc.data()!;
        final uTeam = userData['teamId']?.toString();
        final uProgramme = userData['programmeId']?.toString();

        if (role == 'manager' &&
            programmeId != null &&
            uProgramme == programmeId) {
          allowed.add(correction);
        }

        if (role == 'teamLeader' &&
            teamId != null &&
            uTeam == teamId) {
          allowed.add(correction);
        }
      }

      return allowed;
    });
  }

  Future<void> decide({
    required AttendanceCorrection correction,
    required bool approve,
    required String decisionReason,
  }) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) {
      throw Exception('Not authenticated');
    }

    await _db.collection(correctionsCol).doc(correction.id).update({
      'status': approve ? 'approved' : 'rejected',
      'reviewedBy': reviewer.uid,
      'reviewedAtMs': DateTime.now().millisecondsSinceEpoch,
      'decisionReason': decisionReason.trim(),
    });
  }
}
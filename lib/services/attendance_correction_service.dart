import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_event.dart';
import '../models/attendance_correction.dart';

class AttendanceCorrectionService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  AttendanceCorrectionService(this._db, this._auth);

  static const String collection = 'attendanceCorrections';

  /// Create a "forgot to clock out" correction
  Future<void> submitClockOutCorrection({
    required AttendanceEvent clockInEvent,
    required DateTime proposedClockOut,
    required String reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (proposedClockOut.isBefore(clockInEvent.timestamp)) {
      throw Exception('Clock-out time cannot be before clock-in time');
    }

    final correction = AttendanceCorrection(
      id: _uuid.v4(),
      userId: user.uid,
      clockInEventId: clockInEvent.localId,
      proposedClockOutMs: proposedClockOut.millisecondsSinceEpoch,
      reason: reason.trim(),
      status: 'pending',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    await _db
        .collection(collection)
        .doc(correction.id)
        .set(correction.toMap());
  }

  /// User can see own correction requests
  Stream<List<AttendanceCorrection>> streamMyCorrections() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => AttendanceCorrection.fromMap(d.data())).toList());
  }
}

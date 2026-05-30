import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/leave_request.dart';

class LeaveService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  LeaveService(this._db, this._auth);

  static const String collection = 'leaveRequests';

  Future<void> submitLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (endDate.isBefore(startDate)) {
      throw Exception('End date cannot be before start date');
    }

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final request = LeaveRequest(
      id: id,
      userId: user.uid,
      leaveType: leaveType,
      startDateMs: startDate.millisecondsSinceEpoch,
      endDateMs: endDate.millisecondsSinceEpoch,
      reason: reason.trim(),
      status: 'pending',
      createdAtMs: now,
    );

    await _db.collection(collection).doc(id).set(request.toMap());
  }

  Stream<List<LeaveRequest>> streamMyLeaves() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LeaveRequest.fromMap(d.data())).toList());
  }

  Stream<List<LeaveRequest>> streamTeamLeaves(String teamId) {
    if (teamId.trim().isEmpty) return const Stream.empty();
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      final results = <LeaveRequest>[];
      for (final d in snap.docs) {
        final req = LeaveRequest.fromMap(d.data());
        final userDoc = await _db.collection('users').doc(req.userId).get();
        if (userDoc.exists && userDoc.data()?['teamId'] == teamId) {
          results.add(req);
        }
      }
      return results;
    });
  }

  Stream<List<LeaveRequest>> streamProgrammeLeaves(String programmeId) {
    if (programmeId.trim().isEmpty) return const Stream.empty();
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .asyncMap((snap) async {
      final results = <LeaveRequest>[];
      for (final d in snap.docs) {
        final req = LeaveRequest.fromMap(d.data());
        final userDoc = await _db.collection('users').doc(req.userId).get();
        if (userDoc.exists && userDoc.data()?['programmeId'] == programmeId) {
          results.add(req);
        }
      }
      return results;
    });
  }

  Stream<List<LeaveRequest>> streamAllPendingLeaves() {
    return _db
        .collection(collection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => LeaveRequest.fromMap(d.data())).toList());
  }

  Future<void> decide({
    required LeaveRequest request,
    required bool approve,
    required String decisionReason,
  }) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) throw Exception('Not authenticated');

    await _db.collection(collection).doc(request.id).update({
      'status': approve ? 'approved' : 'rejected',
      'reviewedBy': reviewer.uid,
      'reviewedAtMs': DateTime.now().millisecondsSinceEpoch,
      'decisionReason': decisionReason.trim(),
    });
  }
}

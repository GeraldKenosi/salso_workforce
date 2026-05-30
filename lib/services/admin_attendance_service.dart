import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch pending corrections (with optional override to show all)
  Stream<List<Map<String, dynamic>>> pendingCorrections({bool all = false}) {
    Query query = _db.collection('attendanceCorrections').orderBy('createdAtMs', descending: true);
    if (!all) query = query.where('status', isEqualTo: 'pending');
    return query.snapshots().map((snap) => snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      return <String, dynamic>{'id': d.id, ...data};
    }).toList());
  }

  /// Approve correction, capture original event snapshot, create clock-out, link to SOP
  Future<void> approveCorrection({
    required String correctionDocId,
    required String proposedClockOutEventId,
    required int proposedClockOutMs,
    String? workflowRequestId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final correctionRef = _db.collection('attendanceCorrections').doc(correctionDocId);
    final correctionSnap = await correctionRef.get();
    if (!correctionSnap.exists) throw Exception('Correction not found');
    final correctionData = correctionSnap.data()!;

    // Snapshot original event
    final originalEventId = correctionData['clockInEventFirestoreId'] ?? '';
    Map<String, dynamic>? originalEvent;
    if (originalEventId.isNotEmpty) {
      final originalSnap = await _db.collection('clockInEvents').doc(originalEventId).get();
      if (originalSnap.exists) {
        originalEvent = {'id': originalSnap.id, ...originalSnap.data()!};
      }
    }

    // Create actual clock-out event
    final clockOutRef = await _db.collection('clockInEvents').add({
      'userId': correctionData['userId'],
      'clockInMs': correctionData['clockInEventId'],
      'clockOutMs': proposedClockOutMs,
      'type': 'clockOut',
      'isManual': true,
      'correctionId': correctionDocId,
      'source': 'attendanceCorrection',
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });

    final auditEntry = {
      'action': 'approved',
      'by': user.uid,
      'atMs': DateTime.now().millisecondsSinceEpoch,
      'detail': 'Created clockOut event ${clockOutRef.id}',
    };

    await correctionRef.update({
      'status': 'approved',
      'reviewedBy': user.uid,
      'reviewedAtMs': DateTime.now().millisecondsSinceEpoch,
      'originalEvent': originalEvent,
      'newEventFirestoreId': clockOutRef.id,
      'correctedTimestampMs': proposedClockOutMs,
      'appliedAtMs': DateTime.now().millisecondsSinceEpoch,
      'appliedBy': user.uid,
      'workflowRequestId': workflowRequestId,
      'auditLog': FieldValue.arrayUnion([auditEntry]),
    });
  }

  /// Reject correction
  Future<void> rejectCorrection({
    required String correctionDocId,
    String? reason,
    String? workflowRequestId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final auditEntry = {
      'action': 'rejected',
      'by': user.uid,
      'atMs': DateTime.now().millisecondsSinceEpoch,
      'detail': reason ?? 'No reason provided',
    };

    final correctionRef = _db.collection('attendanceCorrections').doc(correctionDocId);

    // Snapshot original event before rejecting too
    final correctionSnap = await correctionRef.get();
    Map<String, dynamic>? originalEvent;
    if (correctionSnap.exists) {
      final data = correctionSnap.data()!;
      final originalEventId = data['clockInEventFirestoreId'] ?? '';
      if (originalEventId.isNotEmpty) {
        final originalSnap = await _db.collection('clockInEvents').doc(originalEventId).get();
        if (originalSnap.exists) {
          originalEvent = {'id': originalSnap.id, ...originalSnap.data()!};
        }
      }
    }

    await correctionRef.update({
      'status': 'rejected',
      'reviewedBy': user.uid,
      'reviewedAtMs': DateTime.now().millisecondsSinceEpoch,
      'decisionReason': reason ?? 'Rejected',
      'originalEvent': originalEvent,
      'workflowRequestId': workflowRequestId,
      'auditLog': FieldValue.arrayUnion([auditEntry]),
    });
  }

  /// Link existing correction to SOP workflow request
  Future<void> linkToWorkflow({
    required String correctionDocId,
    required String workflowRequestId,
  }) async {
    await _db.collection('attendanceCorrections').doc(correctionDocId).update({
      'workflowRequestId': workflowRequestId,
    });
  }
}

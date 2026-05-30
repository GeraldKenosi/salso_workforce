import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class WorkflowService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  static const String collection = 'workflowRequests';

  WorkflowService(this._db, this._auth);

  Future<String> createRequest({
    required String sopCategory,
    required String sopType,
    required String title,
    required Map<String, dynamic> data,
    required List<String> approvalSteps,
    double amount = 0,
    String? programmeId,
    String? teamId,
    List<String> attachmentUrls = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final displayName = (userDoc.data()?['fullName'] ?? user.email ?? '').toString();

    await _db.collection(collection).doc(id).set({
      'id': id,
      'userId': user.uid,
      'userDisplayName': displayName,
      'sopCategory': sopCategory,
      'sopType': sopType,
      'title': title.trim(),
      'status': 'submitted',
      'approvalSteps': approvalSteps,
      'currentStepIndex': 0,
      'approvals': {},
      'amount': amount,
      'data': data,
      'attachmentUrls': attachmentUrls,
      'programmeId': programmeId ?? '',
      'teamId': teamId ?? '',
      'auditLog': [
        {'action': 'submitted', 'by': user.uid, 'byName': displayName, 'at': now},
      ],
      'createdAtMs': now,
      'updatedAtMs': now,
      'submittedAtMs': now,
      'completedAtMs': null,
      'delegatedTo': null,
      'delegatedFrom': null,
      'delegationExpiryMs': null,
      'reminderSent': false,
      'attendanceCorrectionId': null,
      'filerSignature': null,
    });

    return id;
  }

  Future<void> addComment(String requestId, String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final commentId = _uuid.v4();
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final displayName = (userDoc.data()?['fullName'] ?? user.email ?? '').toString();

    await _db
        .collection(collection).doc(requestId)
        .collection('comments').doc(commentId).set({
      'id': commentId,
      'userId': user.uid,
      'userName': displayName,
      'text': text.trim(),
      'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });

    await _appendAuditLog(requestId, 'comment_added', user.uid, displayName, text);
  }

  Future<void> decide({
    required String requestId,
    required bool approve,
    required String comment,
    String? signatureUrl,
  }) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) throw Exception('Not authenticated');

    final doc = await _db.collection(collection).doc(requestId).get();
    if (!doc.exists) throw Exception('Request not found');

    final data = doc.data()!;
    final steps = List<String>.from(data['approvalSteps'] ?? []);
    final currentIdx = (data['currentStepIndex'] ?? 0) as int;

    if (currentIdx >= steps.length) throw Exception('All steps already completed');

    final userDoc = await _db.collection('users').doc(reviewer.uid).get();
    final displayName = (userDoc.data()?['fullName'] ?? reviewer.email ?? '').toString();

    final stepName = steps[currentIdx];
    final now = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> stepResult = {
      'approved': approve,
      'by': reviewer.uid,
      'byName': displayName,
      'at': now,
      'comment': comment.trim(),
      'signatureUrl': signatureUrl,
    };

    final path = 'approvals.$stepName';
    final updates = <String, dynamic>{
      path: stepResult,
      'updatedAtMs': now,
    };

    if (!approve) {
      updates['status'] = 'rejected';
      updates['completedAtMs'] = now;
    } else if (currentIdx + 1 >= steps.length) {
      updates['status'] = 'approved';
      updates['completedAtMs'] = now;
      updates['currentStepIndex'] = currentIdx + 1;
    } else {
      updates['status'] = 'submitted';
      updates['currentStepIndex'] = currentIdx + 1;
    }

    await _db.collection(collection).doc(requestId).update(updates);
    await _appendAuditLog(requestId,
      approve ? 'approved_step_$stepName' : 'rejected_step_$stepName',
      reviewer.uid, displayName, comment);
  }

  Future<void> setUnderReview(String requestId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _db.collection('users').doc(user.uid).get();
    final displayName = (userDoc.data()?['fullName'] ?? user.email ?? '').toString();

    await _db.collection(collection).doc(requestId).update({'status': 'under_review'});
    await _appendAuditLog(requestId, 'under_review', user.uid, displayName, null);
  }

  Future<void> setDelegate({
    required String delegateUid,
    required int expiryMs,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final stream = _db
        .collection(collection)
        .where('status', whereIn: ['submitted', 'under_review']);
    final snap = await stream.get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {
        'delegatedTo': delegateUid,
        'delegatedFrom': user.uid,
        'delegationExpiryMs': expiryMs,
      });
    }
    await batch.commit();
  }

  Future<void> _appendAuditLog(String requestId, String action, String byUid, String byName, String? detail) async {
    final doc = _db.collection(collection).doc(requestId);
    await doc.update({
      'auditLog': FieldValue.arrayUnion([
        {'action': action, 'by': byUid, 'byName': byName, 'at': DateTime.now().millisecondsSinceEpoch, 'detail': detail}
      ]),
    });
  }

  Future<void> updateFilerSignature(String requestId, String signatureUrl) async {
    await _db.collection(collection).doc(requestId).update({
      'filerSignature': signatureUrl,
    });
  }

  Stream<Map<String, dynamic>?> streamRequest(String requestId) {
    return _db.collection(collection).doc(requestId).snapshots()
        .map((s) => s.exists ? s.data() : null);
  }

  Stream<List<Map<String, dynamic>>> streamMyRequests() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> streamPendingApprovals() {
    return _db
        .collection(collection)
        .where('status', whereIn: ['submitted', 'under_review'])
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> streamAllRequests() {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<List<Map<String, dynamic>>> getStatsForPeriod(int startMs, int endMs) async {
    final snap = await _db
        .collection(collection)
        .where('createdAtMs', isGreaterThanOrEqualTo: startMs)
        .where('createdAtMs', isLessThanOrEqualTo: endMs)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/narrative_report.dart';

class NarrativeReportService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  static const String collection = 'narrativeReports';

  NarrativeReportService(this._db, this._auth);

  Future<String> saveDraft(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final id = data['id'] ?? _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final isNew = data['id'] == null;

    final report = {
      'id': id,
      'userId': user.uid,
      'status': 'draft',
      'createdAtMs': isNew ? now : (data['createdAtMs'] ?? now),
      'updatedAtMs': now,
      ...data,
    };

    await _db.collection(collection).doc(id.toString()).set(report);
    return id.toString();
  }

  Future<String> submitReport({
    required Map<String, dynamic> data,
    required String filerSignatureUrl,
    required String filerSignatureName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final id = data['id'] ?? _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final report = {
      'id': id,
      'userId': user.uid,
      'status': 'submitted',
      'filerSignatureUrl': filerSignatureUrl,
      'filerSignatureName': filerSignatureName,
      'createdAtMs': data['createdAtMs'] ?? now,
      'updatedAtMs': now,
      ...data,
    };

    await _db.collection(collection).doc(id.toString()).set(report);
    return id.toString();
  }

  Future<void> approveReport(String reportId, {
    required bool approve,
    required String comment,
  }) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) throw Exception('Not authenticated');

    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.collection(collection).doc(reportId).update({
      'status': approve ? 'approved' : 'rejected',
      'reviewedBy': reviewer.uid,
      'reviewedAtMs': now,
      'decisionReason': comment.trim(),
      'updatedAtMs': now,
    });
  }

  Future<void> signOffReport(String reportId, {
    required String signOffComment,
    required String signOffSignatureUrl,
    required String pdfUrl,
  }) async {
    final signer = _auth.currentUser;
    if (signer == null) throw Exception('Not authenticated');

    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.collection(collection).doc(reportId).update({
      'status': 'signed_off',
      'signedOffBy': signer.uid,
      'signedOffAtMs': now,
      'signOffComment': signOffComment.trim(),
      'signOffSignatureUrl': signOffSignatureUrl,
      'pdfUrl': pdfUrl,
      'updatedAtMs': now,
    });
  }

  Future<NarrativeReport?> getReport(String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return NarrativeReport.fromMap(doc.data()!);
  }

  Stream<NarrativeReport?> streamReport(String id) {
    return _db.collection(collection).doc(id).snapshots()
        .map((s) => s.exists ? NarrativeReport.fromMap(s.data()!) : null);
  }

  Stream<List<NarrativeReport>> streamMyReports() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => NarrativeReport.fromMap(d.data())).toList());
  }

  Stream<List<NarrativeReport>> streamPendingApprovals() {
    return _db
        .collection(collection)
        .where('status', isEqualTo: 'submitted')
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => NarrativeReport.fromMap(d.data())).toList());
  }

  Stream<List<NarrativeReport>> streamAllForPeriod(int startMs, int endMs) {
    return _db
        .collection(collection)
        .where('startDateMs', isGreaterThanOrEqualTo: startMs)
        .where('startDateMs', isLessThanOrEqualTo: endMs)
        .where('status', whereIn: ['approved', 'signed_off'])
        .snapshots()
        .map((s) => s.docs.map((d) => NarrativeReport.fromMap(d.data())).toList());
  }

  Future<Map<String, dynamic>?> findDraft() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'draft')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }
}

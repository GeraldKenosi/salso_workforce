import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/report.dart';

class ReportService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  static const String collection = 'reports';

  ReportService(this._db, this._auth);

  Future<void> createReport({
    required String reportType,
    required String title,
    required String content,
    required DateTime periodStart,
    required DateTime periodEnd,
    String programmeId = '',
    String teamId = '',
    List<String> photoUrls = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final report = Report(
      id: id,
      userId: user.uid,
      programmeId: programmeId,
      teamId: teamId,
      reportType: reportType.trim(),
      title: title.trim(),
      content: content.trim(),
      periodStartMs: periodStart.millisecondsSinceEpoch,
      periodEndMs: periodEnd.millisecondsSinceEpoch,
      status: 'draft',
      createdAtMs: now,
      updatedAtMs: now,
      photoUrls: photoUrls,
      sharePointPath: '/SALSO/Reports/$reportType/${user.uid}/$id',
      sharePointStatus: 'pending',
      sharePointFileUrl: null,
    );

    await _db.collection(collection).doc(id).set(report.toMap());
  }

  Future<void> submitReport(Report report) async {
    await _db.collection(collection).doc(report.id).update({
      'status': 'submitted',
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> approveReport(Report report, {required bool approve, required String comment}) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) throw Exception('Not authenticated');

    await _db.collection(collection).doc(report.id).update({
      'status': approve ? 'approved' : 'rejected',
      'reviewedBy': reviewer.uid,
      'reviewedAtMs': DateTime.now().millisecondsSinceEpoch,
      'decisionReason': comment.trim(),
      'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // NOTE: returning untyped Stream prevents your environment from breaking on generics.
  Stream streamMyReports() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Report.fromMap(d.data())).toList();
      list.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      return list;
    });
  }

  Stream streamTeamReports(String teamId) {
    if (teamId.trim().isEmpty) return const Stream.empty();

    return _db
        .collection(collection)
        .where('teamId', isEqualTo: teamId.trim())
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Report.fromMap(d.data())).toList();
      final filtered = list.where((r) => r.status != 'draft').toList();
      filtered.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      return filtered;
    });
  }

  Stream streamProgrammeReports(String programmeId) {
    if (programmeId.trim().isEmpty) return const Stream.empty();

    return _db
        .collection(collection)
        .where('programmeId', isEqualTo: programmeId.trim())
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Report.fromMap(d.data())).toList();
      final filtered = list.where((r) => r.status != 'draft').toList();
      filtered.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      return filtered;
    });
  }

  Stream streamAllSubmittedReports({int limit = 200}) {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) {
      final list = s.docs.map((d) => Report.fromMap(d.data())).toList();
      final filtered = list.where((r) => r.status != 'draft').toList();
      return filtered;
    });
  }
}
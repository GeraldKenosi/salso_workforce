import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/kpi_target.dart';
import '../models/kpi_config.dart';
import '../models/kpi_score.dart';

class KpiService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  static const String configCol = 'kpiConfig';
  static const String scoreCol = 'kpiScores';
  static const String targetCol = 'kpiTargets';

  KpiService(this._db, this._auth);

  Future<String> getCurrentQuarter() {
    final now = DateTime.now();
    final q = ((now.month - 1) ~/ 3) + 1;
    return Future.value('${now.year}-Q$q');
  }

  static (int, int) quarterDateRange(String quarter) {
    final parts = quarter.split('-Q');
    final year = int.parse(parts[0]);
    final q = int.parse(parts[1]);
    final startMonth = (q - 1) * 3 + 1;
    final start = DateTime(year, startMonth, 1);
    final end = DateTime(year, startMonth + 3, 0);
    return (start.millisecondsSinceEpoch, end.millisecondsSinceEpoch);
  }

  // ── KPI CONFIG (set by ED) ──

  Future<String> setConfig({
    required String roleGroup,
    required String quarter,
    required List<KpiMetricConfig> metrics,
    String? programmeId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final id = '${roleGroup}_$quarter${programmeId != null ? '_$programmeId' : ''}';
    await _db.collection(configCol).doc(id).set({
      'id': id, 'roleGroup': roleGroup, 'quarter': quarter,
      'programmeId': programmeId,
      'metrics': metrics.map((m) => m.toMap()).toList(),
      'createdBy': user.uid, 'createdAtMs': DateTime.now().millisecondsSinceEpoch,
    });
    return id;
  }

  Stream<KpiConfig?> streamConfig(String roleGroup, String quarter, {String? programmeId}) {
    final id = '${roleGroup}_$quarter${programmeId != null ? '_$programmeId' : ''}';
    return _db.collection(configCol).doc(id).snapshots()
        .map((s) => s.exists ? KpiConfig.fromMap(s.data()!) : null);
  }

  Future<KpiConfig?> getConfig(String roleGroup, String quarter, {String? programmeId}) async {
    final id = '${roleGroup}_$quarter${programmeId != null ? '_$programmeId' : ''}';
    final doc = await _db.collection(configCol).doc(id).get();
    return doc.exists ? KpiConfig.fromMap(doc.data()!) : null;
  }

  Stream<List<KpiConfig>> streamAllConfigs() {
    return _db.collection(configCol).snapshots()
        .map((s) => s.docs.map((d) => KpiConfig.fromMap(d.data())).toList());
  }

  // ── KPI SCORES ──

  Future<String> createOrUpdateScore({
    required String userId,
    required String quarter,
    required Map<String, MetricScore> scores,
    required double overallPercentage,
    required String rating,
    bool finalized = false,
  }) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) throw Exception('Not authenticated');

    final reviewerDoc = await _db.collection('users').doc(reviewer.uid).get();
    final reviewerName = (reviewerDoc.data()?['fullName'] ?? reviewer.email ?? '').toString();

    final id = '${userId}_$quarter';
    final now = DateTime.now().millisecondsSinceEpoch;

    final data = {
      'id': id, 'userId': userId, 'quarter': quarter,
      'scores': scores.map((k, v) => MapEntry(k, v.toMap())),
      'overallPercentage': overallPercentage, 'rating': rating,
      'reviewerId': reviewer.uid, 'reviewerName': reviewerName,
      'reviewDateMs': now, 'finalized': finalized,
      'oneOnOne': {'scheduled': false, 'completed': false},
      'updatedAtMs': now,
    };

    await _db.collection(scoreCol).doc(id).set(data, SetOptions(merge: true));
    return id;
  }

  Future<void> setOneOnOne(String userId, String quarter, {
    required int meetingDateMs,
    String? meetingNotes,
  }) async {
    final id = '${userId}_$quarter';
    final doc = await _db.collection(scoreCol).doc(id).get();
    if (!doc.exists) throw Exception('Score not found');

    final existing = doc.data()!;
    final oneOnOne = Map<String, dynamic>.from(existing['oneOnOne'] as Map? ?? {});
    oneOnOne['scheduled'] = true;
    oneOnOne['meetingDateMs'] = meetingDateMs;
    if (meetingNotes != null) oneOnOne['meetingNotes'] = meetingNotes;

    await _db.collection(scoreCol).doc(id).update({'oneOnOne': oneOnOne});
  }

  Future<void> completeOneOnOne(String userId, String quarter, {required String notes}) async {
    final id = '${userId}_$quarter';
    await _db.collection(scoreCol).doc(id).update({
      'oneOnOne.completed': true,
      'oneOnOne.meetingNotes': notes.trim(),
    });
  }

  Future<KpiScore?> getScore(String userId, String quarter) async {
    final id = '${userId}_$quarter';
    final doc = await _db.collection(scoreCol).doc(id).get();
    return doc.exists ? KpiScore.fromMap(doc.data()!) : null;
  }

  Stream<KpiScore?> streamScore(String userId, String quarter) {
    final id = '${userId}_$quarter';
    return _db.collection(scoreCol).doc(id).snapshots()
        .map((s) => s.exists ? KpiScore.fromMap(s.data()!) : null);
  }

  Stream<List<KpiScore>> streamTeamScores(List<String> userIds, String quarter) {
    if (userIds.isEmpty) return const Stream.empty();
    return _db
        .collection(scoreCol)
        .where('userId', whereIn: userIds.take(10).toList())
        .snapshots()
        .map((s) => s.docs.map((d) => KpiScore.fromMap(d.data())).toList());
  }

  Stream<List<KpiScore>> streamAllScores(String quarter) {
    return _db
        .collection(scoreCol)
        .where('quarter', isEqualTo: quarter)
        .snapshots()
        .map((s) => s.docs.map((d) => KpiScore.fromMap(d.data())).toList());
  }

  // ── LEGACY KPI TARGET SUPPORT ──

  Future<void> setKpi({
    required String userId,
    required String metric,
    required double targetValue,
    required String period,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final id = _uuid.v4();
    final kpi = KpiTarget(
      id: id, userId: userId, metric: metric,
      targetValue: targetValue, period: period,
      periodStartMs: periodStart.millisecondsSinceEpoch,
      periodEndMs: periodEnd.millisecondsSinceEpoch,
    );
    await _db.collection(targetCol).doc(id).set(kpi.toMap());
  }

  Future<void> updateProgress(String kpiId, double value) async {
    await _db.collection(targetCol).doc(kpiId).update({'currentValue': value});
  }

  Stream<List<KpiTarget>> streamMyKpis() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection(targetCol)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((s) => s.docs.map((d) => KpiTarget.fromMap(d.data())).toList());
  }

  Stream<List<KpiTarget>> streamAllKpis() {
    return _db.collection(targetCol).snapshots()
        .map((s) => s.docs.map((d) => KpiTarget.fromMap(d.data())).toList());
  }

  Stream<List<KpiTarget>> streamTeamKpis(List<String> userIds) {
    if (userIds.isEmpty) return const Stream.empty();
    return _db
        .collection(targetCol)
        .where('userId', whereIn: userIds)
        .snapshots()
        .map((s) => s.docs.map((d) => KpiTarget.fromMap(d.data())).toList());
  }
}

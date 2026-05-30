import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _db;

  AnalyticsService(this._db);

  Future<Map<String, dynamic>> getMonthlyStats(int startMs, int endMs) async {
    final snap = await _db
        .collection('narrativeReports')
        .where('startDateMs', isGreaterThanOrEqualTo: startMs)
        .where('startDateMs', isLessThanOrEqualTo: endMs)
        .where('status', whereIn: ['approved', 'signed_off'])
        .get();

    int totalParticipants = 0;
    int totalMen = 0;
    int totalWomen = 0;
    int totalUnder18 = 0;
    int total18to35 = 0;
    int total36to59 = 0;
    int total60plus = 0;
    double totalCost = 0;
    final Map<String, int> programmeBreakdown = {};
    final Map<String, int> activityTypeBreakdown = {};

    for (final doc in snap.docs) {
      final d = doc.data();
      totalParticipants += _toInt(d['totalParticipants']);
      totalMen += _toInt(d['men']);
      totalWomen += _toInt(d['women']);
      totalUnder18 += _toInt(d['under18']);
      total18to35 += _toInt(d['age18to35']);
      total36to59 += _toInt(d['age36to59']);
      total60plus += _toInt(d['age60plus']);
      totalCost += _toDouble(d['totalCost']);

      final prog = (d['programmeId'] ?? 'unknown').toString();
      programmeBreakdown[prog] = (programmeBreakdown[prog] ?? 0) + 1;

      final type = (d['activityType'] ?? 'unknown').toString();
      activityTypeBreakdown[type] = (activityTypeBreakdown[type] ?? 0) + 1;
    }

    return {
      'totalActivities': snap.docs.length,
      'totalParticipants': totalParticipants,
      'totalMen': totalMen,
      'totalWomen': totalWomen,
      'totalUnder18': totalUnder18,
      'total18to35': total18to35,
      'total36to59': total36to59,
      'total60plus': total60plus,
      'totalCost': totalCost,
      'programmeBreakdown': programmeBreakdown,
      'activityTypeBreakdown': activityTypeBreakdown,
    };
  }

  Future<Map<String, dynamic>> getWorkflowStats(int startMs, int endMs) async {
    final snap = await _db
        .collection('workflowRequests')
        .where('createdAtMs', isGreaterThanOrEqualTo: startMs)
        .where('createdAtMs', isLessThanOrEqualTo: endMs)
        .get();

    int total = 0, approved = 0, rejected = 0, pending = 0;
    double totalAmount = 0;
    final Map<String, int> byType = {};

    for (final doc in snap.docs) {
      final d = doc.data();
      total++;
      final status = d['status'] ?? '';
      if (status == 'approved') approved++;
      else if (status == 'rejected') rejected++;
      else pending++;
      totalAmount += _toDouble(d['amount']);
      final type = (d['sopType'] ?? 'unknown').toString();
      byType[type] = (byType[type] ?? 0) + 1;
    }

    return {
      'total': total, 'approved': approved, 'rejected': rejected, 'pending': pending,
      'totalAmount': totalAmount, 'byType': byType,
    };
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

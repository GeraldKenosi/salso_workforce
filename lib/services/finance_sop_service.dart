import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/finance_sop.dart';

class FinanceSopService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  FinanceSopService(this._db, this._auth);

  static const String collection = 'financeSops';

  Future<void> submitSop({
    required String sopType,
    required String title,
    required double amount,
    required String description,
    List<String> attachmentUrls = const [],
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    if (amount <= 0) throw Exception('Amount must be greater than zero');

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final sop = FinanceSop(
      id: id,
      userId: user.uid,
      sopType: sopType,
      title: title.trim(),
      amount: amount,
      description: description.trim(),
      status: 'submitted',
      attachmentUrls: attachmentUrls,
      createdAtMs: now,
    );

    await _db.collection(collection).doc(id).set(sop.toMap());
  }

  Stream<List<FinanceSop>> streamMySops() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => FinanceSop.fromMap(d.data())).toList());
  }

  Stream<List<FinanceSop>> streamPendingManagerApproval() {
    return _db
        .collection(collection)
        .where('status', isEqualTo: 'submitted')
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => FinanceSop.fromMap(d.data())).toList());
  }

  Stream<List<FinanceSop>> streamPendingFinanceApproval() {
    return _db
        .collection(collection)
        .where('managerApproval', isEqualTo: 'approved')
        .where('financeApproval', whereIn: [null, ''])
        .snapshots()
        .map((s) => s.docs.map((d) => FinanceSop.fromMap(d.data())).toList());
  }

  Stream<List<FinanceSop>> streamPendingEdApproval() {
    return _db
        .collection(collection)
        .where('status', isEqualTo: 'finance_approved')
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => FinanceSop.fromMap(d.data())).toList());
  }

  Stream<List<FinanceSop>> streamAllSops() {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => FinanceSop.fromMap(d.data())).toList());
  }

  Future<void> approveStep({
    required FinanceSop sop,
    required String step,
    required bool approve,
    required String comment,
    required bool financeEnabled,
  }) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{
      'reviewedBy': reviewer.uid,
      'reviewedAtMs': DateTime.now().millisecondsSinceEpoch,
      'decisionReason': comment.trim(),
    };

    if (step == 'manager') {
      updates['managerApproval'] = approve ? 'approved' : 'rejected';
      if (!approve) updates['status'] = 'rejected';
      else if (!financeEnabled) updates['status'] = 'finance_approved';
    } else if (step == 'finance') {
      updates['financeApproval'] = approve ? 'approved' : 'rejected';
      if (!approve) updates['status'] = 'rejected';
      else updates['status'] = 'finance_approved';
    } else if (step == 'ed') {
      updates['edApproval'] = approve ? 'approved' : 'rejected';
      updates['status'] = approve ? 'approved' : 'rejected';
    }

    await _db.collection(collection).doc(sop.id).update(updates);
  }
}

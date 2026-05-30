import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/reimbursement.dart';

class ReimbursementService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  ReimbursementService(this._db, this._auth);

  static const String collection = 'reimbursements';

  Future<void> submitClaim({
    required double amount,
    required String description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    if (amount <= 0) throw Exception('Amount must be greater than zero');

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final claim = Reimbursement(
      id: id,
      userId: user.uid,
      amount: amount,
      description: description.trim(),
      status: 'pending',
      createdAtMs: now,
    );

    await _db.collection(collection).doc(id).set(claim.toMap());
  }

  Stream<List<Reimbursement>> streamMyClaims() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Reimbursement.fromMap(d.data())).toList());
  }

  Stream<List<Reimbursement>> streamAllPendingClaims() {
    return _db
        .collection(collection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Reimbursement.fromMap(d.data())).toList());
  }

  Future<void> decide({
    required Reimbursement claim,
    required bool approve,
    required String decisionReason,
  }) async {
    final reviewer = _auth.currentUser;
    if (reviewer == null) throw Exception('Not authenticated');

    await _db.collection(collection).doc(claim.id).update({
      'status': approve ? 'approved' : 'rejected',
      'reviewedBy': reviewer.uid,
      'reviewedAtMs': DateTime.now().millisecondsSinceEpoch,
      'decisionReason': decisionReason.trim(),
    });
  }
}

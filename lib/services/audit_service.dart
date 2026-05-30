import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/audit_log.dart';

class AuditService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  AuditService(this._db, this._auth);

  static const String collection = 'auditLogs';

  Future<void> log({
    required String action,
    required String entityType,
    required String entityId,
    required String details,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final id = _uuid.v4();
    final log = AuditLog(
      id: id,
      userId: user.uid,
      userName: user.displayName ?? user.email ?? 'Unknown',
      action: action,
      entityType: entityType,
      entityId: entityId,
      details: details,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.collection(collection).doc(id).set(log.toMap());
  }

  Stream<List<AuditLog>> streamAllLogs({int limit = 100}) {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => AuditLog.fromMap(d.data())).toList());
  }

  Stream<List<AuditLog>> streamUserLogs(String userId) {
    return _db
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAtMs', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => AuditLog.fromMap(d.data())).toList());
  }
}

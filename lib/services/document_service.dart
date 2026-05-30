import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/employee_document.dart';

class DocumentService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  DocumentService(this._db, this._auth);

  static const String documentsCol = 'documents';

  /// ✅ Immediate upload record (NO QUEUE)
  Future<void> createUploadedDocument({
    required String docType,
    required String originalFileName,
    required int originalFileSizeBytes,
    required String sharePointPath,
    required String sharePointFileUrl,
    required String uploadedByName,
    required String uploadedByEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final now = DateTime.now().millisecondsSinceEpoch;

    final doc = EmployeeDocument(
      id: _uuid.v4(),
      userId: user.uid,
      docType: docType,
      originalFileName: originalFileName,
      originalFileSizeBytes: originalFileSizeBytes,
      sharePointPath: sharePointPath,
      sharePointStatus: 'uploaded',
      sharePointFileUrl: sharePointFileUrl,
      createdAtMs: now,
      updatedAtMs: now,
      uploadedByUid: user.uid,
      uploadedByName: uploadedByName,
      uploadedByEmail: uploadedByEmail,
      uploadedAtMs: now,
    );

    await _db.collection(documentsCol).doc(doc.id).set(doc.toMap());
  }

  Stream<List<EmployeeDocument>> streamMyDocuments() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection(documentsCol)
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((s) {
      final list =
          s.docs.map((d) => EmployeeDocument.fromMap(d.data())).toList();
      list.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      return list;
    });
  }
}
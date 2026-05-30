import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/contact_message.dart';

class ContactService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  ContactService(this._db, this._auth);

  static const String collection = 'contactMessages';

  Future<void> sendMessage({
    required String subject,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final msg = ContactMessage(
      id: id,
      userId: user.uid,
      userName: user.displayName ?? '',
      userEmail: user.email ?? '',
      subject: subject.trim(),
      message: message.trim(),
      createdAtMs: now,
    );

    await _db.collection(collection).doc(id).set(msg.toMap());
  }

  Stream<List<ContactMessage>> streamAllMessages() {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ContactMessage.fromMap(d.data())).toList());
  }
}

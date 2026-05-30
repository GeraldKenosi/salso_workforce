import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/announcement.dart';

class AnnouncementService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  AnnouncementService(this._db, this._auth);

  static const String collection = 'announcements';

  Future<void> createAnnouncement({
    required String title,
    required String body,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final announcement = Announcement(
      id: id,
      title: title.trim(),
      body: body.trim(),
      authorName: user.displayName ?? user.email ?? 'Unknown',
      createdAtMs: now,
    );

    await _db.collection(collection).doc(id).set(announcement.toMap());
  }

  Stream<List<Announcement>> streamAnnouncements() {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Announcement.fromMap(d.data())).toList());
  }
}

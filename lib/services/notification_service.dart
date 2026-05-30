import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  NotificationService(this._db, this._auth);

  static const String collection = 'notifications';

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? relatedEntityId,
    String? relatedEntityType,
  }) async {
    final id = _uuid.v4();
    final notif = AppNotification(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.collection(collection).doc(id).set(notif.toMap());
  }

  Stream<List<AppNotification>> streamMyNotifications() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMs', descending: true)
        .limit(30)
        .snapshots()
        .map((s) => s.docs.map((d) => AppNotification.fromMap(d.data())).toList());
  }

  Future<void> markRead(String notificationId) async {
    await _db.collection(collection).doc(notificationId).update({'read': true});
  }

  Future<void> markAllRead() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final snap = await _db
        .collection(collection)
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .get();
    for (final d in snap.docs) {
      await d.reference.update({'read': true});
    }
  }
}

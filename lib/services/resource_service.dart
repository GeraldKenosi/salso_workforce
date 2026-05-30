import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/app_resource.dart';

class ResourceService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final _uuid = const Uuid();

  ResourceService(this._db, this._auth);

  static const String collection = 'resources';

  Future<void> createResource({
    required String title,
    required String category,
    required String description,
    required String url,
  }) async {
    final id = _uuid.v4();
    final resource = AppResource(
      id: id,
      title: title,
      category: category,
      description: description,
      url: url,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.collection(collection).doc(id).set(resource.toMap());
  }

  Stream<List<AppResource>> streamResources() {
    return _db
        .collection(collection)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AppResource.fromMap(d.data())).toList());
  }

  Stream<List<AppResource>> streamResourcesByCategory(String category) {
    return _db
        .collection(collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAtMs', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AppResource.fromMap(d.data())).toList());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/sharepoint_queue_item.dart';

class SharePointQueueService {
  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  static const String collection = 'sharepointQueue';

  SharePointQueueService(this._db);

  Future<void> enqueueReport({
    required String reportId,
    required String sharePointPath,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    final item = SharePointQueueItem(
      id: id,
      reportId: reportId,
      sharePointPath: sharePointPath,
      status: 'queued',
      createdAtMs: now,
    );

    await _db.collection(collection).doc(id).set(item.toMap());
  }
}
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum SyncOperation { create, update, delete }

class PendingSyncItem {
  final String id;
  final SyncOperation operation;
  final String collection;
  final String docId;
  final Map<String, dynamic> data;
  final String? fileBytesKey;
  final String? storagePath;
  final String? fileMimeType;
  final int createdAtMs;

  PendingSyncItem({
    required this.id,
    required this.operation,
    required this.collection,
    required this.docId,
    required this.data,
    this.fileBytesKey,
    this.storagePath,
    this.fileMimeType,
    required this.createdAtMs,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'operation': operation.name,
    'collection': collection,
    'docId': docId,
    'data': data,
    'fileBytesKey': fileBytesKey,
    'storagePath': storagePath,
    'fileMimeType': fileMimeType,
    'createdAtMs': createdAtMs,
  };

  factory PendingSyncItem.fromMap(Map<String, dynamic> m) => PendingSyncItem(
    id: m['id'] ?? '',
    operation: SyncOperation.values.firstWhere((o) => o.name == m['operation']),
    collection: m['collection'] ?? '',
    docId: m['docId'] ?? '',
    data: Map<String, dynamic>.from(m['data'] ?? {}),
    fileBytesKey: m['fileBytesKey'],
    storagePath: m['storagePath'],
    fileMimeType: m['fileMimeType'],
    createdAtMs: m['createdAtMs'] ?? 0,
  );

  static final hiveKey = 'pendingSync';
}

class SyncService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final Box _hive;
  final Connectivity _connectivity;

  bool _processing = false;
  int _pendingCount = 0;
  StreamSubscription? _connectivitySub;

  int get pendingCount => _pendingCount;

  SyncService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required FirebaseStorage storage,
    required Box hive,
    required Connectivity connectivity,
  }) : _firestore = firestore,
       _auth = auth,
       _storage = storage,
       _hive = hive,
       _connectivity = connectivity {
    _pendingCount = _loadQueue().length;
    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) => _tryProcess());
  }

  List<PendingSyncItem> _loadQueue() {
    final raw = _hive.get(PendingSyncItem.hiveKey, defaultValue: <Map>[]);
    return (raw as List)
        .map((e) => PendingSyncItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void _saveQueue(List<PendingSyncItem> items) {
    _hive.put(PendingSyncItem.hiveKey, items.map((e) => e.toMap()).toList());
    _pendingCount = items.length;
    notifyListeners();
  }

  Future<void> enqueueWrite({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    String? fileBytesKey,
    String? storagePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final online = await _checkOnline();
    if (online) {
      await _writeDirect(collection, docId, data, fileBytesKey, storagePath);
      return;
    }

    final queue = _loadQueue();
    queue.add(PendingSyncItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_${queue.length}',
      operation: SyncOperation.create,
      collection: collection,
      docId: docId,
      data: data,
      fileBytesKey: fileBytesKey,
      storagePath: storagePath,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    ));
    _saveQueue(queue);
  }

  Future<void> enqueueUpdate({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    final online = await _checkOnline();
    if (online) {
      await _firestore.collection(collection).doc(docId).update(data);
      return;
    }

    final queue = _loadQueue();
    queue.add(PendingSyncItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_${queue.length}',
      operation: SyncOperation.update,
      collection: collection,
      docId: docId,
      data: data,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    ));
    _saveQueue(queue);
  }

  Future<void> _writeDirect(
    String collection,
    String docId,
    Map<String, dynamic> data,
    String? fileBytesKey,
    String? storagePath,
  ) async {
    if (storagePath != null && fileBytesKey != null) {
      final bytes = _hive.get(fileBytesKey);
      if (bytes != null) {
        final ref = _storage.ref().child(storagePath);
        await ref.putData(bytes is Uint8List ? bytes : Uint8List.fromList(bytes.cast<int>()));
        data['downloadUrl'] = await ref.getDownloadURL();
        _hive.delete(fileBytesKey);
      }
    }
    await _firestore.collection(collection).doc(docId).set(data);
  }

  Future<bool> _checkOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _tryProcess() async {
    if (_processing) return;
    _processing = true;
    try {
      await processQueue();
    } finally {
      _processing = false;
    }
  }

  Future<int> processQueue() async {
    final online = await _checkOnline();
    if (!online) return 0;

    final queue = _loadQueue();
    if (queue.isEmpty) return 0;

    final failed = <PendingSyncItem>[];
    int processed = 0;

    for (final item in queue) {
      try {
        await _writeDirect(
          item.collection,
          item.docId,
          item.data,
          item.fileBytesKey,
          item.storagePath,
        );
        processed++;
      } catch (_) {
        failed.add(item);
      }
    }

    _saveQueue(failed);
    return processed;
  }

  Future<void> clearQueue() async {
    _saveQueue([]);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}

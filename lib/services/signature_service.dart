import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignatureService {
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final Box _cache;

  static const _cacheKey = 'my_signature';

  SignatureService(this._auth, this._storage, this._cache);

  Uint8List? getCachedSignature() {
    final raw = _cache.get(_cacheKey);
    if (raw == null) return null;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    return null;
  }

  String? getCachedSignatureUrl() {
    return _cache.get('${_cacheKey}_url');
  }

  Future<String> saveSignature(Uint8List pngBytes) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final path = 'signatures/${user.uid}/signature.png';
    final ref = _storage.ref().child(path);
    await ref.putData(pngBytes, SettableMetadata(contentType: 'image/png'));
    final url = await ref.getDownloadURL();

    _cache.put(_cacheKey, pngBytes);
    _cache.put('${_cacheKey}_url', url);

    return url;
  }

  Future<void> deleteSignature() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _storage.ref().child('signatures/${user.uid}/signature.png').delete();
    } catch (_) {}
    _cache.delete(_cacheKey);
    _cache.delete('${_cacheKey}_url');
  }

  Future<Uint8List?> fetchSignature(String uid) async {
    try {
      final ref = _storage.ref().child('signatures/$uid/signature.png');
      final bytes = await ref.getData();
      if (bytes != null) return bytes;
    } catch (_) {}
    return null;
  }
}

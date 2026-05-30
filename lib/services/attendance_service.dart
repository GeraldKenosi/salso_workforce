import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/attendance_event.dart';

class AttendanceService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  final Box _box;

  final _uuid = const Uuid();
  Timer? _periodicTimer;

  AttendanceService(this._auth, this._db, this._box);

  static const String collectionName = 'attendanceEvents';

  // ----------------------------
  // Local storage
  // ----------------------------
  List getAllLocalEventsForUser(String uid) {
    final events = <AttendanceEvent>[];
    for (final v in _box.values) {
      if (v is Map) {
        final e = AttendanceEvent.fromMap(v);
        if (e.userId == uid) events.add(e);
      }
    }
    events.sort((a, b) => a.timestampMs.compareTo(b.timestampMs));
    return events;
  }

  List getUnsyncedEventsForUser(String uid) {
    final events = getAllLocalEventsForUser(uid).cast<AttendanceEvent>();
    return events.where((e) => !e.synced).toList();
  }

  Future<void> saveLocalEvent(AttendanceEvent e) async {
    await _box.put(e.localId, e.toMap());
  }

  Future<void> updateLocalEvent(AttendanceEvent e) async {
    await _box.put(e.localId, e.toMap());
  }

  AttendanceEvent? getLastEvent(String uid) {
    final events = getAllLocalEventsForUser(uid).cast<AttendanceEvent>();
    return events.isEmpty ? null : events.last;
  }

  bool isCurrentlyClockedIn(String uid) {
    final last = getLastEvent(uid);
    return last != null && last.type == 'clock_in';
  }

  // ----------------------------
  // Location (audit)
  // ----------------------------
  Future<_LocResult> _getAuditLocation() async {
    if (kIsWeb) {
      return const _LocResult(status: 'unavailable');
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return const _LocResult(status: 'services_off');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const _LocResult(status: 'denied');
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _LocResult(
        status: 'granted',
        lat: pos.latitude,
        lng: pos.longitude,
        accuracyM: pos.accuracy,
      );
    } catch (_) {
      return const _LocResult(status: 'error');
    }
  }

  // ----------------------------
  // Clock in / out
  // ----------------------------
  Future<void> clockIn() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    if (isCurrentlyClockedIn(user.uid)) throw Exception('Already clocked in');

    final loc = await _getAuditLocation();

    final e = AttendanceEvent(
      localId: _uuid.v4(),
      userId: user.uid,
      type: 'clock_in',
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      platform: kIsWeb ? 'web' : 'android',
      synced: false,
      latitude: loc.lat,
      longitude: loc.lng,
      accuracyM: loc.accuracyM,
      locationStatus: loc.status,
    );

    await saveLocalEvent(e);
    _unawaited(syncPendingEvents());
  }

  Future<void> clockOut() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');
    if (!isCurrentlyClockedIn(user.uid)) throw Exception('Not clocked in');

    final loc = await _getAuditLocation();

    final e = AttendanceEvent(
      localId: _uuid.v4(),
      userId: user.uid,
      type: 'clock_out',
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      platform: kIsWeb ? 'web' : 'android',
      synced: false,
      latitude: loc.lat,
      longitude: loc.lng,
      accuracyM: loc.accuracyM,
      locationStatus: loc.status,
    );

    await saveLocalEvent(e);
    _unawaited(syncPendingEvents());
  }

  // ----------------------------
  // Hours calculation
  // ----------------------------
  Duration calculateWorkedForDay(String uid, DateTime day) {
    final events = getAllLocalEventsForUser(uid).cast<AttendanceEvent>();

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    DateTime? currentIn;
    var total = Duration.zero;

    for (final e in events) {
      final t = e.timestamp;
      if (t.isBefore(start) || t.isAfter(end)) continue;

      if (e.type == 'clock_in') {
        currentIn = t;
      } else if (e.type == 'clock_out' && currentIn != null) {
        if (t.isAfter(currentIn)) total += t.difference(currentIn);
        currentIn = null;
      }
    }

    if (currentIn != null) {
      total += DateTime.now().difference(currentIn);
    }

    return total;
  }

  // ----------------------------
  // Auto sync
  // ----------------------------
  void startAutoSync() {
    stopAutoSync();
    _periodicTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => syncPendingEvents(),
    );
    _unawaited(syncPendingEvents());
  }

  void stopAutoSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  // ----------------------------
  // Firestore sync (audit fields included)
  // ----------------------------
  Future<int> syncPendingEvents() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final pending = getUnsyncedEventsForUser(user.uid).cast<AttendanceEvent>();
    if (pending.isEmpty) return 0;

    var uploaded = 0;
    for (final e in pending) {
      try {
        await _db.collection(collectionName).doc(e.localId).set({
          'localId': e.localId,
          'userId': e.userId,
          'type': e.type,
          'timestampMs': e.timestampMs,
          'platform': e.platform,
          'latitude': e.latitude,
          'longitude': e.longitude,
          'accuracyM': e.accuracyM,
          'locationStatus': e.locationStatus,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await updateLocalEvent(e.copyWith(synced: true, firestoreId: e.localId));
        uploaded++;
      } catch (_) {
        // retry next sync
      }
    }

    return uploaded;
  }

  void dispose() {
    stopAutoSync();
  }
}

class _LocResult {
  final String status;
  final double? lat;
  final double? lng;
  final double? accuracyM;

  const _LocResult({
    required this.status,
    this.lat,
    this.lng,
    this.accuracyM,
  });
}

void _unawaited(Future<void> f) {}

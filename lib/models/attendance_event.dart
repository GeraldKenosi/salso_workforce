class AttendanceEvent {
  final String localId;
  final String userId;
  final String type; // clock_in | clock_out
  final int timestampMs;
  final String platform;
  final bool synced;
  final String? firestoreId;

  // ✅ Location audit fields (optional)
  final double? latitude;
  final double? longitude;
  final double? accuracyM;
  // granted | denied | services_off | error | unavailable
  final String locationStatus;

  AttendanceEvent({
    required this.localId,
    required this.userId,
    required this.type,
    required this.timestampMs,
    required this.platform,
    required this.synced,
    this.firestoreId,
    this.latitude,
    this.longitude,
    this.accuracyM,
    this.locationStatus = 'unavailable',
  });

  DateTime get timestamp => DateTime.fromMillisecondsSinceEpoch(timestampMs);

  Map toMap() {
    return {
      'localId': localId,
      'userId': userId,
      'type': type,
      'timestampMs': timestampMs,
      'platform': platform,
      'synced': synced,
      'firestoreId': firestoreId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyM': accuracyM,
      'locationStatus': locationStatus,
    };
  }

  factory AttendanceEvent.fromMap(Map map) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return AttendanceEvent(
      localId: (map['localId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      timestampMs: (map['timestampMs'] ?? 0) as int,
      platform: (map['platform'] ?? 'unknown').toString(),
      synced: (map['synced'] ?? false) as bool,
      firestoreId: map['firestoreId']?.toString(),
      latitude: toDouble(map['latitude']),
      longitude: toDouble(map['longitude']),
      accuracyM: toDouble(map['accuracyM']),
      locationStatus: (map['locationStatus'] ?? 'unavailable').toString(),
    );
  }

  AttendanceEvent copyWith({
    bool? synced,
    String? firestoreId,
    double? latitude,
    double? longitude,
    double? accuracyM,
    String? locationStatus,
  }) {
    return AttendanceEvent(
      localId: localId,
      userId: userId,
      type: type,
      timestampMs: timestampMs,
      platform: platform,
      synced: synced ?? this.synced,
      firestoreId: firestoreId ?? this.firestoreId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyM: accuracyM ?? this.accuracyM,
      locationStatus: locationStatus ?? this.locationStatus,
    );
  }
}
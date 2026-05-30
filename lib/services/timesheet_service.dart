import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_event.dart';
import '../models/attendance_correction.dart';

class TimesheetService {
  final FirebaseFirestore _db;

  TimesheetService(this._db);

  static const String attendanceCol = 'attendanceEvents';
  static const String correctionCol = 'attendanceCorrections';

  /// Fetch approved corrections for a user
  Future<List<AttendanceCorrection>> _loadApprovedCorrections(
    String userId,
  ) async {
    final snap = await _db
        .collection(correctionCol)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'approved')
        .get();

    return snap.docs
        .map((d) => AttendanceCorrection.fromMap(d.data()))
        .toList();
  }

  /// Fetch raw attendance events
  Future<List<AttendanceEvent>> _loadAttendanceEvents(
    String userId,
  ) async {
    final snap = await _db
        .collection(attendanceCol)
        .where('userId', isEqualTo: userId)
        .orderBy('timestampMs')
        .get();

    return snap.docs
        .map((d) => AttendanceEvent.fromMap(d.data()))
        .toList();
  }

  /// Compute total worked duration in a date range
  Future<Duration> calculateRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) async {
    final events = await _loadAttendanceEvents(userId);
    final corrections = await _loadApprovedCorrections(userId);

    final Map<String, AttendanceCorrection> correctionMap = {
      for (var c in corrections) c.clockInEventId: c
    };

    Duration total = Duration.zero;
    DateTime? activeClockIn;
    String? activeClockInId;

    for (final e in events) {
      final t = e.timestamp;
      if (t.isBefore(start) || t.isAfter(end)) continue;

      if (e.type == 'clock_in') {
        activeClockIn = t;
        activeClockInId = e.localId;
      }

      if (e.type == 'clock_out' && activeClockIn != null) {
        total += t.difference(activeClockIn);
        activeClockIn = null;
        activeClockInId = null;
      }
    }

    // Apply approved corrections (virtual clock‑outs)
    if (activeClockIn != null && activeClockInId != null) {
      final correction = correctionMap[activeClockInId];
      if (correction != null) {
        final correctedOut =
            DateTime.fromMillisecondsSinceEpoch(correction.proposedClockOutMs);

        if (!correctedOut.isBefore(activeClockIn)) {
          total += correctedOut.difference(activeClockIn);
        }
      }
    }

    return total;
  }
}

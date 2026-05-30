import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/attendance_service.dart';
import '../../state/session_provider.dart';
import '../../models/attendance_event.dart';

class MyAttendanceHistoryPage extends StatelessWidget {
  const MyAttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final attendance = context.watch<AttendanceService>();
    final uid = session.firebaseUser?.uid ?? '';

    final events = uid.isEmpty
        ? <AttendanceEvent>[]
        : attendance.getAllLocalEventsForUser(uid).cast<AttendanceEvent>().reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance History')),
      body: events.isEmpty
          ? const Center(child: Text('No attendance events yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: events.length,
              itemBuilder: (ctx, i) {
                final e = events[i];
                final t = DateFormat('dd MMM yyyy, HH:mm').format(e.timestamp);

                final locText = (e.latitude != null && e.longitude != null)
                    ? 'Loc: ${e.latitude!.toStringAsFixed(5)}, ${e.longitude!.toStringAsFixed(5)} • ${(e.accuracyM ?? 0).toStringAsFixed(0)}m'
                    : 'Loc: ${e.locationStatus}';

                return Card(
                  child: ListTile(
                    title: Text(e.type == 'clock_in' ? 'Clock In' : 'Clock Out'),
                    subtitle: Text('$t\n$locText'),
                    trailing: Text(
                      e.synced ? 'SYNCED' : 'PENDING',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: e.synced ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
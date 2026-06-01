import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/attendance_service.dart';
import '../../services/attendance_correction_service.dart';
import '../../state/session_provider.dart';
import '../../models/attendance_event.dart';
import '../../models/attendance_correction.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';
import '../attendance/my_attendance_history_page.dart';
import '../attendance/register/register_list_page.dart';

class TabAttendance extends StatefulWidget {
  const TabAttendance({super.key});

  @override
  State<TabAttendance> createState() => _TabAttendanceState();
}

class _TabAttendanceState extends State<TabAttendance> {
  bool _working = false;
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final attendance = context.watch<AttendanceService>();
    final correctionService = context.watch<AttendanceCorrectionService>();

    final uid = session.firebaseUser?.uid ?? '';
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, dd MMM yyyy').format(now);

    final clockedIn = uid.isNotEmpty && attendance.isCurrentlyClockedIn(uid);
    final workedToday = uid.isEmpty ? Duration.zero : attendance.calculateWorkedForDay(uid, now);
    final lastEvent = uid.isEmpty ? null : attendance.getLastEvent(uid);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Red header
            Container(
              decoration: const BoxDecoration(
                color: SalsoTheme.primary,
                borderRadius: BorderRadius.zero,
              ),
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            const Text('Attendance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.15),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${workedToday.inHours.toString().padLeft(2, '0')}:${workedToday.inMinutes.remainder(60).toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'today',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: clockedIn ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      clockedIn ? 'CLOCKED IN' : 'CLOCKED OUT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: clockedIn ? Colors.greenAccent : Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Clock in/out buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: (_working || clockedIn) ? null : () => _doClockIn(attendance),
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text("Clock In"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0FA65A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: (_working || !clockedIn) ? null : () => _doClockOut(attendance),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text("Clock Out"),
                        style: ElevatedButton.styleFrom(backgroundColor: SalsoTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_syncing) ...[const SizedBox(height: 8), const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: LinearProgressIndicator())],
            const SizedBox(height: 6),

            // Forgot to clock out
            if (clockedIn && lastEvent != null && lastEvent.type == 'clock_in')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextButton.icon(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => _openCorrectionDialog(context, lastEvent, attendance, correctionService),
                  label: const Text("Forgot to clock out?"),
                ),
              ),

            // History card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SalsoCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAttendanceHistoryPage())),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: SalsoTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.history, color: SalsoTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Attendance History', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('View clock-in/out records', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ])),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // Event registration (digital register)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SalsoCard(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterListPage())),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF1E9CCC).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.event_note, color: Color(0xFF1E9CCC), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Event Registration', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('Digital attendance register', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ])),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            // Correction requests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SalsoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Correction Requests", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 8),
                    StreamBuilder(
                      stream: correctionService.streamMyCorrections(),
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator());
                        }
                        if (snap.hasError) {
                          return Text("Error: ${snap.error}", style: const TextStyle(color: Colors.red, fontSize: 13));
                        }
                        final data = snap.data;
                        final List<AttendanceCorrection> list = (data is List<AttendanceCorrection>) ? data : [];
                        if (list.isEmpty) {
                          return const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("No corrections.", style: TextStyle(color: Colors.grey)));
                        }
                        return Column(
                          children: list.take(8).map((c) {
                            final t = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.fromMillisecondsSinceEpoch(c.proposedClockOutMs));
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Proposed: $t", style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                        Text(c.reason, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  SalsoStatusBadge(status: c.status, fontSize: 11),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _doClockIn(AttendanceService attendance) async {
    setState(() => _working = true);
    try {
      await attendance.clockIn();
      _snack("Clock-in saved.");
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _doClockOut(AttendanceService attendance) async {
    setState(() => _working = true);
    try {
      await attendance.clockOut();
      _snack("Clock-out saved.");
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _openCorrectionDialog(BuildContext context, AttendanceEvent clockInEvent, AttendanceService attendance, AttendanceCorrectionService correctionService) async {
    DateTime proposed = DateTime.now();
    final reasonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Request clock-out correction"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Clock-in: ${DateFormat('HH:mm').format(clockInEvent.timestamp)}"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.fromDateTime(proposed),
                );
                if (picked != null) {
                  proposed = DateTime(
                    clockInEvent.timestamp.year, clockInEvent.timestamp.month,
                    clockInEvent.timestamp.day, picked.hour, picked.minute,
                  );
                }
              },
              child: const Text("Select clock-out time"),
            ),
            TextField(controller: reasonCtrl, decoration: const InputDecoration(labelText: "Reason")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await correctionService.submitClockOutCorrection(
                  clockInEvent: clockInEvent,
                  proposedClockOut: proposed,
                  reason: reasonCtrl.text,
                );
                Navigator.pop(ctx);
                _snack("Correction submitted.");
              } catch (e) {
                Navigator.pop(ctx);
                _snack("Submit failed: $e");
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg.replaceAll('Exception: ', ''))));
  }
}

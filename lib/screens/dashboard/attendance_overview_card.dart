import 'package:flutter/material.dart';
import '../manager/team_attendance_screen.dart';

class AttendanceOverviewCard extends StatelessWidget {
  const AttendanceOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text(
          'Attendance Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Tap to view team attendance'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TeamAttendanceScreen(),
            ),
          );
        },
      ),
    );
  }
}
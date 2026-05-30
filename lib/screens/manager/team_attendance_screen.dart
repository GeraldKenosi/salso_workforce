import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/session_provider.dart';

class TeamAttendanceScreen extends StatelessWidget {
  const TeamAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final role = session.profile?.roleTemplateId ?? '';
    final programmeId = session.profile?.programmeId ?? '';
    final teamId = session.profile?.teamId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          role == 'executiveDirector'
              ? 'Organisation Attendance'
              : role == 'manager'
                  ? 'Programme Attendance'
                  : 'Team Attendance',
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allUsers = (userSnap.data?.docs ?? []).where((d) {
            final data = d.data();
            final userRole = (data['roleTemplateId'] ?? '').toString();
            if (userRole == 'executiveDirector' || userRole == 'admin') return false;
            if (role == 'manager' && programmeId.isNotEmpty) {
              return data['programmeId']?.toString() == programmeId;
            }
            if (role == 'teamLeader' && teamId.isNotEmpty) {
              return data['teamId']?.toString() == teamId;
            }
            return true;
          }).toList();

          if (allUsers.isEmpty) {
            return const Center(child: Text('No team members found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: allUsers.length,
            itemBuilder: (ctx, i) {
              final doc = allUsers[i];
              final data = doc.data();
              final uid = doc.id;
              final name = (data['fullName'] ?? 'Unknown').toString();
              final userTeam = (data['teamId'] ?? '').toString();
              final userProgramme = (data['programmeId'] ?? '').toString();

              return _UserAttendanceCard(
                uid: uid,
                name: name,
                team: userTeam,
                programme: userProgramme,
              );
            },
          );
        },
      ),
    );
  }
}

class _UserAttendanceCard extends StatelessWidget {
  final String uid;
  final String name;
  final String team;
  final String programme;

  const _UserAttendanceCard({
    required this.uid,
    required this.name,
    required this.team,
    required this.programme,
  });

  @override
  Widget build(BuildContext context) {
    final todayStart = DateTime.now();
    final todayEnd = todayStart.add(const Duration(days: 1));

    return Card(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('attendanceEvents')
            .where('userId', isEqualTo: uid)
            .where('timestampMs', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
            .where('timestampMs', isLessThan: todayEnd.millisecondsSinceEpoch)
            .snapshots(),
        builder: (ctx, snap) {
          String status = 'No activity today';
          Color statusColor = Colors.grey;
          Duration worked = Duration.zero;

          if (snap.hasData) {
            final events = snap.data!.docs
                .map((d) => d.data())
                .toList()
              ..sort((a, b) => (a['timestampMs'] ?? 0).compareTo(b['timestampMs'] ?? 0));

            if (events.isNotEmpty) {
              final lastType = events.last['type']?.toString() ?? '';
              status = lastType == 'clock_in' ? 'Clocked In' : 'Clocked Out';
              statusColor = lastType == 'clock_in' ? Colors.green : Colors.black87;
            }

            DateTime? currentIn;
            for (final e in events) {
              final t = DateTime.fromMillisecondsSinceEpoch(e['timestampMs'] ?? 0);
              if (e['type'] == 'clock_in') {
                currentIn = t;
              } else if (e['type'] == 'clock_out' && currentIn != null) {
                if (t.isAfter(currentIn)) worked += t.difference(currentIn);
                currentIn = null;
              }
            }
            if (currentIn != null) {
              worked += DateTime.now().difference(currentIn);
            }
          }

          final hours = worked.inHours.toString().padLeft(2, '0');
          final mins = worked.inMinutes.remainder(60).toString().padLeft(2, '0');

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withValues(alpha: 0.15),
              child: Icon(Icons.person, color: statusColor),
            ),
            title: Text(name),
            subtitle: Text(
              '$status • ${hours}h${mins}m today\n'
              '${programme.isEmpty ? '' : '$programme • '}${team.isEmpty ? '' : team}',
            ),
            trailing: Text(
              status == 'Clocked In' ? 'IN' : 'OUT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

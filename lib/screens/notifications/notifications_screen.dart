import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../services/notification_service.dart';
import '../../models/app_notification.dart';
import '../../widgets/salso_card.dart';
import '../../app/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NotificationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => service.markAllRead(),
            child: const Text('Mark All Read', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: service.streamMyNotifications(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifs = snap.data ?? [];
          if (notifs.isEmpty) {
            return const SalsoEmptyState(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              subtitle: 'You\'ll see approvals, reminders, and announcements here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (ctx, i) {
              final n = notifs[i];
              final date = DateFormat('dd MMM yyyy HH:mm').format(
                DateTime.fromMillisecondsSinceEpoch(n.createdAtMs),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SalsoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: n.read ? Colors.transparent : SalsoTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(n.body, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

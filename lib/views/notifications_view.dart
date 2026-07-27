import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'New frames added!',
        'message': 'We just added 20 new frame styles that match your face shape. Check them out in the AR try-on!',
        'time': '2 hours ago',
        'icon': PhosphorIcons.sunglasses,
        'isUnread': true,
      },
      {
        'title': 'Reservation Confirmed',
        'message': 'Your reservation for the Classic Rectangular frames has been confirmed. Visit our partner store within 7 days.',
        'time': '1 day ago',
        'icon': PhosphorIcons.checkCircle,
        'isUnread': false,
      },
      {
        'title': 'Scan reminder',
        'message': 'You haven\'t completed a face scan yet! Get personalized frame recommendations by scanning your face today.',
        'time': '3 days ago',
        'icon': PhosphorIcons.scan,
        'isUnread': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final isUnread = notif['isUnread'] as bool;
          
          return Container(
            color: isUnread ? colorScheme.primary.withValues(alpha: 0.05) : Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A2A35)),
                ),
                child: Icon(
                  notif['icon'] as IconData,
                  color: isUnread ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      notif['title'] as String,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        color: isUnread ? Colors.white : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif['message'] as String,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif['time'] as String,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

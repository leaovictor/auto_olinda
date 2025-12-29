import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../features/notifications/data/notification_repository.dart';
import '../../../../features/notifications/domain/user_notification.dart';
import '../theme/admin_theme.dart';

class AdminInboxScreen extends ConsumerWidget {
  const AdminInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Notificações', style: AdminTheme.headingMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AdminTheme.textPrimary),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AdminTheme.bgDark.withOpacity(0.9), Colors.transparent],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AdminTheme.textPrimary),
            tooltip: 'Marcar todas como lidas',
            onPressed: () {
              ref.read(notificationRepositoryProvider).markAllAsRead();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AdminTheme.backgroundGradient,
        ),
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: AdminTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma notificação',
                      style: AdminTheme.headingSmall.copyWith(
                        color: AdminTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Você será notificado sobre atualizações aqui',
                      style: AdminTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 20,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _AdminNotificationCard(
                  notification: notification,
                ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1), // Gradient Primary [0]
            ),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Erro ao carregar notificações',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNotificationCard extends ConsumerWidget {
  final UserNotification notification;

  const _AdminNotificationCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFormat = DateFormat('dd/MM HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AdminTheme.glassmorphicDecoration(
        opacity: notification.isRead ? 0.3 : 0.6,
        glowColor: _getIconColor(notification.type),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Mark as read
            if (!notification.isRead) {
              try {
                await ref
                    .read(notificationRepositoryProvider)
                    .markAsRead(notification.id);
              } catch (_) {
                // Ignore error for UI smoothness
              }
            }

            // Navigate if applicable (admin might not need booking nav, but keeping it flexible)
            if (notification.bookingId != null && context.mounted) {
              // Admin might want to view the booking details in admin panel
              // For now, let's just mark read. Converting client route to admin route is tricky without more context.
              // Assuming userNotificationsProvider returns notifications relevant to the logged in user (admin).
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getIconColor(notification.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(notification.type),
                    color: _getIconColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AdminTheme.bodyLarge.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: notification.isRead
                                    ? AdminTheme.textSecondary
                                    : AdminTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AdminTheme.gradientPrimary[0],
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: AdminTheme.bodyMedium.copyWith(
                          color: AdminTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeFormat.format(notification.timestamp),
                        style: AdminTheme.bodySmall.copyWith(
                          color: AdminTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'status_update':
        return Icons.local_car_wash;
      case 'promotion':
        return Icons.sell;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'status_update':
        return Colors.blue;
      case 'promotion':
        return Colors.orange;
      case 'reminder':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

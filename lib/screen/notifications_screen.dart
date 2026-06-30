import 'package:flutter/material.dart';
import 'package:gep_point/services/s_notification.dart';
import 'package:gep_point/themes/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await _notificationService.fetchNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notif) async {
    if (notif.isRead) return;
    
    final success = await _notificationService.markAsRead(notif.id);
    if (success && mounted) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notif.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: notif.id,
            type: notif.type,
            data: notif.data,
            readAt: DateTime.now(),
            createdAt: notif.createdAt,
          );
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success && mounted) {
      _loadNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tout marquer comme lu',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text("Aucune notification"))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final title = notif.data['title'] ?? 'Notification';
                      final message = notif.data['message'] ?? '';
                      
                      return Card(
                        color: notif.isRead ? AppColors.card : AppColors.primary.withOpacity(0.1),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            notif.isRead ? Icons.notifications_none : Icons.notifications_active,
                            color: notif.isRead ? Colors.grey : AppColors.primary,
                          ),
                          title: Text(title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Text(message),
                          trailing: notif.isRead ? null : IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                            onPressed: () => _markAsRead(notif),
                          ),
                          onTap: () => _markAsRead(notif),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

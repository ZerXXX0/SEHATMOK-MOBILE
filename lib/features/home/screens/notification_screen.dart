import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/fridge_item_model.dart';
import '../../../models/meal_plan_model.dart';
import '../../../services/fridge_service.dart';
import '../../../services/meal_plan_service.dart';
import '../../../widgets/common_widgets.dart';

class AppNotification {
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  AppNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<AppNotification> _notifications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todayStr = _formatDate(DateTime.now());
      final todayMidnight = _normalizeDate(DateTime.now());

      // Fetch fridge items and today's meal plans in parallel
      final results = await Future.wait([
        context.read<FridgeService>().getFridgeItems(),
        context.read<MealPlanService>().getMealPlans(date: todayStr).catchError((_) => MealPlanDay(date: todayStr, items: [])),
      ]);

      final fridgeItems = results[0] as List<FridgeItem>;
      final mealPlan = results[1] as MealPlanDay;

      final List<AppNotification> tempNotifications = [];

      // 1. Process Fridge Expirations
      for (final item in fridgeItems) {
        if (item.expiryDate == null) continue;

        final expiryMidnight = _normalizeDate(item.expiryDate!);
        final diffDays = expiryMidnight.difference(todayMidnight).inDays;

        if (diffDays < 0) {
          tempNotifications.add(
            AppNotification(
              title: 'Product Expired',
              message: '${item.name} (${item.quantity} ${item.unit}) expired on ${_formatDate(item.expiryDate!)}. Please discard it.',
              timestamp: item.expiryDate!,
              icon: Icons.report_gmailerrorred_outlined,
              color: Colors.red,
            ),
          );
        } else if (diffDays == 0) {
          tempNotifications.add(
            AppNotification(
              title: 'Expires Today!',
              message: '${item.name} (${item.quantity} ${item.unit}) expires today. Cook it now to avoid waste!',
              timestamp: DateTime.now(),
              icon: Icons.warning_amber_rounded,
              color: Colors.orange.shade800,
            ),
          );
        } else if (diffDays == 1) {
          tempNotifications.add(
            AppNotification(
              title: 'Expires Tomorrow',
              message: '${item.name} (${item.quantity} ${item.unit}) will expire tomorrow.',
              timestamp: DateTime.now(),
              icon: Icons.info_outline,
              color: Colors.orange.shade600,
            ),
          );
        } else if (diffDays == 2) {
          tempNotifications.add(
            AppNotification(
              title: 'Expires in 2 Days',
              message: '${item.name} (${item.quantity} ${item.unit}) will expire in 2 days.',
              timestamp: DateTime.now(),
              icon: Icons.info_outline,
              color: Colors.blue,
            ),
          );
        }
      }

      // 2. Process Today's Meal Plan
      for (final item in mealPlan.items) {
        if (item.recipe == null) continue;

        String slotLabel = item.slot;
        if (item.slot == 'BREAKFAST') slotLabel = 'Breakfast';
        if (item.slot == 'LUNCH') slotLabel = 'Lunch';
        if (item.slot == 'DINNER') slotLabel = 'Dinner';

        tempNotifications.add(
          AppNotification(
            title: "Today's Meal Plan",
            message: 'Remember to cook/eat "${item.recipe!.name}" for $slotLabel today.',
            timestamp: DateTime.now(),
            icon: Icons.restaurant_menu_outlined,
            color: Colors.green,
          ),
        );
      }

      // Sort notifications (red/orange first, then blue/green)
      tempNotifications.sort((a, b) {
        final severityMap = {
          Colors.red: 0,
          Colors.orange.shade800: 1,
          Colors.orange.shade600: 2,
          Colors.blue: 3,
          Colors.green: 4,
        };
        final severityA = severityMap[a.color] ?? 5;
        final severityB = severityMap[b.color] ?? 5;
        return severityA.compareTo(severityB);
      });

      setState(() {
        _notifications = tempNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load notifications: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? EmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: 'Error loading notifications',
                  description: _errorMessage!,
                  onRetry: _loadNotifications,
                )
              : _notifications.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none_outlined,
                      title: 'All caught up!',
                      description: 'No active notifications or expiring items.',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: notification.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: notification.color.withOpacity(0.1),
                                child: Icon(
                                  notification.icon,
                                  color: notification.color,
                                ),
                              ),
                              title: Text(
                                notification.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(notification.message),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

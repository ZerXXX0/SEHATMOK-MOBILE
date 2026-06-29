import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../config/app_config.dart';
import '../../../models/dashboard_summary_model.dart';
import '../../../models/fridge_item_model.dart';
import '../../../models/meal_plan_model.dart';
import '../../../models/recipe_model.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../services/fridge_service.dart';
import '../../../services/meal_plan_service.dart';
import '../../../services/recipe_service.dart';
import '../../../widgets/common_widgets.dart';
import '../../auth/screens/login_screen.dart';
import 'notification_screen.dart';
import 'add_recipe_screen.dart';
import 'ai_generate_screen.dart';
import 'grocery_screen.dart';
import 'logs_screen.dart';
import '../../../models/ai_recipe_model.dart';
import '../../../models/hydration_model.dart';
import '../../../models/nutrition_log_model.dart';
import '../../../services/hydration_service.dart';
import '../../../services/logs_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthService>().currentUser == null) {
        context.read<AuthService>().getCurrentUser().catchError((_) => null);
      }
    });
  }

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SehatMok'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          Consumer<AuthService>(
            builder: (context, authService, _) {
              final user = authService.currentUser;
              String? avatarPath = user?.avatarUrl;
              String? fullAvatarUrl;
              if (avatarPath != null && avatarPath.isNotEmpty) {
                if (avatarPath.startsWith('http')) {
                  fullAvatarUrl = avatarPath;
                } else {
                  final base = AppConfig.apiBaseUrl.endsWith('/')
                      ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
                      : AppConfig.apiBaseUrl;
                  final path = avatarPath.startsWith('/') ? avatarPath : '/$avatarPath';
                  fullAvatarUrl = '$base$path';
                }
              }

              return GestureDetector(
                onTap: () {
                  setState(() => _currentIndex = 4);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 8),
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      child: ClipOval(
                        child: fullAvatarUrl != null && fullAvatarUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: fullAvatarUrl,
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Icon(
                                  Icons.account_circle_outlined,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 24,
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.account_circle_outlined,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  size: 24,
                                ),
                              )
                            : Icon(
                                Icons.account_circle_outlined,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            label: 'Fridge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today_outlined),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const DashboardView();
      case 1:
        return const FridgeView();
      case 2:
        return const RecipesView();
      case 3:
        return const MealPlansView();
      case 4:
        return const ProfileView();
      default:
        return const DashboardView();
    }
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final summary = await context.read<DashboardService>().getSummary();
    List<NutritionLog> logs = [];
    try {
      logs = await context.read<LogsService>().getLogs();
    } catch (_) {
      // ignore
    }
    return {
      'summary': summary,
      'logs': logs,
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _dataFuture = _loadData();
    });
    await _dataFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return EmptyState(
            icon: Icons.insights_outlined,
            title: 'Unable to load dashboard',
            description: 'Check your connection and try again.',
            onRetry: _refresh,
          );
        }

        final data = snapshot.data!;
        final summary = data['summary'] as DashboardSummary;
        final logs = data['logs'] as List<NutritionLog>;
        final greetingName = summary.user.name?.trim().isNotEmpty == true
            ? summary.user.name!
            : summary.user.email;
        final displayIntake = summary.totalIntakeToday + summary.caloriesCurrent;
        final displayRemaining = summary.targetCalories - displayIntake + summary.totalOuttakeToday;
        final progress = summary.targetCalories > 0
            ? displayIntake / summary.targetCalories
            : 0.0;
        final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
        final hydrationProgress = summary.hydration.targetMl > 0
            ? summary.hydration.amountMl / summary.hydration.targetMl
            : 0.0;
        final clampedHydrationProgress = hydrationProgress
            .clamp(0.0, 1.0)
            .toDouble();

        int logIntakeToday = 0;
        int logOuttakeToday = 0;
        final today = DateTime.now();
        for (final log in logs) {
          final isToday = log.createdAt.year == today.year &&
              log.createdAt.month == today.month &&
              log.createdAt.day == today.day;
          if (isToday) {
            if (log.type == 'INTAKE') {
              logIntakeToday += log.calories;
            } else if (log.type == 'OUTTAKE') {
              logOuttakeToday += log.calories;
            }
          }
        }
        final logNetToday = logIntakeToday - logOuttakeToday;
        final logProgress = summary.targetCalories > 0
            ? logIntakeToday / summary.targetCalories
            : 0.0;
        final clampedLogProgress = logProgress.clamp(0.0, 1.0).toDouble();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $greetingName',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your nutrition and stay healthy',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Today\'s Nutrition Plan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  onTap: () {
                    context.findAncestorStateOfType<_HomeScreenState>()?.changeTab(3);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NutritionItem(
                              label: 'Calories',
                              value: '$displayIntake',
                              target: '${summary.targetCalories}',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            _NutritionItem(
                              label: 'Protein',
                              value: '${summary.macroCurrent.proteinG}g',
                              target: '${summary.macroTargets.proteinG}g',
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            _NutritionItem(
                              label: 'Carbs',
                              value: '${summary.macroCurrent.carbsG}g',
                              target: '${summary.macroTargets.carbsG}g',
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: clampedProgress,
                            minHeight: 8,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$displayRemaining kcal remaining',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Today\'s Nutrition (Logs)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LogsScreen()),
                    ).then((_) => _refresh());
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Intake',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$logIntakeToday kcal',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Outtake',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$logOuttakeToday kcal',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Net Calorie',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$logNetToday kcal',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: logNetToday > summary.targetCalories
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: clampedLogProgress,
                            minHeight: 8,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(logProgress * 100).round()}% of target intake',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Hydration', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${summary.hydration.amountMl} ml',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Target ${summary.hydration.targetMl} ml',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: clampedHydrationProgress,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      label: 'Fridge Items',
                      value: '${summary.fridgeItemCount}',
                      icon: Icons.kitchen_outlined,
                      onTap: () {
                        context.findAncestorStateOfType<_HomeScreenState>()?.changeTab(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCard(
                      label: 'Grocery',
                      value: '${summary.activeGroceryCount}',
                      icon: Icons.shopping_cart_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GroceryScreen()),
                        ).then((_) => _refresh());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OverviewCard(
                      label: 'Near Expiry',
                      value: '${summary.nearExpiryCount}',
                      icon: Icons.warning_amber_rounded,
                      onTap: () {
                        context.findAncestorStateOfType<_HomeScreenState>()?.changeTab(1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OverviewCard(
                      label: 'Expired',
                      value: '${summary.expiredCount}',
                      icon: Icons.report_gmailerrorred_outlined,
                      onTap: () {
                        context.findAncestorStateOfType<_HomeScreenState>()?.changeTab(1);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Near Expiry Items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (summary.nearExpiryItems.isEmpty)
                Text(
                  'No items are near expiry.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...summary.nearExpiryItems.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.expiryLabel),
                      trailing: Text('${item.quantity} ${item.unit}'),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              if (summary.mealPlanMissingSlots.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.today_outlined),
                    title: const Text('Meal plan missing'),
                    subtitle: Text(summary.mealPlanMissingSlots.join(', ')),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final Color color;

  const _NutritionItem({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          'of $target',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FridgeView extends StatefulWidget {
  const FridgeView({Key? key}) : super(key: key);

  @override
  State<FridgeView> createState() => _FridgeViewState();
}

class _FridgeViewState extends State<FridgeView> {
  static const List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Proteins',
    'Dairy',
    'Grains',
    'Other',
  ];
  late Future<List<FridgeItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<FridgeItem>> _loadItems() {
    return context.read<FridgeService>().getFridgeItems();
  }

  Future<void> _refresh() async {
    setState(() {
      _itemsFuture = _loadItems();
    });
    await _itemsFuture;
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    String selectedCategory = 'Vegetables';
    final quantityController = TextEditingController(text: '1');
    final unitController = TextEditingController();
    final expiryController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Fridge Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: expiryController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              expiryController.text = _formatDate(picked);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true) {
      return;
    }

    final name = nameController.text.trim();
    final category = selectedCategory;
    final quantity = double.tryParse(quantityController.text.trim());
    final unit = unitController.text.trim();
    final expiryText = expiryController.text.trim();
    DateTime? expiryDate;

    if (expiryText.isNotEmpty) {
      expiryDate = DateTime.tryParse('${expiryText}T00:00:00');
    }

    if (name.isEmpty || category.isEmpty || unit.isEmpty || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    try {
      await context.read<FridgeService>().addFridgeItem(
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
      );
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add item.')));
    }
  }

  Future<void> _showEditDialog(FridgeItem item) async {
    final nameController = TextEditingController(text: item.name);
    String selectedCategory = _categories.contains(item.category) ? item.category : 'Other';
    final quantityController = TextEditingController(text: item.quantity.toString());
    final unitController = TextEditingController(text: item.unit);
    final expiryController = TextEditingController(
      text: item.expiryDate != null ? _formatDate(item.expiryDate!) : '',
    );

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Fridge Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: expiryController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'Select Date',
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: item.expiryDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              expiryController.text = _formatDate(picked);
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true) {
      return;
    }

    final name = nameController.text.trim();
    final category = selectedCategory;
    final quantity = double.tryParse(quantityController.text.trim());
    final unit = unitController.text.trim();
    final expiryText = expiryController.text.trim();
    DateTime? expiryDate;

    if (expiryText.isNotEmpty) {
      expiryDate = DateTime.tryParse('${expiryText}T00:00:00');
    }

    if (name.isEmpty || category.isEmpty || unit.isEmpty || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    try {
      await context.read<FridgeService>().updateFridgeItem(
        id: item.id,
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
        clearExpiryDate: expiryText.isEmpty,
      );
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update item.')));
    }
  }

  Future<void> _showDeleteConfirmation(FridgeItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteItem(item);
    }
  }

  Future<void> _deleteItem(FridgeItem item) async {
    try {
      await context.read<FridgeService>().deleteFridgeItem(item.id);
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete item.')));
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.eco;
      case 'fruits':
        return Icons.apple;
      case 'proteins':
        return Icons.egg;
      case 'dairy':
        return Icons.local_drink;
      case 'grains':
        return Icons.grass;
      default:
        return Icons.kitchen;
    }
  }

  Color _getExpiryColor(BuildContext context, DateTime? expiryDate) {
    if (expiryDate == null) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
    final difference = expiryDate.difference(DateTime.now()).inDays;
    if (difference < 0) {
      return Theme.of(context).colorScheme.error;
    } else if (difference <= 3) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FridgeItem>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.kitchen_outlined,
            title: 'Unable to load fridge items',
            description: 'Check your connection and try again.',
            onRetry: _refresh,
          );
        }

        final items = snapshot.data ?? [];

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fridge Items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.kitchen_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your fridge is empty',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items to track what you have at home.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showAddDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...items.map(
                (item) => Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onDismissed: (_) => _deleteItem(item),
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(item.category),
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.quantity} ${item.unit} • ${item.category}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatExpiry(item.expiryDate),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _getExpiryColor(context, item.expiryDate),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () => _showEditDialog(item),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                onPressed: () => _showDeleteConfirmation(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RecipesView extends StatefulWidget {
  const RecipesView({Key? key}) : super(key: key);

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  final _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecipes({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final recipes = await context.read<RecipeService>().getRecipes(
        query: query,
      );
      setState(() {
        _recipes = recipes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load recipes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showRecipeDetails(Recipe recipe) async {
    try {
      final details = await context.read<RecipeService>().getRecipeDetails(
        recipe.id,
      );

      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    if (details.description != null) ...[
                      const SizedBox(height: 8),
                      Text(details.description!),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...?details.ingredients?.map(
                      (ingredient) => Text(
                        '- ${ingredient.name}${_formatIngredientSuffix(ingredient)}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Steps',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...?details.steps?.map(
                      (step) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(step),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load recipe details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search recipes',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _fetchRecipes();
                },
              ),
            ),
            onSubmitted: (value) => _fetchRecipes(query: value.trim()),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Recipe'),
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddRecipeScreen(),
                        ),
                      );
                      if (result == true) {
                        _fetchRecipes();
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI Generate'),
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiGenerateScreen(),
                        ),
                      );
                      if (result == true) {
                        _fetchRecipes();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_errorMessage != null) ErrorBanner(message: _errorMessage!),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_recipes.isEmpty)
            const Expanded(
              child: EmptyState(
                icon: Icons.restaurant_menu,
                title: 'No recipes found',
                description: 'Try a different search or refresh the list.',
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchRecipes(query: _searchController.text),
                child: ListView.builder(
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showRecipeDetails(recipe),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.menu_book_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      recipe.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _buildRecipeSubtitle(recipe),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Recipe'),
                                      content: Text('Are you sure you want to delete "${recipe.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await context.read<RecipeService>().deleteRecipe(recipe.id);
                                      _fetchRecipes(query: _searchController.text);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Recipe deleted successfully.')),
                                        );
                                      }
                                    } catch (_) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to delete recipe.')),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MealPlansView extends StatefulWidget {
  const MealPlansView({Key? key}) : super(key: key);

  @override
  State<MealPlansView> createState() => _MealPlansViewState();
}

class _MealPlansViewState extends State<MealPlansView> {
  late Future<(MealPlanDay, HydrationSummary)> _plansFuture;
  late String _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = _formatDate(DateTime.now());
    _plansFuture = _loadPlans();
  }

  Future<(MealPlanDay, HydrationSummary)> _loadPlans() async {
    final results = await Future.wait([
      context.read<MealPlanService>().getMealPlans(date: _currentDate),
      context.read<HydrationService>().getHydration(date: _currentDate),
    ]);
    return (results[0] as MealPlanDay, results[1] as HydrationSummary);
  }

  Future<void> _refresh() async {
    setState(() {
      _plansFuture = _loadPlans();
    });
    await _plansFuture;
  }

  Future<void> _deleteItem(MealPlanItem item) async {
    try {
      await context.read<MealPlanService>().deleteMealPlanItem(item.id);
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete meal plan item.')),
      );
    }
  }

  Future<void> _updateWater(int deltaMl) async {
    try {
      await context.read<HydrationService>().updateHydration(
        date: _currentDate,
        deltaMl: deltaMl,
      );
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update water intake.')),
      );
    }
  }

  Future<void> _showEditWaterDialog(HydrationSummary hydration) async {
    final amountController = TextEditingController(text: hydration.amountMl.toString());
    final targetController = TextEditingController(text: hydration.targetMl.toString());
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Water Intake'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Current Intake (ml)',
                    suffixText: 'ml',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    final parsed = int.tryParse(val.trim());
                    if (parsed == null || parsed < 0) return 'Enter a valid non-negative number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Daily Goal (ml)',
                    suffixText: 'ml',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Required';
                    final parsed = int.tryParse(val.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final amount = int.parse(amountController.text.trim());
                final target = int.parse(targetController.text.trim());
                Navigator.of(context).pop();
                
                try {
                  await context.read<HydrationService>().updateHydration(
                    date: _currentDate,
                    amountMl: amount,
                    targetMl: target,
                  );
                  await _refresh();
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update water intake.')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPlanMealDialog(String slot) async {
    List<Recipe> recipes = [];
    try {
      recipes = await context.read<RecipeService>().getRecipes();
    } catch (_) {}

    List<FridgeItem> fridgeItems = [];
    try {
      fridgeItems = await context.read<FridgeService>().getFridgeItems();
    } catch (_) {}

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _PlanMealBottomSheet(
          slot: slot,
          date: _currentDate,
          recipes: recipes,
          fridgeItems: fridgeItems,
          onSuccess: () {
            Navigator.of(context).pop();
            _refresh();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(MealPlanDay, HydrationSummary)>(
      future: _plansFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return EmptyState(
            icon: Icons.today_outlined,
            title: 'Unable to load meal plans',
            description: 'Check your connection and try again.',
            onRetry: _refresh,
          );
        }

        final (mealPlan, hydration) = snapshot.data!;
        
        final breakfastItem = mealPlan.items.firstWhere(
          (item) => item.slot == 'BREAKFAST',
          orElse: () => const MealPlanItem(id: '', slot: 'BREAKFAST', recipe: null),
        );
        final lunchItem = mealPlan.items.firstWhere(
          (item) => item.slot == 'LUNCH',
          orElse: () => const MealPlanItem(id: '', slot: 'LUNCH', recipe: null),
        );
        final dinnerItem = mealPlan.items.firstWhere(
          (item) => item.slot == 'DINNER',
          orElse: () => const MealPlanItem(id: '', slot: 'DINNER', recipe: null),
        );

        final List<MealPlanItem> slots = [
          breakfastItem,
          lunchItem,
          dinnerItem,
        ];

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Meal Plans (${mealPlan.date})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...slots.map(
                (item) {
                  final isPlanned = item.recipe != null;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isPlanned
                                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
                                  : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlanned ? Icons.restaurant : Icons.restaurant_menu_outlined,
                              color: isPlanned
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatSlot(item.slot),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPlanned
                                      ? '${item.recipe!.name}\n${item.recipe!.calories ?? 0} kcal | P: ${item.recipe!.protein ?? 0}g | C: ${item.recipe!.carbs ?? 0}g | F: ${item.recipe!.fat ?? 0}g'
                                      : 'Nothing planned yet',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isPlanned
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          isPlanned
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                  onPressed: () => _deleteItem(item),
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 22,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                  onPressed: () => _showPlanMealDialog(item.slot),
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Water Consumption',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showEditWaterDialog(hydration),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${hydration.amountMl} / ${hydration.targetMl} ml',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            hydration.targetMl > 0
                                ? '${(hydration.amountMl / hydration.targetMl * 100).clamp(0.0, 100.0).toStringAsFixed(0)}%'
                                : '0%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: hydration.targetMl > 0
                              ? (hydration.amountMl / hydration.targetMl).clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _updateWater(250),
                            icon: const Icon(Icons.local_drink),
                            label: const Text('+250 ml'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _updateWater(500),
                            icon: const Icon(Icons.local_drink),
                            label: const Text('+500 ml'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: hydration.amountMl >= 250
                                ? () => _updateWater(-250)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanMealBottomSheet extends StatefulWidget {
  final String slot;
  final String date;
  final List<Recipe> recipes;
  final List<FridgeItem> fridgeItems;
  final VoidCallback onSuccess;

  const _PlanMealBottomSheet({
    Key? key,
    required this.slot,
    required this.date,
    required this.recipes,
    required this.fridgeItems,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<_PlanMealBottomSheet> createState() => _PlanMealBottomSheetState();
}

class _PlanMealBottomSheetState extends State<_PlanMealBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Recipe? _selectedRecipe;

  // Custom log controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController(text: '0');
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  final _fiberController = TextEditingController(text: '0');

  final Set<String> _selectedFridgeItemIds = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.recipes.isNotEmpty) {
      _selectedRecipe = widget.recipes.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  Future<void> _submitExisting() async {
    if (_selectedRecipe == null) return;
    setState(() => _isSaving = true);
    try {
      await context.read<MealPlanService>().upsertMealPlan(
        date: widget.date,
        slot: widget.slot,
        recipeId: _selectedRecipe!.id,
      );
      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add meal plan: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _submitCustom() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final calories = int.tryParse(_caloriesController.text.trim()) ?? 0;
      final protein = double.tryParse(_proteinController.text.trim()) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text.trim()) ?? 0.0;
      final fat = double.tryParse(_fatController.text.trim()) ?? 0.0;
      final fiber = double.tryParse(_fiberController.text.trim()) ?? 0.0;

      // Map chosen fridge items to recipe ingredients
      final List<RecipeIngredient> ingredients = [];
      for (final id in _selectedFridgeItemIds) {
        final item = widget.fridgeItems.firstWhere((x) => x.id == id);
        ingredients.add(RecipeIngredient(
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
        ));
      }

      if (ingredients.isEmpty) {
        // Just add a generic ingredient representing the meal itself so Zod validation is satisfied
        ingredients.add(RecipeIngredient(
          name: name,
          quantity: 1.0,
          unit: 'serving',
        ));
      }

      final candidate = AiRecipeCandidate(
        name: name,
        description: 'Ad-hoc meal planned for ${widget.slot.toLowerCase()} on ${widget.date}',
        servings: 1,
        cookTimeMinutes: 5,
        ingredients: ingredients,
        steps: ['Enjoy your meal!'],
        nutrition: NutritionInfo(
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
        ),
        matchedIngredientCount: ingredients.length,
        totalRequiredIngredientCount: ingredients.length,
        ingredientMatchPercent: 100,
        missingIngredients: [],
      );

      // Save custom recipe
      final savedRecipe = await context.read<RecipeService>().saveAiRecipe(candidate);

      // Link to meal plan
      await context.read<MealPlanService>().upsertMealPlan(
        date: widget.date,
        slot: widget.slot,
        recipeId: savedRecipe.recipeId,
      );

      widget.onSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save manual log: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plan ${_formatSlot(widget.slot)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Saved Recipes'),
                Tab(text: 'Manual Log'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Saved Recipes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.recipes.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No saved recipes found.\nTry adding a custom recipe or using AI Chef first.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else ...[
                        const Text('Select one of your recipes:'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Recipe>(
                          value: _selectedRecipe,
                          isExpanded: true,
                          items: widget.recipes.map((r) {
                            return DropdownMenuItem<Recipe>(
                              value: r,
                              child: Text(r.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedRecipe = val);
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submitExisting,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Add to Meal Plan'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Tab 2: Manual Log
                  Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Meal / Item Name',
                            hintText: 'e.g., Apple with Peanut Butter',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _caloriesController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Calories',
                                  suffixText: 'kcal',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _proteinController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Protein',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _carbsController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Carbs',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _fatController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Fat',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _fiberController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Fiber',
                                  suffixText: 'g',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (widget.fridgeItems.isNotEmpty) ...[
                          const Text(
                            'Select ingredients from fridge (optional):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: widget.fridgeItems.map((item) {
                              final isSelected = _selectedFridgeItemIds.contains(item.id);
                              return FilterChip(
                                selected: isSelected,
                                label: Text(item.name),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFridgeItemIds.add(item.id);
                                    } else {
                                      _selectedFridgeItemIds.remove(item.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submitCustom,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.check),
                          label: const Text('Save & Plan Meal'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Future<User> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<User> _loadProfile() {
    return context.read<AuthService>().getCurrentUser();
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = _loadProfile();
    });
    await _profileFuture;
  }

  Future<void> _updateProfilePicture(String? currentAvatarUrl) async {
    final picker = ImagePicker();
    final urlController = TextEditingController(text: currentAvatarUrl ?? '');

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Enter Image URL'),
              onTap: () => Navigator.of(context).pop('url'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    if (choice == 'gallery') {
      try {
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );

        if (image == null) return;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uploading avatar...')),
          );
        }

        final authService = context.read<AuthService>();
        final uploadedUrl = await authService.uploadAvatar(filePath: image.path);
        
        await authService.updateProfile(avatarUrl: uploadedUrl);
        await _refresh();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload profile picture: $e')),
          );
        }
      }
    } else if (choice == 'url') {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enter Image URL'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com/avatar.jpg',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (shouldSave != true) return;

      final url = urlController.text.trim();
      if (url.isEmpty) return;

      try {
        await context.read<AuthService>().updateProfile(avatarUrl: url);
        await _refresh();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully!')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile picture.')),
          );
        }
      }
    }
  }

  Future<void> _updateTargetCalories() async {
    final controller = TextEditingController();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Target Calories'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 2100'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    final value = int.tryParse(controller.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid number.')));
      return;
    }

    try {
      await context.read<AuthService>().updateProfile(targetCalories: value);
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  Future<void> _updateWeight(double? currentWeight) async {
    final controller = TextEditingController(text: currentWeight?.toString() ?? '');

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'e.g. 70.5', suffixText: 'kg'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    final value = double.tryParse(controller.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid weight.')));
      return;
    }

    try {
      await context.read<AuthService>().updateProfile(weight: value);
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update weight.')),
      );
    }
  }

  Future<void> _updateHeight(double? currentHeight) async {
    final controller = TextEditingController(text: currentHeight?.toString() ?? '');

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Height'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'e.g. 175.0', suffixText: 'cm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    final value = double.tryParse(controller.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid height.')));
      return;
    }

    try {
      await context.read<AuthService>().updateProfile(height: value);
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update height.')),
      );
    }
  }

  Future<void> _updateAge(int? currentAge) async {
    final controller = TextEditingController(text: currentAge?.toString() ?? '');

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Age'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'e.g. 25'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    final value = int.tryParse(controller.text.trim());
    if (value == null || value < 10 || value > 120) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid age (10-120).')));
      return;
    }

    try {
      await context.read<AuthService>().updateProfile(age: value);
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update age.')),
      );
    }
  }

  Future<void> _updateActivityLevel(String? currentLevel) async {
    String selectedLevel = currentLevel ?? 'MODERATE';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Activity Level'),
        content: DropdownButtonFormField<String>(
          value: selectedLevel,
          items: const [
            DropdownMenuItem(value: 'SEDENTARY', child: Text('Sedentary')),
            DropdownMenuItem(value: 'LIGHT', child: Text('Lightly active')),
            DropdownMenuItem(value: 'MODERATE', child: Text('Moderately active')),
            DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
            DropdownMenuItem(value: 'VERY_ACTIVE', child: Text('Very active')),
          ],
          onChanged: (val) {
            if (val != null) {
              selectedLevel = val;
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    try {
      await context.read<AuthService>().updateProfile(activityLevel: selectedLevel);
      await _refresh();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update activity level.')),
      );
    }
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.edit_outlined, size: 18),
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return EmptyState(
            icon: Icons.person_outline,
            title: 'Unable to load profile',
            description: 'Check your connection and try again.',
            onRetry: _refresh,
          );
        }

        final user = snapshot.data!;

        // Dynamic client-side calculation fallback for BMR / TDEE
        int bmrVal = user.bmr ?? 0;
        int tdeeVal = user.tdee ?? 0;

        if (bmrVal == 0 && user.weight != null && user.height != null) {
          final ageVal = user.age ?? 25;
          bmrVal = (66.47 + (13.75 * user.weight!) + (5.003 * user.height!) - (6.755 * ageVal)).round();
        }
        if (tdeeVal == 0 && bmrVal > 0) {
          final activity = user.activityLevel ?? 'MODERATE';
          double multiplier = 1.55;
          if (activity == 'SEDENTARY') multiplier = 1.2;
          else if (activity == 'LIGHT') multiplier = 1.375;
          else if (activity == 'MODERATE') multiplier = 1.55;
          else if (activity == 'ACTIVE') multiplier = 1.725;
          else if (activity == 'VERY_ACTIVE') multiplier = 1.9;
          tdeeVal = (bmrVal * multiplier).round();
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              (() {
                String? avatarPath = user.avatarUrl;
                String? fullAvatarUrl;
                if (avatarPath != null && avatarPath.isNotEmpty) {
                  if (avatarPath.startsWith('http')) {
                    fullAvatarUrl = avatarPath;
                  } else {
                    final base = AppConfig.apiBaseUrl.endsWith('/')
                        ? AppConfig.apiBaseUrl.substring(0, AppConfig.apiBaseUrl.length - 1)
                        : AppConfig.apiBaseUrl;
                    final path = avatarPath.startsWith('/') ? avatarPath : '/$avatarPath';
                    fullAvatarUrl = '$base$path';
                  }
                }

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _updateProfilePicture(user.avatarUrl),
                          child: Stack(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                ),
                                child: ClipOval(
                                  child: fullAvatarUrl != null && fullAvatarUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: fullAvatarUrl,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Icon(
                                            Icons.person,
                                            size: 36,
                                            color: Colors.grey,
                                          ),
                                          errorWidget: (context, url, error) => const Icon(
                                            Icons.person,
                                            size: 36,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 36,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.name ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => _updateProfilePicture(user.avatarUrl),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                            padding: const EdgeInsets.all(8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })(),
              _buildProfileItem(
                icon: Icons.calendar_today_outlined,
                title: 'Age',
                value: user.age != null ? '${user.age} years' : 'Not set',
                onTap: () => _updateAge(user.age),
              ),
              _buildProfileItem(
                icon: Icons.local_fire_department_outlined,
                title: 'Target Calories',
                value: '${user.targetCalories ?? 0} kcal',
                onTap: _updateTargetCalories,
              ),
              _buildProfileItem(
                icon: Icons.monitor_weight_outlined,
                title: 'Weight',
                value: '${user.weight ?? 0} kg',
                onTap: () => _updateWeight(user.weight),
              ),
              _buildProfileItem(
                icon: Icons.height_outlined,
                title: 'Height',
                value: '${user.height ?? 0} cm',
                onTap: () => _updateHeight(user.height),
              ),
              _buildProfileItem(
                icon: Icons.directions_run_outlined,
                title: 'Activity Level',
                value: user.activityLevel != null ? user.activityLevel! : 'Not set',
                onTap: () => _updateActivityLevel(user.activityLevel),
              ),
              _buildProfileItem(
                icon: Icons.bolt_outlined,
                title: 'BMR / TDEE',
                value: '$bmrVal / $tdeeVal kcal',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthService>().logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatExpiry(DateTime? expiryDate) {
  if (expiryDate == null) return 'No expiry';
  final date = expiryDate.toIso8601String().split('T').first;
  return 'Expires $date';
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatSlot(String slot) {
  switch (slot) {
    case 'BREAKFAST':
      return 'Breakfast';
    case 'LUNCH':
      return 'Lunch';
    case 'DINNER':
      return 'Dinner';
    default:
      return slot;
  }
}

String _formatIngredientSuffix(RecipeIngredient ingredient) {
  if (ingredient.quantity == null && ingredient.unit == null) {
    return '';
  }

  final parts = <String>[];
  if (ingredient.quantity != null) {
    parts.add('${ingredient.quantity}');
  }
  if (ingredient.unit != null && ingredient.unit!.isNotEmpty) {
    parts.add(ingredient.unit!);
  }
  return parts.isEmpty ? '' : ' (${parts.join(' ')})';
}

String _buildRecipeSubtitle(Recipe recipe) {
  final calories = recipe.calories != null ? '${recipe.calories} kcal' : null;
  final match = recipe.matchPercent != null
      ? '${recipe.matchPercent}% match'
      : null;
  final availability = recipe.ingredientAvailabilityPercent != null
      ? '${recipe.ingredientAvailabilityPercent}% ingredients'
      : null;

  return [
    calories,
    match,
    availability,
  ].whereType<String>().where((value) => value.isNotEmpty).join(' • ');
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

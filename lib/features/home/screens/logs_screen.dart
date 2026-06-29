import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/nutrition_log_model.dart';
import '../../../models/recipe_model.dart';
import '../../../services/logs_service.dart';
import '../../../services/recipe_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({Key? key}) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late Future<List<NutritionLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _logsFuture = context.read<LogsService>().getLogs();
    });
  }

  Future<void> _showAddLogDialog() async {
    final calorieController = TextEditingController();
    String logType = 'INTAKE';
    List<Recipe> savedRecipes = [];

    try {
      savedRecipes = await context.read<RecipeService>().getRecipes();
    } catch (_) {
      // ignore
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Calorie Log'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: logType,
                  decoration: const InputDecoration(labelText: 'Log Type'),
                  items: const [
                    DropdownMenuItem(
                      value: 'INTAKE',
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Intake (Food)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'OUTTAKE',
                      child: Row(
                        children: [
                          Icon(Icons.directions_run, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Outtake (Exercise)'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        logType = val;
                      });
                    }
                  },
                ),
                if (logType == 'INTAKE' && savedRecipes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Recipe?>(
                    decoration: const InputDecoration(
                      labelText: 'Select from Recipe',
                      hintText: 'Choose a recipe to autofill',
                    ),
                    items: [
                      const DropdownMenuItem<Recipe?>(
                        value: null,
                        child: Text('Custom Calories'),
                      ),
                      ...savedRecipes.map((r) => DropdownMenuItem<Recipe?>(
                            value: r,
                            child: Text('${r.name} (${r.calories ?? 0} kcal)'),
                          )),
                    ],
                    onChanged: (recipe) {
                      if (recipe != null) {
                        calorieController.text = '${recipe.calories ?? 0}';
                      } else {
                        calorieController.clear();
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: calorieController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal) *',
                    hintText: 'e.g. 350',
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    final caloriesStr = calorieController.text.trim();
    final calories = int.tryParse(caloriesStr);
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid calorie amount.')),
      );
      return;
    }

    try {
      await context.read<LogsService>().addLog(
            type: logType,
            calories: calories,
          );
      _loadLogs();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add log.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nutrition & Calorie Logs',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: FutureBuilder<List<NutritionLog>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading calorie logs.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadLogs,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final logs = snapshot.data ?? [];

          // Compute today's intake, outtake, and net calories
          int intakeSum = 0;
          int outtakeSum = 0;
          final today = DateTime.now();

          for (final log in logs) {
            final isToday = log.createdAt.year == today.year &&
                log.createdAt.month == today.month &&
                log.createdAt.day == today.day;
            if (isToday) {
              if (log.type == 'INTAKE') {
                intakeSum += log.calories;
              } else if (log.type == 'OUTTAKE') {
                outtakeSum += log.calories;
              }
            }
          }

          final netCalories = intakeSum - outtakeSum;

          return Column(
            children: [
              // Summary card at the top
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Today's Net Calories",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$netCalories kcal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.restaurant, size: 16, color: Colors.greenAccent),
                                SizedBox(width: 4),
                                Text('Intake', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$intakeSum kcal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white24,
                        ),
                        Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.directions_run, size: 16, color: Colors.orangeAccent),
                                SizedBox(width: 4),
                                Text('Outtake', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$outtakeSum kcal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'History Logs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text(
                          'No logs recorded yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final isIntake = log.type == 'INTAKE';
                          final formattedDate =
                              DateFormat('MMM dd, yyyy - hh:mm a').format(log.createdAt);

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isIntake
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                child: Icon(
                                  isIntake ? Icons.restaurant : Icons.directions_run,
                                  color: isIntake ? Colors.green : Colors.orange,
                                ),
                              ),
                              title: Text(
                                isIntake ? 'Calorie Intake' : 'Calorie Outtake',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                formattedDate,
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                isIntake ? '+${log.calories} kcal' : '-${log.calories} kcal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isIntake ? Colors.green : Colors.orange,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLogDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

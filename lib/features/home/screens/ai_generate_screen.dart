import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/fridge_item_model.dart';
import '../../../models/ai_recipe_model.dart';
import '../../../services/fridge_service.dart';
import '../../../services/recipe_service.dart';
import '../../../widgets/common_widgets.dart';

class AiGenerateScreen extends StatefulWidget {
  const AiGenerateScreen({Key? key}) : super(key: key);

  @override
  State<AiGenerateScreen> createState() => _AiGenerateScreenState();
}

class _AiGenerateScreenState extends State<AiGenerateScreen> {
  final _preferencesController = TextEditingController();
  List<FridgeItem> _fridgeItems = [];
  final Set<String> _selectedItemIds = {};
  bool _isLoadingFridge = true;
  bool _isGenerating = false;
  List<AiRecipeCandidate> _candidates = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFridgeItems();
  }

  @override
  void dispose() {
    _preferencesController.dispose();
    super.dispose();
  }

  Future<void> _loadFridgeItems() async {
    setState(() {
      _isLoadingFridge = true;
      _errorMessage = null;
    });

    try {
      final items = await context.read<FridgeService>().getFridgeItems();
      setState(() {
        _fridgeItems = items;
        _isLoadingFridge = false;
        // Pre-select first few items as a default helper
        if (items.isNotEmpty) {
          for (var i = 0; i < items.length && i < 3; i++) {
            _selectedItemIds.add(items[i].id);
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load fridge items: $e';
        _isLoadingFridge = false;
      });
    }
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
    });
  }

  Future<void> _generateRecipes() async {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one ingredient.')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _candidates = [];
    });

    try {
      final response = await context.read<RecipeService>().generateRecipesWithAI(
            selectedFridgeItemIds: _selectedItemIds.toList(),
            dietaryPreferences: _preferencesController.text.trim(),
          );
      setState(() {
        _candidates = response.candidates;
        _isGenerating = false;
      });
      if (response.candidates.isEmpty) {
        setState(() {
          _errorMessage = 'No recipe candidates returned from AI. Try different ingredients.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }

  Future<void> _saveRecipe(AiRecipeCandidate candidate) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await context.read<RecipeService>().saveAiRecipe(candidate);

      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "${candidate.name}" successfully!')),
      );

      Navigator.of(context).pop(true); // Pop back to recipes page with success status
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recipe Generator'),
      ),
      body: SafeArea(
        child: _isLoadingFridge
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header Card
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Atelier AI Chef",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Select ingredients from your fridge, specify any dietary preferences, and let AI generate personalized recipes for you.",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Ingredients selector
                  Text(
                    'Select Ingredients from Fridge',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_fridgeItems.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Your fridge is empty. Add ingredients to use AI generation.'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadFridgeItems,
                              child: const Text('Reload Fridge'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _fridgeItems.map((item) {
                        final isSelected = _selectedItemIds.contains(item.id);
                        return FilterChip(
                          selected: isSelected,
                          label: Text(
                            '${item.name} (${item.quantity} ${item.unit})',
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                          onSelected: (_) => _toggleItem(item.id),
                          selectedColor: Theme.of(context).colorScheme.primary,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Dietary preferences
                  Text(
                    'Dietary Preferences / Restrictions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _preferencesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Vegan, high protein, no peanuts, low sodium...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Generate Button
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateRecipes,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_isGenerating ? 'Generating Gourmet Suggestions...' : 'Generate AI Recipes'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    ErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 24),
                  ],

                  // AI Candidates list
                  if (_candidates.isNotEmpty) ...[
                    Text(
                      'AI Created Recipes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._candidates.map((candidate) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          title: Text(
                            candidate.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${candidate.cookTimeMinutes} mins • ${candidate.servings} servings • ${candidate.nutrition.calories} kcal',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    candidate.description,
                                    style: const TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Ingredients Needed:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...candidate.ingredients.map(
                                    (ing) => Text('- ${ing.name} (${ing.quantity} ${ing.unit})'),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Instructions:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...List.generate(
                                    candidate.steps.length,
                                    (idx) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4.0),
                                      child: Text('${idx + 1}. ${candidate.steps[idx]}'),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Nutrition Info:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Protein: ${candidate.nutrition.protein}g | Carbs: ${candidate.nutrition.carbs}g | Fat: ${candidate.nutrition.fat}g',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _saveRecipe(candidate),
                                      icon: const Icon(Icons.bookmark_add_outlined),
                                      label: const Text('Save to My Recipes'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
      ),
    );
  }
}

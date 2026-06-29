import 'package:logger/logger.dart';

import '../models/grocery_item_model.dart';
import 'api_service.dart';

class GroceryService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  GroceryService(this._apiService);

  Future<List<GroceryItem>> getItems() async {
    try {
      _logger.d('Fetching grocery items');
      final response = await _apiService.get('/api/grocery');

      return (response as List)
          .map((item) => GroceryItem.fromJson(item))
          .toList();
    } catch (e) {
      _logger.e('Error fetching grocery items: $e');
      rethrow;
    }
  }

  Future<GroceryItem> createItem({
    required String name,
    double? quantity,
    String? unit,
  }) async {
    try {
      _logger.d('Creating grocery item');

      final response = await _apiService.post(
        '/api/grocery',
        data: {
          'name': name,
          if (quantity != null) 'quantity': quantity,
          if (unit != null && unit.trim().isNotEmpty) 'unit': unit.trim(),
        },
      );

      return GroceryItem.fromJson(response);
    } catch (e) {
      _logger.e('Error creating grocery item: $e');
      rethrow;
    }
  }

  Future<GroceryItem> updateItem({
    required String id,
    String? name,
    double? quantity,
    String? unit,
    bool? isDone,
    bool clearQuantity = false,
    bool clearUnit = false,
  }) async {
    try {
      _logger.d('Updating grocery item');

      final data = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) data['name'] = name.trim();
      if (quantity != null || clearQuantity) data['quantity'] = quantity;
      if (unit != null || clearUnit) {
        final trimmed = unit?.trim();
        data['unit'] = trimmed == null || trimmed.isEmpty ? null : trimmed;
      }
      if (isDone != null) data['isDone'] = isDone;

      if (data.isEmpty) {
        throw Exception('No fields provided to update the grocery item.');
      }

      final response = await _apiService.patch(
        '/api/grocery/$id',
        data: data,
      );

      return GroceryItem.fromJson(response);
    } catch (e) {
      _logger.e('Error updating grocery item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      _logger.d('Deleting grocery item');
      await _apiService.delete('/api/grocery/$id');
    } catch (e) {
      _logger.e('Error deleting grocery item: $e');
      rethrow;
    }
  }
}

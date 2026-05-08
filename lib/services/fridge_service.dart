import 'package:logger/logger.dart';
import '../models/fridge_item_model.dart';
import 'api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_service.dart';

class FridgeService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  FridgeService(this._apiService);

  // Get all fridge items
  Future<List<FridgeItem>> getFridgeItems() async {
    try {
      _logger.d('Fetching fridge items');

      final response = await _apiService.get('/api/fridge');
      final items = (response as List)
          .map((item) => FridgeItem.fromJson(item))
          .toList();

      _logger.d('Fetched ${items.length} fridge items');
      try {
        await DatabaseService.instance.upsertFridgeItems(items);
      } catch (_) {}
      return items;
    } catch (e) {
      _logger.e('Error fetching fridge items: $e');
      // Fallback to cached items
      try {
        final cached = await DatabaseService.instance.getFridgeItems();
        if (cached.isNotEmpty) return cached;
      } catch (_) {}
      rethrow;
    }
  }

  // Add fridge item
  Future<FridgeItem> addFridgeItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    try {
      _logger.d('Adding fridge item: $name');

      final response = await _apiService.post(
        '/api/fridge',
        data: {
          'name': name,
          'category': category,
          'quantity': quantity,
          'unit': unit,
          if (expiryDate != null) 'expiryDate': expiryDate.toIso8601String(),
        },
      );

      final created = FridgeItem.fromJson(response);
      try {
        await DatabaseService.instance.upsertFridgeItems([created]);
      } catch (_) {}
      return created;
    } catch (e) {
      _logger.e('Error adding fridge item: $e');
      rethrow;
    }
  }

  // Update fridge item
  Future<FridgeItem> updateFridgeItem({
    required String id,
    required String name,
    required String category,
    required double quantity,
    required String unit,
    DateTime? expiryDate,
  }) async {
    try {
      _logger.d('Updating fridge item: $id');

      final response = await _apiService.put(
        '/api/fridge/$id',
        data: {
          'name': name,
          'category': category,
          'quantity': quantity,
          'unit': unit,
          if (expiryDate != null) 'expiryDate': expiryDate.toIso8601String(),
        },
      );

      final updated = FridgeItem.fromJson(response);
      try {
        await DatabaseService.instance.upsertFridgeItems([updated]);
      } catch (_) {}
      return updated;
    } catch (e) {
      _logger.e('Error updating fridge item: $e');
      rethrow;
    }
  }

  // Delete fridge item
  Future<void> deleteFridgeItem(String id) async {
    try {
      _logger.d('Deleting fridge item: $id');

      await _apiService.delete('/api/fridge/$id');
      _logger.d('Fridge item deleted');
      try {
        await DatabaseService.instance.deleteFridgeItem(id);
      } catch (_) {}
    } catch (e) {
      _logger.e('Error deleting fridge item: $e');
      rethrow;
    }
  }

  // Get items expiring soon
  Future<List<FridgeItem>> getExpiringItems() async {
    try {
      final items = await getFridgeItems();
      return items.where((item) => item.isExpiringSoon || item.isExpired).toList();
    } catch (e) {
      _logger.e('Error getting expiring items: $e');
      return [];
    }
  }

  // Group items by category
  Map<String, List<FridgeItem>> groupByCategory(List<FridgeItem> items) {
    final grouped = <String, List<FridgeItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }
}

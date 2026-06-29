import 'package:logger/logger.dart';
import '../models/fridge_item_model.dart';
import 'api_service.dart';
import 'database_service.dart';

class FridgeService {
  final ApiService _apiService;
  final Logger _logger = Logger();

  FridgeService(this._apiService);

  // Get fridge items (optionally near expiry)
  Future<List<FridgeItem>> getFridgeItems({bool nearExpiry = false}) async {
    try {
      _logger.d('Fetching fridge items');

      final itemsResponse = nearExpiry
          ? await _apiService.get(
              '/api/fridge',
              queryParameters: {'status': 'near-expiry'},
            )
          : await _apiService.get('/api/fridge');
      final items = (itemsResponse as List)
          .map((item) => FridgeItem.fromJson(item))
          .toList();

      _logger.d('Fetched ${items.length} fridge items');
      if (!nearExpiry) {
        try {
          await DatabaseService.instance.upsertFridgeItems(items);
        } catch (_) {}
      }
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
          if (expiryDate != null) 'expiryDate': expiryDate.toUtc().toIso8601String(),
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
    bool clearExpiryDate = false,
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
          if (expiryDate != null || clearExpiryDate)
            'expiryDate': expiryDate?.toUtc().toIso8601String(),
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

  // Get items expiring soon (server-calculated)
  Future<List<FridgeItem>> getExpiringItems() async {
    try {
      return await getFridgeItems(nearExpiry: true);
    } catch (e) {
      _logger.e('Error getting expiring items: $e');
      return [];
    }
  }

  // Delete all expired items
  Future<int> deleteExpiredItems() async {
    try {
      final response = await _apiService.delete(
        '/api/fridge/expired',
        fromJson: (data) => data,
      );

      if (response is Map<String, dynamic> && response['deletedCount'] is int) {
        return response['deletedCount'] as int;
      }

      return 0;
    } catch (e) {
      _logger.e('Error deleting expired items: $e');
      rethrow;
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

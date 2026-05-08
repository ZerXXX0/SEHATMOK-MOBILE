import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fridge_item_model.dart';
import '../models/recipe_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;
  DatabaseService._internal();
  static DatabaseService get instance => _instance;

  late Database _db;
  SharedPreferences? _prefs;
  final Logger _logger = Logger();
  bool _isWeb = false;

  Future<void> initialize() async {
    _isWeb = kIsWeb;
    if (_isWeb) {
      _prefs = await SharedPreferences.getInstance();
      _logger.d('DatabaseService initialized using SharedPreferences (web)');
      return;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'sehatmok.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE fridge_items(
          id TEXT PRIMARY KEY,
          data TEXT NOT NULL,
          updatedAt INTEGER
        )
        ''');

        await db.execute('''
        CREATE TABLE recipes(
          id TEXT PRIMARY KEY,
          data TEXT NOT NULL,
          updatedAt INTEGER
        )
        ''');
      },
    );

    _logger.d('Database initialized at $path');
  }

  // Fridge items
  Future<void> upsertFridgeItems(List<FridgeItem> items) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_isWeb) {
      final existing = await getFridgeItems();
      final map = {for (var e in existing) e.id: e};
      for (final item in items) {
        map[item.id] = item;
      }
      final jsonList = map.values.map((e) => jsonEncode(e.toJson())).toList();
      await _prefs!.setStringList('fridge_items', jsonList);
      _logger.d('Upserted ${items.length} fridge items (web)');
      return;
    }

    final batch = _db.batch();
    final nowMs = now;
    for (final item in items) {
      batch.insert(
        'fridge_items',
        {
          'id': item.id,
          'data': jsonEncode(item.toJson()),
          'updatedAt': nowMs,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    _logger.d('Upserted ${items.length} fridge items');
  }

  Future<List<FridgeItem>> getFridgeItems() async {
    if (_isWeb) {
      final list = _prefs?.getStringList('fridge_items') ?? [];
      return list.map((s) {
        final data = jsonDecode(s) as Map<String, dynamic>;
        return FridgeItem.fromJson(data);
      }).toList();
    }

    final rows = await _db.query('fridge_items');
    return rows.map((r) {
      final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
      return FridgeItem.fromJson(data);
    }).toList();
  }

  Future<void> clearFridgeItems() async {
    if (_isWeb) {
      await _prefs?.remove('fridge_items');
      _logger.d('Cleared fridge items (web)');
      return;
    }
    await _db.delete('fridge_items');
    _logger.d('Cleared fridge items');
  }

  Future<void> deleteFridgeItem(String id) async {
    if (_isWeb) {
      final list = _prefs?.getStringList('fridge_items') ?? [];
      final filtered = list.where((s) {
        final data = jsonDecode(s) as Map<String, dynamic>;
        return data['id'] != id;
      }).toList();
      await _prefs?.setStringList('fridge_items', filtered);
      _logger.d('Deleted fridge item $id (web)');
      return;
    }
    await _db.delete('fridge_items', where: 'id = ?', whereArgs: [id]);
    _logger.d('Deleted fridge item $id');
  }

  // Recipes
  Future<void> upsertRecipes(List<Recipe> recipes) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_isWeb) {
      final existing = await getRecipes();
      final map = {for (var e in existing) e.id: e};
      for (final r in recipes) {
        map[r.id] = r;
      }
      final jsonList = map.values.map((e) => jsonEncode(e.toJson())).toList();
      await _prefs!.setStringList('recipes', jsonList);
      _logger.d('Upserted ${recipes.length} recipes (web)');
      return;
    }

    final batch = _db.batch();
    final nowMs = now;
    for (final r in recipes) {
      batch.insert(
        'recipes',
        {
          'id': r.id,
          'data': jsonEncode(r.toJson()),
          'updatedAt': nowMs,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    _logger.d('Upserted ${recipes.length} recipes');
  }

  Future<List<Recipe>> getRecipes() async {
    if (_isWeb) {
      final list = _prefs?.getStringList('recipes') ?? [];
      return list.map((s) {
        final data = jsonDecode(s) as Map<String, dynamic>;
        return Recipe.fromJson(data);
      }).toList();
    }

    final rows = await _db.query('recipes');
    return rows.map((r) {
      final data = jsonDecode(r['data'] as String) as Map<String, dynamic>;
      return Recipe.fromJson(data);
    }).toList();
  }

  Future<void> clearRecipes() async {
    if (_isWeb) {
      await _prefs?.remove('recipes');
      _logger.d('Cleared recipes (web)');
      return;
    }
    await _db.delete('recipes');
    _logger.d('Cleared recipes');
  }

  Future<void> deleteRecipe(String id) async {
    if (_isWeb) {
      final list = _prefs?.getStringList('recipes') ?? [];
      final filtered = list.where((s) {
        final data = jsonDecode(s) as Map<String, dynamic>;
        return data['id'] != id;
      }).toList();
      await _prefs?.setStringList('recipes', filtered);
      _logger.d('Deleted recipe $id (web)');
      return;
    }
    await _db.delete('recipes', where: 'id = ?', whereArgs: [id]);
    _logger.d('Deleted recipe $id');
  }
}

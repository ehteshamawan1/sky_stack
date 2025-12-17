import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/player_data.dart';
import '../../features/city_builder/data/models/city_model.dart';

/// Service for managing Hive database initialization and boxes
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  /// Box names
  static const String playerDataBoxName = 'player_data';
  static const String cityBoxName = 'cities';
  static const String cacheBoxName = 'cache';

  /// Keys
  static const String currentPlayerKey = 'current_player';
  static const String currentCityKey = 'current_city';

  /// Boxes
  Box<PlayerData>? _playerDataBox;
  Box<CityModel>? _cityBox;
  Box<dynamic>? _cacheBox;

  /// Whether Hive has been initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Get player data box
  Box<PlayerData> get playerDataBox {
    if (_playerDataBox == null || !_playerDataBox!.isOpen) {
      throw StateError('PlayerData box not initialized. Call initialize() first.');
    }
    return _playerDataBox!;
  }

  /// Get city box
  Box<CityModel> get cityBox {
    if (_cityBox == null || !_cityBox!.isOpen) {
      throw StateError('City box not initialized. Call initialize() first.');
    }
    return _cityBox!;
  }

  /// Get cache box
  Box<dynamic> get cacheBox {
    if (_cacheBox == null || !_cacheBox!.isOpen) {
      throw StateError('Cache box not initialized. Call initialize() first.');
    }
    return _cacheBox!;
  }

  /// Initialize Hive and register all adapters
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Register adapters for City Builder
      _registerAdapterSafe<BuildingType>(BuildingTypeAdapter());
      _registerAdapterSafe<BuildingSlot>(BuildingSlotAdapter());
      _registerAdapterSafe<CityModel>(CityModelAdapter());

      // Register adapters for Player Data
      _registerAdapterSafe<PlayerSettings>(PlayerSettingsAdapter());
      _registerAdapterSafe<PlayerStats>(PlayerStatsAdapter());
      _registerAdapterSafe<AchievementStatus>(AchievementStatusAdapter());
      _registerAdapterSafe<AchievementRecord>(AchievementRecordAdapter());
      _registerAdapterSafe<PlayerUnlocks>(PlayerUnlocksAdapter());
      _registerAdapterSafe<PlayerData>(PlayerDataAdapter());

      // Open boxes
      _cityBox = await Hive.openBox<CityModel>(cityBoxName);
      _playerDataBox = await Hive.openBox<PlayerData>(playerDataBoxName);
      _cacheBox = await Hive.openBox<dynamic>(cacheBoxName);

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Safely register an adapter (skip if already registered)
  void _registerAdapterSafe<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  /// Get or create player data
  Future<PlayerData> getOrCreatePlayerData() async {
    var playerData = _playerDataBox?.get(currentPlayerKey);

    if (playerData == null) {
      playerData = PlayerData.create();
      await _playerDataBox?.put(currentPlayerKey, playerData);
    }

    return playerData;
  }

  /// Save player data
  Future<void> savePlayerData(PlayerData playerData) async {
    playerData.markModified();
    await _playerDataBox?.put(currentPlayerKey, playerData);
  }

  /// Get or create city
  Future<CityModel> getOrCreateCity() async {
    var city = _cityBox?.get(currentCityKey);

    if (city == null) {
      city = CityModel.create();
      await _cityBox?.put(currentCityKey, city);
    }

    return city;
  }

  /// Save city
  Future<void> saveCity(CityModel city) async {
    city.lastPlayedAt = DateTime.now();
    await _cityBox?.put(currentCityKey, city);
  }

  /// Update a city slot after completing a tower
  Future<void> updateCitySlot({
    required int slotIndex,
    required int towerHeight,
    required int score,
    required int population,
  }) async {
    final city = await getOrCreateCity();
    city.updateSlot(
      index: slotIndex,
      towerHeight: towerHeight,
      score: score,
      population: population,
    );
    await saveCity(city);
  }

  /// Clear all data (for debugging/reset)
  Future<void> clearAllData() async {
    await _playerDataBox?.clear();
    await _cityBox?.clear();
    await _cacheBox?.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    await _playerDataBox?.close();
    await _cityBox?.close();
    await _cacheBox?.close();
    _isInitialized = false;
  }

  /// Compact boxes (call periodically for optimization)
  Future<void> compact() async {
    await _playerDataBox?.compact();
    await _cityBox?.compact();
    await _cacheBox?.compact();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hive_service.dart';
import '../data/models/city_model.dart';

/// Notifier for managing the player's city
class CityNotifier extends StateNotifier<CityModel?> {
  final HiveService _hiveService = HiveService();

  CityNotifier() : super(null) {
    _loadCity();
  }

  /// Load city from Hive
  Future<void> _loadCity() async {
    try {
      final city = await _hiveService.getOrCreateCity();
      state = city;
    } catch (e) {
      // Error loading city - state remains null
    }
  }

  /// Save city to Hive
  Future<void> _save() async {
    if (state == null) return;
    await _hiveService.saveCity(state!);
  }

  /// Update a building slot after completing a tower
  Future<void> updateSlot({
    required int slotIndex,
    required int towerHeight,
    required int score,
    required int population,
    BuildingType? type,
  }) async {
    if (state == null) return;

    state!.updateSlot(
      index: slotIndex,
      towerHeight: towerHeight,
      score: score,
      population: population,
      type: type,
    );

    await _save();
    // Create a copy to trigger state update
    state = state!.copy();
  }

  /// Clear a building slot (demolish)
  Future<void> clearSlot(int slotIndex) async {
    if (state == null) return;

    state!.clearSlot(slotIndex);
    await _save();
    state = state!.copy();
  }

  /// Rename the city
  Future<void> renameCity(String newName) async {
    if (state == null) return;

    state!.rename(newName);
    await _save();
    state = state!.copy();
  }

  /// Reset the city (clear all buildings)
  Future<void> resetCity() async {
    if (state == null) return;

    state!.reset();
    await _save();
    state = state!.copy();
  }

  /// Get a specific slot
  BuildingSlot? getSlot(int index) {
    if (state == null || index < 0 || index >= CityModel.totalSlots) {
      return null;
    }
    return state!.getSlot(index);
  }

  /// Get the next empty slot index
  int? get nextEmptySlot => state?.nextEmptySlotIndex;

  /// Whether the city is complete
  bool get isComplete => state?.isComplete ?? false;

  /// Number of buildings built
  int get buildingsCount => state?.buildingsCount ?? 0;

  /// Total city score
  int get totalScore => state?.totalScore ?? 0;

  /// Total city population
  int get totalPopulation => state?.totalPopulation ?? 0;

  /// Highest tower in city
  int get highestTower => state?.highestTower ?? 0;

  /// Force refresh from storage
  Future<void> refresh() async {
    await _loadCity();
  }
}

/// Provider for the player's city
final cityProvider = StateNotifierProvider<CityNotifier, CityModel?>((ref) {
  return CityNotifier();
});

/// Provider for the number of buildings built
final buildingsCountProvider = Provider<int>((ref) {
  final city = ref.watch(cityProvider);
  return city?.buildingsCount ?? 0;
});

/// Provider for total city population
final cityPopulationProvider = Provider<int>((ref) {
  final city = ref.watch(cityProvider);
  return city?.totalPopulation ?? 0;
});

/// Provider for total city score
final cityScoreProvider = Provider<int>((ref) {
  final city = ref.watch(cityProvider);
  return city?.totalScore ?? 0;
});

/// Provider for whether city is complete
final cityCompleteProvider = Provider<bool>((ref) {
  final city = ref.watch(cityProvider);
  return city?.isComplete ?? false;
});

/// Provider for individual building slots
final buildingSlotProvider = Provider.family<BuildingSlot?, int>((ref, index) {
  final city = ref.watch(cityProvider);
  if (city == null || index < 0 || index >= CityModel.totalSlots) {
    return null;
  }
  return city.getSlot(index);
});

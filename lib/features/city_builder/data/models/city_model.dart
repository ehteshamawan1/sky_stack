import 'package:hive/hive.dart';

part 'city_model.g.dart';

/// Type of building in a city slot
@HiveType(typeId: 3)
enum BuildingType {
  @HiveField(0)
  residential,

  @HiveField(1)
  commercial,

  @HiveField(2)
  industrial,

  @HiveField(3)
  special,
}

/// Represents a single building slot in the city
@HiveType(typeId: 2)
class BuildingSlot {
  @HiveField(0)
  final int index;

  @HiveField(1)
  int? towerHeight;

  @HiveField(2)
  int? score;

  @HiveField(3)
  BuildingType type;

  @HiveField(4)
  int? population;

  @HiveField(5)
  DateTime? builtAt;

  BuildingSlot({
    required this.index,
    this.towerHeight,
    this.score,
    this.type = BuildingType.residential,
    this.population,
    this.builtAt,
  });

  /// Whether this slot has a building
  bool get isBuilt => towerHeight != null && towerHeight! > 0;

  /// Whether this slot is empty
  bool get isEmpty => !isBuilt;

  /// Create a copy with updated values
  BuildingSlot copyWith({
    int? index,
    int? towerHeight,
    int? score,
    BuildingType? type,
    int? population,
    DateTime? builtAt,
  }) {
    return BuildingSlot(
      index: index ?? this.index,
      towerHeight: towerHeight ?? this.towerHeight,
      score: score ?? this.score,
      type: type ?? this.type,
      population: population ?? this.population,
      builtAt: builtAt ?? this.builtAt,
    );
  }

  /// Create an empty slot
  factory BuildingSlot.empty(int index) {
    return BuildingSlot(index: index);
  }

  /// Update this slot with building data
  void updateBuilding({
    required int height,
    required int buildingScore,
    required int buildingPopulation,
    BuildingType? buildingType,
  }) {
    towerHeight = height;
    score = buildingScore;
    population = buildingPopulation;
    if (buildingType != null) {
      type = buildingType;
    }
    builtAt = DateTime.now();
  }

  /// Clear this slot (demolish building)
  void clear() {
    towerHeight = null;
    score = null;
    population = null;
    builtAt = null;
    type = BuildingType.residential;
  }

  @override
  String toString() {
    return 'BuildingSlot(index: $index, height: $towerHeight, score: $score, population: $population)';
  }
}

/// Represents a player's city with a 3x3 grid of building slots
@HiveType(typeId: 1)
class CityModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<BuildingSlot> slots;

  @HiveField(3)
  int unlockedSlots;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? lastPlayedAt;

  /// Grid size (3x3 = 9 slots)
  static const int gridSize = 3;
  static const int totalSlots = gridSize * gridSize;

  CityModel({
    required this.id,
    required this.name,
    required this.slots,
    this.unlockedSlots = totalSlots,
    DateTime? createdAt,
    this.lastPlayedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a new city with empty slots
  factory CityModel.create({String? name}) {
    return CityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name ?? 'My City',
      slots: List.generate(totalSlots, (i) => BuildingSlot.empty(i)),
    );
  }

  /// Get a specific slot by index
  BuildingSlot getSlot(int index) {
    if (index < 0 || index >= slots.length) {
      throw RangeError('Slot index $index is out of range');
    }
    return slots[index];
  }

  /// Whether the city is complete (all slots built)
  bool get isComplete => slots.every((slot) => slot.isBuilt);

  /// Number of buildings built
  int get buildingsCount => slots.where((slot) => slot.isBuilt).length;

  /// Total population across all buildings
  int get totalPopulation =>
      slots.fold(0, (sum, slot) => sum + (slot.population ?? 0));

  /// Total score across all buildings
  int get totalScore => slots.fold(0, (sum, slot) => sum + (slot.score ?? 0));

  /// Highest tower in the city
  int get highestTower {
    int max = 0;
    for (final slot in slots) {
      if (slot.towerHeight != null && slot.towerHeight! > max) {
        max = slot.towerHeight!;
      }
    }
    return max;
  }

  /// Average tower height (only counting built towers)
  double get averageTowerHeight {
    final builtSlots = slots.where((s) => s.isBuilt).toList();
    if (builtSlots.isEmpty) return 0;
    final total = builtSlots.fold(0, (sum, s) => sum + (s.towerHeight ?? 0));
    return total / builtSlots.length;
  }

  /// Get the next empty slot index, or null if city is full
  int? get nextEmptySlotIndex {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i].isEmpty) return i;
    }
    return null;
  }

  /// Update a specific slot with building data
  void updateSlot({
    required int index,
    required int towerHeight,
    required int score,
    required int population,
    BuildingType? type,
  }) {
    if (index < 0 || index >= slots.length) {
      throw RangeError('Slot index $index is out of range');
    }

    slots[index].updateBuilding(
      height: towerHeight,
      buildingScore: score,
      buildingPopulation: population,
      buildingType: type,
    );
    lastPlayedAt = DateTime.now();
  }

  /// Clear a specific slot (demolish building)
  void clearSlot(int index) {
    if (index < 0 || index >= slots.length) {
      throw RangeError('Slot index $index is out of range');
    }
    slots[index].clear();
  }

  /// Reset the entire city (clear all buildings)
  void reset() {
    for (final slot in slots) {
      slot.clear();
    }
  }

  /// Rename the city
  void rename(String newName) {
    name = newName;
  }

  /// Create a deep copy of this city (for state management)
  CityModel copy() {
    return CityModel(
      id: id,
      name: name,
      slots: slots.map((s) => s.copyWith()).toList(),
      unlockedSlots: unlockedSlots,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt,
    );
  }

  @override
  String toString() {
    return 'CityModel(id: $id, name: $name, buildings: $buildingsCount/$totalSlots, score: $totalScore)';
  }
}

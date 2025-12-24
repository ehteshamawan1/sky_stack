enum HazardType {
  wind,
  fastCrane,
}

class HazardDefinition {
  final HazardType type;
  final String name;
  final int startBlock;
  final double probability;
  final double durationSeconds;

  const HazardDefinition({
    required this.type,
    required this.name,
    required this.startBlock,
    required this.probability,
    required this.durationSeconds,
  });

  static const Map<HazardType, HazardDefinition> launch = {
    HazardType.wind: HazardDefinition(
      type: HazardType.wind,
      name: 'Wind Gust',
      startBlock: 10,
      probability: 0.18,
      durationSeconds: 3.0,
    ),
    HazardType.fastCrane: HazardDefinition(
      type: HazardType.fastCrane,
      name: 'Fast Crane',
      startBlock: 12,
      probability: 0.14,
      durationSeconds: 4.0,
    ),
  };
}

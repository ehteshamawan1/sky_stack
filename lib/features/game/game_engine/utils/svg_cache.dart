import 'package:flame_svg/flame_svg.dart';

/// Global SVG cache to avoid reloading the same SVGs multiple times
class SvgCache {
  static final SvgCache _instance = SvgCache._internal();
  factory SvgCache() => _instance;
  SvgCache._internal();

  final Map<String, Svg> _cache = {};
  final Map<String, Future<Svg>> _loading = {};

  /// Get SVG from cache or load it
  Future<Svg?> get(String path) async {
    // Return from cache if available
    if (_cache.containsKey(path)) {
      return _cache[path];
    }

    // If already loading, wait for it
    if (_loading.containsKey(path)) {
      return _loading[path];
    }

    // Start loading
    try {
      final future = Svg.load(path);
      _loading[path] = future;
      final svg = await future;
      _cache[path] = svg;
      _loading.remove(path);
      return svg;
    } catch (e) {
      _loading.remove(path);
      return null;
    }
  }

  /// Preload SVGs for a theme
  Future<void> preloadTheme(String theme) async {
    await Future.wait([
      get('svg/blocks/${theme}_block.svg'),
      get('svg/backgrounds/${theme}_sky.svg'),
      get('svg/backgrounds/${theme}_far.svg'),
      get('svg/backgrounds/${theme}_mid.svg'),
      get('svg/backgrounds/${theme}_near.svg'),
      get('svg/characters/${theme}_umbrella_person.svg'),
    ]);
  }

  /// Clear cache
  void clear() {
    _cache.clear();
    _loading.clear();
  }
}

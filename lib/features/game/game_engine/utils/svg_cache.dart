import 'package:flame_svg/flame_svg.dart';

/// Global SVG cache to avoid reloading the same SVGs multiple times
class SvgCache {
  static final SvgCache _instance = SvgCache._internal();
  factory SvgCache() => _instance;
  SvgCache._internal();

  final Map<String, Svg> _cache = {};
  final Map<String, Future<Svg>> _loading = {};
  final Map<String, int> _lastAccess = {};
  int _accessCounter = 0;
  static const int _maxCacheSize = 32;

  /// Get SVG from cache or load it
  Future<Svg?> get(String path) async {
    // Return from cache if available
    if (_cache.containsKey(path)) {
      _touch(path);
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
      _touch(path);
      _enforceLimit();
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
    _lastAccess.clear();
    _accessCounter = 0;
  }

  void _touch(String path) {
    _accessCounter++;
    _lastAccess[path] = _accessCounter;
  }

  void _enforceLimit() {
    if (_cache.length <= _maxCacheSize) return;

    final entries = _lastAccess.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final toRemove = _cache.length - _maxCacheSize;

    for (int i = 0; i < toRemove && i < entries.length; i++) {
      final key = entries[i].key;
      _cache.remove(key);
      _lastAccess.remove(key);
    }
  }
}

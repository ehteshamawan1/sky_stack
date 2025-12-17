import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/asset_paths.dart';

/// Service for preloading game assets to prevent lag on first game start
class AssetPreloader {
  static final AssetPreloader _instance = AssetPreloader._internal();
  factory AssetPreloader() => _instance;
  AssetPreloader._internal();

  bool _isPreloaded = false;
  bool get isPreloaded => _isPreloaded;

  /// Preload all critical game assets
  Future<void> preloadAssets(BuildContext context) async {
    if (_isPreloaded) return;

    try {
      // Preload SVG assets in parallel
      await Future.wait([
        // UI elements
        _preloadSvg(AssetPaths.appIcon),
        _preloadSvg(AssetPaths.btnPlay),
        _preloadSvg(AssetPaths.btnPause),
        _preloadSvg(AssetPaths.iconCoin),
        _preloadSvg(AssetPaths.iconHeart),
        _preloadSvg(AssetPaths.iconStar),

        // Block themes - preload default city theme
        _preloadSvg(AssetPaths.block('city')),

        // Backgrounds - preload city theme
        _preloadSvg(AssetPaths.bgSky('city')),
        _preloadSvg(AssetPaths.bgFar('city')),
        _preloadSvg(AssetPaths.bgMid('city')),
        _preloadSvg(AssetPaths.bgNear('city')),
      ]);

      _isPreloaded = true;
    } catch (e) {
      // Don't fail - assets will load on demand
      _isPreloaded = true;
    }
  }

  /// Preload SVG asset
  Future<void> _preloadSvg(String assetPath) async {
    try {
      final loader = SvgAssetLoader(assetPath);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    } catch (e) {
      // Silently fail - asset will load on demand
    }
  }

  /// Preload a specific theme's assets
  Future<void> preloadTheme(String themeId) async {
    try {
      await Future.wait([
        _preloadSvg(AssetPaths.block(themeId)),
        _preloadSvg(AssetPaths.bgSky(themeId)),
        _preloadSvg(AssetPaths.bgFar(themeId)),
        _preloadSvg(AssetPaths.bgMid(themeId)),
        _preloadSvg(AssetPaths.bgNear(themeId)),
      ]);
    } catch (e) {
      // Theme preload failed - will load on demand
    }
  }
}

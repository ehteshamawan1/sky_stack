import 'package:audioplayers/audioplayers.dart';
import '../constants/asset_paths.dart';

/// Audio context configured for game use - no audio focus stealing
final _gameAudioContext = AudioContext(
  iOS: AudioContextIOS(
    category: AVAudioSessionCategory.playback,
    options: {
      AVAudioSessionOptions.mixWithOthers,
    },
  ),
  android: AudioContextAndroid(
    isSpeakerphoneOn: false,
    stayAwake: false,
    contentType: AndroidContentType.music,
    usageType: AndroidUsageType.game,
    audioFocus: AndroidAudioFocus.none,
  ),
);

/// Service for managing game audio (SFX and Music)
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Music player (single instance for background music)
  AudioPlayer? _musicPlayer;

  // Pool of SFX players to reuse
  final List<AudioPlayer> _sfxPool = [];
  static const int _maxPoolSize = 8;

  // Settings
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _masterVolume = 1.0;
  double _sfxVolume = 1.0;
  double _musicVolume = 0.7;
  double _musicPlayerVolume = 0.7;

  // State
  bool _isInitialized = false;
  String? _currentMusic;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create music player with game audio context (no focus stealing)
      _musicPlayer = AudioPlayer();
      await _musicPlayer!.setAudioContext(_gameAudioContext);
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);

      // Pre-create SFX players for the pool with same audio context
      for (int i = 0; i < 4; i++) {
        final player = AudioPlayer();
        await player.setAudioContext(_gameAudioContext);
        await player.setReleaseMode(ReleaseMode.release);
        _sfxPool.add(player);
      }

      _isInitialized = true;
    } catch (e) {
      // Audio init failed - sounds will be silently skipped
    }
  }

  /// Update audio settings
  void updateSettings({
    bool? soundEnabled,
    bool? musicEnabled,
    double? masterVolume,
    double? sfxVolume,
    double? musicVolume,
  }) {
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    if (musicEnabled != null) {
      _musicEnabled = musicEnabled;
      if (!_musicEnabled) {
        stopMusic();
      }
    }
    if (masterVolume != null) _masterVolume = masterVolume;
    if (sfxVolume != null) _sfxVolume = sfxVolume;
    if (musicVolume != null) {
      _musicVolume = musicVolume;
      _musicPlayerVolume = _effectiveMusicVolume;
      _musicPlayer?.setVolume(_musicPlayerVolume);
    }
  }

  double get _effectiveSfxVolume => _masterVolume * _sfxVolume;
  double get _effectiveMusicVolume => _masterVolume * _musicVolume;

  /// Get an available player from pool or create new one
  AudioPlayer _getPlayer() {
    // Try to find a stopped player in the pool
    for (final player in _sfxPool) {
      if (player.state == PlayerState.stopped ||
          player.state == PlayerState.completed) {
        return player;
      }
    }

    // If pool not full, create new player
    if (_sfxPool.length < _maxPoolSize) {
      final player = AudioPlayer();
      player.setAudioContext(_gameAudioContext);
      player.setReleaseMode(ReleaseMode.release);
      _sfxPool.add(player);
      return player;
    }

    // Return first player (will interrupt current sound)
    return _sfxPool.first;
  }

  // ============ SFX Methods ============

  /// Play a sound effect
  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled || _effectiveSfxVolume <= 0) return;

    try {
      final player = _getPlayer();
      await player.stop();
      await player.setVolume(_effectiveSfxVolume);
      // Pass audio context with no focus to each play call
      await player.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
        ctx: _gameAudioContext,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      // SFX playback failed - ignore
    }
  }

  /// Play block drop sound
  Future<void> playBlockDrop() => playSfx(AssetPaths.sfxDrop);

  /// Play block land sound based on quality
  Future<void> playBlockLand(PlacementQuality quality) {
    switch (quality) {
      case PlacementQuality.perfect:
        return playSfx(AssetPaths.sfxPerfect);
      case PlacementQuality.good:
        return playSfx(AssetPaths.sfxGood);
      case PlacementQuality.bad:
        return playSfx(AssetPaths.sfxBad);
    }
  }

  /// Play block fall sound
  Future<void> playBlockFall() => playSfx(AssetPaths.sfxFall);

  /// Play tower collapse sound
  Future<void> playTowerCollapse() => playSfx(AssetPaths.sfxCollapse);

  /// Play combo sound based on combo level
  Future<void> playCombo(int comboLevel) {
    if (comboLevel >= 10) {
      return playSfx(AssetPaths.sfxCombo3);
    } else if (comboLevel >= 5) {
      return playSfx(AssetPaths.sfxCombo2);
    } else if (comboLevel >= 3) {
      return playSfx(AssetPaths.sfxCombo1);
    }
    return Future.value();
  }

  /// Play UI tap sound
  Future<void> playTap() => playSfx(AssetPaths.sfxTap);

  /// Play UI back sound
  Future<void> playBack() => playSfx(AssetPaths.sfxBack);

  /// Play achievement unlocked sound
  Future<void> playAchievement() => playSfx(AssetPaths.sfxAchievement);

  /// Play level up sound
  Future<void> playLevelUp() => playSfx(AssetPaths.sfxLevelUp);

  /// Play powerup pickup sound
  Future<void> playPowerupPickup() => playSfx(AssetPaths.sfxPowerupPickup);

  /// Play powerup use sound
  Future<void> playPowerupUse() => playSfx(AssetPaths.sfxPowerupUse);

  /// Play wind gust sound
  Future<void> playWindGust() => playSfx(AssetPaths.sfxWindGust);

  /// Play hazard warning sound
  Future<void> playHazardWarning() => playSfx(AssetPaths.sfxHazardWarning);

  // ============ Music Methods ============

  /// Play background music
  Future<void> playMusic(String assetPath) async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer?.stop();
      _currentMusic = assetPath;
      await _musicPlayer?.setReleaseMode(ReleaseMode.loop);
      _musicPlayerVolume = _effectiveMusicVolume;
      await _musicPlayer?.setVolume(_musicPlayerVolume);
      // Pass audio context with no focus to prevent SFX from stopping music
      await _musicPlayer?.play(
        AssetSource(assetPath.replaceFirst('assets/', '')),
        ctx: _gameAudioContext,
        mode: PlayerMode.mediaPlayer,
      );
    } catch (e) {
      // Music playback failed - ignore
    }
  }

  /// Play menu theme music
  Future<void> playMenuMusic() => playMusic(AssetPaths.musicMenu);

  /// Play game music for the selected theme
  Future<void> playGameMusic([String theme = 'city']) {
    return playMusic(AssetPaths.musicTheme(theme));
  }

  /// Play victory music
  Future<void> playVictoryMusic() => playMusic(AssetPaths.musicVictory);

  /// Stop music
  Future<void> stopMusic() async {
    await _musicPlayer?.stop();
    _currentMusic = null;
  }

  /// Pause music (optional fade)
  Future<void> pauseMusic({bool fade = true}) async {
    if (_musicPlayer == null) return;

    if (fade) {
      await _fadeMusic(to: 0.0, durationMs: 300);
    }
    await _musicPlayer?.pause();
  }

  /// Resume music (optional fade)
  Future<void> resumeMusic({bool fade = true}) async {
    if (!_musicEnabled || _currentMusic == null || _musicPlayer == null) {
      return;
    }

    await _musicPlayer?.resume();
    if (fade) {
      await _fadeMusic(to: _effectiveMusicVolume, durationMs: 300);
    }
  }

  Future<void> _fadeMusic({required double to, int durationMs = 300}) async {
    final player = _musicPlayer;
    if (player == null) return;

    final from = _musicPlayerVolume;
    final steps = 10;
    final stepDuration = (durationMs / steps).round();

    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      final volume = from + (to - from) * t;
      _musicPlayerVolume = volume;
      await player.setVolume(_musicPlayerVolume);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }

  /// Dispose all resources
  void dispose() {
    _musicPlayer?.dispose();
    _musicPlayer = null;
    for (final player in _sfxPool) {
      player.dispose();
    }
    _sfxPool.clear();
    _isInitialized = false;
  }
}

/// Placement quality enum for audio
enum PlacementQuality { perfect, good, bad }

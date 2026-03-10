import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    _loadSettings();
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  final AudioPlayer _musicPlayer = AudioPlayer();
  String? _currentMusic;
  double _masterVolume = 1.0;
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;

  double get masterVolume => _masterVolume;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isMusicEnabled => _isMusicEnabled;

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _masterVolume = prefs.getDouble('master_volume') ?? 1.0;
      _isSoundEnabled = prefs.getBool('is_sound_enabled') ?? true;
      _isMusicEnabled = prefs.getBool('is_music_enabled') ?? true;
      _applyVolume();
    } catch (e) {
      debugPrint('Error loading audio settings: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    _masterVolume = volume;
    _applyVolume();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('master_volume', _masterVolume);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_sound_enabled', _isSoundEnabled);
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    if (!_isMusicEnabled) {
      await _musicPlayer.pause();
    } else if (_currentMusic != null) {
      await _musicPlayer.resume();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_music_enabled', _isMusicEnabled);
    notifyListeners();
  }

  void _applyVolume() {
    _musicPlayer.setVolume(_isMusicEnabled ? _masterVolume : 0.0);
  }

  /// Plays a sound effect without interrupting background music or other SFX.
  Future<void> playSfx(String assetPath) async {
    if (!_isSoundEnabled) return;

    // Creating a one-shot player for SFX to allow overlapping sounds
    final player = AudioPlayer();
    await player.setVolume(_masterVolume);
    await player.play(AssetSource('sounds/$assetPath'));
    // Auto-dispose when done
    player.onPlayerComplete.listen((_) {
      player.dispose();
    });
  }

  /// Plays background music in a loop
  Future<void> playMusic(String assetPath) async {
    if (_currentMusic == assetPath) {
      if (_isMusicEnabled && _musicPlayer.state != PlayerState.playing) {
        await _musicPlayer.resume();
      }
      return;
    }

    _currentMusic = assetPath;
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _applyVolume();
    if (_isMusicEnabled) {
      await _musicPlayer.play(AssetSource('sounds/$assetPath'));
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentMusic = null;
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_isMusicEnabled) {
      await _musicPlayer.resume();
    }
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    super.dispose();
  }
}

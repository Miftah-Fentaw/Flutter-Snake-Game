import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/services/audio_service.dart';
import 'game_state.dart' show GameStatus, SwallowAnimation;

enum VerticalObjectType { food, brick, wood }

class VerticalWorldObject {
  final String id;
  final VerticalObjectType type;
  Offset position;
  final String? imagePath;
  bool isActive = true;

  VerticalWorldObject({
    required this.id,
    required this.type,
    required this.position,
    this.imagePath,
  });
}

class VerticalGameState extends ChangeNotifier {
  double _worldWidth = 600.0;
  double _worldHeight = 900.0;
  double get worldWidth => _worldWidth;
  double get worldHeight => _worldHeight;

  double topUIHeight = 100.0;
  double bottomUIHeight = 50.0;

  final Map<String, ui.Image> _loadedImages = {};
  Map<String, ui.Image> get loadedImages => _loadedImages;
  bool _imagesLoaded = false;
  bool get imagesLoaded => _imagesLoaded;

  late Offset _headPos;
  final List<Offset> _bodySegments = [];
  final List<double> _bodyAngles = [];
  final List<Offset> _pathHistory = [];

  Offset get headPos => _headPos;
  List<Offset> get bodySegments => _bodySegments;
  List<double> get bodyAngles => _bodyAngles;

  final List<SwallowAnimation> _swallowAnimations = [];
  List<SwallowAnimation> get swallowAnimations => _swallowAnimations;

  final List<VerticalWorldObject> _worldObjects = [];
  List<VerticalWorldObject> get worldObjects => _worldObjects;

  final List<String> _animalImages = [
    'assets/animals/bigdog.png',
    'assets/animals/bird.png',
    'assets/animals/bug.png',
    'assets/animals/fish.png',
    'assets/animals/frog.png',
    'assets/animals/frog2.png',
    'assets/animals/penguin.png',
    'assets/animals/rabit.png',
  ];

  GameStatus _status = GameStatus.idle;
  GameStatus get status => _status;

  bool _tongueVisible = false;
  bool get tongueVisible => _tongueVisible;
  double _pulseValue = 0.0;
  double get pulseValue => _pulseValue;
  double _tongueTimer = 0.0;
  double _pulseTimer = 0.0;

  int _score = 0;
  int get score => _score;

  int _highScore = 0;
  int get highScore => _highScore;

  Timer? _gameLoop;
  double _gameSpeed = 0.5; // 0.1 to 1.0
  String _selectedSkin = 'Classic';
  int _selectedThemeIndex = 0;

  double get gameSpeed => _gameSpeed;
  String get selectedSkin => _selectedSkin;
  int get selectedThemeIndex => _selectedThemeIndex;

  double _spawnTimer = 0.0;
  final double _spawnInterval = 1.0; // Spawn something every second

  final double _segmentSpacing = 5.0;
  int _targetBodyLength = 30;
  double _targetX = 300.0;
  double get targetX => _targetX;
  double _lerpFactor = 0.15; // Smooth horizontal follow

  double get _scrollSpeed {
    // 100.0 baseline + speed factor * 300.0
    return 100.0 + (_gameSpeed * 300.0);
  }

  VerticalGameState() {
    _headPos = Offset(_worldWidth / 2, _worldHeight * 0.7);
    _targetX = _headPos.dx;
    _loadSettings();
    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
    for (final path in _animalImages) {
      try {
        final ByteData data = await rootBundle.load(path);
        final ui.Codec codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
        );
        final ui.FrameInfo fi = await codec.getNextFrame();
        _loadedImages[path] = fi.image;
      } catch (e) {
        debugPrint('Error loading image $path: $e');
      }
    }
    _imagesLoaded = true;
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _highScore = prefs.getInt('vertical_high_score') ?? 0;
      _gameSpeed = prefs.getDouble('vertical_game_speed') ?? 0.5;
      _selectedSkin = prefs.getString('vertical_selected_skin') ?? 'Classic';
      _selectedThemeIndex = prefs.getInt('vertical_selected_theme_index') ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> saveSettings({
    double? speed,
    String? skin,
    int? themeIndex,
  }) async {
    if (speed != null) _gameSpeed = speed;
    if (skin != null) _selectedSkin = skin;
    if (themeIndex != null) _selectedThemeIndex = themeIndex;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('vertical_game_speed', _gameSpeed);
      await prefs.setString('vertical_selected_skin', _selectedSkin);
      await prefs.setInt('vertical_selected_theme_index', _selectedThemeIndex);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
    notifyListeners();
  }

  void updateWorldSize(double width, double height) {
    if (width <= 0 || height <= 0) return;
    _worldWidth = width;
    _worldHeight = height;
    if (_status == GameStatus.idle) {
      _headPos = Offset(_worldWidth / 2, _worldHeight * 0.7);
      _targetX = _headPos.dx;
    }
    notifyListeners();
  }

  void startGame() {
    _resetGame();
    _status = GameStatus.playing;
    _startLoop();
    AudioService().playMusic('playingbackground.mp3');
    notifyListeners();
  }

  void _startLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _update(0.016);
    });
  }

  void pauseGame() {
    if (_status == GameStatus.playing) {
      _status = GameStatus.paused;
      _gameLoop?.cancel();
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_status == GameStatus.paused) {
      _status = GameStatus.playing;
      _startLoop();
      notifyListeners();
    }
  }

  void _resetGame() {
    _headPos = Offset(_worldWidth / 2, _worldHeight * 0.7);
    _targetX = _headPos.dx;
    _score = 0;
    _targetBodyLength = 30;
    _pathHistory.clear();
    _bodySegments.clear();
    _bodyAngles.clear();
    _swallowAnimations.clear();
    _worldObjects.clear();
    _spawnTimer = 0.0;

    for (int i = 0; i < 300; i++) {
      _pathHistory.add(_headPos + Offset(0, i.toDouble()));
    }
    _updateBodySegments();
  }

  void updateTargetX(double screenX, double screenWidth) {
    if (_status != GameStatus.playing) return;
    _targetX = (screenX / screenWidth) * _worldWidth;
  }

  void _update(double dt) {
    if (_status != GameStatus.playing) return;

    _headPos = Offset(
      _headPos.dx + (_targetX - _headPos.dx) * _lerpFactor,
      _headPos.dy,
    );

    for (var obj in _worldObjects) {
      obj.position += Offset(0, _scrollSpeed * dt);
      if (obj.position.dy > _worldHeight + 50) {
        obj.isActive = false;
      }
    }
    _worldObjects.removeWhere((o) => !o.isActive);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnObject();
    }

    // In vertical mode, the "path" moves down as the world scrolls
    for (int i = 0; i < _pathHistory.length; i++) {
      _pathHistory[i] += Offset(0, _scrollSpeed * dt);
    }
    _pathHistory.insert(0, _headPos);
    if (_pathHistory.length > 2000) _pathHistory.removeLast();
    _updateBodySegments();

    _checkCollisions();

    for (int i = _swallowAnimations.length - 1; i >= 0; i--) {
      _swallowAnimations[i].progress += dt * 1.5;
      if (_swallowAnimations[i].progress >= 1.0) {
        _swallowAnimations.removeAt(i);
      }
    }

    _tongueTimer += dt;
    if (_tongueTimer > 0.5) {
      _tongueVisible = !_tongueVisible;
      _tongueTimer = 0;
    }

    _pulseTimer += dt * 2;
    _pulseValue = (sin(_pulseTimer) + 1) / 2; // 0 to 1

    notifyListeners();
  }

  void _spawnObject() {
    final random = Random();
    double x = 50 + random.nextDouble() * (_worldWidth - 100);

    // 30% chance for food, 70% for obstacle
    if (random.nextDouble() < 0.3) {
      _worldObjects.add(
        VerticalWorldObject(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: VerticalObjectType.food,
          position: Offset(x, -50),
          imagePath: _animalImages[random.nextInt(_animalImages.length)],
        ),
      );
    } else {
      _worldObjects.add(
        VerticalWorldObject(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: random.nextBool()
              ? VerticalObjectType.brick
              : VerticalObjectType.wood,
          position: Offset(x, -50),
        ),
      );
    }
  }

  void _checkCollisions() {
    for (var obj in _worldObjects) {
      if (!obj.isActive) continue;

      double dist = (_headPos - obj.position).distance;
      if (dist < 40.0) {
        if (obj.type == VerticalObjectType.food) {
          _score += 10;
          _targetBodyLength += 5;
          _swallowAnimations.add(SwallowAnimation(startTime: 0));
          obj.isActive = false;
        } else {
          _gameOver();
        }
      }
    }
  }

  void _updateBodySegments() {
    _bodySegments.clear();
    _bodyAngles.clear();
    double currentDistance = 0;
    int lastHistoryIndex = 0;

    for (int i = 0; i < _targetBodyLength; i++) {
      double targetDist = (i + 1) * _segmentSpacing;

      while (lastHistoryIndex < _pathHistory.length - 1) {
        Offset p1 = _pathHistory[lastHistoryIndex];
        Offset p2 = _pathHistory[lastHistoryIndex + 1];
        double d = (p1 - p2).distance;

        if (currentDistance + d >= targetDist) {
          double t = (targetDist - currentDistance) / d;
          Offset pos = Offset.lerp(p1, p2, t)!;
          _bodySegments.add(pos);
          _bodyAngles.add(atan2(p1.dy - p2.dy, p1.dx - p2.dx));
          break;
        }
        currentDistance += d;
        lastHistoryIndex++;
      }
    }
  }

  void _gameOver() {
    _status = GameStatus.gameOver;
    _gameLoop?.cancel();
    _saveHighScore();
    AudioService().playMusic('appbackground.mp3');
    notifyListeners();
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      _highScore = _score;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('vertical_high_score', _highScore);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }
}

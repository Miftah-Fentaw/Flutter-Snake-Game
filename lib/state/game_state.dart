import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameStatus { idle, playing, paused, gameOver }

class SwallowAnimation {
  double progress; // 0.0 to 1.0 (head to tail)
  final double startTime;

  SwallowAnimation({required this.startTime}) : progress = 0.0;
}

class FoodData {
  Offset position;
  String image;

  FoodData({required this.position, required this.image});
}

class SnakeData {
  bool isPlayer;
  Color color;

  Offset headPos;
  double headAngle;
  double targetAngle;
  final List<Offset> pathHistory = [];
  final List<Offset> bodySegments = [];
  final List<double> bodyAngles = [];
  final List<SwallowAnimation> swallowAnimations = [];

  int targetBodyLength = 15;
  int get size => targetBodyLength;
  bool isDead = false;

  SnakeData({
    required this.isPlayer,
    required this.color,
    required this.headPos,
    this.headAngle = -pi / 2,
  }) : targetAngle = headAngle;
}

class GameState extends ChangeNotifier {
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

  List<SnakeData> snakes = [];
  SnakeData? get playerSnake {
    try {
      return snakes.firstWhere((s) => s.isPlayer && !s.isDead);
    } catch (e) {
      return null;
    }
  }

  // Backwards compatibility / convenience getters for UI
  Offset get headPos =>
      playerSnake?.headPos ?? Offset(_worldWidth / 2, _worldHeight / 2);
  double get headAngle => playerSnake?.headAngle ?? -pi / 2;
  List<Offset> get bodySegments => playerSnake?.bodySegments ?? [];
  List<double> get bodyAngles => playerSnake?.bodyAngles ?? [];
  List<SwallowAnimation> get swallowAnimations =>
      playerSnake?.swallowAnimations ?? [];

  List<FoodData> foods = [];

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

  int _lastPlayerScore = 0;
  int get score => _lastPlayerScore;

  int _highScore = 0;
  int get highScore => _highScore;

  Timer? _gameLoop;

  double _gameSpeed = 0.5; // 0.1 to 1.0
  Color _snakeColor = Colors.green;
  Color _foodColor = Colors.red;
  int _selectedThemeIndex = 0;
  String _selectedSkin = 'Classic';

  double get gameSpeed => _gameSpeed;
  Color get snakeColor => _snakeColor;
  Color get foodColor => _foodColor;
  int get selectedThemeIndex => _selectedThemeIndex;
  String get selectedSkin => _selectedSkin;

  double get _currentBaseSpeed {
    return 100.0; // Calm snake speed, overriding settings
  }

  final double _segmentSpacing = 10.0;
  final double _rotationSpeed = 8.0;

  double _spawnTimer = 0.0;
  final double _spawnInterval = 2.0; // Spawn an AI snake every 2 seconds

  GameState() {
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
      _highScore = prefs.getInt('high_score') ?? 0;
      _gameSpeed = prefs.getDouble('game_speed') ?? 0.5;
      _snakeColor = Color(prefs.getInt('snake_color') ?? Colors.green.value);
      _foodColor = Color(prefs.getInt('food_color') ?? Colors.red.value);
      _selectedThemeIndex = prefs.getInt('selected_theme_index') ?? 0;
      _selectedSkin = prefs.getString('selected_skin') ?? 'Classic';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> saveSettings({
    double? speed,
    Color? snakeColor,
    Color? foodColor,
    int? themeIndex,
    String? skin,
  }) async {
    if (speed != null) _gameSpeed = speed;
    if (snakeColor != null) _snakeColor = snakeColor;
    if (foodColor != null) _foodColor = foodColor;
    if (themeIndex != null) _selectedThemeIndex = themeIndex;
    if (skin != null) _selectedSkin = skin;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('game_speed', _gameSpeed);
      await prefs.setInt('snake_color', _snakeColor.value);
      await prefs.setInt('food_color', _foodColor.value);
      await prefs.setInt('selected_theme_index', _selectedThemeIndex);
      await prefs.setString('selected_skin', _selectedSkin);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
    notifyListeners();
  }

  void updateSettings({
    required Color snakeColor,
    required Color foodColor,
    required double gameSpeed,
    int? themeIndex,
    String? skin,
  }) {
    _snakeColor = snakeColor;
    _foodColor = foodColor;
    _gameSpeed = gameSpeed;
    if (themeIndex != null) _selectedThemeIndex = themeIndex;
    if (skin != null) _selectedSkin = skin;
    saveSettings();
  }

  Future<void> _saveHighScore() async {
    if (score > _highScore) {
      _highScore = score;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('high_score', _highScore);
      } catch (e) {
        debugPrint('Error saving high score: $e');
      }
      notifyListeners();
    }
  }

  void updateWorldSize(double width, double height) {
    if (width <= 0 || height <= 0) return;
    _worldWidth = width;
    _worldHeight = height;
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

  void resetGame() {
    _gameLoop?.cancel();
    _resetGame();
    _status = GameStatus.idle;
    AudioService().playMusic('appbackground.mp3');
    notifyListeners();
  }

  void _resetGame() {
    snakes.clear();
    _spawnTimer = 0.0;
    _lastPlayerScore = 15;

    // Spawn player snake
    final pSnake = SnakeData(
      isPlayer: true,
      color: _snakeColor,
      headPos: Offset(worldWidth / 2, worldHeight - bottomUIHeight - 200),
      headAngle: -pi / 2,
    );
    pSnake.pathHistory.add(pSnake.headPos);
    for (int i = 1; i < 200; i++) {
      pSnake.pathHistory.add(pSnake.headPos + Offset(0, i.toDouble()));
    }
    _updateBodySegmentsForSnake(pSnake);
    snakes.add(pSnake);

    // Initial AI snakes
    for (int i = 0; i < 15; i++) {
      _spawnAISnake();
    }

    foods.clear();
    for (int i = 0; i < 20; i++) {
      _generateFood();
    }
  }

  void _generateFood() {
    if (foods.length > 30) return;
    final random = Random();
    // Keep food within playable area
    double minX = 30;
    double maxX = worldWidth - 30;
    double minY = topUIHeight + 30;
    double maxY = worldHeight - bottomUIHeight - 30;

    final newFoodPos = Offset(
      minX + random.nextDouble() * (maxX - minX),
      minY + random.nextDouble() * (maxY - minY),
    );
    final newFoodImage = _animalImages[random.nextInt(_animalImages.length)];
    foods.add(FoodData(position: newFoodPos, image: newFoodImage));
  }

  void _spawnAISnake() {
    // Don't spawn too many
    if (snakes.length > 25) return;

    final random = Random();
    double minX = 30;
    double maxX = worldWidth - 30;
    double minY = topUIHeight + 30;
    double maxY = worldHeight - bottomUIHeight - 30;

    Offset spawnPos;
    int attempts = 0;
    do {
      spawnPos = Offset(
        minX + random.nextDouble() * (maxX - minX),
        minY + random.nextDouble() * (maxY - minY),
      );
      attempts++;
    } while (playerSnake != null &&
        (spawnPos - playerSnake!.headPos).distance < 200 &&
        attempts < 10);

    final colorList = [
      Colors.red,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.yellow,
      Colors.pink,
      Colors.lime,
    ];
    final snakeColor = colorList[random.nextInt(colorList.length)];

    final angle = random.nextDouble() * 2 * pi;

    final ai = SnakeData(
      isPlayer: false,
      color: snakeColor,
      headPos: spawnPos,
      headAngle: angle,
    );

    // AI size varies from 5 to roughly player size + a little bit
    int pSize = playerSnake?.size ?? 15;
    ai.targetBodyLength = max(
      5,
      (pSize * (0.2 + random.nextDouble() * 1.0)).toInt(),
    );

    ai.pathHistory.add(ai.headPos);
    for (int i = 1; i < 200; i++) {
      ai.pathHistory.add(
        ai.headPos + Offset(cos(angle + pi), sin(angle + pi)) * i.toDouble(),
      );
    }
    _updateBodySegmentsForSnake(ai);

    snakes.add(ai);
  }

  void setTargetAngle(double angle) {
    if (playerSnake != null && playerSnake!.targetAngle != angle) {
      playerSnake!.targetAngle = angle;
      notifyListeners();
    }
  }

  void setDirection(double angle) {
    setTargetAngle(angle);
  }

  void updateTargetAngleFromTouch(Offset touchPosition, Size screenSize) {
    if (_status != GameStatus.playing || playerSnake == null) return;

    final screenHead = Offset(
      (playerSnake!.headPos.dx / _worldWidth) * screenSize.width,
      (playerSnake!.headPos.dy / _worldHeight) * screenSize.height,
    );

    final dx = touchPosition.dx - screenHead.dx;
    final dy = touchPosition.dy - screenHead.dy;

    if (sqrt(dx * dx + dy * dy) > 10.0) {
      final angle = atan2(dy, dx);
      setTargetAngle(angle);
    }
  }

  void _update(double dt) {
    if (_status != GameStatus.playing) return;

    // Keep track of score for game over screen
    if (playerSnake != null) {
      _lastPlayerScore = playerSnake!.size;
    }

    _spawnTimer += dt;
    if (_spawnTimer > _spawnInterval) {
      _spawnTimer = 0;
      _spawnAISnake();
    }

    _updateAISnakes(dt);

    for (var snake in snakes) {
      if (snake.isDead) continue;

      // Smoothly update head angle towards target
      double angleDiff = snake.targetAngle - snake.headAngle;
      while (angleDiff > pi) {
        angleDiff -= 2 * pi;
      }
      while (angleDiff < -pi) {
        angleDiff += 2 * pi;
      }

      double rotationStep = _rotationSpeed * dt;
      if (angleDiff.abs() < rotationStep) {
        snake.headAngle = snake.targetAngle;
      } else {
        snake.headAngle += rotationStep * angleDiff.sign;
      }

      // Move head
      final velocity =
          Offset(cos(snake.headAngle), sin(snake.headAngle)) *
          _currentBaseSpeed *
          dt;
      snake.headPos += velocity;

      // Wall Collision
      if (snake.headPos.dx < 0 ||
          snake.headPos.dx > worldWidth ||
          snake.headPos.dy < topUIHeight ||
          snake.headPos.dy > worldHeight - bottomUIHeight) {
        if (snake.isPlayer) {
          _gameOver();
          return;
        } else {
          snake.isDead = true;
        }
      }

      // Path history
      snake.pathHistory.insert(0, snake.headPos);
      if (snake.pathHistory.length > 3000) snake.pathHistory.removeLast();

      _updateBodySegmentsForSnake(snake);

      // Swallow animations
      for (int i = snake.swallowAnimations.length - 1; i >= 0; i--) {
        snake.swallowAnimations[i].progress += dt * 1.5;
        if (snake.swallowAnimations[i].progress >= 1.0) {
          snake.swallowAnimations.removeAt(i);
        }
      }
    }

    _checkCollisions();

    // Cleanup dead snakes
    snakes.removeWhere((s) => s.isDead);

    notifyListeners();
  }

  void _updateAISnakes(double dt) {
    for (var ai in snakes) {
      if (ai.isPlayer || ai.isDead) continue;

      Offset steerTarget =
          ai.headPos + Offset(cos(ai.headAngle), sin(ai.headAngle)) * 100;
      bool forcingTurn = false;

      // Wall avoidance
      double margin = 50.0;
      if (ai.headPos.dx < margin ||
          ai.headPos.dx > worldWidth - margin ||
          ai.headPos.dy < topUIHeight + margin ||
          ai.headPos.dy > worldHeight - bottomUIHeight - margin) {
        steerTarget = Offset(worldWidth / 2, worldHeight / 2);
        forcingTurn = true;
      }

      if (!forcingTurn) {
        SnakeData? closestBigger;
        double closestBiggerDist = 99999;

        SnakeData? closestSmaller;
        double closestSmallerDist = 99999;

        for (var other in snakes) {
          if (other == ai || other.isDead || other.isPlayer) continue;
          double dist = (ai.headPos - other.headPos).distance;
          if (other.size >= ai.size) {
            // Equals implies danger just in case
            if (dist < closestBiggerDist) {
              closestBiggerDist = dist;
              closestBigger = other;
            }
          } else if (other.size < ai.size) {
            if (dist < closestSmallerDist) {
              closestSmallerDist = dist;
              closestSmaller = other;
            }
          }
        }

        if (closestBigger != null && closestBiggerDist < 150) {
          // Flee
          Offset fleeDir = ai.headPos - closestBigger.headPos;
          steerTarget = ai.headPos + fleeDir;
        } else if (closestSmaller != null && closestSmallerDist < 250) {
          // Chase
          steerTarget = closestSmaller.headPos;
        } else if (foods.isNotEmpty) {
          // Go to closest food
          FoodData? closestFood;
          double closestFoodDist = 99999;
          for (var f in foods) {
            double d = (ai.headPos - f.position).distance;
            if (d < closestFoodDist) {
              closestFoodDist = d;
              closestFood = f;
            }
          }
          if (closestFood != null) {
            steerTarget = closestFood.position;
          }
        }
      }

      final angleToTarget = atan2(
        steerTarget.dy - ai.headPos.dy,
        steerTarget.dx - ai.headPos.dx,
      );
      ai.targetAngle = angleToTarget;
    }
  }

  void _checkCollisions() {
    for (int i = 0; i < snakes.length; i++) {
      var s1 = snakes[i];
      if (s1.isDead) continue;

      for (int j = i + 1; j < snakes.length; j++) {
        var s2 = snakes[j];
        if (s2.isDead) continue;

        bool hit = false;
        for (var seg in s2.bodySegments) {
          if ((s1.headPos - seg).distance < 15.0) {
            hit = true;
            break;
          }
        }
        if (!hit) {
          for (var seg in s1.bodySegments) {
            if ((s2.headPos - seg).distance < 15.0) {
              hit = true;
              break;
            }
          }
        }
        if (!hit && (s1.headPos - s2.headPos).distance < 20.0) {
          hit = true;
        }

        if (hit) {
          if (s1.size > s2.size) {
            s2.isDead = true;
            s1.targetBodyLength += max(1, s2.size ~/ 2);
            s1.swallowAnimations.add(SwallowAnimation(startTime: 0));
          } else if (s2.size > s1.size) {
            s1.isDead = true;
            s2.targetBodyLength += max(1, s1.size ~/ 2);
            s2.swallowAnimations.add(SwallowAnimation(startTime: 0));
          } else {
            // Equal sizes: Both bounce or ignore. Let's make them both die if it's head to head? Or ignore.
            // Let's ignore to avoid frustration.
          }
        }
      }
    }

    var pSnake = !snakes.any((s) => s.isPlayer && !s.isDead);
    if (pSnake) {
      _gameOver();
      return;
    }

    for (var snake in snakes) {
      if (snake.isDead) continue;

      for (int i = foods.length - 1; i >= 0; i--) {
        if ((snake.headPos - foods[i].position).distance < 40.0) {
          snake.targetBodyLength += 2;
          snake.swallowAnimations.add(SwallowAnimation(startTime: 0));
          foods.removeAt(i);
          _generateFood();
        }
      }
    }
  }

  void _updateBodySegmentsForSnake(SnakeData snake) {
    snake.bodySegments.clear();
    snake.bodyAngles.clear();
    double currentDistance = 0;
    int lastHistoryIndex = 0;

    for (int i = 0; i < snake.targetBodyLength; i++) {
      double targetDist = (i + 1) * _segmentSpacing;

      while (lastHistoryIndex < snake.pathHistory.length - 1) {
        Offset p1 = snake.pathHistory[lastHistoryIndex];
        Offset p2 = snake.pathHistory[lastHistoryIndex + 1];
        double d = (p1 - p2).distance;

        if (currentDistance + d >= targetDist) {
          double t = (targetDist - currentDistance) / d;
          Offset pos = Offset.lerp(p1, p2, t)!;
          snake.bodySegments.add(pos);
          snake.bodyAngles.add(atan2(p1.dy - p2.dy, p1.dx - p2.dx));
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

  @override
  void dispose() {
    _gameLoop?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:game/state/game_state.dart';
import 'package:game/widgets/game_overlays.dart';
import 'package:game/widgets/game_painter.dart';
import 'package:game/widgets/ui_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _GameView();
  }
}

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final size = MediaQuery.of(context).size;

    // Update world size and start game if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        gameState.updateWorldSize(size.width, size.height);
        if (gameState.status == GameStatus.idle) {
          gameState.startGame();
        }
        // Adjust safe areas
        gameState.topUIHeight = 50.0;
        gameState.bottomUIHeight = 50.0;
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: GamePainter(
                  gameState: gameState,
                  theme: Theme.of(context),
                  screenSize: size,
                ),
              ),
            ),

            // (Ensures touches are caught even in "empty" areas of the stack)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (details) => gameState.updateTargetAngleFromTouch(
                  details.localPosition,
                  size,
                ),
                onPanUpdate: (details) => gameState.updateTargetAngleFromTouch(
                  details.localPosition,
                  size,
                ),
                onTapDown: (details) => gameState.updateTargetAngleFromTouch(
                  details.localPosition,
                  size,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Since it's after the gesture handler, its buttons will be hit-tested first
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UIBadge(
                      label: "SCORE",
                      value: "${gameState.score}",
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Row(
                      children: [
                        UIBadge(
                          label: "BEST",
                          value: "${gameState.highScore}",
                          color: Theme.of(context).colorScheme.tertiary,
                          icon: Icons.emoji_events_rounded,
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () => gameState.pauseGame(),
                          icon: const Icon(Icons.pause_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (gameState.status == GameStatus.playing && gameState.score < 50)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Text(
                      "TAP OR DRAG TO STEER",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),

            if (gameState.status == GameStatus.paused)
              PauseOverlay(
                onResume: () => gameState.resumeGame(),
                onQuit: () => context.go('/'),
              ),

            if (gameState.status == GameStatus.gameOver)
              GameOverOverlay(
                score: gameState.score,
                highScore: gameState.highScore,
                onRestart: () => gameState.startGame(),
                onMenu: () => context.go('/'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:game/state/game_state.dart' show GameStatus;
import 'package:game/state/game_state2.dart';
import 'package:game/widgets/game_overlays.dart';
import 'package:game/widgets/game_painter2.dart';
import 'package:game/widgets/ui_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GameScreen2 extends StatelessWidget {
  const GameScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VerticalGameState(),
      child: const _GameView2(),
    );
  }
}

class _GameView2 extends StatefulWidget {
  const _GameView2();

  @override
  State<_GameView2> createState() => _GameView2State();
}

class _GameView2State extends State<_GameView2> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VerticalGameState>().startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<VerticalGameState>();
    final size = MediaQuery.of(context).size;

    // Update world size to match screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        gameState.updateWorldSize(size.width, size.height);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: VerticalGamePainter(
                  gameState: gameState,
                  theme: Theme.of(context),
                  screenSize: size,
                ),
              ),
            ),

            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) => gameState.updateTargetX(
                  details.localPosition.dx,
                  size.width,
                ),
                onTapDown: (details) => gameState.updateTargetX(
                  details.localPosition.dx,
                  size.width,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),

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
                      "DRAG SIDE-TO-SIDE TO STEER",
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

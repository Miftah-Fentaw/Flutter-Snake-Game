import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const PauseOverlay({super.key, required this.onResume, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "PAUSED",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
              ),
            ),
            const SizedBox(height: 40),
            OverlayButton(
              label: "CONTINUE",
              color: Colors.blue,
              onTap: onResume,
            ),
            const SizedBox(height: 16),
            OverlayButton(label: "QUIT", color: Colors.red, onTap: onQuit),
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "GAME OVER",
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "SCORE: $score",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              "BEST: $highScore",
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 48),
            OverlayButton(
              label: "TRY AGAIN",
              color: Colors.green,
              onTap: onRestart,
            ),
            const SizedBox(height: 16),
            OverlayButton(
              label: "MAIN MENU",
              color: Colors.white24,
              onTap: onMenu,
            ),
          ],
        ),
      ),
    );
  }
}

class OverlayButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const OverlayButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
    );
  }
}

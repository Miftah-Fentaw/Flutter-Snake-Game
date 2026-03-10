// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:game/widgets/neon_background.dart';
import 'package:game/services/audio_service.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _classicHighScore = 0;
  int _runnerHighScore = 0;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _loadHighScore();
    // Ensure app background music starts if we're not in the middle of a game
    AudioService().playMusic('appbackground.mp3');
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _classicHighScore = prefs.getInt('high_score') ?? 0;
          _runnerHighScore = prefs.getInt('vertical_high_score') ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading high score: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return NeonBackground(
                  progress: _bgController.value,
                  backgroundColor: colorScheme.background,
                );
              },
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  _buildLogo(),

                  const SizedBox(height: 24),

                  _buildTitle(),

                  const SizedBox(height: 60),

                  _buildButtons(),

                  const SizedBox(height: 48),

                  _buildScorePanel(),

                  const SizedBox(height: 32),

                  _buildFooter(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 180,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          Lottie.asset('assets/Snake.json'),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "NEON",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Theme.of(context).colorScheme.primary,
            shadows: [
              Shadow(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        Text(
          "SLITHER",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        _NeonButton(
          label: "CLASSIC MODE",
          icon: Icons.grid_4x4_rounded,
          color: Theme.of(context).colorScheme.primary,
          onTap: () => context.push('/game').then((_) => _loadHighScore()),
        ),
        _NeonButton(
          label: "VERTICAL RUNNER",
          icon: Icons.keyboard_double_arrow_up_rounded,
          color: Theme.of(context).colorScheme.secondary,
          onTap: () => context.push('/game2'),
        ),
        _NeonButton(
          label: "SETTINGS",
          icon: Icons.tune_rounded,
          color: Theme.of(context).colorScheme.tertiary,
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }

  Widget _buildScorePanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScoreDetail(
                title: "CLASSIC\nBEST SCORE",
                value: "$_classicHighScore",
                color: Theme.of(context).colorScheme.primary,
              ),
              Container(
                width: 1,
                height: 40,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
              _ScoreDetail(
                title: "RUNNER\nBEST SCORE",
                value: "$_runnerHighScore",
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      "VERSION 1.0.5 • POWERED BY FLUTTER",
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _NeonButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NeonButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<_NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glowAnimation = Tween<double>(
      begin: 5.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 300),
            height: 60,
            margin: const EdgeInsets.only(bottom: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: _glowAnimation.value,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.icon, color: widget.color, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.label,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScoreDetail extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ScoreDetail({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

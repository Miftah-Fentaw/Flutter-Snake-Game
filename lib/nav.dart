import 'package:flutter/material.dart';
import 'package:game/screens/game_screen.dart';
import 'package:game/screens/game_screen2.dart';
import 'package:game/screens/home_screen.dart';
import 'package:game/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';

/// GoRouter configuration for app navigation
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.game,
        name: 'game',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const GameScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.game2,
        name: 'game2',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const GameScreen2(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) =>
            const MaterialPage(child: SettingsScreen()),
      ),
    ],
  );
}

/// Route path constants
class AppRoutes {
  static const String home = '/';
  static const String game = '/game';
  static const String game2 = '/game2';
  static const String settings = '/settings';
}

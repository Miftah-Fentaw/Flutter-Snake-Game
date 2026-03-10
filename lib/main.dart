import 'package:flutter/material.dart';
import 'package:game/nav.dart';
import 'package:game/services/audio_service.dart';
import 'package:game/theme.dart';
import 'package:game/state/game_state.dart';
import 'package:game/state/game_state2.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Play intro sound
  AudioService().playMusic('snake.mp3');

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const SnakeApp());
}

class SnakeApp extends StatefulWidget {
  const SnakeApp({super.key});

  @override
  State<SnakeApp> createState() => _SnakeAppState();
}

class _SnakeAppState extends State<SnakeApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioService().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AudioService().pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      AudioService().resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        ChangeNotifierProvider(create: (_) => VerticalGameState()),
        // Expose the AudioService singleton so it can be accessed as a ChangeNotifier
        ChangeNotifierProvider.value(value: AudioService()),
      ],
      child: MaterialApp.router(
        title: 'Neon Snake',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

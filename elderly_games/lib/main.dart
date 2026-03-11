import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'games/memory/screens/memory_phase_screen.dart';
import 'games/memory/screens/memory_play_screen.dart';
import 'games/number_sequence/screens/number_sequence_play_screen.dart';
import 'games/word_search/screens/word_search_play_screen.dart';
import 'models/game_info.dart';
import 'models/user_profile.dart';
import 'screens/game_placeholder_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/points_manager.dart';
import 'services/storage_service.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, light icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final storage = StorageService();
  await storage.init();

  runApp(ElderlyGamesApp(storage: storage));
}

class ElderlyGamesApp extends StatelessWidget {
  final StorageService storage;

  const ElderlyGamesApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final profile = storage.loadUserProfile() ??
        UserProfile(
          id: const Uuid().v4(),
          name: 'Jogador',
        );

    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider<PointsManager>(
          create: (_) => PointsManager(storage, profile),
        ),
      ],
      child: MaterialApp(
        title: 'Jogos para Todos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => SplashScreen(storage: storage),
          '/welcome': (_) => WelcomeScreen(storage: storage),
          '/home': (_) => const HomeScreen(),
        },
        onGenerateRoute: (settings) {
          final args = settings.arguments;
          final name = settings.name;

          // ── Memory game ───────────────────────────────────────────────────────

          // Home → Memory phase selection
          if (name == '/memory_cards') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const MemoryPhaseScreen(),
            );
          }

          // Phase selection → Play screen
          // MemoryPlayScreen owns its own ChangeNotifierProvider<MemoryGameState>.
          if (name == '/memory/game' && args is int) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => MemoryPlayScreen(phaseNumber: args),
            );
          }

          // ── Number Sequence ───────────────────────────────────────────────────

          if (name == '/number_sequence') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const NumberSequencePlayScreen(),
            );
          }

          // ── Word Search ───────────────────────────────────────────────────────

          if (name == '/word_search') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const WordSearchPlayScreen(),
            );
          }

          // ── Other games → placeholder ─────────────────────────────────────────

          if (args is GameInfo) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => GamePlaceholderScreen(game: args),
            );
          }

          // Explicit /game/* fallback
          if (name?.startsWith('/game/') == true) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const _RouteNotFoundScreen(),
            );
          }

          return null;
        },
      ),
    );
  }
}

class _RouteNotFoundScreen extends StatelessWidget {
  const _RouteNotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página não encontrada')),
      body: const Center(
        child: Text(
          '404 — Rota não encontrada.',
          style: TextStyle(fontSize: AppTheme.fontBody),
        ),
      ),
    );
  }
}

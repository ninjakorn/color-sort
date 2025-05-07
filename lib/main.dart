// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/game/logic/color_sort_game.dart';
import 'features/home/ui/home_screen.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ColorSortGame(),
      child: Builder(
        builder: (context) {
          // Access the provider to use its theme
          final gameProvider = Provider.of<ColorSortGame>(context);

          return MaterialApp(
            title: 'Color Sort Game',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              fontFamily: 'Roboto',
            ),
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer>
    with SingleTickerProviderStateMixin {
  late AnimationController _splashController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Create a splash screen animation controller
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize the game after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });

    // Start the splash animation
    _splashController.forward();
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  // Initialize the game and load saved data
  Future<void> _initializeGame() async {
    final gameProvider = Provider.of<ColorSortGame>(context, listen: false);
    await gameProvider.initialize();

    // Delay slightly to show splash screen even if initialization is fast
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If game is initialized, show home screen
    if (_isInitialized) {
      return const HomeScreen();
    }

    // Otherwise, show splash screen
    return _buildSplashScreen();
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[300]!],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _splashController,
            builder: (context, child) {
              // Create a bouncing animation for the logo
              double bounce =
                  1.0 +
                  sin(_splashController.value * 3 * 3.14159) *
                      (1.0 - _splashController.value) *
                      0.2;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated game title
                  Transform.scale(
                    scale: bounce,
                    child: Text(
                      'COLOR SORT',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Loading indicator
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

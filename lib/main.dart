// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/game/logic/color_sort_game.dart';
import 'features/game/ui/game_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ColorSortGame(),
      child: MaterialApp(
        title: 'Color Sort Game',
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
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize the game after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ColorSortGame>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const GameScreen();
  }
}

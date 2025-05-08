// lib/features/home/ui/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Added missing import
import '../../game/logic/color_sort_game.dart';
import '../../game/ui/game_screen.dart';
import 'theme_config.dart';
import 'level_selection_screen.dart'; // Updated import

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: false);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<ColorSortGame>(context);
    final themeConfig = ThemeConfig.getTheme(gameProvider.selectedTheme);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeConfig.primaryColor.withOpacity(0.8),
              themeConfig.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Game title with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildGameTitle(themeConfig),
              ),

              const SizedBox(height: 60),

              // Decorative tubes
              _buildDecorativeTubes(themeConfig),

              const Spacer(),

              // Play button
              _buildPlayButton(context, gameProvider, themeConfig),

              const SizedBox(height: 20),

              // Level selection button
              _buildLevelSelectionButton(context, gameProvider, themeConfig),

              const SizedBox(height: 20),

              // Settings button
              _buildSettingsButton(context, gameProvider, themeConfig),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameTitle(ThemeConfig themeConfig) {
    return Column(
      children: [
        Text(
          'COLOR',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: themeConfig.titleColor,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        Text(
          'SORT',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: themeConfig.titleColor,
            letterSpacing: 8,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeTubes(ThemeConfig themeConfig) {
    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDecorativeTube([
            themeConfig.tubeColors[0],
            themeConfig.tubeColors[1],
            themeConfig.tubeColors[2],
            themeConfig.tubeColors[3],
          ], -1.0),
          const SizedBox(width: 20),
          _buildDecorativeTube([
            themeConfig.tubeColors[2],
            themeConfig.tubeColors[2],
            themeConfig.tubeColors[2],
            themeConfig.tubeColors[2],
          ], 0.0),
          const SizedBox(width: 20),
          _buildDecorativeTube([
            themeConfig.tubeColors[3],
            themeConfig.tubeColors[0],
            themeConfig.tubeColors[1],
            themeConfig.tubeColors[2],
          ], 1.0),
        ],
      ),
    );
  }

  Widget _buildDecorativeTube(List<Color> colors, double rotationOffset) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double animValue = _animationController.value;
        // Creating a wave effect with different phases based on rotationOffset
        double waveOffset = sin(animValue * 6.28 + rotationOffset) * 0.05;

        return Transform.rotate(angle: waveOffset, child: child);
      },
      child: Container(
        width: 60,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(color: Colors.grey[700]!, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Empty space in the tube
            Expanded(
              flex: 0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey[400]!, width: 1),
                    right: BorderSide(color: Colors.grey[400]!, width: 1),
                    top: BorderSide(color: Colors.grey[400]!, width: 1),
                  ),
                ),
              ),
            ),

            // Display colored blocks
            ...colors
                .map(
                  (color) => Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [color.withOpacity(0.7), color],
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    ColorSortGame gameProvider,
    ThemeConfig themeConfig,
  ) {
    return Hero(
      tag: 'play_button',
      child: Material(
        color: Colors.transparent,
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the game screen with current level
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const GameScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeConfig.buttonColor,
            foregroundColor: themeConfig.buttonTextColor,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow, size: 28),
              SizedBox(width: 8),
              Text(
                'PLAY GAME',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelSelectionButton(
    BuildContext context,
    ColorSortGame gameProvider,
    ThemeConfig themeConfig,
  ) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to level selection screen
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LevelSelectionScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: themeConfig.secondaryButtonColor,
        foregroundColor: themeConfig.buttonTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grid_view),
          SizedBox(width: 8),
          Text(
            'LEVEL SELECTION',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(
    BuildContext context,
    ColorSortGame gameProvider,
    ThemeConfig themeConfig,
  ) {
    return ElevatedButton(
      onPressed: () {
        // Show theme selection dialog
        _showThemeSelectionDialog(context, gameProvider);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: themeConfig.tertiaryButtonColor,
        foregroundColor: themeConfig.buttonTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings),
          SizedBox(width: 8),
          Text(
            'SETTINGS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog(
    BuildContext context,
    ColorSortGame gameProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: gameProvider.themeNames.length,
              itemBuilder: (context, index) {
                final isSelected = gameProvider.selectedTheme == index;
                final themeConfig = ThemeConfig.getTheme(index);

                return ListTile(
                  title: Text(gameProvider.themeNames[index]),
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeConfig.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    gameProvider.setTheme(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }
}

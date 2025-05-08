// lib/features/home/ui/level_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/logic/color_sort_game.dart';
import '../../game/logic/level_manager.dart';
import '../../game/ui/game_screen.dart';
import 'theme_config.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<ColorSortGame>(context);
    final themeConfig = ThemeConfig.getTheme(gameProvider.selectedTheme);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        backgroundColor: themeConfig.primaryColor,
        foregroundColor: themeConfig.buttonTextColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeConfig.primaryColor.withOpacity(0.3),
              themeConfig.backgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: LevelManager.totalLevels,
            itemBuilder: (context, index) {
              final levelNumber = index + 1;
              final isUnlocked =
                  levelNumber <= gameProvider.highestUnlockedLevel;
              final starRating = gameProvider.getStarRatingForLevel(
                levelNumber,
              );

              return GestureDetector(
                onTap: () {
                  if (isUnlocked) {
                    gameProvider.loadLevel(levelNumber);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isUnlocked
                            ? themeConfig.levelSelectionColor
                            : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$levelNumber',
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isUnlocked)
                        const Icon(Icons.lock, color: Colors.white70, size: 18),
                      if (isUnlocked && starRating > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            return Icon(
                              i < starRating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

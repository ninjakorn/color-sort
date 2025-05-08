// lib/features/game/ui/level_complete_dialog.dart

import 'package:flutter/material.dart';
import '../../home/ui/theme_config.dart';

void showLevelCompleteDialog(
  BuildContext context,
  int levelNumber,
  int moveCount,
  int parMoveCount,
  int starRating,
  ThemeConfig themeConfig,
  VoidCallback onNextLevel,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeConfig.backgroundColor.withOpacity(0.9),
                themeConfig.primaryColor.withOpacity(0.2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level $levelNumber Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildStarRating(starRating, themeConfig),
              const SizedBox(height: 20),
              Text(
                'You completed the level in:',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 8),
              Text(
                '$moveCount Moves',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:
                      moveCount <= parMoveCount
                          ? Colors.green[700]
                          : Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Par: $parMoveCount',
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('CLOSE'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onNextLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeConfig.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text('NEXT LEVEL'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildStarRating(int starRating, ThemeConfig themeConfig) {
  return TweenAnimationBuilder(
    tween: Tween<double>(begin: 0, end: 1),
    duration: const Duration(seconds: 1),
    builder: (context, double value, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          double starSize = index < starRating ? 50 : 40;
          double opacity = index < starRating * value ? 1.0 : 0.3;
          double scale = index < starRating * value ? 1.0 : 0.8;

          return Transform.scale(
            scale: scale,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Opacity(
                opacity: opacity,
                child: Icon(Icons.star, color: Colors.amber, size: starSize),
              ),
            ),
          );
        }),
      );
    },
  );
}

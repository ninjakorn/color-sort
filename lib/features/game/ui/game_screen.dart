// lib/features/game/ui/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Added missing import
import '../logic/color_sort_game.dart';
import '../logic/level_manager.dart';
import '../../home/ui/theme_config.dart';
import 'animated_tube_widget.dart'; // Updated to use the renamed widget
import 'level_complete_dialog.dart'; // Updated import
import 'tutorial_overlay.dart'; // Updated import

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _completionController;
  late AnimationController _hintController;
  bool _showingTutorial = false;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _hintController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Check if we should show the tutorial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = Provider.of<ColorSortGame>(context, listen: false);
      if (!game.tutorialCompleted && game.currentLevel == 1) {
        setState(() {
          _showingTutorial = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _completionController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<ColorSortGame>(context);
    final themeConfig = ThemeConfig.getTheme(game.selectedTheme);

    // Check for game completion
    if (game.isGameComplete && !_completionController.isAnimating) {
      _completionController.forward(from: 0.0);

      // Show level complete dialog
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          showLevelCompleteDialog(
            context,
            game.currentLevel,
            game.moveCount,
            game.parMoveCount,
            game.starRating,
            themeConfig,
            () => _onNextLevel(game),
          );
        }
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Level ${game.currentLevel} - ${LevelManager.getDifficultyLabel(game.currentLevel)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: themeConfig.primaryColor.withOpacity(0.7),
        elevation: 0,
        leading: Hero(
          tag: 'play_button',
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        actions: [
          // Hint button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildHintButton(game, themeConfig),
          ),
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: game.resetLevel,
            tooltip: 'Reset Level',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeConfig.primaryColor.withOpacity(0.7),
              themeConfig.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Level info and moves counter
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_vert, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Moves: ${game.moveCount}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  game.moveCount > game.parMoveCount * 1.5
                                      ? Colors.red[700]
                                      : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Par info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 20, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            'Par: ${game.parMoveCount}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Game board
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate tubes per row based on screen width
                        int tubesPerRow = (constraints.maxWidth / 70).floor();
                        tubesPerRow =
                            tubesPerRow > game.tubes.length
                                ? game.tubes.length
                                : tubesPerRow;

                        return _buildGameBoard(
                          context,
                          game,
                          tubesPerRow,
                          themeConfig,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Control buttons
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUndoButton(game, themeConfig),
                    _buildResetButton(game, themeConfig),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Tutorial overlay
      floatingActionButton:
          _showingTutorial ? null : _buildLevelsButton(themeConfig),
    );
  }

  Widget _buildGameBoard(
    BuildContext context,
    ColorSortGame game,
    int tubesPerRow,
    ThemeConfig themeConfig,
  ) {
    // Calculate number of rows needed
    int numRows = (game.tubes.length / tubesPerRow).ceil();

    return Stack(
      children: [
        // Game board with tubes
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(numRows, (rowIndex) {
            int startIndex = rowIndex * tubesPerRow;
            int endIndex = (rowIndex + 1) * tubesPerRow;
            endIndex =
                endIndex > game.tubes.length ? game.tubes.length : endIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(endIndex - startIndex, (index) {
                  int tubeIndex = startIndex + index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: AnimatedTubeWidget(
                      // Updated to use the renamed widget
                      tube: game.tubes[tubeIndex],
                      tubeIndex: tubeIndex,
                      isSelected: game.selectedTubeIndex == tubeIndex,
                      onTap: game.selectTube,
                      onMove: (fromTube, toTube) {
                        _moveController.forward(from: 0.0);
                        HapticFeedback.mediumImpact();
                        game.moveColor(fromTube, toTube);
                      },
                      isAnimating: game.isAnimating,
                      isHinted:
                          game.hintActive &&
                          (game.hintMove.fromTube == tubeIndex ||
                              game.hintMove.toTube == tubeIndex),
                      hintAnimation: _hintController,
                      useGlassEffect: themeConfig.useGlassEffect,
                      themeColors: themeConfig.tubeColors,
                    ),
                  );
                }),
              ),
            );
          }),
        ),

        // Animated confetti overlay on completion
        if (game.isGameComplete)
          AnimatedBuilder(
            animation: _completionController,
            builder: (context, child) {
              return Opacity(
                opacity: _completionController.value,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: CustomPaint(
                    painter: ConfettiPainter(
                      progress: _completionController.value,
                      colors: themeConfig.tubeColors,
                    ),
                    size: Size.infinite,
                  ),
                ),
              );
            },
          ),

        // Tutorial overlay if needed
        if (_showingTutorial)
          TutorialOverlay(
            onComplete: () {
              setState(() {
                _showingTutorial = false;
              });
              final game = Provider.of<ColorSortGame>(context, listen: false);
              game.setTutorialCompleted();
            },
            themeConfig: themeConfig,
          ),
      ],
    );
  }

  Widget _buildHintButton(ColorSortGame game, ThemeConfig themeConfig) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.lightbulb_outline,
            color:
                game.canUseHint ? Colors.white : Colors.white.withOpacity(0.5),
          ),
          onPressed: game.canUseHint ? game.showHint : null,
          tooltip: 'Hint (${game.hintsRemaining} left)',
        ),
        // Hint counter
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: game.canUseHint ? themeConfig.secondaryColor : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${game.hintsRemaining}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUndoButton(ColorSortGame game, ThemeConfig themeConfig) {
    return ElevatedButton.icon(
      onPressed: game.moveCount > 0 ? game.undoMove : null,
      icon: const Icon(Icons.undo),
      label: const Text('Undo'),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeConfig.secondaryButtonColor,
        foregroundColor: themeConfig.buttonTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
      ),
    );
  }

  Widget _buildResetButton(ColorSortGame game, ThemeConfig themeConfig) {
    return ElevatedButton.icon(
      onPressed: game.moveCount > 0 ? game.resetLevel : null,
      icon: const Icon(Icons.refresh),
      label: const Text('Reset'),
      style: ElevatedButton.styleFrom(
        backgroundColor: themeConfig.tertiaryButtonColor,
        foregroundColor: themeConfig.buttonTextColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
      ),
    );
  }

  Widget _buildLevelsButton(ThemeConfig themeConfig) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      backgroundColor: themeConfig.secondaryColor,
      child: const Icon(Icons.menu),
      tooltip: 'Level Selection',
    );
  }

  void _onNextLevel(ColorSortGame game) {
    if (game.currentLevel < LevelManager.totalLevels) {
      game.nextLevel();
    } else {
      // All levels completed - show congratulations dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Congratulations!'),
              content: const Text(
                'You have completed all the levels! More levels coming soon.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }
}

/// Painter for confetti animation on level completion
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final Random random = Random(42); // Fixed seed for deterministic animation
  final int particleCount = 100;

  ConfettiPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particleCount; i++) {
      final paint =
          Paint()
            ..color = colors[random.nextInt(colors.length)]
            ..style = PaintingStyle.fill;

      // Generate random position
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = random.nextDouble() * size.height;

      // Calculate current position based on progress
      final y = startY + (endY - startY) * progress;

      // Particle size
      final particleSize = 5.0 + random.nextDouble() * 10.0;

      // Rotation angle
      final angle = random.nextDouble() * 2 * pi;

      // Draw confetti particle (rectangle or circle)
      if (random.nextBool()) {
        // Rectangle
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle + progress * 10);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particleSize,
            height: particleSize * 2,
          ),
          paint,
        );
        canvas.restore();
      } else {
        // Circle
        canvas.drawCircle(Offset(x, y), particleSize / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

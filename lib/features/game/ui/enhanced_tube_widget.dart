// lib/features/game/ui/enhanced_tube_widget.dart

import 'package:flutter/material.dart';
import '../data/color_tube.dart';
import 'dart:ui';

class EnhancedTubeWidget extends StatelessWidget {
  final ColorTube tube;
  final int tubeIndex;
  final bool isSelected;
  final bool isHighlighted;
  final Function(int) onTap;
  final Function(int, int) onMove;
  final bool isAnimating;
  final bool isHinted;
  final AnimationController hintAnimation;
  final bool useGlassEffect;
  final List<Color> themeColors;

  const EnhancedTubeWidget({
    Key? key,
    required this.tube,
    required this.tubeIndex,
    required this.isSelected,
    required this.onTap,
    required this.onMove,
    this.isHighlighted = false,
    this.isAnimating = false,
    this.isHinted = false,
    required this.hintAnimation,
    this.useGlassEffect = false,
    required this.themeColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a draggable tube if it has blocks and is selected
    if (isSelected && !tube.isEmpty() && !isAnimating) {
      return _buildDraggableTube(context);
    }

    // Create a drag target tube for receiving blocks
    return _buildDragTargetTube(context);
  }

  Widget _buildDraggableTube(BuildContext context) {
    Color topColor = tube.getTopColor()!;

    return Draggable<int>(
      data: tubeIndex,
      feedback: _buildFeedback(topColor),
      childWhenDragging: _buildTubeContent(false, true),
      child: _buildTubeContent(true, false),
    );
  }

  Widget _buildDragTargetTube(BuildContext context) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        bool isHighlightedNow = isHighlighted || candidateData.isNotEmpty;
        return _buildTubeContent(isSelected, false, isHighlightedNow);
      },
      onWillAccept: (fromTubeIndex) {
        if (fromTubeIndex == null || fromTubeIndex == tubeIndex) return false;
        
        // Get the source tube from the parent widget
        var sourceColor = _getColorFromTubeIndex(fromTubeIndex);
        if (sourceColor == null) return false;

        // Check if we can move from the source tube to this tube
        return !tube.isFull() &&
            (tube.isEmpty() || tube.getTopColor() == sourceColor);
      },
      onAccept: (fromTubeIndex) {
        onMove(fromTubeIndex, tubeIndex);
      },
    );
  }

  Widget _buildTubeContent(bool isSelected, bool isDragging, [bool isHighlighted = false]) {
    // Calculate the vertical animation offset for hinted tubes
    double hintOffset = isHinted ? (hintAnimation.value * 4.0) : 0.0;
    
    return GestureDetector(
      onTap: () => onTap(tubeIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected || isHighlighted ? 65 : 60,
        height: 200,
        margin: EdgeInsets.only(top: hintOffset),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(
            color: _getBorderColor(isSelected, isHighlighted, isHinted),
            width: isSelected || isHighlighted || isHinted ? 3 : 2,
          ),
          boxShadow: _getBoxShadow(isSelected, isHighlighted, isHinted),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Empty space in the tube
              Expanded(
                flex: tube.capacity - tube.blocks.length,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: Colors.grey[400]!, width: 1),
                      right: BorderSide(color: Colors.grey[400]!, width: 1),
                      top: BorderSide(color: Colors.grey[400]!, width: 1),
                    ),
                    // Glass effect for empty space
                    color: useGlassEffect 
                      ? Colors.white.withOpacity(0.15) 
                      : Colors.grey[100]!.withOpacity(0.5),
                  ),
                  // Add subtle glass shine
                  child: useGlassEffect ? _buildGlassShine() : null,
                ),
              ),

              // Display colored blocks inside the tube
              ...List.generate(tube.blocks.length, (index) {
                bool isTopBlock = index == tube.blocks.length - 1;
                bool isActiveBlock = isTopBlock && (isSelected || isDragging);
                // Hide the top block if it's being dragged
                if (isActiveBlock && isDragging) {
                  return SizedBox(height: 40);
                }
                
                return _buildColorBlock(
                  tube.blocks[index],
                  isTopBlock,
                  isActiveBlock,
                  isAnimating && isTopBlock,
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGlassShine() {
    return CustomPaint(
      painter: GlassShinePainter(),
      size: const Size(60, 200),
    );
  }

  Widget _buildColorBlock(Color color, bool isTopBlock, bool isSelected, bool isAnimating) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isSelected ? 65 : 60,
      height: 40,
      margin: EdgeInsets.only(
        bottom: isTopBlock ? 0 : 0,
        top: isAnimating ? 20 : 0,
      ),
      decoration: BoxDecoration(
        color: color,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(useGlassEffect ? 0.7 : 0.8), 
            color
          ],
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ]
            : null,
        border: isTopBlock
            ? Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              )
            : null,
      ),
      // Add liquid-like shine effect on blocks
      child: useGlassEffect ? _buildLiquidShine(color) : null,
    );
  }
  
  Widget _buildLiquidShine(Color color) {
    return CustomPaint(
      painter: LiquidShinePainter(baseColor: color),
      size: const Size(60, 40),
    );
  }

  Widget _buildFeedback(Color topColor) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: topColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor.withOpacity(0.7), topColor],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      // Add liquid effect to the dragged item
      child: useGlassEffect ? _buildLiquidShine(topColor) : null,
    );
  }

  Color _getBorderColor(bool isSelected, bool isHighlighted, bool isHinted) {
    if (isHinted) {
      return Colors.amber;
    } else if (isSelected) {
      return Colors.blue;
    } else if (isHighlighted) {
      return Colors.green;
    } else {
      return Colors.grey[700]!;
    }
  }

  List<BoxShadow>? _getBoxShadow(bool isSelected, bool isHighlighted, bool isHinted) {
    if (isHinted) {
      return [
        BoxShadow(
          color: Colors.amber.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ];
    } else if (isSelected) {
      return [
        BoxShadow(
          color: Colors.blue.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ];
    } else if (isHighlighted) {
      return [
        BoxShadow(
          color: Colors.green.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ];
    } else {
      return null;
    }
  }

  // Helper to get color at index - in a real implementation, this would be more robust
  Color? _getColorFromTubeIndex(int index) {
    return tube.getTopColor();
  }
}

/// Custom painter for glass shine effect
class GlassShinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    // Draw a subtle shine gradient
    final rect = Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final gradientPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, gradientPaint);
  }
  
  @override
  bool shouldRepaint(GlassShinePainter oldDelegate) => false;
}

/// Custom painter for liquid shine effect
class LiquidShinePainter extends CustomPainter {
  final Color baseColor;
  
  LiquidShinePainter({required this.baseColor});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw a curved highlight
    final highlightPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.2,
        size.width * 0.9, size.height * 0.1
      )
      ..lineTo(size.width * 0.9, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.5, size.height * 0.4,
        size.width * 0.1, size.height * 0.3
      )
      ..close();
    
    final Color lighterColor = Color.fromRGBO(
      (baseColor.red + 40).clamp(0, 255),
      (baseColor.green + 40).clamp(0, 255),
      (baseColor.blue + 40).clamp(0, 255),
      0.3,
    );
    
    final paint = Paint()
      ..color = lighterColor
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(highlightPath, paint);
  }
  
  @override
  bool shouldRepaint(LiquidShinePainter oldDelegate) => 
    oldDelegate.baseColor != baseColor;
}

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
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$moveCount Moves',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: moveCount <= parMoveCount 
                      ? Colors.green[700]
                      : Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Par: $parMoveCount',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                child: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: starSize,
                ),
              ),
            ),
          );
        }),
      );
    },
  );
}

// lib/features/game/ui/tutorial_overlay.dart

import 'package:flutter/material.dart';
import '../../home/ui/theme_config.dart';
import 'dart:math';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final ThemeConfig themeConfig;
  
  const TutorialOverlay({
    Key? key,
    required this.onComplete,
    required this.themeConfig,
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;
  final int _totalPages = 4;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tutorial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: widget.onComplete,
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildTutorialPage(
                  'Sort Colors',
                  'The goal is to sort colors by moving them between tubes. Each tube can hold up to 4 blocks.',
                  _buildColorSortingAnimation(),
                ),
                _buildTutorialPage(
                  'Moving Colors',
                  'Tap a tube to select it, then tap another tube to move the top color. You can only move colors to empty tubes or on top of matching colors.',
                  _buildMoveAnimation(),
                ),
                _buildTutorialPage(
                  'Complete Tubes',
                  'A tube is complete when it contains 4 blocks of the same color, or it\'s empty. Complete all tubes to win!',
                  _buildCompleteTubeAnimation(),
                ),
                _buildTutorialPage(
                  'Hints & Stars',
                  'Use hints when stuck. Earn stars by completing levels in fewer moves than the par count.',
                  _buildHintAndStarsAnimation(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white70),
                        SizedBox(width: 8),
                        Text(
                          'BACK',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  children: List.generate(_totalPages, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? widget.themeConfig.secondaryColor
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
                if (_currentPage < _totalPages - 1)
                  TextButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Row(
                      children: [
                        Text(
                          'NEXT',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: widget.onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeConfig.buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('START PLAYING'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTutorialPage(String title, String description, Widget animation) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: widget.themeConfig.secondaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: animation,
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorSortingAnimation() {
    final List<Color> colors = widget.themeConfig.tubeColors;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTutorialTube([
              colors[0],
              colors[1],
              colors[2],
              colors[0],
            ], false),
            const SizedBox(width: 20),
            _buildTutorialTube([
              colors[1],
              colors[2],
              colors[0],
              colors[1],
            ], false),
            const SizedBox(width: 20),
            // The animated tube showing colors sorting
            _buildTutorialTube([
              colors[2],
              colors[2],
              colors[2],
              _animationController.value > 0.5 ? colors[2] : colors[1],
            ], _animationController.value > 0.5),
          ],
        );
      },
    );
  }
  
  Widget _buildMoveAnimation() {
    final List<Color> colors = widget.themeConfig.tubeColors;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double moveProgress = _animationController.value;
        bool isMoving = moveProgress > 0.3 && moveProgress < 0.7;
        bool hasCompleted = moveProgress >= 0.7;
        
        // Calculate the position for the moving block
        double left = isMoving 
            ? Curves.easeInOut.transform((moveProgress - 0.3) / 0.4) * 160
            : 0;
        double top = isMoving
            ? -sin((moveProgress - 0.3) / 0.4 * 3.14) * 50
            : 0;
        
        return Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTutorialTube([
                  colors[0],
                  colors[1],
                  colors[2],
                  hasCompleted ? null : colors[0],
                ], moveProgress < 0.3),
                const SizedBox(width: 160),
                _buildTutorialTube(
                  hasCompleted 
                      ? [colors[1], colors[0]] 
                      : [colors[1]],
                  hasCompleted,
                ),
              ],
            ),
            if (isMoving)
              Positioned(
                left: 60 + left,
                top: 200 + top,
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors[0],
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colors[0].withOpacity(0.7), colors[0]],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildCompleteTubeAnimation() {
    final List<Color> colors = widget.themeConfig.tubeColors;
    double pulse = 1.0 + sin(_animationController.value * 2 * 3.14159) * 0.05;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTutorialTube([], true),
        const SizedBox(width: 20),
        Transform.scale(
          scale: pulse,
          child: _buildTutorialTube([
            colors[1],
            colors[1],
            colors[1],
            colors[1],
          ], true),
        ),
        const SizedBox(width: 20),
        Transform.scale(
          scale: pulse,
          child: _buildTutorialTube([
            colors[2],
            colors[2],
            colors[2],
            colors[2],
          ], true),
        ),
      ],
    );
  }
  
  Widget _buildHintAndStarsAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated hint
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final pulse = 1.0 + sin(_animationController.value * 2 * 3.14159) * 0.1;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber,
                  size: 40 * pulse,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Use Hints',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 40),
        // Animated stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return TweenAnimationBuilder(
              tween: Tween<double>(
                begin: 0, 
                end: _animationController.value > (index + 1) / 4 ? 1.0 : 0.2,
              ),
              duration: const Duration(milliseconds: 500),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value * 0.8 + 0.2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.star,
                      color: Colors.amber.withOpacity(value),
                      size: 50,
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 20),
        const Text(
          'Complete levels in fewer moves to earn more stars!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTutorialTube(List<Color?> colors, bool isComplete) {
    while (colors.length < 4) {
      colors.add(null);
    }
    
    return Container(
      width: 60,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: Border.all(
          color: isComplete ? Colors.green : Colors.grey[700]!,
          width: isComplete ? 3 : 2,
        ),
        boxShadow: isComplete
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: colors.where((c) => c == null).length,
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
          ...colors.where((c) => c != null).map((color) => Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color!.withOpacity(0.7), color],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
// lib/features/game/ui/tutorial_overlay.dart

import 'package:flutter/material.dart';
import 'dart:math';
import '../../home/ui/theme_config.dart';

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

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
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
                const Text(
                  'Tutorial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: widget.onComplete,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
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
                        Text('BACK', style: TextStyle(color: Colors.white70)),
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
                        color:
                            index == _currentPage
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
                        Text('NEXT', style: TextStyle(color: Colors.white)),
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

  Widget _buildTutorialPage(
    String title,
    String description,
    Widget animation,
  ) {
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
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(child: animation),
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
        double left =
            isMoving
                ? Curves.easeInOut.transform((moveProgress - 0.3) / 0.4) * 160
                : 0;
        double top =
            isMoving ? -sin((moveProgress - 0.3) / 0.4 * 3.14) * 50 : 0;

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
                  hasCompleted ? [colors[1], colors[0]] : [colors[1]],
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
            final pulse =
                1.0 + sin(_animationController.value * 2 * 3.14159) * 0.1;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lightbulb, color: Colors.amber, size: 40 * pulse),
                const SizedBox(width: 10),
                const Text(
                  'Use Hints',
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
          style: TextStyle(color: Colors.white, fontSize: 16),
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
        boxShadow:
            isComplete
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
          ...colors
              .where((c) => c != null)
              .map(
                (color) => Container(
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
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

// lib/features/game/ui/animated_tube_widget.dart
// (renamed from enhanced_tube_widget.dart for consistent naming)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../data/color_tube.dart';
import '../logic/color_sort_game.dart';
import 'tube_effects.dart';

class AnimatedTubeWidget extends StatelessWidget {
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

  const AnimatedTubeWidget({
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
    Color? topColor = tube.getTopColor();
    if (topColor == null) return _buildTubeContent(false, false);

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

        // Get the source tube from the game provider
        Color? sourceColor = _getColorFromTubeIndex(context, fromTubeIndex);
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

  Widget _buildTubeContent(
    bool isSelected,
    bool isDragging, [
    bool isHighlighted = false,
  ]) {
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
                    color:
                        useGlassEffect
                            ? Colors.white.withOpacity(0.15)
                            : Colors.grey[100]!.withOpacity(0.5),
                  ),
                  // Add subtle glass shine
                  child:
                      useGlassEffect
                          ? CustomPaint(
                            painter: GlassShinePainter(),
                            size: const Size(60, 200),
                          )
                          : null,
                ),
              ),

              // Display colored blocks inside the tube
              ...List.generate(tube.blocks.length, (index) {
                bool isTopBlock = index == tube.blocks.length - 1;
                bool isActiveBlock = isTopBlock && (isSelected || isDragging);
                // Hide the top block if it's being dragged
                if (isActiveBlock && isDragging) {
                  return const SizedBox(height: 40);
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

  Widget _buildColorBlock(
    Color color,
    bool isTopBlock,
    bool isSelected,
    bool isAnimating,
  ) {
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
          colors: [color.withOpacity(useGlassEffect ? 0.7 : 0.8), color],
        ),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ]
                : null,
        border:
            isTopBlock
                ? Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                )
                : null,
      ),
      // Add liquid-like shine effect on blocks
      child:
          useGlassEffect
              ? CustomPaint(
                painter: LiquidShinePainter(baseColor: color),
                size: const Size(60, 40),
              )
              : null,
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
      child:
          useGlassEffect
              ? CustomPaint(
                painter: LiquidShinePainter(baseColor: topColor),
                size: const Size(60, 40),
              )
              : null,
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

  List<BoxShadow>? _getBoxShadow(
    bool isSelected,
    bool isHighlighted,
    bool isHinted,
  ) {
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

  // Get the top color from a tube by its index using provider
  Color? _getColorFromTubeIndex(BuildContext context, int index) {
    final gameProvider = Provider.of<ColorSortGame>(context, listen: false);
    return index >= 0 && index < gameProvider.tubes.length
        ? gameProvider.tubes[index].getTopColor()
        : null;
  }
}

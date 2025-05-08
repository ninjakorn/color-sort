// lib/features/game/ui/draggable_tube_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/color_tube.dart';
import '../logic/color_sort_game.dart';
import 'tube_widget.dart';

class DraggableTubeWidget extends StatelessWidget {
  final ColorTube tube;
  final int tubeIndex;
  final bool isSelected;
  final Function(int) onTap;
  final Function(int, int) onMove;
  final bool isAnimating;

  const DraggableTubeWidget({
    Key? key,
    required this.tube,
    required this.tubeIndex,
    required this.isSelected,
    required this.onTap,
    required this.onMove,
    this.isAnimating = false,
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
    if (topColor == null)
      return TubeWidget(
        tube: tube,
        tubeIndex: tubeIndex,
        isSelected: isSelected,
        onTap: onTap,
      );

    return Draggable<int>(
      data: tubeIndex,
      feedback: Container(
        width: 56,
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
        ),
      ),
      childWhenDragging: TubeWidget(
        tube: tube,
        tubeIndex: tubeIndex,
        isSelected: false,
        onTap: onTap,
        isAnimating: true,
      ),
      child: TubeWidget(
        tube: tube,
        tubeIndex: tubeIndex,
        isSelected: true,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDragTargetTube(BuildContext context) {
    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return TubeWidget(
          tube: tube,
          tubeIndex: tubeIndex,
          isSelected: isSelected,
          isHighlighted: candidateData.isNotEmpty,
          onTap: onTap,
          isAnimating: isAnimating,
        );
      },
      onWillAccept: (fromTubeIndex) {
        if (fromTubeIndex == null || fromTubeIndex == tubeIndex) return false;

        // Get the source tube from the provider
        final fromTube = getTubeAtIndex(context, fromTubeIndex);
        if (fromTube == null) return false;

        // Check if we can move from the source tube to this tube
        return !tube.isFull() &&
            (tube.isEmpty() || tube.getTopColor() == fromTube.getTopColor());
      },
      onAccept: (fromTubeIndex) {
        onMove(fromTubeIndex, tubeIndex);
      },
    );
  }

  // Helper to get tube at index from the provider
  ColorTube? getTubeAtIndex(BuildContext context, int index) {
    final gameProvider = Provider.of<ColorSortGame>(context, listen: false);
    return index >= 0 && index < gameProvider.tubes.length
        ? gameProvider.tubes[index]
        : null;
  }
}

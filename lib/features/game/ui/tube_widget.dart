// lib/features/game/ui/tube_widget.dart

import 'package:flutter/material.dart';
import '../data/color_tube.dart';

class TubeWidget extends StatelessWidget {
  final ColorTube tube;
  final int tubeIndex;
  final bool isSelected;
  final bool isHighlighted;
  final Function(int) onTap;
  final bool isAnimating;

  const TubeWidget({
    Key? key,
    required this.tube,
    required this.tubeIndex,
    required this.isSelected,
    required this.onTap,
    this.isHighlighted = false,
    this.isAnimating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(tubeIndex),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: isSelected || isHighlighted ? 65 : 60,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          border: Border.all(
            color:
                isSelected
                    ? Colors.blue
                    : isHighlighted
                    ? Colors.green
                    : Colors.grey[700]!,
            width: isSelected || isHighlighted ? 3 : 2,
          ),
          boxShadow:
              isSelected || isHighlighted
                  ? [
                    BoxShadow(
                      color:
                          isSelected
                              ? Colors.blue.withOpacity(0.5)
                              : Colors.green.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ]
                  : null,
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
                ),
              ),
            ),

            // Display colored blocks inside the tube
            ...List.generate(tube.blocks.length, (index) {
              return ColorBlock(
                color: tube.blocks[index],
                isTopBlock: index == tube.blocks.length - 1,
                isSelected: isSelected && index == tube.blocks.length - 1,
                isAnimating: isAnimating && index == tube.blocks.length - 1,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class ColorBlock extends StatelessWidget {
  final Color color;
  final bool isTopBlock;
  final bool isSelected;
  final bool isAnimating;

  const ColorBlock({
    Key? key,
    required this.color,
    this.isTopBlock = false,
    this.isSelected = false,
    this.isAnimating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isSelected ? 64 : 60,
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
          colors: [color.withOpacity(0.7), color],
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
    );
  }
}

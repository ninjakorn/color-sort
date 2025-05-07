// lib/features/game/data/color_tube.dart

import 'package:flutter/material.dart';

/// Represents a tube/container that holds colored blocks in the game
class ColorTube {
  /// Standard capacity of each tube
  final int capacity = 4;

  /// List of colors stored in the tube (bottom to top)
  List<Color> blocks = [];

  ColorTube({List<Color>? initialBlocks}) {
    if (initialBlocks != null) {
      blocks = List.from(initialBlocks);
    }
  }

  /// Creates a deep copy of this tube
  ColorTube copy() {
    return ColorTube(initialBlocks: List.from(blocks));
  }

  /// Checks if the tube has no blocks
  bool isEmpty() => blocks.isEmpty;

  /// Checks if the tube is at maximum capacity
  bool isFull() => blocks.length >= capacity;

  /// Checks if the tube is complete (empty or filled with same color)
  bool isComplete() =>
      isEmpty() ||
      (blocks.length == capacity && blocks.every((b) => b == blocks.first));

  /// Gets the color of the top block, or null if empty
  Color? getTopColor() => blocks.isNotEmpty ? blocks.last : null;

  /// Counts how many consecutive blocks of the same color are at the top
  int getTopBlockCount() {
    if (isEmpty()) return 0;

    Color topColor = blocks.last;
    int count = 0;

    for (int i = blocks.length - 1; i >= 0; i--) {
      if (blocks[i] == topColor) {
        count++;
      } else {
        break;
      }
    }

    return count;
  }

  /// Adds a color block to the tube if possible
  bool addBlock(Color color) {
    if (isFull()) return false;

    blocks.add(color);
    return true;
  }

  /// Removes the top block and returns its color (or null if empty)
  Color? removeTopBlock() {
    if (isEmpty()) return null;

    return blocks.removeLast();
  }

  /// Removes multiple blocks of the same color from the top
  List<Color> removeTopBlocks(int count) {
    if (isEmpty() || count <= 0 || count > blocks.length) {
      return [];
    }

    List<Color> removedBlocks = [];
    for (int i = 0; i < count; i++) {
      removedBlocks.add(blocks.removeLast());
    }

    return removedBlocks;
  }
}

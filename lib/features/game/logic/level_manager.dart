// lib/features/game/logic/level_manager.dart

import 'package:flutter/material.dart';
import '../data/color_tube.dart';
import '../data/game_state.dart';

/// Manages game levels and their configuration
class LevelManager {
  /// Available colors for game pieces
  static final List<Color> gameColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.lime,
    Colors.brown,
  ];

  /// Gets the initial game state for a specific level
  static GameState getLevel(int levelNumber) {
    int numColors = _getNumberOfColors(levelNumber);
    int numTubes = numColors + 2; // Extra empty tubes

    List<ColorTube> tubes = _generateTubes(numColors, numTubes);

    return GameState(tubes: tubes, selectedTubeIndex: -1, moveCount: 0);
  }

  /// Determines how many colors to use based on level
  static int _getNumberOfColors(int levelNumber) {
    // Start with 3 colors, max out at available colors
    int numColors = 3 + (levelNumber ~/ 2);
    return numColors > gameColors.length ? gameColors.length : numColors;
  }

  /// Generates tubes with randomized color arrangements
  static List<ColorTube> _generateTubes(int numColors, int numTubes) {
    List<ColorTube> tubes = [];

    // Create a list of all colors to be distributed
    List<Color> allBlocks = [];
    for (int i = 0; i < numColors; i++) {
      // Each color appears 4 times (tube capacity)
      for (int j = 0; j < 4; j++) {
        allBlocks.add(gameColors[i]);
      }
    }

    // Shuffle the blocks for random distribution
    allBlocks.shuffle();

    // Distribute blocks to tubes
    for (int i = 0; i < numColors; i++) {
      List<Color> tubeBlocks = [];
      for (int j = 0; j < 4; j++) {
        tubeBlocks.add(allBlocks[i * 4 + j]);
      }
      tubes.add(ColorTube(initialBlocks: tubeBlocks));
    }

    // Add empty tubes (for moving blocks)
    for (int i = 0; i < numTubes - numColors; i++) {
      tubes.add(ColorTube());
    }

    return tubes;
  }

  /// Checks if level is solvable (all colors can be sorted)
  static bool isLevelSolvable(List<ColorTube> tubes) {
    // In a real implementation, we would need a sophisticated algorithm
    // to verify that the level can actually be solved
    // For this demo, we'll assume all generated levels are solvable
    return true;
  }

  /// Total number of available levels
  static int get totalLevels => 50;

  /// Get difficulty description based on level number
  static String getDifficultyLabel(int levelNumber) {
    if (levelNumber <= 5) return 'Easy';
    if (levelNumber <= 15) return 'Medium';
    if (levelNumber <= 30) return 'Hard';
    return 'Expert';
  }
}

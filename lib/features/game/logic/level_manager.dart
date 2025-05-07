// lib/features/game/logic/level_manager.dart

import 'package:flutter/material.dart';
import '../data/color_tube.dart';
import '../data/game_state.dart';
import 'dart:math';

/// Manages game levels and their configuration with enhanced difficulty progression
/// and solvability verification
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
    int numTubes = _getNumberOfTubes(levelNumber);
    int maxAttempts = 10; // Maximum attempts to generate a solvable level

    List<ColorTube> tubes;
    bool isSolvable = false;

    // Keep generating levels until we find a solvable one
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      tubes = _generateTubes(numColors, numTubes, levelNumber);

      if (isLevelSolvable(tubes)) {
        isSolvable = true;
        break;
      }
    }

    // If we couldn't generate a solvable level, create a simple one
    if (!isSolvable) {
      tubes = _generateSimpleSolvableLevel(numColors, numTubes);
    }

    // Calculate par (optimal) move count for star rating
    int parMoveCount = _calculateParMoveCount(tubes);

    return GameState(
      tubes: tubes,
      selectedTubeIndex: -1,
      moveCount: 0,
      parMoveCount: parMoveCount,
    );
  }

  /// Determines how many colors to use based on level
  static int _getNumberOfColors(int levelNumber) {
    // Start with 3 colors, max out at available colors
    int numColors = 3 + (levelNumber ~/ 3);
    return numColors > gameColors.length ? gameColors.length : numColors;
  }

  /// Determines how many tubes to use based on level
  static int _getNumberOfTubes(int levelNumber) {
    int numColors = _getNumberOfColors(levelNumber);

    // Base number of empty tubes starts at 2 and increases with difficulty
    int emptyTubes = 2;
    if (levelNumber > 15) emptyTubes = 3;
    if (levelNumber > 30) emptyTubes = 4;

    return numColors + emptyTubes;
  }

  /// Generates tubes with randomized color arrangements
  /// with difficulty based on level number
  static List<ColorTube> _generateTubes(
    int numColors,
    int numTubes,
    int levelNumber,
  ) {
    List<ColorTube> tubes = [];

    // Create a list of all colors to be distributed
    List<Color> allBlocks = [];
    for (int i = 0; i < numColors; i++) {
      // Each color appears 4 times (tube capacity)
      for (int j = 0; j < 4; j++) {
        allBlocks.add(gameColors[i]);
      }
    }

    // For higher levels, make it more challenging
    if (levelNumber > 5) {
      // More thorough shuffle for higher levels
      Random rnd = Random();
      for (int i = 0; i < levelNumber; i++) {
        allBlocks.shuffle(rnd);
      }
    } else {
      allBlocks.shuffle();
    }

    // For higher difficulty, sometimes pre-sort some colors to make it trickier
    if (levelNumber > 20 && Random().nextBool()) {
      // Occasionally partially pre-sort to create more complex puzzles
      int presetColorIndex = Random().nextInt(numColors);
      int count = Random().nextInt(3) + 1; // Pre-sort 1-3 blocks of a color

      // Find blocks of the preset color and gather them
      List<Color> presetBlocks = [];
      for (int i = 0; i < allBlocks.length; i++) {
        if (allBlocks[i] == gameColors[presetColorIndex] &&
            presetBlocks.length < count) {
          presetBlocks.add(allBlocks.removeAt(i));
          i--; // Adjust for the removed item
        }
      }

      // Create a tube with these pre-sorted blocks
      ColorTube presetTube = ColorTube();
      for (Color block in presetBlocks) {
        presetTube.addBlock(block);
      }
      tubes.add(presetTube);
    }

    // Distribute remaining blocks to tubes
    int tubesNeeded = numColors - tubes.length;
    for (int i = 0; i < tubesNeeded; i++) {
      List<Color> tubeBlocks = [];

      // Calculate how many blocks this tube should have
      int blocksPerTube = 4;
      if (allBlocks.length < blocksPerTube * (tubesNeeded - i)) {
        blocksPerTube = (allBlocks.length / (tubesNeeded - i)).ceil();
      }

      for (int j = 0; j < blocksPerTube && allBlocks.isNotEmpty; j++) {
        tubeBlocks.add(allBlocks.removeAt(0));
      }

      tubes.add(ColorTube(initialBlocks: tubeBlocks));
    }

    // Add empty tubes (for moving blocks)
    int emptyTubesNeeded = numTubes - tubes.length;
    for (int i = 0; i < emptyTubesNeeded; i++) {
      tubes.add(ColorTube());
    }

    // Shuffle the tube order for more randomness
    tubes.shuffle();

    return tubes;
  }

  /// Generate a simple solvable level as a fallback
  static List<ColorTube> _generateSimpleSolvableLevel(
    int numColors,
    int numTubes,
  ) {
    List<ColorTube> tubes = [];

    // Create tubes with nearly sorted colors
    for (int i = 0; i < numColors; i++) {
      List<Color> tubeBlocks = [];

      // Each tube gets 3 blocks of same color and 1 different
      for (int j = 0; j < 3; j++) {
        tubeBlocks.add(gameColors[i]);
      }

      // Add one different colored block
      int differentColorIndex = (i + 1) % numColors;
      tubeBlocks.add(gameColors[differentColorIndex]);

      tubes.add(ColorTube(initialBlocks: tubeBlocks));
    }

    // Add empty tubes
    for (int i = 0; i < numTubes - numColors; i++) {
      tubes.add(ColorTube());
    }

    // Shuffle the tube order
    tubes.shuffle();

    return tubes;
  }

  /// Checks if level is solvable using a simulation algorithm
  static bool isLevelSolvable(List<ColorTube> tubes) {
    // Create a deep copy of tubes to simulate moves
    List<ColorTube> tubeCopy = List.generate(
      tubes.length,
      (i) => tubes[i].copy(),
    );

    // Check if already solved
    if (_isLevelComplete(tubeCopy)) {
      return true;
    }

    // Set a limit to avoid infinite loops
    int maxMoves = 200;
    int movesMade = 0;

    // Track previous states to avoid cycles
    Set<String> previousStates = {};
    String currentState = _getStateString(tubeCopy);
    previousStates.add(currentState);

    // Simulation loop
    while (movesMade < maxMoves) {
      bool moveMade = false;

      // Try all possible moves
      for (int fromTube = 0; fromTube < tubeCopy.length; fromTube++) {
        if (tubeCopy[fromTube].isEmpty()) continue;

        // If tube is already complete, skip it
        if (_isTubeComplete(tubeCopy[fromTube])) continue;

        for (int toTube = 0; toTube < tubeCopy.length; toTube++) {
          if (fromTube == toTube) continue;

          // Check if move is valid
          if (_canMove(tubeCopy, fromTube, toTube)) {
            // Make the move
            _executeMove(tubeCopy, fromTube, toTube);
            movesMade++;

            // Check if level is complete
            if (_isLevelComplete(tubeCopy)) {
              return true;
            }

            // Check if we've seen this state before
            currentState = _getStateString(tubeCopy);
            if (previousStates.contains(currentState)) {
              // We're in a cycle, try a different move
              // Undo the move and continue
              _executeMove(tubeCopy, toTube, fromTube);
              continue;
            }

            previousStates.add(currentState);
            moveMade = true;
            break;
          }
        }

        if (moveMade) break;
      }

      // If no move was made, this level might be unsolvable
      if (!moveMade) {
        // Try random moves as a last resort
        bool randomMoveMade = _makeRandomMove(tubeCopy);
        if (!randomMoveMade) {
          return false;
        }
      }
    }

    // If we reached move limit, consider it unsolvable
    return false;
  }

  /// Make a random valid move to try to break out of deadlocks
  static bool _makeRandomMove(List<ColorTube> tubes) {
    List<int> fromTubes = [];
    List<int> toTubes = [];

    // Find all possible moves
    for (int fromTube = 0; fromTube < tubes.length; fromTube++) {
      if (tubes[fromTube].isEmpty()) continue;

      for (int toTube = 0; toTube < tubes.length; toTube++) {
        if (fromTube == toTube) continue;

        if (_canMove(tubes, fromTube, toTube)) {
          fromTubes.add(fromTube);
          toTubes.add(toTube);
        }
      }
    }

    if (fromTubes.isEmpty) return false;

    // Choose a random move
    int randomIndex = Random().nextInt(fromTubes.length);
    _executeMove(tubes, fromTubes[randomIndex], toTubes[randomIndex]);

    return true;
  }

  /// Check if a tube is complete (single color or empty)
  static bool _isTubeComplete(ColorTube tube) {
    return tube.isEmpty() ||
        (tube.blocks.length == tube.capacity &&
            tube.blocks.every((b) => b == tube.blocks.first));
  }

  /// Check if the level is complete (all tubes sorted)
  static bool _isLevelComplete(List<ColorTube> tubes) {
    return tubes.every((tube) => _isTubeComplete(tube));
  }

  /// Check if a move is valid
  static bool _canMove(List<ColorTube> tubes, int fromTube, int toTube) {
    if (tubes[fromTube].isEmpty()) return false;
    if (tubes[toTube].isFull()) return false;

    Color fromColor = tubes[fromTube].getTopColor()!;

    return tubes[toTube].isEmpty() || tubes[toTube].getTopColor() == fromColor;
  }

  /// Execute a move from one tube to another
  static void _executeMove(List<ColorTube> tubes, int fromTube, int toTube) {
    if (!_canMove(tubes, fromTube, toTube)) return;

    Color topColor = tubes[fromTube].getTopColor()!;
    int blockCount = tubes[fromTube].getTopBlockCount();

    // Limit transfer to available space in target tube
    int availableSpace = tubes[toTube].capacity - tubes[toTube].blocks.length;
    int transferCount =
        blockCount > availableSpace ? availableSpace : blockCount;

    // Remove blocks from source tube
    List<Color> movedBlocks = tubes[fromTube].removeTopBlocks(transferCount);

    // Add blocks to target tube
    for (int i = movedBlocks.length - 1; i >= 0; i--) {
      tubes[toTube].addBlock(movedBlocks[i]);
    }
  }

  /// Create a string representation of the current state
  static String _getStateString(List<ColorTube> tubes) {
    List<String> tubeStrings = [];

    for (ColorTube tube in tubes) {
      List<String> colorCodes = [];
      for (Color color in tube.blocks) {
        // Use color value as a unique identifier
        colorCodes.add(color.value.toString());
      }
      tubeStrings.add(colorCodes.join(','));
    }

    // Sort the strings to make comparison state-independent
    tubeStrings.sort();
    return tubeStrings.join('|');
  }

  /// Calculate par (optimal) move count for star rating
  static int _calculateParMoveCount(List<ColorTube> tubes) {
    // This is a heuristic calculation, not perfect
    int numColors = 0;
    Set<Color> uniqueColors = {};

    // Count unique colors
    for (ColorTube tube in tubes) {
      for (Color color in tube.blocks) {
        uniqueColors.add(color);
      }
    }

    numColors = uniqueColors.length;

    // Base par move count on color count, tube count, and minimum theoretical moves
    int minTheoretical =
        numColors * 3; // At minimum, need to move 3 blocks per color
    int tubeComplexity =
        tubes.length - numColors - 2; // Extra tubes beyond minimum needed

    // Baseline par
    int par = minTheoretical + (tubeComplexity * 2);

    // Scale for difficulty level
    if (uniqueColors.length <= 3) {
      par = (par * 1.2).round(); // Easier level, more forgiving
    } else if (uniqueColors.length >= 8) {
      par = (par * 0.9).round(); // Hard level, tighter par
    }

    return max(par, numColors * 2); // Ensure minimum reasonable par
  }

  /// Get star rating based on move count compared to par
  static int getStarRating(int moveCount, int parMoveCount) {
    if (moveCount <= parMoveCount) {
      return 3;
    } else if (moveCount <= parMoveCount * 1.5) {
      return 2;
    } else {
      return 1;
    }
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

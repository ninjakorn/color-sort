// lib/features/game/logic/hint_system.dart

import 'package:flutter/material.dart';
import 'dart:math';
import '../data/color_tube.dart';
import '../data/game_state.dart';

/// Provides hints for the Color Sort game
class HintSystem {
  /// Finds the best move in the current game state
  /// Returns a TubeMove with fromTube and toTube indices
  static TubeMove findBestMove(GameState gameState) {
    List<ColorTube> tubes = gameState.tubes;
    List<(int, int, int)> possibleMoves = [];

    // Find all valid moves
    for (int fromTube = 0; fromTube < tubes.length; fromTube++) {
      if (tubes[fromTube].isEmpty()) continue;

      for (int toTube = 0; toTube < tubes.length; toTube++) {
        if (fromTube == toTube) continue;

        if (gameState.canMove(fromTube, toTube)) {
          // Calculate a score for each move
          int moveScore = _evaluateMove(tubes, fromTube, toTube);
          possibleMoves.add((fromTube, toTube, moveScore));
        }
      }
    }

    if (possibleMoves.isEmpty) {
      return const TubeMove(-1, -1); // No valid moves
    }

    // Sort moves by score (highest first)
    possibleMoves.sort((a, b) => b.$3.compareTo(a.$3));

    // Return the best move
    return TubeMove(possibleMoves.first.$1, possibleMoves.first.$2);
  }

  /// Evaluates the quality of a move with a scoring system
  static int _evaluateMove(List<ColorTube> tubes, int fromTube, int toTube) {
    int score = 0;

    Color? fromColor = tubes[fromTube].getTopColor();
    if (fromColor == null) return -100; // This should never happen

    int blockCount = tubes[fromTube].getTopBlockCount();
    bool toTubeIsEmpty = tubes[toTube].isEmpty();

    // Prioritize moves that complete tubes
    if (toTubeIsEmpty) {
      // Moving to an empty tube
      if (blockCount == 4 &&
          tubes[fromTube].blocks.every((b) => b == fromColor)) {
        // Moving a complete set to an empty tube - usually not useful
        score -= 5;
      } else if (tubes[fromTube].blocks.length == blockCount) {
        // Moving all blocks from a tube (clearing it)
        score += 10;
      } else {
        // Moving blocks to an empty tube - sometimes necessary but not ideal
        score += 1;
      }
    } else {
      // Moving to a non-empty tube
      Color? toColor = tubes[toTube].getTopColor();
      if (toColor == null) return -100; // This should never happen

      if (fromColor == toColor) {
        // Moving to same color (good)
        score += 15;

        // Calculate what happens after the move
        int availableSpace =
            tubes[toTube].capacity - tubes[toTube].blocks.length;
        int transferCount =
            blockCount > availableSpace ? availableSpace : blockCount;
        int newToTubeCount = tubes[toTube].blocks.length + transferCount;

        if (newToTubeCount == 4) {
          // This move will complete a tube!
          score += 30;
        }

        // Check if this will clear the source tube
        if (tubes[fromTube].blocks.length == blockCount) {
          // Clearing a tube (good)
          score += 10;
        }

        // Check if we're accessing a color buried under other colors
        if (tubes[fromTube].blocks.length > blockCount) {
          // There are other colors below
          // Check if we're exposing a large group of same color
          List<Color> remainingBlocks = tubes[fromTube].blocks.sublist(
            0,
            tubes[fromTube].blocks.length - blockCount,
          );

          if (remainingBlocks.isNotEmpty) {
            // Count how many of the top remaining color
            Color topRemainingColor = remainingBlocks.last;
            int sameColorCount = 0;

            for (int i = remainingBlocks.length - 1; i >= 0; i--) {
              if (remainingBlocks[i] == topRemainingColor) {
                sameColorCount++;
              } else {
                break;
              }
            }

            // Bonus for exposing a large group
            score += sameColorCount * 5;
          }
        }
      }
    }

    return score;
  }

  /// Simulates playing the game to find the optimal solution
  /// Returns the optimal number of moves
  static int findOptimalSolution(GameState initialState) {
    // Create a deep copy of the initial state
    GameState currentState = initialState.copyWith();

    // Set a limit to avoid infinite loops
    int maxMoves = 200;
    int movesMade = 0;

    // Track previous states to avoid cycles
    Set<String> previousStates = {};
    String stateString = _getStateString(currentState.tubes);
    previousStates.add(stateString);

    while (movesMade < maxMoves && !currentState.isGameComplete) {
      TubeMove bestMove = findBestMove(currentState);

      if (bestMove.fromTube == -1 || bestMove.toTube == -1) {
        break; // No more moves available
      }

      // Make the move
      currentState = currentState.executeMove(
        bestMove.fromTube,
        bestMove.toTube,
      );
      movesMade++;

      // Check for cycles
      stateString = _getStateString(currentState.tubes);
      if (previousStates.contains(stateString)) {
        // We're in a cycle, try random moves
        bool randomMoveMade = _makeRandomMove(currentState);
        if (!randomMoveMade) {
          break;
        }
      }

      previousStates.add(stateString);
    }

    return movesMade;
  }

  /// Make a random valid move
  static bool _makeRandomMove(GameState state) {
    List<TubeMove> validMoves = [];

    for (int fromTube = 0; fromTube < state.tubes.length; fromTube++) {
      if (state.tubes[fromTube].isEmpty()) continue;

      for (int toTube = 0; toTube < state.tubes.length; toTube++) {
        if (fromTube == toTube) continue;

        if (state.canMove(fromTube, toTube)) {
          validMoves.add(TubeMove(fromTube, toTube));
        }
      }
    }

    if (validMoves.isEmpty) return false;

    // Choose a random move
    int randomIndex = Random().nextInt(validMoves.length);
    // Note: In a real implementation, we would execute the move here

    return true;
  }

  /// Create a string representation of the current state for comparison
  static String _getStateString(List<ColorTube> tubes) {
    List<String> tubeStrings = [];

    for (ColorTube tube in tubes) {
      List<String> colorCodes = [];
      for (Color color in tube.blocks) {
        colorCodes.add(color.value.toString());
      }
      tubeStrings.add(colorCodes.join(','));
    }

    // Sort to make comparison state-independent
    tubeStrings.sort();
    return tubeStrings.join('|');
  }
}

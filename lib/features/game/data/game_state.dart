// lib/features/game/data/game_state.dart

import 'package:flutter/material.dart';
import 'color_tube.dart';

/// Represents a move in the game
class Move {
  final int fromTube;
  final int toTube;
  final int blockCount;
  final Color color;

  Move({
    required this.fromTube,
    required this.toTube,
    required this.blockCount,
    required this.color,
  });
}

/// Tuple-like class to store hint move information
class TubeMove {
  final int fromTube;
  final int toTube;

  const TubeMove(this.fromTube, this.toTube);
}

/// Represents the current state of the Color Sort game
class GameState {
  /// All tubes in the current game
  final List<ColorTube> tubes;

  /// Index of the currently selected tube (-1 if none)
  final int selectedTubeIndex;

  /// Number of moves the player has made
  final int moveCount;

  /// History of moves for undo functionality
  final List<Move> moveHistory;

  /// Par (optimal) number of moves for this level
  final int parMoveCount;

  /// Whether a hint is currently active
  final bool hintActive;

  /// The tubes suggested by the hint (from, to)
  final TubeMove hintMove;

  /// Whether the game is complete (all tubes sorted)
  bool get isGameComplete => tubes.every((tube) => tube.isComplete());

  /// Get star rating based on moves compared to par
  int get starRating {
    if (!isGameComplete) return 0;

    if (moveCount <= parMoveCount) {
      return 3;
    } else if (moveCount <= parMoveCount * 1.5) {
      return 2;
    } else {
      return 1;
    }
  }

  GameState({
    required this.tubes,
    this.selectedTubeIndex = -1,
    this.moveCount = 0,
    List<Move>? moveHistory,
    this.parMoveCount = 0,
    this.hintActive = false,
    TubeMove? hintMove,
  }) : this.moveHistory = moveHistory ?? [],
       this.hintMove = hintMove ?? const TubeMove(-1, -1);

  /// Creates a copy of the current game state with optional changes
  GameState copyWith({
    List<ColorTube>? tubes,
    int? selectedTubeIndex,
    int? moveCount,
    List<Move>? moveHistory,
    int? parMoveCount,
    bool? hintActive,
    TubeMove? hintMove,
  }) {
    return GameState(
      tubes:
          tubes ??
          List.generate(this.tubes.length, (i) => this.tubes[i].copy()),
      selectedTubeIndex: selectedTubeIndex ?? this.selectedTubeIndex,
      moveCount: moveCount ?? this.moveCount,
      moveHistory: moveHistory ?? List.from(this.moveHistory),
      parMoveCount: parMoveCount ?? this.parMoveCount,
      hintActive: hintActive ?? this.hintActive,
      hintMove: hintMove ?? this.hintMove,
    );
  }

  /// Activates a hint
  GameState activateHint(TubeMove suggestedMove) {
    return copyWith(hintActive: true, hintMove: suggestedMove);
  }

  /// Clears the active hint
  GameState clearHint() {
    return copyWith(hintActive: false, hintMove: const TubeMove(-1, -1));
  }

  /// Checks if a move from one tube to another is valid
  bool canMove(int fromTube, int toTube) {
    if (fromTube == toTube) return false;
    if (tubes[fromTube].isEmpty()) return false;
    if (tubes[toTube].isFull()) return false;

    Color? fromColor = tubes[fromTube].getTopColor();
    if (fromColor == null) return false;

    Color? toColor = tubes[toTube].getTopColor();
    return tubes[toTube].isEmpty() || toColor == fromColor;
  }

  /// Execute a move from one tube to another
  GameState executeMove(int fromTube, int toTube) {
    if (!canMove(fromTube, toTube)) {
      return this;
    }

    // Create copies to avoid modifying the current state
    List<ColorTube> newTubes = List.generate(
      tubes.length,
      (i) => tubes[i].copy(),
    );

    Color? topColor = newTubes[fromTube].getTopColor();
    if (topColor == null) return this;

    int blockCount = newTubes[fromTube].getTopBlockCount();

    // Limit transfer to available space in target tube
    int availableSpace =
        newTubes[toTube].capacity - newTubes[toTube].blocks.length;
    int transferCount =
        blockCount > availableSpace ? availableSpace : blockCount;

    // Remove blocks from source tube
    List<Color> movedBlocks = newTubes[fromTube].removeTopBlocks(transferCount);

    // Add blocks to target tube
    for (int i = movedBlocks.length - 1; i >= 0; i--) {
      newTubes[toTube].addBlock(movedBlocks[i]);
    }

    // Create a record of this move
    Move move = Move(
      fromTube: fromTube,
      toTube: toTube,
      blockCount: transferCount,
      color: topColor,
    );

    List<Move> newMoveHistory = List.from(moveHistory);
    newMoveHistory.add(move);

    return copyWith(
      tubes: newTubes,
      selectedTubeIndex: -1, // Deselect after move
      moveCount: moveCount + 1,
      moveHistory: newMoveHistory,
      hintActive: false, // Clear any active hint
      hintMove: const TubeMove(-1, -1),
    );
  }

  /// Undo the last move
  GameState undoLastMove() {
    if (moveHistory.isEmpty) {
      return this;
    }

    // Get the last move from history
    Move lastMove = moveHistory.last;

    // Create copies to avoid modifying the current state
    List<ColorTube> newTubes = List.generate(
      tubes.length,
      (i) => tubes[i].copy(),
    );

    // Move blocks back from toTube to fromTube
    for (int i = 0; i < lastMove.blockCount; i++) {
      Color? blockColor = newTubes[lastMove.toTube].removeTopBlock();
      if (blockColor != null) {
        newTubes[lastMove.fromTube].addBlock(blockColor);
      }
    }

    List<Move> newMoveHistory = List.from(moveHistory);
    newMoveHistory.removeLast();

    return copyWith(
      tubes: newTubes,
      selectedTubeIndex: -1,
      moveCount: moveCount - 1,
      moveHistory: newMoveHistory,
      hintActive: false, // Clear any active hint
      hintMove: const TubeMove(-1, -1),
    );
  }
}

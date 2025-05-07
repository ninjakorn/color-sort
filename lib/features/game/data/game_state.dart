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

  /// Whether the game is complete (all tubes sorted)
  bool get isGameComplete => tubes.every((tube) => tube.isComplete());

  GameState({
    required this.tubes,
    this.selectedTubeIndex = -1,
    this.moveCount = 0,
    List<Move>? moveHistory,
  }) : this.moveHistory = moveHistory ?? [];

  /// Creates a copy of the current game state with optional changes
  GameState copyWith({
    List<ColorTube>? tubes,
    int? selectedTubeIndex,
    int? moveCount,
    List<Move>? moveHistory,
  }) {
    return GameState(
      tubes:
          tubes ??
          List.generate(this.tubes.length, (i) => this.tubes[i].copy()),
      selectedTubeIndex: selectedTubeIndex ?? this.selectedTubeIndex,
      moveCount: moveCount ?? this.moveCount,
      moveHistory: moveHistory ?? List.from(this.moveHistory),
    );
  }

  /// Checks if a move from one tube to another is valid
  bool canMove(int fromTube, int toTube) {
    if (fromTube == toTube) return false;
    if (tubes[fromTube].isEmpty()) return false;
    if (tubes[toTube].isFull()) return false;

    Color fromColor = tubes[fromTube].getTopColor()!;

    return tubes[toTube].isEmpty() || tubes[toTube].getTopColor() == fromColor;
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

    Color topColor = newTubes[fromTube].getTopColor()!;
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
    );
  }
}

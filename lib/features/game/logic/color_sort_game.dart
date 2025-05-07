// lib/features/game/logic/color_sort_game.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/color_tube.dart';
import '../data/game_state.dart';
import 'level_manager.dart';

class ColorSortGame extends ChangeNotifier {
  // Current game state
  GameState _gameState = GameState(tubes: []);

  // Current level number
  int _currentLevel = 1;

  // Highest unlocked level
  int _highestUnlockedLevel = 1;

  // Is there a move animation playing?
  bool _isAnimating = false;

  // Getters
  GameState get gameState => _gameState;
  int get currentLevel => _currentLevel;
  int get highestUnlockedLevel => _highestUnlockedLevel;
  bool get isAnimating => _isAnimating;
  List<ColorTube> get tubes => _gameState.tubes;
  int get moveCount => _gameState.moveCount;
  int get selectedTubeIndex => _gameState.selectedTubeIndex;
  bool get isGameComplete => _gameState.isGameComplete;

  // Initialize with stored progress
  Future<void> initialize() async {
    await _loadProgress();
    loadLevel(_currentLevel);
  }

  // Load saved progress
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLevel = prefs.getInt('currentLevel') ?? 1;
    _highestUnlockedLevel = prefs.getInt('highestUnlockedLevel') ?? 1;
  }

  // Save progress
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevel', _currentLevel);
    await prefs.setInt('highestUnlockedLevel', _highestUnlockedLevel);
  }

  // Load a specific level
  void loadLevel(int level) {
    if (level < 1 || level > LevelManager.totalLevels) {
      return;
    }

    _currentLevel = level;
    _gameState = LevelManager.getLevel(level);
    _isAnimating = false;
    notifyListeners();

    _saveProgress();
  }

  // Handle tube selection
  void selectTube(int index) {
    if (_isAnimating || _gameState.isGameComplete) {
      return;
    }

    if (_gameState.selectedTubeIndex == -1) {
      // No tube selected yet
      if (!_gameState.tubes[index].isEmpty()) {
        _gameState = _gameState.copyWith(selectedTubeIndex: index);
        notifyListeners();
      }
    } else if (_gameState.selectedTubeIndex == index) {
      // Deselect the current tube
      _gameState = _gameState.copyWith(selectedTubeIndex: -1);
      notifyListeners();
    } else {
      // Attempt to move from selected tube to this tube
      if (_gameState.canMove(_gameState.selectedTubeIndex, index)) {
        moveColor(_gameState.selectedTubeIndex, index);
      } else {
        // Change selection if can't move
        if (!_gameState.tubes[index].isEmpty()) {
          _gameState = _gameState.copyWith(selectedTubeIndex: index);
        } else {
          _gameState = _gameState.copyWith(selectedTubeIndex: -1);
        }
        notifyListeners();
      }
    }
  }

  // Move color from one tube to another
  void moveColor(int fromTube, int toTube) {
    if (_isAnimating || _gameState.isGameComplete) {
      return;
    }

    if (_gameState.canMove(fromTube, toTube)) {
      _isAnimating = true;
      notifyListeners();

      // Perform the move
      _gameState = _gameState.executeMove(fromTube, toTube);

      // Check if game is completed after the move
      if (_gameState.isGameComplete) {
        _onLevelComplete();
      }

      // Short delay to show animation
      Future.delayed(Duration(milliseconds: 300), () {
        _isAnimating = false;
        notifyListeners();
      });
    }
  }

  // Handle level completion
  void _onLevelComplete() {
    if (_currentLevel >= _highestUnlockedLevel) {
      _highestUnlockedLevel = _currentLevel + 1;
      _saveProgress();
    }
  }

  // Proceed to next level
  void nextLevel() {
    if (_currentLevel < LevelManager.totalLevels) {
      loadLevel(_currentLevel + 1);
    }
  }

  // Undo the last move
  void undoMove() {
    if (_isAnimating || _gameState.moveHistory.isEmpty) {
      return;
    }

    _isAnimating = true;
    notifyListeners();

    _gameState = _gameState.undoLastMove();

    // Short delay to show animation
    Future.delayed(Duration(milliseconds: 300), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  // Reset the current level
  void resetLevel() {
    loadLevel(_currentLevel);
  }
}

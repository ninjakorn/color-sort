// lib/features/game/logic/color_sort_game.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/color_tube.dart';
import '../data/game_state.dart';
import 'level_manager.dart';
import 'hint_system.dart';

class ColorSortGame extends ChangeNotifier {
  // Current game state
  GameState _gameState = GameState(tubes: []);

  // Current level number
  int _currentLevel = 1;

  // Highest unlocked level
  int _highestUnlockedLevel = 1;

  // Is there a move animation playing?
  bool _isAnimating = false;

  // Maximum number of hints per level
  final int _maxHintsPerLevel = 3;

  // Number of hints used in current level
  int _hintsUsed = 0;

  // Tutorial completed status
  bool _tutorialCompleted = false;

  // Selected theme
  int _selectedTheme = 0;

  // Available themes
  final List<String> _themeNames = ['Classic', 'Ocean', 'Neon', 'Pastel'];

  // Level statistics tracking
  Map<int, LevelStats> _levelStats = {};

  // Getters
  GameState get gameState => _gameState;
  int get currentLevel => _currentLevel;
  int get highestUnlockedLevel => _highestUnlockedLevel;
  bool get isAnimating => _isAnimating;
  List<ColorTube> get tubes => _gameState.tubes;
  int get moveCount => _gameState.moveCount;
  int get selectedTubeIndex => _gameState.selectedTubeIndex;
  bool get isGameComplete => _gameState.isGameComplete;
  int get parMoveCount => _gameState.parMoveCount;
  int get hintsRemaining => _maxHintsPerLevel - _hintsUsed;
  bool get tutorialCompleted => _tutorialCompleted;
  int get selectedTheme => _selectedTheme;
  List<String> get themeNames => _themeNames;
  bool get canUseHint => _hintsUsed < _maxHintsPerLevel;
  bool get hintActive => _gameState.hintActive;
  TubeMove get hintMove => _gameState.hintMove;

  // Get star rating for current level
  int get starRating => _gameState.starRating;

  // Get star rating for a specific level
  int getStarRatingForLevel(int level) {
    if (_levelStats.containsKey(level)) {
      return _levelStats[level]!.starRating;
    }
    return 0;
  }

  // Get best move count for a specific level
  int getBestMoveCountForLevel(int level) {
    if (_levelStats.containsKey(level)) {
      return _levelStats[level]!.bestMoveCount;
    }
    return 0;
  }

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
    _tutorialCompleted = prefs.getBool('tutorialCompleted') ?? false;
    _selectedTheme = prefs.getInt('selectedTheme') ?? 0;

    // Load level statistics
    for (int i = 1; i <= LevelManager.totalLevels; i++) {
      int bestMoves = prefs.getInt('bestMoves_$i') ?? 0;
      int starRating = prefs.getInt('starRating_$i') ?? 0;

      if (bestMoves > 0) {
        _levelStats[i] = LevelStats(
          bestMoveCount: bestMoves,
          starRating: starRating,
        );
      }
    }
  }

  // Save progress
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentLevel', _currentLevel);
    await prefs.setInt('highestUnlockedLevel', _highestUnlockedLevel);
    await prefs.setBool('tutorialCompleted', _tutorialCompleted);
    await prefs.setInt('selectedTheme', _selectedTheme);

    // Save level statistics
    _levelStats.forEach((level, stats) {
      prefs.setInt('bestMoves_$level', stats.bestMoveCount);
      prefs.setInt('starRating_$level', stats.starRating);
    });
  }

  // Load a specific level
  void loadLevel(int level) {
    if (level < 1 || level > LevelManager.totalLevels) {
      return;
    }

    _currentLevel = level;
    _gameState = LevelManager.getLevel(level);
    _isAnimating = false;
    _hintsUsed = 0;
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
        _gameState = _gameState.copyWith(
          selectedTubeIndex: index,
          hintActive: false,
          hintMove: const TubeMove(-1, -1),
        );
        notifyListeners();
      }
    } else if (_gameState.selectedTubeIndex == index) {
      // Deselect the current tube
      _gameState = _gameState.copyWith(
        selectedTubeIndex: -1,
        hintActive: false,
        hintMove: const TubeMove(-1, -1),
      );
      notifyListeners();
    } else {
      // Attempt to move from selected tube to this tube
      if (_gameState.canMove(_gameState.selectedTubeIndex, index)) {
        moveColor(_gameState.selectedTubeIndex, index);
      } else {
        // Change selection if can't move
        if (!_gameState.tubes[index].isEmpty()) {
          _gameState = _gameState.copyWith(
            selectedTubeIndex: index,
            hintActive: false,
            hintMove: const TubeMove(-1, -1),
          );
        } else {
          _gameState = _gameState.copyWith(
            selectedTubeIndex: -1,
            hintActive: false,
            hintMove: const TubeMove(-1, -1),
          );
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
      Future.delayed(const Duration(milliseconds: 300), () {
        _isAnimating = false;
        notifyListeners();
      });
    }
  }

  // Show a hint
  void showHint() {
    if (_isAnimating ||
        _gameState.isGameComplete ||
        _hintsUsed >= _maxHintsPerLevel) {
      return;
    }

    // Find the best move
    TubeMove bestMove = HintSystem.findBestMove(_gameState);

    if (bestMove.fromTube != -1 && bestMove.toTube != -1) {
      _gameState = _gameState.activateHint(bestMove);
      _hintsUsed++;
      notifyListeners();
    }
  }

  // Handle level completion
  void _onLevelComplete() {
    // Update level statistics
    int currentStars = _gameState.starRating;
    int currentMoves = _gameState.moveCount;

    if (!_levelStats.containsKey(_currentLevel) ||
        currentMoves < _levelStats[_currentLevel]!.bestMoveCount) {
      _levelStats[_currentLevel] = LevelStats(
        bestMoveCount: currentMoves,
        starRating: currentStars,
      );
    } else if (currentStars > _levelStats[_currentLevel]!.starRating) {
      _levelStats[_currentLevel] = LevelStats(
        bestMoveCount: _levelStats[_currentLevel]!.bestMoveCount,
        starRating: currentStars,
      );
    }

    // Unlock next level if this is highest completed
    if (_currentLevel >= _highestUnlockedLevel &&
        _currentLevel < LevelManager.totalLevels) {
      _highestUnlockedLevel = _currentLevel + 1;
    }

    _saveProgress();
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
    Future.delayed(const Duration(milliseconds: 300), () {
      _isAnimating = false;
      notifyListeners();
    });
  }

  // Reset the current level
  void resetLevel() {
    loadLevel(_currentLevel);
  }

  // Set tutorial completed
  void setTutorialCompleted() {
    _tutorialCompleted = true;
    _saveProgress();
    notifyListeners();
  }

  // Change theme
  void setTheme(int themeIndex) {
    if (themeIndex >= 0 && themeIndex < _themeNames.length) {
      _selectedTheme = themeIndex;
      _saveProgress();
      notifyListeners();
    }
  }
}

/// Stores statistics for a completed level
class LevelStats {
  final int bestMoveCount;
  final int starRating;

  LevelStats({required this.bestMoveCount, required this.starRating});
}
